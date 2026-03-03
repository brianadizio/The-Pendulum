#!/usr/bin/env python3
"""
Download all user data from Firebase Storage to local and Synology.

Downloads:
    - Chat fine-tuning data (conversations with AI)
    - Gameplay session data (CSV files and metadata)
    - User profiles

Storage policy:
    - Under LOCAL_STORAGE_LIMIT: save to Mac Studio + sync to Synology
    - Over LOCAL_STORAGE_LIMIT: save to Synology only (requires NAS mount)
    - Hard cap at TOTAL_STORAGE_LIMIT (10 TB) across all destinations

Usage:
    python download_firebase_data.py

Requires:
    pip install google-cloud-storage firebase-admin

Setup:
    1. Download service account key from Firebase Console → Project Settings → Service Accounts
    2. Save as ~/.config/firebase/pendulum-service-account.json
    3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable (or script does it)
"""

import os
import json
import shutil
import subprocess
import time
from pathlib import Path
from datetime import datetime

# Set credentials path before importing google libraries
SERVICE_ACCOUNT_PATH = os.path.expanduser("~/.config/firebase/pendulum-service-account.json")
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = SERVICE_ACCOUNT_PATH

from google.cloud import storage

# Configuration
FIREBASE_BUCKET = "the-pendulum-2p0.firebasestorage.app"

# Storage limits
LOCAL_STORAGE_LIMIT = 100 * 1024**3    # 100 GB — switch to Synology-only above this
TOTAL_STORAGE_LIMIT = 10 * 1024**4     # 10 TB — hard cap, stop downloading

# Output directories
PROJECT_DIR = Path(__file__).parent.parent
LOCAL_CHAT_DIR = PROJECT_DIR / "assets" / "processed" / "chat_finetuning"
LOCAL_GAMEPLAY_DIR = PROJECT_DIR / "assets" / "processed" / "gameplay_data"
SYNOLOGY_BASE_DIR = Path("/Volumes/home/Solutions/The Pendulum Data")


# ---------------------------------------------------------------------------
# Storage policy
# ---------------------------------------------------------------------------

def get_dir_size(path: Path) -> int:
    """Get total size of a directory in bytes. Returns 0 if not found."""
    if not path.exists():
        return 0
    total = 0
    try:
        for item in path.rglob("*"):
            if item.is_file():
                try:
                    total += item.stat().st_size
                except OSError:
                    pass
    except OSError:
        pass
    return total


def bytes_human(n: int) -> str:
    """Format bytes as a human-readable string."""
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if abs(n) < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} PB"


class StoragePolicy:
    """Decide where to store data based on current usage."""

    def __init__(self):
        self.local_size = get_dir_size(LOCAL_CHAT_DIR) + get_dir_size(LOCAL_GAMEPLAY_DIR)
        self.synology_mounted = SYNOLOGY_BASE_DIR.exists()
        self.synology_size = (
            get_dir_size(SYNOLOGY_BASE_DIR / "chat_finetuning")
            + get_dir_size(SYNOLOGY_BASE_DIR / "gameplay_data")
        ) if self.synology_mounted else 0

        # Total unique data: if both destinations exist, the larger one is
        # the best estimate (they mirror each other).
        self.total_size = max(self.local_size, self.synology_size)

        # Determine mode
        if self.total_size >= TOTAL_STORAGE_LIMIT:
            self.mode = "capped"
        elif self.local_size >= LOCAL_STORAGE_LIMIT:
            self.mode = "synology_only"
        else:
            self.mode = "local_and_synology"

    def print_status(self):
        print(f"\nStorage status:")
        print(f"  Local data:    {bytes_human(self.local_size)}")
        if self.synology_mounted:
            print(f"  Synology data: {bytes_human(self.synology_size)}")
        else:
            print(f"  Synology:      not mounted")
        print(f"  Total data:    {bytes_human(self.total_size)} / {bytes_human(TOTAL_STORAGE_LIMIT)}")
        print(f"  Mode:          {self.mode}")

        if self.mode == "capped":
            print("  *** 10 TB cap reached — no new data will be downloaded ***")
        elif self.mode == "synology_only":
            print(f"  Local storage exceeds {bytes_human(LOCAL_STORAGE_LIMIT)} — downloading to Synology only")
        print()

    @property
    def can_download(self) -> bool:
        if self.mode == "capped":
            return False
        if self.mode == "synology_only" and not self.synology_mounted:
            return False
        return True

    def chat_dir(self) -> Path:
        if self.mode == "synology_only":
            return SYNOLOGY_BASE_DIR / "chat_finetuning"
        return LOCAL_CHAT_DIR

    def gameplay_dir(self) -> Path:
        if self.mode == "synology_only":
            return SYNOLOGY_BASE_DIR / "gameplay_data"
        return LOCAL_GAMEPLAY_DIR

    def remaining_bytes(self) -> int:
        return max(0, TOTAL_STORAGE_LIMIT - self.total_size)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def notify(title: str, message: str):
    """Send macOS notification."""
    try:
        subprocess.run([
            "osascript", "-e",
            f'display notification "{message}" with title "{title}"'
        ], timeout=5, capture_output=True)
    except Exception:
        pass  # Notification is best-effort


def list_blobs_with_retry(bucket, prefix: str, max_retries: int = 4):
    """List blobs with exponential backoff for transient network errors."""
    for attempt in range(max_retries):
        try:
            return list(bucket.list_blobs(prefix=prefix))
        except Exception as e:
            err_str = str(e).lower()
            is_transient = any(k in err_str for k in [
                "name resolution", "dns", "timeout", "connection",
                "temporary failure", "network is unreachable",
                "could not resolve", "errno 8", "errno -2",
            ])
            if is_transient and attempt < max_retries - 1:
                wait = 2 ** attempt * 15  # 15s, 30s, 60s, 120s
                print(f"[WARN] Transient network error (attempt {attempt + 1}/{max_retries}), "
                      f"retrying in {wait}s: {e}")
                time.sleep(wait)
            else:
                raise


# ---------------------------------------------------------------------------
# Download logic
# ---------------------------------------------------------------------------

def download_all_data():
    """Download all user data from Firebase Storage."""

    print(f"[{datetime.now()}] Starting Firebase data download...")
    print("=" * 60)

    # Evaluate storage policy
    policy = StoragePolicy()
    policy.print_status()

    if not policy.can_download:
        if policy.mode == "capped":
            msg = "10 TB storage cap reached — skipping download"
            print(msg)
            notify("Pendulum Sync", msg)
        else:
            msg = "Synology-only mode but NAS not mounted — skipping download"
            print(msg)
            notify("Pendulum Sync", msg)
        return

    # Initialize client
    try:
        client = storage.Client()
        bucket = client.bucket(FIREBASE_BUCKET)
    except Exception as e:
        print(f"Error connecting to Firebase Storage: {e}")
        print("Make sure service account key exists at:", SERVICE_ACCOUNT_PATH)
        return

    # Resolve output directories for this run
    chat_dir = policy.chat_dir()
    gameplay_dir = policy.gameplay_dir()
    profiles_dir = gameplay_dir / "profiles"

    chat_dir.mkdir(parents=True, exist_ok=True)
    gameplay_dir.mkdir(parents=True, exist_ok=True)
    profiles_dir.mkdir(parents=True, exist_ok=True)

    remaining = policy.remaining_bytes()

    # Download all files
    print("1. Downloading Chat Fine-Tuning Data...")
    chat_stats, remaining = download_by_category(
        bucket, "chat_finetuning", chat_dir, [".json"], remaining
    )

    print("\n2. Downloading Gameplay Session Data...")
    gameplay_stats, remaining = download_by_category(
        bucket, "sessions", gameplay_dir, [".csv", ".json"], remaining
    )

    print("\n3. Downloading User Profiles...")
    profile_stats, remaining = download_by_category(
        bucket, "profile", profiles_dir, [".json"], remaining
    )

    # Print summary
    total_downloaded = chat_stats["downloaded"] + gameplay_stats["downloaded"] + profile_stats["downloaded"]
    total_bytes = chat_stats["bytes"] + gameplay_stats["bytes"] + profile_stats["bytes"]

    print("\n" + "=" * 60)
    print("Download Summary:")
    print(f"  Chat data:    {chat_stats['downloaded']} downloaded, {chat_stats['skipped']} skipped")
    print(f"  Gameplay data: {gameplay_stats['downloaded']} downloaded, {gameplay_stats['skipped']} skipped")
    print(f"  Profiles:     {profile_stats['downloaded']} downloaded, {profile_stats['skipped']} skipped")
    print(f"  Total new data: {bytes_human(total_bytes)}")
    print(f"  Storage remaining: {bytes_human(remaining)}")
    if chat_stats["cap_skipped"] + gameplay_stats["cap_skipped"] + profile_stats["cap_skipped"] > 0:
        cap_skipped = chat_stats["cap_skipped"] + gameplay_stats["cap_skipped"] + profile_stats["cap_skipped"]
        print(f"  *** {cap_skipped} files skipped due to 10 TB storage cap ***")
    print(f"  Destination:  {'Synology only' if policy.mode == 'synology_only' else 'Local + Synology'}")

    # Sync to Synology (only needed in local_and_synology mode)
    if policy.mode == "local_and_synology":
        sync_to_synology()

    # Generate summary reports (always write to local if accessible, and to the active dir)
    generate_chat_summary_report(chat_dir)
    generate_gameplay_summary_report(gameplay_dir)

    # If we wrote to Synology directly, also save summary reports locally for log inspection
    if policy.mode == "synology_only":
        LOCAL_CHAT_DIR.mkdir(parents=True, exist_ok=True)
        LOCAL_GAMEPLAY_DIR.mkdir(parents=True, exist_ok=True)
        src_chat_summary = chat_dir / "summary_report.json"
        src_gameplay_summary = gameplay_dir / "summary_report.json"
        if src_chat_summary.exists():
            shutil.copy(src_chat_summary, LOCAL_CHAT_DIR / "summary_report.json")
        if src_gameplay_summary.exists():
            shutil.copy(src_gameplay_summary, LOCAL_GAMEPLAY_DIR / "summary_report.json")


def download_by_category(bucket, folder_name, output_dir, extensions, remaining_bytes):
    """Download files from a specific category/folder, respecting storage cap."""

    stats = {"downloaded": 0, "skipped": 0, "bytes": 0, "cap_skipped": 0}

    # List all files under users/
    prefix = "users/"
    blobs = list_blobs_with_retry(bucket, prefix=prefix)

    for blob in blobs:
        # Check if this blob matches our folder and extensions
        if folder_name not in blob.name:
            continue

        has_valid_ext = any(blob.name.endswith(ext) for ext in extensions)
        if not has_valid_ext:
            continue

        # Extract user ID and filename
        parts = blob.name.split("/")
        if len(parts) < 3:
            continue

        user_id = parts[1]
        filename = parts[-1]

        # Create user subdirectory
        user_dir = output_dir / user_id
        user_dir.mkdir(parents=True, exist_ok=True)

        local_path = user_dir / filename

        # Skip if already downloaded (check by size)
        if local_path.exists():
            local_size = local_path.stat().st_size
            if local_size == blob.size:
                stats["skipped"] += 1
                continue

        # Check storage cap before downloading
        if blob.size and blob.size > remaining_bytes:
            stats["cap_skipped"] += 1
            continue

        # Download
        print(f"    {blob.name}")
        blob.download_to_filename(str(local_path))
        stats["downloaded"] += 1
        dl_size = blob.size or 0
        stats["bytes"] += dl_size
        remaining_bytes -= dl_size

    return stats, remaining_bytes


def download_finetuning_data():
    """Alias for backward compatibility."""
    download_all_data()


def sync_to_synology():
    """Copy downloaded files to Synology NAS if mounted."""

    if not SYNOLOGY_BASE_DIR.exists():
        print(f"\nSynology not mounted at {SYNOLOGY_BASE_DIR}, skipping sync")
        return

    print(f"\n4. Syncing to Synology: {SYNOLOGY_BASE_DIR}")

    try:
        # Sync chat data
        sync_directory(LOCAL_CHAT_DIR, SYNOLOGY_BASE_DIR / "chat_finetuning")

        # Sync gameplay data
        sync_directory(LOCAL_GAMEPLAY_DIR, SYNOLOGY_BASE_DIR / "gameplay_data")

        print("Synology sync complete")

    except Exception as e:
        print(f"Error syncing to Synology: {e}")


def sync_directory(source_dir, dest_dir):
    """Sync a directory to destination, copying only new/modified files."""

    if not source_dir.exists():
        return

    dest_dir.mkdir(parents=True, exist_ok=True)

    for item in source_dir.rglob("*"):
        if item.is_dir():
            continue

        # Get relative path and create destination
        rel_path = item.relative_to(source_dir)
        dest_file = dest_dir / rel_path
        dest_file.parent.mkdir(parents=True, exist_ok=True)

        try:
            # Only copy if newer or doesn't exist
            should_copy = not dest_file.exists()
            if not should_copy:
                try:
                    should_copy = item.stat().st_mtime > dest_file.stat().st_mtime
                except OSError:
                    should_copy = True

            if should_copy:
                # Use shutil.copy instead of copy2 for better NAS compatibility
                shutil.copy(item, dest_file)
                print(f"    Synced: {rel_path}")
        except Exception as e:
            print(f"    Warning: Could not sync {rel_path}: {e}")


def generate_chat_summary_report(chat_dir: Path):
    """Generate a summary of all chat/fine-tuning data."""

    print("\n5. Generating Chat Summary Report...")

    summary = {
        "generated_at": datetime.now().isoformat(),
        "data_type": "chat_finetuning",
        "users": {},
        "total_conversations": 0,
        "total_messages": 0,
        "total_tokens": 0,
        "fallback_count": 0,
        "model_usage": {}
    }

    for user_dir in chat_dir.iterdir():
        if not user_dir.is_dir():
            continue

        user_id = user_dir.name
        user_stats = {
            "conversations": 0,
            "messages": 0,
            "tokens": 0
        }

        for json_file in user_dir.glob("*.json"):
            try:
                with open(json_file, "r") as f:
                    data = json.load(f)

                user_stats["conversations"] += 1
                summary["total_conversations"] += 1

                for msg in data.get("messages", []):
                    user_stats["messages"] += 1
                    summary["total_messages"] += 1

                    if msg.get("isFallback"):
                        summary["fallback_count"] += 1

                    if msg.get("tokenUsage"):
                        tokens = msg["tokenUsage"].get("totalTokens", 0)
                        user_stats["tokens"] += tokens
                        summary["total_tokens"] += tokens

                    model = msg.get("modelName")
                    if model:
                        summary["model_usage"][model] = summary["model_usage"].get(model, 0) + 1

            except Exception as e:
                print(f"Error processing {json_file}: {e}")

        summary["users"][user_id] = user_stats

    # Save summary
    summary_path = chat_dir / "summary_report.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"  Chat Summary:")
    print(f"    Users: {len(summary['users'])}")
    print(f"    Conversations: {summary['total_conversations']}")
    print(f"    Messages: {summary['total_messages']}")
    print(f"    Total Tokens: {summary['total_tokens']}")
    print(f"    Fallback Responses: {summary['fallback_count']}")


def generate_gameplay_summary_report(gameplay_dir: Path):
    """Generate a summary of all gameplay session data."""

    print("\n6. Generating Gameplay Summary Report...")

    summary = {
        "generated_at": datetime.now().isoformat(),
        "data_type": "gameplay_sessions",
        "users": {},
        "total_sessions": 0,
        "total_csv_files": 0,
        "total_metadata_files": 0
    }

    for user_dir in gameplay_dir.iterdir():
        if not user_dir.is_dir() or user_dir.name == "profiles":
            continue

        user_id = user_dir.name
        csv_files = list(user_dir.glob("*.csv"))
        json_files = list(user_dir.glob("*.json"))

        user_stats = {
            "csv_files": len(csv_files),
            "metadata_files": len(json_files),
            "sessions": len(csv_files)
        }

        summary["users"][user_id] = user_stats
        summary["total_sessions"] += len(csv_files)
        summary["total_csv_files"] += len(csv_files)
        summary["total_metadata_files"] += len(json_files)

    # Save summary
    summary_path = gameplay_dir / "summary_report.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"  Gameplay Summary:")
    print(f"    Users: {len(summary['users'])}")
    print(f"    Total Sessions: {summary['total_sessions']}")
    print(f"    CSV Files: {summary['total_csv_files']}")
    print(f"    Metadata Files: {summary['total_metadata_files']}")


if __name__ == "__main__":
    try:
        download_all_data()
        notify("Pendulum Sync", "Firebase data download complete")
    except Exception as e:
        print(f"[FATAL] {e}")
        notify("Pendulum Sync FAILED", str(e)[:100])
        raise

#!/usr/bin/env python3
"""
Download all user data from Firebase Storage to local and Synology.

Downloads:
    - Chat fine-tuning data (conversations with AI)
    - Gameplay session data (CSV files and metadata)
    - User profiles

Usage:
    python download_finetuning_data.py

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
from pathlib import Path
from datetime import datetime

# Set credentials path before importing google libraries
SERVICE_ACCOUNT_PATH = os.path.expanduser("~/.config/firebase/pendulum-service-account.json")
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = SERVICE_ACCOUNT_PATH

from google.cloud import storage

# Configuration
FIREBASE_BUCKET = "the-pendulum-2p0.firebasestorage.app"

# Output directories
PROJECT_DIR = Path(__file__).parent.parent
LOCAL_CHAT_DIR = PROJECT_DIR / "assets" / "processed" / "chat_finetuning"
LOCAL_GAMEPLAY_DIR = PROJECT_DIR / "assets" / "processed" / "gameplay_data"
SYNOLOGY_BASE_DIR = Path("/Volumes/home/Solutions/The Pendulum Data")

def download_all_data():
    """Download all user data from Firebase Storage."""

    print(f"[{datetime.now()}] Starting Firebase data download...")
    print("=" * 60)

    # Initialize client
    try:
        client = storage.Client()
        bucket = client.bucket(FIREBASE_BUCKET)
    except Exception as e:
        print(f"Error connecting to Firebase Storage: {e}")
        print("Make sure service account key exists at:", SERVICE_ACCOUNT_PATH)
        return

    # Create output directories
    LOCAL_CHAT_DIR.mkdir(parents=True, exist_ok=True)
    LOCAL_GAMEPLAY_DIR.mkdir(parents=True, exist_ok=True)

    # Download all files
    print("\n1. Downloading Chat Fine-Tuning Data...")
    chat_stats = download_by_category(bucket, "chat_finetuning", LOCAL_CHAT_DIR, [".json"])

    print("\n2. Downloading Gameplay Session Data...")
    gameplay_stats = download_by_category(bucket, "sessions", LOCAL_GAMEPLAY_DIR, [".csv", ".json"])

    print("\n3. Downloading User Profiles...")
    profiles_dir = LOCAL_GAMEPLAY_DIR / "profiles"
    profiles_dir.mkdir(parents=True, exist_ok=True)
    profile_stats = download_by_category(bucket, "profile", profiles_dir, [".json"])

    # Print summary
    print("\n" + "=" * 60)
    print("Download Summary:")
    print(f"  Chat data: {chat_stats['downloaded']} downloaded, {chat_stats['skipped']} skipped")
    print(f"  Gameplay data: {gameplay_stats['downloaded']} downloaded, {gameplay_stats['skipped']} skipped")
    print(f"  Profiles: {profile_stats['downloaded']} downloaded, {profile_stats['skipped']} skipped")

    # Sync to Synology if mounted
    sync_to_synology()

    # Generate summary reports
    generate_chat_summary_report()
    generate_gameplay_summary_report()


def download_by_category(bucket, folder_name, output_dir, extensions):
    """Download files from a specific category/folder."""

    stats = {"downloaded": 0, "skipped": 0}

    # List all files under users/
    prefix = "users/"
    blobs = bucket.list_blobs(prefix=prefix)

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

        # Download
        print(f"    {blob.name}")
        blob.download_to_filename(str(local_path))
        stats["downloaded"] += 1

    return stats


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

def generate_chat_summary_report():
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

    for user_dir in LOCAL_CHAT_DIR.iterdir():
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
    summary_path = LOCAL_CHAT_DIR / "summary_report.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"  Chat Summary:")
    print(f"    Users: {len(summary['users'])}")
    print(f"    Conversations: {summary['total_conversations']}")
    print(f"    Messages: {summary['total_messages']}")
    print(f"    Total Tokens: {summary['total_tokens']}")
    print(f"    Fallback Responses: {summary['fallback_count']}")


def generate_gameplay_summary_report():
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

    for user_dir in LOCAL_GAMEPLAY_DIR.iterdir():
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
    summary_path = LOCAL_GAMEPLAY_DIR / "summary_report.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"  Gameplay Summary:")
    print(f"    Users: {len(summary['users'])}")
    print(f"    Total Sessions: {summary['total_sessions']}")
    print(f"    CSV Files: {summary['total_csv_files']}")
    print(f"    Metadata Files: {summary['total_metadata_files']}")

if __name__ == "__main__":
    download_all_data()

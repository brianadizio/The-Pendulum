# Firebase Data Download Setup

Downloads all user data from Firebase Storage:
- **Chat fine-tuning data** (AI conversations with token usage)
- **Gameplay session data** (CSV files and metadata)
- **User profiles**

## Prerequisites

```bash
pip install google-cloud-storage firebase-admin
```

## Step 1: Get Service Account Key

1. Go to **Firebase Console** → Your Project → **Project Settings** (gear icon)
2. Click **Service Accounts** tab
3. Click **Generate New Private Key**
4. Save the JSON file to: `~/.config/firebase/pendulum-service-account.json`

```bash
mkdir -p ~/.config/firebase
mv ~/Downloads/your-project-firebase-adminsdk-*.json ~/.config/firebase/pendulum-service-account.json
```

## Step 2: Update Configuration

Edit `download_firebase_data.py` and update:

```python
FIREBASE_BUCKET = "your-project-id.firebasestorage.app"  # Your actual bucket
SYNOLOGY_OUTPUT_DIR = Path("/Volumes/YourNAS/path")      # Your Synology mount point
```

To find your bucket name:
- Firebase Console → Storage → Look at the URL (gs://your-bucket-name)

## Step 3: Test Manual Download

```bash
cd /Users/briandizio/Documents/2023-Now/Golden\ Enterprise\ Solutions/Solutions/The\ Pendulum/scripts
python download_firebase_data.py
```

## Step 4: Automate with Cron (Daily Download)

Add to crontab (`crontab -e`):

```cron
# Download Firebase fine-tuning data daily at 3 AM
0 3 * * * cd /Users/briandizio/Documents/2023-Now/Golden\ Enterprise\ Solutions/Solutions/The\ Pendulum/scripts && /usr/bin/python3 download_firebase_data.py >> /tmp/firebase_download.log 2>&1
```

## Alternative: Automate with LaunchAgent (macOS)

Create `~/Library/LaunchAgents/com.golden.firebase-download.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.golden.firebase-download</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/scripts/download_firebase_data.py</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/firebase_download.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/firebase_download_error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>GOOGLE_APPLICATION_CREDENTIALS</key>
        <string>/Users/briandizio/.config/firebase/pendulum-service-account.json</string>
    </dict>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.golden.firebase-download.plist
```

## Output Locations

**Chat Fine-Tuning Data:**
- Local: `assets/processed/chat_finetuning/{userId}/*.json`
- Synology: `/Volumes/GoldenData/ThePendulum/chat_finetuning/{userId}/*.json`
- Summary: `assets/processed/chat_finetuning/summary_report.json`

**Gameplay Session Data:**
- Local: `assets/processed/gameplay_data/{userId}/*.csv` and `*.json`
- Synology: `/Volumes/GoldenData/ThePendulum/gameplay_data/{userId}/`
- Summary: `assets/processed/gameplay_data/summary_report.json`

**User Profiles:**
- Local: `assets/processed/gameplay_data/profiles/{userId}/*.json`

## Data Format

Each conversation JSON contains:
```json
{
  "conversationId": "uuid",
  "userId": "firebase-uid",
  "createdAt": "2026-02-05T00:00:00Z",
  "updatedAt": "2026-02-05T00:01:00Z",
  "messages": [
    {
      "id": "uuid",
      "role": "user",
      "content": "Am I cautious or impulsive?",
      "timestamp": "2026-02-05T00:00:00Z",
      "presetQuestionId": "cautious_impulsive"
    },
    {
      "id": "uuid",
      "role": "assistant",
      "content": "Based on your gameplay...",
      "timestamp": "2026-02-05T00:00:05Z",
      "tokenUsage": {
        "promptTokens": 1500,
        "completionTokens": 350,
        "totalTokens": 1850
      },
      "responseLatencyMs": 2340,
      "modelName": "gemini-2.5-flash-lite",
      "isFallback": false
    }
  ],
  "gameplayContext": {
    "sessionsPlayed": 25,
    "stabilityScore": 53.3,
    "lyapunovExponent": 111.2,
    ...
  }
}
```

## Synology Cloud Sync Alternative

If you prefer automatic sync without scripts:

1. On Synology DSM → **Cloud Sync**
2. Add **Google Cloud Storage** connection
3. Use service account credentials
4. Sync `your-bucket/users/` → `/volume1/GoldenData/ThePendulum/`
5. Set sync direction: Download only

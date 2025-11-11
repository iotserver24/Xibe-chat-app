# Local Development Setup

Guide for running Xibe Chat locally with Firebase configuration from `.env` file.

---

## Quick Start

### Step 1: Create `.env` File

```bash
# Copy the example file
cp .env.example .env
```

The `.env` file is already created with your Firebase values. It's gitignored, so safe to use.

### Step 2: Run the App

**Windows (PowerShell):**
```powershell
.\scripts\run_local.ps1 windows
```

**Linux/macOS:**
```bash
./scripts/run_local.sh windows
```

**Or manually:**
```bash
flutter run -d windows --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=...
```

---

## Using the Scripts

### Windows (PowerShell)

```powershell
# Run on Windows
.\scripts\run_local.ps1 windows

# Run on Android
.\scripts\run_local.ps1 android

# Run on specific device
.\scripts\run_local.ps1 android emulator-5554
```

### Linux/macOS (Bash)

```bash
# Make script executable (first time only)
chmod +x scripts/run_local.sh

# Run on Windows
./scripts/run_local.sh windows

# Run on Android
./scripts/run_local.sh android

# Run on specific device
./scripts/run_local.sh android emulator-5554
```

---

## Supported Platforms

- `windows` - Windows desktop
- `macos` - macOS desktop
- `linux` - Linux desktop
- `android` - Android mobile
- `ios` - iOS mobile (macOS only)
- `web` - Web browser

---

## Manual Setup (Without Scripts)

If you prefer to run Flutter commands manually:

### Windows (PowerShell)

```powershell
# Load .env file
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

# Run Flutter
flutter run -d windows `
  --dart-define=FIREBASE_PROJECT_ID=$env:FIREBASE_PROJECT_ID `
  --dart-define=FIREBASE_AUTH_DOMAIN=$env:FIREBASE_AUTH_DOMAIN `
  --dart-define=FIREBASE_STORAGE_BUCKET=$env:FIREBASE_STORAGE_BUCKET `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$env:FIREBASE_MESSAGING_SENDER_ID `
  --dart-define=FIREBASE_API_KEY=$env:FIREBASE_WINDOWS_API_KEY `
  --dart-define=FIREBASE_APP_ID=$env:FIREBASE_WINDOWS_APP_ID `
  --dart-define=E2B_BACKEND_URL=$env:E2B_BACKEND_URL
```

### Linux/macOS (Bash)

```bash
# Load .env file
export $(grep -v '^#' .env | xargs)

# Run Flutter
flutter run -d windows \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_WINDOWS_API_KEY \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_WINDOWS_APP_ID \
  --dart-define=E2B_BACKEND_URL=$E2B_BACKEND_URL
```

---

## Platform-Specific Examples

### Android

```bash
# Using script
.\scripts\run_local.ps1 android  # Windows
./scripts/run_local.sh android    # Linux/macOS

# Manual
flutter run -d android \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_ANDROID_API_KEY \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_ANDROID_APP_ID \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
```

### iOS

```bash
# Using script (macOS only)
./scripts/run_local.sh ios

# Manual
flutter run -d ios \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_IOS_API_KEY \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_IOS_APP_ID \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=$FIREBASE_IOS_BUNDLE_ID \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
```

### Web

```bash
# Using script
.\scripts\run_local.ps1 web  # Windows
./scripts/run_local.sh web   # Linux/macOS

# Manual
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_WEB_API_KEY \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_WEB_APP_ID \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
```

---

## Troubleshooting

### Script Not Found

**Error:** `.\scripts\run_local.ps1 : The term '.\scripts\run_local.ps1' is not recognized`

**Solution:**
```powershell
# Allow script execution (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Permission Denied (Linux/macOS)

**Error:** `Permission denied: ./scripts/run_local.sh`

**Solution:**
```bash
chmod +x scripts/run_local.sh
```

### .env File Not Found

**Error:** `❌ Error: .env file not found!`

**Solution:**
```bash
# Copy example file
cp .env.example .env

# Or create manually
touch .env
# Then add your Firebase values
```

### Firebase Not Initializing

**Error:** `Firebase initialization failed`

**Solution:**
1. Check `.env` file has all required variables
2. Verify values are correct (no extra spaces)
3. Check platform-specific API keys match your Firebase apps
4. Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place

---

## File Structure

```
.
├── .env                    # Your local config (gitignored)
├── .env.example            # Template file (committed)
├── scripts/
│   ├── run_local.ps1      # Windows script
│   └── run_local.sh       # Linux/macOS script
└── docs/
    └── LOCAL_DEVELOPMENT.md  # This file
```

---

## Notes

- ✅ `.env` file is gitignored - safe to commit your values
- ✅ Scripts automatically detect platform and use correct Firebase config
- ✅ All Firebase values are already filled in `.env` file
- ✅ Works with all platforms: Windows, macOS, Linux, Android, iOS, Web

---

## Quick Reference

```bash
# Windows
.\scripts\run_local.ps1 windows

# Android
.\scripts\run_local.ps1 android

# Web
.\scripts\run_local.ps1 web

# Specific device
.\scripts\run_local.ps1 android emulator-5554
```

That's it! Your app will run with Firebase configuration from `.env` file.


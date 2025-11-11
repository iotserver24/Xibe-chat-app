# PowerShell script to run Flutter app with .env file
# Usage: .\scripts\run_local.ps1 [platform] [device]
# Example: .\scripts\run_local.ps1 windows
# Example: .\scripts\run_local.ps1 android

param(
    [string]$platform = "windows",
    [string]$device = ""
)

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ Error: .env file not found!" -ForegroundColor Red
    Write-Host "📝 Copy .env.example to .env and fill in your values" -ForegroundColor Yellow
    exit 1
}

# Read .env file
Write-Host "📖 Loading .env file..." -ForegroundColor Cyan
$envVars = @{}
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $envVars[$key] = $value
    }
}

# Build dart-define flags
$dartDefines = @()
$dartDefines += "--dart-define=E2B_BACKEND_URL=$($envVars['E2B_BACKEND_URL'])"

# Add Firebase variables
$firebaseVars = @(
    "FIREBASE_PROJECT_ID",
    "FIREBASE_AUTH_DOMAIN",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_MESSAGING_SENDER_ID",
    "FIREBASE_API_KEY",
    "FIREBASE_APP_ID"
)

# Add platform-specific Firebase config
switch ($platform.ToLower()) {
    "android" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_ANDROID_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_ANDROID_APP_ID'])"
    }
    "ios" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_IOS_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_IOS_APP_ID'])"
        $dartDefines += "--dart-define=FIREBASE_IOS_BUNDLE_ID=$($envVars['FIREBASE_IOS_BUNDLE_ID'])"
    }
    "windows" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_WINDOWS_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_WINDOWS_APP_ID'])"
    }
    "macos" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_MACOS_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_MACOS_APP_ID'])"
        $dartDefines += "--dart-define=FIREBASE_MACOS_BUNDLE_ID=$($envVars['FIREBASE_MACOS_BUNDLE_ID'])"
    }
    "linux" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_LINUX_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_LINUX_APP_ID'])"
    }
    "web" {
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_WEB_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_WEB_APP_ID'])"
    }
    default {
        # Use web config as default
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
    }
}

# Add shared Firebase variables
foreach ($var in $firebaseVars) {
    if ($envVars.ContainsKey($var)) {
        $dartDefines += "--dart-define=$var=$($envVars[$var])"
    }
}

# Build Flutter command
$flutterCmd = "flutter run -d $platform"
if ($device -ne "") {
    $flutterCmd = "flutter run -d $device"
}

$fullCmd = "$flutterCmd $($dartDefines -join ' ')"

Write-Host "🚀 Running Flutter app..." -ForegroundColor Green
Write-Host "📱 Platform: $platform" -ForegroundColor Cyan
Write-Host "🔧 Command: $fullCmd" -ForegroundColor Gray
Write-Host ""

# Execute Flutter command
Invoke-Expression $fullCmd


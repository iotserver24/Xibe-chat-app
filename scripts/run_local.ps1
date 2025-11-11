# PowerShell script to run Flutter app with .env file
# Usage: .\scripts\run_local.ps1 [platform] [device]
# Example: .\scripts\run_local.ps1 windows
# Example: .\scripts\run_local.ps1 android

param(
    [string]$platform = "windows",
    [string]$device = ""
)

# Kill any running xibe_chat processes to prevent file locking
Write-Host "Checking for running app instances..." -ForegroundColor Cyan
$processes = Get-Process -Name "xibe_chat" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "Found $($processes.Count) running instance(s), killing..." -ForegroundColor Yellow
    $processes | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
    Write-Host "✅ Processes killed" -ForegroundColor Green
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    Write-Host "Copy .env.example to .env and fill in your values" -ForegroundColor Yellow
    exit 1
}

# Read .env file
Write-Host "Loading .env file..." -ForegroundColor Cyan
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

# Add MongoDB API URL if present in .env
if ($envVars.ContainsKey('MONGODB_API_URL')) {
    $dartDefines += "--dart-define=MONGODB_API_URL=$($envVars['MONGODB_API_URL'])"
}

# Add shared Firebase variables first (project-level, not API keys)
$sharedFirebaseVars = @(
    "FIREBASE_PROJECT_ID",
    "FIREBASE_AUTH_DOMAIN",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_MESSAGING_SENDER_ID"
)

foreach ($var in $sharedFirebaseVars) {
    if ($envVars.ContainsKey($var)) {
        $dartDefines += "--dart-define=$var=$($envVars[$var])"
    }
}

# Add platform-specific Firebase config (API keys and App IDs)
# These come AFTER shared vars so they override if needed
switch ($platform.ToLower()) {
    "android" {
        if ($envVars.ContainsKey('FIREBASE_ANDROID_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_ANDROID_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_ANDROID_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_ANDROID_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
    }
    "ios" {
        if ($envVars.ContainsKey('FIREBASE_IOS_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_IOS_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_IOS_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_IOS_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
        if ($envVars.ContainsKey('FIREBASE_IOS_BUNDLE_ID')) {
            $dartDefines += "--dart-define=FIREBASE_IOS_BUNDLE_ID=$($envVars['FIREBASE_IOS_BUNDLE_ID'])"
        }
    }
    "windows" {
        if ($envVars.ContainsKey('FIREBASE_WINDOWS_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_WINDOWS_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_WINDOWS_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_WINDOWS_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
    }
    "macos" {
        if ($envVars.ContainsKey('FIREBASE_MACOS_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_MACOS_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_MACOS_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_MACOS_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
        if ($envVars.ContainsKey('FIREBASE_MACOS_BUNDLE_ID')) {
            $dartDefines += "--dart-define=FIREBASE_MACOS_BUNDLE_ID=$($envVars['FIREBASE_MACOS_BUNDLE_ID'])"
        }
    }
    "linux" {
        if ($envVars.ContainsKey('FIREBASE_LINUX_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_LINUX_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_LINUX_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_LINUX_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
    }
    "web" {
        if ($envVars.ContainsKey('FIREBASE_WEB_API_KEY')) {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_WEB_API_KEY'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        }
        if ($envVars.ContainsKey('FIREBASE_WEB_APP_ID')) {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_WEB_APP_ID'])"
        } else {
            $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
        }
    }
    default {
        # Use web config as default
        $dartDefines += "--dart-define=FIREBASE_API_KEY=$($envVars['FIREBASE_API_KEY'])"
        $dartDefines += "--dart-define=FIREBASE_APP_ID=$($envVars['FIREBASE_APP_ID'])"
    }
}

    # Build Flutter command
    $deviceId = $device
    
    # If platform is android and no specific device provided, try to find Android device
    if ($platform.ToLower() -eq "android" -and $deviceId -eq "") {
        Write-Host "Detecting Android devices..." -ForegroundColor Cyan
        $devicesOutput = flutter devices 2>&1 | Out-String
        # Look for Android device lines (they contain "android-arm" or "android-x86")
        if ($devicesOutput -match 'android') {
            # Parse the output to find device ID
            # Format: "DeviceName (type)  • DEVICE_ID • android-arm64  • Android version"
            $lines = $devicesOutput -split "`r?`n"
            foreach ($line in $lines) {
                # Check if line contains android architecture (android-arm64, android-x86, etc.)
                if ($line -match 'android-(arm|x86)') {
                    # Extract device ID using regex: look for pattern "• DEVICE_ID •"
                    if ($line -match '•\s+([A-Z0-9]{8,})\s+•') {
                        $deviceId = $matches[1]
                        Write-Host "Found Android device: $deviceId" -ForegroundColor Green
                        break
                    }
                }
            }
        }
        
        # If still no device found, use 'android' as fallback
        if ($deviceId -eq "") {
            Write-Host "No specific Android device found. Available devices:" -ForegroundColor Yellow
            flutter devices 2>&1 | Select-String "android" | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            Write-Host ""
            Write-Host "Please specify device ID manually:" -ForegroundColor Yellow
            Write-Host "  .\scripts\run_local.ps1 android WS45Y5LZSOSOPF6X" -ForegroundColor Cyan
            exit 1
        }
    } elseif ($deviceId -eq "") {
        $deviceId = $platform
    }

    $flutterCmd = "flutter run -d $deviceId"
    $fullCmd = "$flutterCmd $($dartDefines -join ' ')"

    Write-Host "Running Flutter app..." -ForegroundColor Green
    Write-Host "Platform: $platform" -ForegroundColor Cyan
    Write-Host "Device: $deviceId" -ForegroundColor Cyan
    Write-Host "Command: $fullCmd" -ForegroundColor Gray
    Write-Host ""

    # Execute Flutter command
    Invoke-Expression $fullCmd

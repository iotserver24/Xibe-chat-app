# Firebase Configuration for GitHub Actions

This guide explains how to configure Firebase environment variables in GitHub Actions for automated builds across **all platforms**: Android, iOS, Windows, macOS, Linux, and Web.

## Quick Start: Shared Configuration (Simplest)

If you want to use the same Firebase app for all platforms:

### Step 1: Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Create a **Web app** (works for all platforms as fallback)
6. Copy the configuration values

### Step 2: Add Shared Variables to GitHub Repository

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click on **Variables** tab
4. Click **New repository variable**
5. Add these 6 shared variables:

   | Variable Name | Value | Example |
   |--------------|-------|---------|
   | `FIREBASE_API_KEY` | Your Firebase API Key | `AIzaSy...` |
   | `FIREBASE_APP_ID` | Your Firebase App ID | `1:123456789:web:abc123` |
   | `FIREBASE_PROJECT_ID` | Your Firebase Project ID | `my-project-123` |
   | `FIREBASE_AUTH_DOMAIN` | Your Auth Domain | `my-project-123.firebaseapp.com` |
   | `FIREBASE_STORAGE_BUCKET` | Your Storage Bucket | `my-project-123.appspot.com` |
   | `FIREBASE_MESSAGING_SENDER_ID` | Your Messaging Sender ID | `123456789` |

6. Click **Add** for each variable

**That's it!** All platforms will use these shared values.

## Advanced: Platform-Specific Configuration

For better isolation and analytics, create separate Firebase apps for each platform:

See [docs/PLATFORM_FIREBASE_CONFIG.md](docs/PLATFORM_FIREBASE_CONFIG.md) for complete platform-specific setup guide.

### Quick Platform-Specific Setup

**Required (Shared):**
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_MESSAGING_SENDER_ID`

**Platform-Specific (Optional - falls back to shared if not set):**
- `FIREBASE_ANDROID_API_KEY` / `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_IOS_API_KEY` / `FIREBASE_IOS_APP_ID` / `FIREBASE_IOS_BUNDLE_ID`
- `FIREBASE_WEB_API_KEY` / `FIREBASE_WEB_APP_ID`
- `FIREBASE_WINDOWS_API_KEY` / `FIREBASE_WINDOWS_APP_ID`
- `FIREBASE_MACOS_API_KEY` / `FIREBASE_MACOS_APP_ID` / `FIREBASE_MACOS_BUNDLE_ID`
- `FIREBASE_LINUX_API_KEY` / `FIREBASE_LINUX_APP_ID`

### Step 3: Verify Variables Are Set

The GitHub Actions workflow (`build-release.yml`) will automatically use these variables:

```yaml
env:
  FIREBASE_API_KEY: ${{ vars.FIREBASE_API_KEY }}
  FIREBASE_APP_ID: ${{ vars.FIREBASE_APP_ID }}
  FIREBASE_PROJECT_ID: ${{ vars.FIREBASE_PROJECT_ID }}
  FIREBASE_AUTH_DOMAIN: ${{ vars.FIREBASE_AUTH_DOMAIN }}
  FIREBASE_STORAGE_BUCKET: ${{ vars.FIREBASE_STORAGE_BUCKET }}
  FIREBASE_MESSAGING_SENDER_ID: ${{ vars.FIREBASE_MESSAGING_SENDER_ID }}
```

These are passed to Flutter builds via `--dart-define` flags.

## How It Works

### Build Process

1. **GitHub Actions** reads variables from repository settings
2. Platform-specific variables are resolved (with fallback to shared)
3. Variables are passed as environment variables to each platform's build step
4. Flutter receives them via `--dart-define` flags
5. App code reads them using `String.fromEnvironment()`
6. `FirebaseConfig.currentPlatform` automatically detects platform and uses correct config
7. Firebase is initialized with platform-specific configuration

### Code Flow

```dart
// lib/config/firebase_config.dart
// Automatically detects platform and uses platform-specific or shared config
final apiKey = getApiKey(); // Returns FIREBASE_ANDROID_API_KEY for Android, etc.
final appId = getAppId();   // Returns FIREBASE_ANDROID_APP_ID for Android, etc.

// lib/main.dart
await Firebase.initializeApp(
  options: FirebaseConfig.currentPlatform, // Platform-specific config
);
```

### Platform Detection

- **Android builds** → Uses `FIREBASE_ANDROID_API_KEY` (or `FIREBASE_API_KEY` as fallback)
- **iOS builds** → Uses `FIREBASE_IOS_API_KEY` (or `FIREBASE_API_KEY` as fallback)
- **Windows builds** → Uses `FIREBASE_WINDOWS_API_KEY` (or `FIREBASE_API_KEY` as fallback)
- **macOS builds** → Uses `FIREBASE_MACOS_API_KEY` (or `FIREBASE_API_KEY` as fallback)
- **Linux builds** → Uses `FIREBASE_LINUX_API_KEY` (or `FIREBASE_API_KEY` as fallback)
- **Web builds** → Uses `FIREBASE_WEB_API_KEY` (or `FIREBASE_API_KEY` as fallback)

## Local Development

For local development, you have two options:

### Option 1: Use Environment Variables (Recommended)

Set environment variables before running:

**Windows (PowerShell):**
```powershell
$env:FIREBASE_API_KEY="your-api-key"
$env:FIREBASE_APP_ID="your-app-id"
$env:FIREBASE_PROJECT_ID="your-project-id"
$env:FIREBASE_AUTH_DOMAIN="your-project.firebaseapp.com"
$env:FIREBASE_STORAGE_BUCKET="your-project.appspot.com"
$env:FIREBASE_MESSAGING_SENDER_ID="your-sender-id"
flutter run
```

**Linux/macOS:**
```bash
export FIREBASE_API_KEY="your-api-key"
export FIREBASE_APP_ID="your-app-id"
export FIREBASE_PROJECT_ID="your-project-id"
export FIREBASE_AUTH_DOMAIN="your-project.firebaseapp.com"
export FIREBASE_STORAGE_BUCKET="your-project.appspot.com"
export FIREBASE_MESSAGING_SENDER_ID="your-sender-id"
flutter run
```

### Option 2: Create firebase_options.dart

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase:
   ```bash
   flutterfire configure
   ```

3. This creates `lib/firebase_options.dart` automatically

4. Update `lib/config/firebase_config.dart` to import and use it as fallback

## Security Notes

- ✅ **Variables are safe**: GitHub repository variables are encrypted and only accessible during workflow runs
- ✅ **Not in code**: Firebase credentials are not hardcoded in your repository
- ✅ **Per-repository**: Each repository can have its own Firebase project
- ⚠️ **Don't commit**: Never commit `firebase_options.dart` or hardcode credentials

## Troubleshooting

### Build Fails with "Firebase configuration not found"

**Cause**: Environment variables not set in GitHub repository

**Solution**:
1. Go to repository Settings → Secrets and variables → Actions → Variables
2. Verify all 6 Firebase variables are set
3. Re-run the workflow

### App Works Locally But Not in CI/CD

**Cause**: Environment variables not passed to Flutter build

**Solution**:
1. Check workflow logs for `--dart-define` flags
2. Verify variables are set in repository settings
3. Ensure workflow file has correct variable references

### Firebase Initialization Fails

**Cause**: Invalid or missing configuration values

**Solution**:
1. Double-check values in Firebase Console
2. Verify all 6 variables are set correctly
3. Check for typos or extra spaces
4. Ensure project ID matches across all variables

## Testing

To test Firebase configuration:

1. **Local Test**:
   ```bash
   flutter run --dart-define=FIREBASE_API_KEY=test --dart-define=FIREBASE_PROJECT_ID=test
   ```

2. **CI/CD Test**:
   - Set variables in GitHub
   - Trigger workflow
   - Check build logs for Firebase initialization

## Multiple Environments

For different Firebase projects (dev/staging/prod):

1. Create separate Firebase projects
2. Use GitHub Environments with different variable sets
3. Update workflow to use environment-specific variables

Example:
```yaml
env:
  FIREBASE_PROJECT_ID: ${{ vars.FIREBASE_PROJECT_ID_${{ github.ref_name }} }}
```

## Summary

- ✅ Set 6 Firebase variables in GitHub repository settings
- ✅ Variables are automatically used in CI/CD builds
- ✅ App reads configuration from environment variables
- ✅ Local development can use env vars or `firebase_options.dart`
- ✅ Secure: Credentials never committed to repository


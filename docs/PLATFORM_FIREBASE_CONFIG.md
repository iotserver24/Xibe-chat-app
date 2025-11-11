# Platform-Specific Firebase Configuration

Xibe Chat supports Firebase across all platforms: **Android**, **iOS**, **Windows**, **macOS**, **Linux**, and **Web**. Each platform can have its own Firebase app configuration.

## Configuration Strategy

### Option 1: Shared Configuration (Simplest)

Use the same Firebase app for all platforms:

**GitHub Variables:**
- `FIREBASE_API_KEY` - Shared API key
- `FIREBASE_APP_ID` - Shared App ID
- `FIREBASE_PROJECT_ID` - Project ID
- `FIREBASE_AUTH_DOMAIN` - Auth domain
- `FIREBASE_STORAGE_BUCKET` - Storage bucket
- `FIREBASE_MESSAGING_SENDER_ID` - Messaging sender ID

All platforms will use these shared values.

### Option 2: Platform-Specific Configuration (Recommended)

Create separate Firebase apps for each platform in Firebase Console, then set platform-specific variables:

**Required (Shared):**
- `FIREBASE_PROJECT_ID` - Your Firebase project ID
- `FIREBASE_AUTH_DOMAIN` - Auth domain (usually `{project-id}.firebaseapp.com`)
- `FIREBASE_STORAGE_BUCKET` - Storage bucket (usually `{project-id}.appspot.com`)
- `FIREBASE_MESSAGING_SENDER_ID` - Messaging sender ID

**Platform-Specific (Optional - falls back to shared if not set):**
- `FIREBASE_ANDROID_API_KEY` / `FIREBASE_ANDROID_APP_ID` - Android app
- `FIREBASE_IOS_API_KEY` / `FIREBASE_IOS_APP_ID` / `FIREBASE_IOS_BUNDLE_ID` - iOS app
- `FIREBASE_WEB_API_KEY` / `FIREBASE_WEB_APP_ID` - Web app
- `FIREBASE_WINDOWS_API_KEY` / `FIREBASE_WINDOWS_APP_ID` - Windows app
- `FIREBASE_MACOS_API_KEY` / `FIREBASE_MACOS_APP_ID` / `FIREBASE_MACOS_BUNDLE_ID` - macOS app
- `FIREBASE_LINUX_API_KEY` / `FIREBASE_LINUX_APP_ID` - Linux app

**Fallback:** If platform-specific variables are not set, the system uses shared `FIREBASE_API_KEY` and `FIREBASE_APP_ID`.

## Setting Up Firebase Apps for Each Platform

### 1. Android App

1. Firebase Console → Project Settings → Your apps → Add app → Android
2. Package name: `com.xibechat.app` (or your package name)
3. Download `google-services.json` → place in `android/app/`
4. Copy API Key and App ID → set as `FIREBASE_ANDROID_API_KEY` and `FIREBASE_ANDROID_APP_ID`

### 2. iOS App

1. Firebase Console → Project Settings → Your apps → Add app → iOS
2. Bundle ID: `com.xibechat.app` (or your bundle ID)
3. Download `GoogleService-Info.plist` → place in `ios/Runner/`
4. Copy API Key and App ID → set as `FIREBASE_IOS_API_KEY` and `FIREBASE_IOS_APP_ID`
5. Set `FIREBASE_IOS_BUNDLE_ID` to your bundle ID

### 3. Web App

1. Firebase Console → Project Settings → Your apps → Add app → Web
2. Copy configuration values:
   - `apiKey` → `FIREBASE_WEB_API_KEY`
   - `appId` → `FIREBASE_WEB_APP_ID`
   - `authDomain` → `FIREBASE_AUTH_DOMAIN`
   - `projectId` → `FIREBASE_PROJECT_ID`
   - `storageBucket` → `FIREBASE_STORAGE_BUCKET`
   - `messagingSenderId` → `FIREBASE_MESSAGING_SENDER_ID`

### 4. Windows App

1. Firebase Console → Project Settings → Your apps → Add app → Web (Windows uses web config)
2. Copy `apiKey` → `FIREBASE_WINDOWS_API_KEY`
3. Copy `appId` → `FIREBASE_WINDOWS_APP_ID`

### 5. macOS App

1. Firebase Console → Project Settings → Your apps → Add app → macOS
2. Bundle ID: `com.xibechat.app` (or your bundle ID)
3. Copy API Key and App ID → set as `FIREBASE_MACOS_API_KEY` and `FIREBASE_MACOS_APP_ID`
4. Set `FIREBASE_MACOS_BUNDLE_ID` to your bundle ID

### 6. Linux App

1. Firebase Console → Project Settings → Your apps → Add app → Web (Linux uses web config)
2. Copy `apiKey` → `FIREBASE_LINUX_API_KEY`
3. Copy `appId` → `FIREBASE_LINUX_APP_ID`

## GitHub Actions Variables Setup

### Minimum Required Variables

For the simplest setup, set these 6 variables:

```
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
```

### Full Platform-Specific Setup

For complete platform separation:

**Shared:**
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
```

**Android:**
```
FIREBASE_ANDROID_API_KEY=android-api-key
FIREBASE_ANDROID_APP_ID=android-app-id
```

**iOS:**
```
FIREBASE_IOS_API_KEY=ios-api-key
FIREBASE_IOS_APP_ID=ios-app-id
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

**Web:**
```
FIREBASE_WEB_API_KEY=web-api-key
FIREBASE_WEB_APP_ID=web-app-id
```

**Windows:**
```
FIREBASE_WINDOWS_API_KEY=windows-api-key
FIREBASE_WINDOWS_APP_ID=windows-app-id
```

**macOS:**
```
FIREBASE_MACOS_API_KEY=macos-api-key
FIREBASE_MACOS_APP_ID=macos-app-id
FIREBASE_MACOS_BUNDLE_ID=com.xibechat.app
```

**Linux:**
```
FIREBASE_LINUX_API_KEY=linux-api-key
FIREBASE_LINUX_APP_ID=linux-app-id
```

## How It Works

### Build Process

1. **GitHub Actions** reads variables from repository settings
2. Platform-specific variables are passed to each build step
3. If platform-specific not set, falls back to shared values
4. Flutter receives config via `--dart-define` flags
5. `FirebaseConfig.currentPlatform` reads the appropriate values

### Code Flow

```dart
// lib/config/firebase_config.dart
// Automatically detects platform and uses correct config
final apiKey = getApiKey(); // Returns platform-specific or shared
final appId = getAppId();   // Returns platform-specific or shared

// lib/main.dart
await Firebase.initializeApp(
  options: FirebaseConfig.currentPlatform, // Platform-specific config
);
```

## Platform-Specific Notes

### Android
- Uses `google-services.json` file (if present)
- Falls back to environment variables
- No bundle ID needed

### iOS
- Uses `GoogleService-Info.plist` file (if present)
- Falls back to environment variables
- Requires bundle ID

### Web
- Uses web Firebase config
- Requires `authDomain` and `storageBucket`
- No bundle ID needed

### Windows/Linux
- Uses web-like Firebase config
- Requires `authDomain` and `storageBucket`
- No bundle ID needed

### macOS
- Uses macOS Firebase config
- Requires bundle ID
- Similar to iOS

## Testing

### Test Each Platform

**Android:**
```bash
flutter run -d android --dart-define=FIREBASE_ANDROID_API_KEY=test
```

**iOS:**
```bash
flutter run -d ios --dart-define=FIREBASE_IOS_API_KEY=test
```

**Web:**
```bash
flutter run -d chrome --dart-define=FIREBASE_WEB_API_KEY=test
```

**Windows:**
```bash
flutter run -d windows --dart-define=FIREBASE_WINDOWS_API_KEY=test
```

**macOS:**
```bash
flutter run -d macos --dart-define=FIREBASE_MACOS_API_KEY=test
```

**Linux:**
```bash
flutter run -d linux --dart-define=FIREBASE_LINUX_API_KEY=test
```

## Benefits of Platform-Specific Config

1. ✅ **Isolation**: Each platform has its own Firebase app
2. ✅ **Security**: Platform-specific API keys
3. ✅ **Analytics**: Separate analytics per platform
4. ✅ **Flexibility**: Different configs per platform
5. ✅ **Fallback**: Shared config if platform-specific not set

## Quick Start

**Simplest setup (shared config):**
1. Create one Firebase app (Web or Android)
2. Set 6 shared variables in GitHub
3. All platforms use the same config

**Full setup (platform-specific):**
1. Create Firebase apps for each platform
2. Set shared + platform-specific variables
3. Each platform uses its own config

Both approaches work! Choose based on your needs.


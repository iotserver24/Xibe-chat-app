# Firebase Package Names for Registration

Use these package names when registering Firebase apps for Android and iOS:

## Android Package Name
```
com.xibechat.app
```

**Location:** `android/app/build.gradle` (line 49: `applicationId "com.xibechat.app"`)

## iOS Bundle ID
```
com.xibechat.app
```

**Location:** Used as default in `lib/config/firebase_config.dart`

---

## Firebase Registration Steps

### 1. Register Android App

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **share-x-56754**
3. Go to **Project Settings** → **Your apps**
4. Click **Add app** → **Android**
5. Enter:
   - **Package name:** `com.xibechat.app`
   - **App nickname (optional):** Xibe Chat Android
   - **Debug signing certificate SHA-1 (optional):** Leave blank for now
6. Click **Register app**
7. Download `google-services.json`
8. Place it in `android/app/` directory
9. Copy the **API Key** and **App ID** from the config

### 2. Register iOS App

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **share-x-56754**
3. Go to **Project Settings** → **Your apps**
4. Click **Add app** → **iOS**
5. Enter:
   - **Bundle ID:** `com.xibechat.app`
   - **App nickname (optional):** Xibe Chat iOS
   - **App Store ID (optional):** Leave blank for now
6. Click **Register app**
7. Download `GoogleService-Info.plist`
8. Place it in `ios/Runner/` directory (open in Xcode and add to project)
9. Copy the **API Key** and **App ID** from the config

---

## GitHub Actions Variables Setup

After registering Android and iOS apps, add these variables to GitHub:

### Shared/Web Config (Already have this)
```
FIREBASE_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_PROJECT_ID=share-x-56754
FIREBASE_AUTH_DOMAIN=share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET=share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=488265380434
```

### Android Config (Add after registering Android app)
```
FIREBASE_ANDROID_API_KEY=<copy-from-android-app-config>
FIREBASE_ANDROID_APP_ID=<copy-from-android-app-config>
```

### iOS Config (Add after registering iOS app)
```
FIREBASE_IOS_API_KEY=<copy-from-ios-app-config>
FIREBASE_IOS_APP_ID=<copy-from-ios-app-config>
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

### Desktop Platforms (Use Web config)
```
FIREBASE_WINDOWS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WINDOWS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_MACOS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_BUNDLE_ID=com.xibechat.app
FIREBASE_LINUX_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_LINUX_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_WEB_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WEB_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
```

---

## Summary

- ✅ **Android:** `com.xibechat.app`
- ✅ **iOS:** `com.xibechat.app`
- ✅ **Web/Windows/macOS/Linux:** Use web config (already provided)

After registering Android and iOS apps, update GitHub Actions variables with their specific API keys and App IDs.


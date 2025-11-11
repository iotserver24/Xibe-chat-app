# Firebase Quick Setup Guide

Based on your Firebase web configuration, here's the complete setup:

## Your Firebase Project
- **Project ID:** `share-x-56754`
- **Web App ID:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- **API Key:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`

## Package Names for Registration

### Android
```
com.xibechat.app
```

### iOS
```
com.xibechat.app
```

---

## Step 1: Register Android App in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **share-x-56754**
3. **Project Settings** → **Your apps** → **Add app** → **Android**
4. **Package name:** `com.xibechat.app`
5. Click **Register app**
6. Download `google-services.json` → place in `android/app/`
7. Copy **API Key** and **App ID** from the config screen

---

## Step 2: Register iOS App in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **share-x-56754**
3. **Project Settings** → **Your apps** → **Add app** → **iOS**
4. **Bundle ID:** `com.xibechat.app`
5. Click **Register app**
6. Download `GoogleService-Info.plist` → place in `ios/Runner/`
7. Copy **API Key** and **App ID** from the config screen

---

## Step 3: Set GitHub Actions Variables

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **Variables**

### Required Variables (Set these first):

**Shared/Web Config (Use your web config):**
```
FIREBASE_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_PROJECT_ID=share-x-56754
FIREBASE_AUTH_DOMAIN=share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET=share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=488265380434
```

**Desktop Platforms (Use web config - same as above):**
```
FIREBASE_WEB_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WEB_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_WINDOWS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WINDOWS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_MACOS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_BUNDLE_ID=com.xibechat.app
FIREBASE_LINUX_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_LINUX_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
```

**Android Config (After registering Android app):**
```
FIREBASE_ANDROID_API_KEY=<copy-from-android-app-config>
FIREBASE_ANDROID_APP_ID=<copy-from-android-app-config>
```

**iOS Config (After registering iOS app):**
```
FIREBASE_IOS_API_KEY=<copy-from-ios-app-config>
FIREBASE_IOS_APP_ID=<copy-from-ios-app-config>
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

---

## Platform Configuration Summary

| Platform | Uses Config | Package/Bundle ID |
|----------|------------|-------------------|
| **Web** | Web config | N/A |
| **Windows** | Web config | N/A |
| **macOS** | Web config | `com.xibechat.app` |
| **Linux** | Web config | N/A |
| **Android** | Android app (register separately) | `com.xibechat.app` |
| **iOS** | iOS app (register separately) | `com.xibechat.app` |

---

## Quick Copy-Paste for GitHub Variables

**Minimum Required (Web config for desktop + web):**
```
FIREBASE_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_PROJECT_ID=share-x-56754
FIREBASE_AUTH_DOMAIN=share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET=share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=488265380434
FIREBASE_WEB_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WEB_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_WINDOWS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WINDOWS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_MACOS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_BUNDLE_ID=com.xibechat.app
FIREBASE_LINUX_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_LINUX_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
```

**After registering Android app:**
```
FIREBASE_ANDROID_API_KEY=<android-api-key>
FIREBASE_ANDROID_APP_ID=<android-app-id>
```

**After registering iOS app:**
```
FIREBASE_IOS_API_KEY=<ios-api-key>
FIREBASE_IOS_APP_ID=<ios-app-id>
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

---

## Notes

- ✅ **Web, Windows, macOS, Linux** → Use your web config (already provided)
- ⏳ **Android** → Register app with package `com.xibechat.app`, then add variables
- ⏳ **iOS** → Register app with bundle ID `com.xibechat.app`, then add variables
- 🔄 **Fallback:** If Android/iOS variables not set, they'll use web config (may not work perfectly)


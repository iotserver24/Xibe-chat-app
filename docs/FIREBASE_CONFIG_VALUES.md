# Firebase Configuration Values

Extracted from your Firebase configuration files. Use these values in GitHub Actions variables.

## Project Information (Shared)

- **Project ID:** `share-x-56754`
- **Project Number:** `488265380434`
- **Storage Bucket:** `share-x-56754.firebasestorage.app`
- **Auth Domain:** `share-x-56754.firebaseapp.com`
- **Messaging Sender ID:** `488265380434`
- **Database URL:** `https://share-x-56754-default-rtdb.asia-southeast1.firebasedatabase.app`

---

## Web Configuration

- **API Key:** `AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI`
- **App ID:** `1:488265380434:web:4e5f01713760cc1c10e58b`
- **Measurement ID:** `G-06GGTY4E96`

---

## Android Configuration

**Package Name:** `com.xibechat.app`

- **API Key:** `AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw`
- **App ID:** `1:488265380434:android:55d3a0fba109b6d410e58b`

**Note:** Your `google-services.json` contains two clients. The correct one for Xibe Chat is:
- Client with package `com.xibechat.app` (line 49)
- App ID: `1:488265380434:android:55d3a0fba109b6d410e58b`

---

## iOS Configuration

**Bundle ID:** `com.xibechat.app`

- **API Key:** `AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng`
- **App ID:** `1:488265380434:ios:fd982cfc53e23bcd10e58b`

---

## GitHub Actions Variables

Copy-paste these into GitHub repository variables:

### Required Shared Variables

```
FIREBASE_PROJECT_ID=share-x-56754
FIREBASE_AUTH_DOMAIN=share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET=share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=488265380434
```

### Web Configuration (for Web, Windows, macOS, Linux)

```
FIREBASE_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
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

### Android Configuration

```
FIREBASE_ANDROID_API_KEY=AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw
FIREBASE_ANDROID_APP_ID=1:488265380434:android:55d3a0fba109b6d410e58b
```

### iOS Configuration

```
FIREBASE_IOS_API_KEY=AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng
FIREBASE_IOS_APP_ID=1:488265380434:ios:fd982cfc53e23bcd10e58b
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

---

## Complete Variable List (All in One)

```
# Shared
FIREBASE_PROJECT_ID=share-x-56754
FIREBASE_AUTH_DOMAIN=share-x-56754.firebaseapp.com
FIREBASE_STORAGE_BUCKET=share-x-56754.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=488265380434

# Web (fallback)
FIREBASE_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b

# Web Platform
FIREBASE_WEB_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WEB_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b

# Windows
FIREBASE_WINDOWS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_WINDOWS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b

# macOS
FIREBASE_MACOS_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_MACOS_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b
FIREBASE_MACOS_BUNDLE_ID=com.xibechat.app

# Linux
FIREBASE_LINUX_API_KEY=AIzaSyDPFI1SOaNauCDQmEvVT-CpIxW2BymkOuI
FIREBASE_LINUX_APP_ID=1:488265380434:web:4e5f01713760cc1c10e58b

# Android
FIREBASE_ANDROID_API_KEY=AIzaSyCeYumB4mv99o6yYS0Q1D8XCsooB0P8Afw
FIREBASE_ANDROID_APP_ID=1:488265380434:android:55d3a0fba109b6d410e58b

# iOS
FIREBASE_IOS_API_KEY=AIzaSyBsfaexrb7pTIJ5QBip08EYyUxVXwFfSng
FIREBASE_IOS_APP_ID=1:488265380434:ios:fd982cfc53e23bcd10e58b
FIREBASE_IOS_BUNDLE_ID=com.xibechat.app
```

---

## Verification Checklist

- ✅ **Android:** `google-services.json` placed in `android/app/`
- ✅ **iOS:** `GoogleService-Info.plist` placed in `ios/Runner/`
- ✅ **Package Names Match:**
  - Android: `com.xibechat.app` ✅
  - iOS: `com.xibechat.app` ✅
- ⚠️ **Note:** `google-services.json` contains an extra client with package `com.example.notes_ai` - this is safe to ignore, the correct client (`com.xibechat.app`) is present

---

## Next Steps

1. ✅ Configuration files are in place
2. ⏳ Add all variables above to GitHub repository variables
3. ⏳ Test a build to verify Firebase initialization works
4. ✅ Ready for cloud sync across all platforms!


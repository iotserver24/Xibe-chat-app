# Firebase Setup Guide

This guide will help you set up Firebase for authentication and cloud sync in Xibe Chat.

## Prerequisites

1. A Firebase account (free tier is sufficient)
2. Firebase project created at [Firebase Console](https://console.firebase.google.com/)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard
4. Enable **Authentication** and **Firestore Database**

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. Save the changes

## Step 3: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development) or **Start in production mode** (for production)
4. Select a location for your database
5. Click "Enable"

### Firestore Security Rules

For production, update your Firestore security rules to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /chats/{chatId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        match /messages/{messageId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
      
      match /memories/{memoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Step 4: Configure GitHub Actions (For CI/CD Builds)

If you're using GitHub Actions for automated builds, set these variables in your repository:

1. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Add these variables:
   - `FIREBASE_API_KEY`
   - `FIREBASE_APP_ID`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_AUTH_DOMAIN`
   - `FIREBASE_STORAGE_BUCKET`
   - `FIREBASE_MESSAGING_SENDER_ID`

See [docs/GITHUB_ACTIONS_FIREBASE.md](docs/GITHUB_ACTIONS_FIREBASE.md) for detailed instructions.

## Step 5: Add Firebase Configuration (For Local Development)

### For Android

1. In Firebase Console, go to **Project Settings** > **Your apps**
2. Click the Android icon to add Android app
3. Enter your package name (found in `android/app/build.gradle` as `applicationId`)
4. Download `google-services.json`
5. Place it in `android/app/` directory

### For iOS

1. In Firebase Console, go to **Project Settings** > **Your apps**
2. Click the iOS icon to add iOS app
3. Enter your bundle ID
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory in Xcode

### For Web (Local Development Only)

**Note**: For CI/CD builds, use GitHub Actions variables (see Step 4 above).

For local development:

1. In Firebase Console, go to **Project Settings** > **Your apps**
2. Click the web icon to add web app
3. Copy the Firebase configuration object
4. Create `lib/firebase_options.dart` (optional - only for local dev):

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );
}
```

5. Update `lib/main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of your code
}
```

## Step 5: Install Dependencies

Run:
```bash
flutter pub get
```

## Step 7: Test the Setup

1. Run the app
2. You should see the login/signup screen
3. Create an account and test syncing

## Troubleshooting

### Firebase not initializing
- Make sure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
- Check that Firebase is enabled in your project settings

### Authentication errors
- Verify Email/Password authentication is enabled in Firebase Console
- Check Firestore security rules allow authenticated users

### Sync not working
- Check internet connection
- Verify Firestore database is created and rules are set correctly
- Check console logs for error messages

## Features Enabled

With Firebase setup, you get:
- ✅ User authentication (sign up, sign in, sign out)
- ✅ Cloud sync for chats across all devices
- ✅ Cloud sync for messages
- ✅ Cloud sync for memories
- ✅ Offline-first architecture (works offline, syncs when online)
- ✅ Fast real-time sync

## Security Notes

- Never commit `google-services.json` or `GoogleService-Info.plist` to public repositories
- Use proper Firestore security rules in production
- Consider enabling additional authentication methods (Google, Apple, etc.) for better UX


# Authentication & Cloud Sync

Xibe Chat now supports user authentication and cloud sync, allowing you to access your chats, messages, and memories across all your devices.

## Features

- ✅ **User Authentication**: Sign up, sign in, and sign out
- ✅ **Cloud Sync**: All chats, messages, and memories sync automatically to Firebase
- ✅ **Offline-First**: Works offline, syncs when online
- ✅ **Fast Performance**: Real-time sync with efficient caching
- ✅ **Cross-Platform**: Sync works across Android, iOS, Windows, macOS, and Linux

## How It Works

### Authentication Flow

1. **First Launch**: App shows login/signup screen
2. **Sign Up**: Create account with email and password
3. **Sign In**: Use your credentials to access your account
4. **Auto-Sync**: Once signed in, all data syncs automatically

### Cloud Sync Architecture

- **Local First**: All data is stored locally in SQLite for fast access
- **Background Sync**: Changes sync to Firebase in the background
- **Conflict Resolution**: Cloud data takes precedence when conflicts occur
- **Offline Support**: App works fully offline, syncs when connection is restored

## User Experience

### Sign Up
1. Open the app
2. Tap "Sign Up"
3. Enter email and password (minimum 6 characters)
4. Optionally add a display name
5. Tap "Sign Up"

### Sign In
1. Open the app
2. Enter your email and password
3. Tap "Sign In"

### Sign Out
1. Go to Settings
2. Scroll to "Account" section
3. Tap "Sign Out"
4. Confirm sign out

### Forgot Password
1. On the sign-in screen, tap "Forgot Password?"
2. Enter your email
3. Check your inbox for password reset email

## Data Sync

### What Syncs
- ✅ All chats (titles, timestamps)
- ✅ All messages (content, images, reactions, etc.)
- ✅ All memories
- ✅ Chat updates (renames, deletions)

### Sync Behavior
- **Real-time**: Changes sync immediately when online
- **Background**: Sync happens in background, doesn't block UI
- **Automatic**: No manual sync needed
- **Bidirectional**: Local ↔ Cloud sync

## Security

- **Encrypted**: All data is encrypted in transit (HTTPS)
- **User Isolation**: Each user can only access their own data
- **Secure Authentication**: Firebase handles password hashing and security
- **Privacy**: Your data is stored securely in Firebase

## Troubleshooting

### Can't Sign In
- Check your email and password are correct
- Try "Forgot Password" if you forgot your password
- Ensure you have internet connection

### Sync Not Working
- Check internet connection
- Verify Firebase is properly configured (see FIREBASE_SETUP.md)
- Check console logs for errors
- Try signing out and signing back in

### Data Not Appearing
- Wait a few seconds for sync to complete
- Pull down to refresh (if available)
- Check if you're signed in with the correct account
- Verify Firebase configuration

## Technical Details

### Architecture
- **Firebase Auth**: User authentication
- **Cloud Firestore**: Cloud database
- **SQLite**: Local database (offline-first)
- **Connectivity Plus**: Network status detection

### Data Structure
```
users/{userId}/
  ├── chats/{chatId}/
  │   ├── messages/{messageId}/
  │   └── metadata
  └── memories/{memoryId}/
```

### Sync Strategy
1. **Write**: Local first, then sync to cloud
2. **Read**: Local first, merge with cloud on login
3. **Conflict**: Cloud takes precedence
4. **Offline**: Queue writes, sync when online

## Future Enhancements

- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Multi-device sync indicators
- [ ] Sync status display
- [ ] Manual sync trigger
- [ ] Export/import data


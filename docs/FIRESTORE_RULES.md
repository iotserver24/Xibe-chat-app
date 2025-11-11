# Firestore Security Rules

This document explains the Firestore security rules for Xibe Chat.

## Rules File Location

Copy the contents of `firestore.rules` to your Firebase Console:
1. Go to Firebase Console → Firestore Database → Rules
2. Paste the rules
3. Click "Publish"

## Rule Structure

```
users/{userId}/
  ├── (user profile document)
  ├── settings/
  │   └── user_settings (document)
  ├── chats/{chatId}/
  │   └── messages/{messageId}/
  └── memories/{memoryId}/
```

## Security Rules Explained

### User Isolation
- Each user can only access their own data
- Rules check: `request.auth.uid == userId`
- Prevents users from accessing other users' data

### Authentication Required
- All operations require authentication
- Rules check: `request.auth != null`
- Unauthenticated users cannot access any data

### Read/Write Permissions
- Users can read and write their own data
- No public read/write access
- Admin access can be added separately if needed

## Testing Rules

Use Firebase Console → Firestore → Rules Simulator to test:
1. Set up test scenarios
2. Verify rules work as expected
3. Test edge cases

## Production Considerations

1. **Enable Rules**: Make sure rules are published
2. **Monitor**: Check Firebase Console for rule violations
3. **Update**: Keep rules updated as features change
4. **Test**: Test rules thoroughly before deploying

## Rule Breakdown

```javascript
// Helper: Check if authenticated
function isAuthenticated() {
  return request.auth != null;
}

// Helper: Check if user owns resource
function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}

// User profile - only owner can access
match /users/{userId} {
  allow read, write: if isOwner(userId);
  
  // Settings - only owner can access
  match /settings/{settingsId} {
    allow read, write: if isOwner(userId);
  }
  
  // Chats - only owner can access
  match /chats/{chatId} {
    allow read, write: if isOwner(userId);
    
    // Messages - only owner can access
    match /messages/{messageId} {
      allow read, write: if isOwner(userId);
    }
  }
  
  // Memories - only owner can access
  match /memories/{memoryId} {
    allow read, write: if isOwner(userId);
  }
}
```

## Common Issues

### Rules Not Working
- Check if rules are published
- Verify user is authenticated
- Check Firebase Console logs

### Access Denied
- Verify user ID matches document path
- Check authentication status
- Review rule conditions

### Performance
- Rules are evaluated on every request
- Keep rules simple and efficient
- Use indexes for complex queries


import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Only initialize GoogleSignIn for mobile platforms (Android/iOS)
  // Desktop platforms will use Firebase Auth web-based sign-in
  GoogleSignIn? _googleSignIn;
  
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
      // For Android, you may need to specify the serverClientId
      // This should match the OAuth 2.0 client ID from Firebase Console
      // Leave it null to use the default from google-services.json
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
    return _googleSignIn!;
  }
  
  // Check if we're on a desktop platform
  bool get _isDesktopPlatform {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign up with email and password
  Future<app_user.User> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      final user = userCredential.user!;
      return app_user.User(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName ?? displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<app_user.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      final user = userCredential.user!;
      return app_user.User(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign in with Google
  Future<app_user.User> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (_isDesktopPlatform) {
        // For desktop platforms, open browser with Google OAuth URL
        // User will sign in via browser, then we'll handle the callback
        throw Exception('desktop_oauth_flow');
      } else if (kIsWeb) {
        // Use Firebase Auth's web-based sign-in for web platform
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        
        try {
          userCredential = await _auth.signInWithPopup(googleProvider);
        } catch (popupError) {
          throw Exception('Google sign in failed: $popupError');
        }
      } else {
        // Use native Google Sign-In for mobile platforms (Android/iOS)
        try {
          // Try native Google Sign-In first
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          
          if (googleUser == null) {
            // User cancelled the sign-in
            throw Exception('Sign in cancelled');
          }

          // Obtain the auth details from the request
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

          // Check if we got valid tokens
          if (googleAuth.accessToken == null && googleAuth.idToken == null) {
            throw Exception('Failed to obtain authentication tokens from Google');
          }

          // Create a new credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Sign in to Firebase with the Google credential
          userCredential = await _auth.signInWithCredential(credential);
        } catch (e) {
          // Log the full error for debugging
          print('Google Sign-In error: $e');
          print('Error type: ${e.runtimeType}');
          
          // Check if it's a platform-specific error
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('missingpluginexception') ||
              errorString.contains('no implementation found')) {
            throw Exception('Google Sign-In plugin not available. Please ensure google_sign_in is properly configured.');
          }
          
          // Check for common Android configuration errors
          if (errorString.contains('sign_in_failed') ||
              errorString.contains('10:') || // Common Google Play Services error code
              errorString.contains('12500') || // Sign-in currently disabled
              errorString.contains('12501')) { // Sign-in cancelled
            throw Exception('Google Sign-In failed: ${e.toString()}. Please check Firebase Console configuration and ensure SHA-1 fingerprint is added.');
          }
          
          // Re-throw the original error with more context
          throw Exception('Google sign in failed: $e');
        }
      }

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      final user = userCredential.user!;
      return app_user.User(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('cancelled') || 
          e.toString().contains('popup_closed_by_user') ||
          e.toString().contains('user_cancelled')) {
        throw Exception('Sign in cancelled');
      }
      throw Exception('Google sign in failed: $e');
    }
  }

  // Open Google OAuth in browser (for desktop platforms)
  Future<void> openGoogleOAuthInBrowser() async {
    try {
      final authDomain = _auth.app.options.authDomain ?? 'share-x-56754.firebaseapp.com';
      final apiKey = _auth.app.options.apiKey;
      
      // Build OAuth URL that opens in browser
      final oauthUrl = Uri.parse(
        'https://$authDomain/__/auth/handler?apiKey=$apiKey&authType=signInWithRedirect&provider=google.com&redirectUrl=xibechat://auth/google'
      );
      
      // Open in browser
      if (await canLaunchUrl(oauthUrl)) {
        await launchUrl(oauthUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Sign-In');
      }
    } catch (e) {
      throw Exception('Failed to open Google Sign-In: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google (only for mobile platforms)
      // Desktop platforms don't need this as they use Firebase Auth web sign-in
      if (!_isDesktopPlatform && !kIsWeb && _googleSignIn != null) {
        try {
          await googleSignIn.signOut();
        } catch (e) {
          // Ignore Google sign out errors - user might not be signed in with Google
          print('Google sign out error (ignored): $e');
        }
      }
      
      // Sign out from Firebase (this is the main sign out)
      await _auth.signOut();
    } catch (e) {
      // If Firebase sign out fails, still throw the error
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // Send password reset email
      // Firebase will use the default email template configured in Firebase Console
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully to $email');
      // Note: Firebase sends email even if user doesn't exist (for security)
      // This prevents email enumeration attacks
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error during password reset: ${e.code} - ${e.message}');
      print('❌ Full error details: $e');
      
      // Handle specific error codes
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          // Firebase doesn't reveal if email exists, but still sends email
          // So we treat this as success
          errorMessage = 'Password reset email sent. Please check your inbox and spam folder.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many password reset requests. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Password reset is not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred. Please try again.';
      }
      
      // Only throw error if it's not user-not-found (which is actually success)
      if (e.code != 'user-not-found') {
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Password reset failed: $e');
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.updateDisplayName(displayName);
      await user.reload();
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.updateEmail(newEmail);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Handle Firebase auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        // Firebase doesn't reveal if email exists for security reasons
        // But it still sends the email, so we treat this as success
        // The actual error won't be thrown for password reset - Firebase sends email anyway
        return 'Password reset email sent. Please check your inbox and spam folder.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many password reset requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Password reset is not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'missing-continue-uri':
        return 'Password reset configuration error. Please contact support.';
      case 'invalid-continue-uri':
        return 'Password reset configuration error. Please contact support.';
      case 'unauthorized-continue-uri':
        return 'Password reset configuration error. Please contact support.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}


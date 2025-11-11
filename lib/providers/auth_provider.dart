import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_user;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  app_user.User? _user;
  bool _isLoading = false;
  String? _error;

  app_user.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    // Ensure auth state changes are handled on the main thread
    // This helps prevent the Firebase Auth plugin threading warning
    _authService.authStateChanges.listen(
      (firebaseUser) {
        // Schedule all handling on the main isolate to prevent threading issues
        Future.microtask(() {
          // Handle auth state changes on the main thread
          if (firebaseUser != null) {
            _user = app_user.User(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoUrl: firebaseUser.photoURL,
              createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
              lastLoginAt: DateTime.now(),
            );
          } else {
            _user = null;
          }
          // Notify listeners on the main thread
          notifyListeners();
        });
      },
      onError: (error) {
        // Schedule error handling on the main isolate
        Future.microtask(() {
          // Handle errors gracefully
          print('Auth state change error: $error');
          notifyListeners();
        });
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


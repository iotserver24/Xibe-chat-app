import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    // Platform-specific environment variables (for CI/CD builds)
    // Each platform can have its own config, or use shared values
    
    // Shared/common values
    final projectId = const String.fromEnvironment('FIREBASE_PROJECT_ID');
    final authDomain = const String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    final storageBucket = const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    final messagingSenderId = const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    
    // Platform-specific API keys and App IDs
    final apiKey = const String.fromEnvironment('FIREBASE_API_KEY');
    final appId = const String.fromEnvironment('FIREBASE_APP_ID');
    
    // Platform-specific overrides (optional)
    final androidApiKey = const String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
    final androidAppId = const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
    final iosApiKey = const String.fromEnvironment('FIREBASE_IOS_API_KEY');
    final iosAppId = const String.fromEnvironment('FIREBASE_IOS_APP_ID');
    final iosBundleId = const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID', defaultValue: 'com.xibechat.app');
    final webApiKey = const String.fromEnvironment('FIREBASE_WEB_API_KEY');
    final webAppId = const String.fromEnvironment('FIREBASE_WEB_APP_ID');
    final windowsApiKey = const String.fromEnvironment('FIREBASE_WINDOWS_API_KEY');
    final windowsAppId = const String.fromEnvironment('FIREBASE_WINDOWS_APP_ID');
    final macosApiKey = const String.fromEnvironment('FIREBASE_MACOS_API_KEY');
    final macosAppId = const String.fromEnvironment('FIREBASE_MACOS_APP_ID');
    final macosBundleId = const String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID', defaultValue: 'com.xibechat.app');
    final linuxApiKey = const String.fromEnvironment('FIREBASE_LINUX_API_KEY');
    final linuxAppId = const String.fromEnvironment('FIREBASE_LINUX_APP_ID');

    // Use platform-specific values if available, otherwise fall back to shared values
    String getApiKey() {
      if (kIsWeb) return webApiKey.isNotEmpty ? webApiKey : apiKey;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return androidApiKey.isNotEmpty ? androidApiKey : apiKey;
        case TargetPlatform.iOS:
          return iosApiKey.isNotEmpty ? iosApiKey : apiKey;
        case TargetPlatform.macOS:
          return macosApiKey.isNotEmpty ? macosApiKey : apiKey;
        case TargetPlatform.windows:
          return windowsApiKey.isNotEmpty ? windowsApiKey : apiKey;
        case TargetPlatform.linux:
          return linuxApiKey.isNotEmpty ? linuxApiKey : apiKey;
        default:
          return apiKey;
      }
    }

    String getAppId() {
      if (kIsWeb) return webAppId.isNotEmpty ? webAppId : appId;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return androidAppId.isNotEmpty ? androidAppId : appId;
        case TargetPlatform.iOS:
          return iosAppId.isNotEmpty ? iosAppId : appId;
        case TargetPlatform.macOS:
          return macosAppId.isNotEmpty ? macosAppId : appId;
        case TargetPlatform.windows:
          return windowsAppId.isNotEmpty ? windowsAppId : appId;
        case TargetPlatform.linux:
          return linuxAppId.isNotEmpty ? linuxAppId : appId;
        default:
          return appId;
      }
    }

    final finalApiKey = getApiKey();
    final finalAppId = getAppId();

    // If environment variables are provided, use them
    if (finalApiKey.isNotEmpty &&
        finalAppId.isNotEmpty &&
        projectId.isNotEmpty &&
        authDomain.isNotEmpty) {
      if (kIsWeb) {
        return FirebaseOptions(
          apiKey: finalApiKey,
          appId: finalAppId,
          messagingSenderId: messagingSenderId.isNotEmpty ? messagingSenderId : '0',
          projectId: projectId,
          authDomain: authDomain,
          storageBucket: storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
        );
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return FirebaseOptions(
            apiKey: finalApiKey,
            appId: finalAppId,
            messagingSenderId: messagingSenderId.isNotEmpty ? messagingSenderId : '0',
            projectId: projectId,
          );
        case TargetPlatform.iOS:
          return FirebaseOptions(
            apiKey: finalApiKey,
            appId: finalAppId,
            messagingSenderId: messagingSenderId.isNotEmpty ? messagingSenderId : '0',
            projectId: projectId,
            iosBundleId: iosBundleId,
          );
        case TargetPlatform.macOS:
          return FirebaseOptions(
            apiKey: finalApiKey,
            appId: finalAppId,
            messagingSenderId: messagingSenderId.isNotEmpty ? messagingSenderId : '0',
            projectId: projectId,
            iosBundleId: macosBundleId,
          );
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          // Desktop platforms use web-like config
          return FirebaseOptions(
            apiKey: finalApiKey,
            appId: finalAppId,
            messagingSenderId: messagingSenderId.isNotEmpty ? messagingSenderId : '0',
            projectId: projectId,
            authDomain: authDomain,
            storageBucket: storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
          );
        default:
          throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.',
          );
      }
    }

    // Fallback: Try to load from firebase_options.dart if it exists
    // This allows local development with firebase_options.dart file
    try {
      // Try to import and use firebase_options.dart if available
      // This is a dynamic import attempt - if the file doesn't exist, this will fail gracefully
      final firebaseOptions = _tryLoadFirebaseOptions();
      if (firebaseOptions != null) {
        return firebaseOptions;
      }
    } catch (e) {
      // firebase_options.dart not available, continue to error
    }

    // No configuration found - provide helpful error message
    throw UnsupportedError(
      'Firebase configuration not found for ${kIsWeb ? 'web' : defaultTargetPlatform.toString()}. '
      'For local development, use: .\\scripts\\run_local.ps1 windows (or ./scripts/run_local.sh windows) '
      'Or set Firebase environment variables via --dart-define flags. '
      'Required variables: FIREBASE_API_KEY (or platform-specific), FIREBASE_APP_ID (or platform-specific), FIREBASE_PROJECT_ID, FIREBASE_AUTH_DOMAIN. '
      'See docs/LOCAL_DEVELOPMENT.md for instructions.',
    );
  }

  // Try to load Firebase options from firebase_options.dart if it exists
  static FirebaseOptions? _tryLoadFirebaseOptions() {
    try {
      // Try to use DefaultFirebaseOptions from firebase_options.dart
      // This will only work if the file exists and is properly configured
      // Using a try-catch to handle the case where it doesn't exist
      // Note: This requires firebase_options.dart to be generated via FlutterFire CLI
      // For now, return null - users should use the run_local script or --dart-define flags
      return null;
    } catch (e) {
      return null;
    }
  }
}


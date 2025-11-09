# GitHub Actions Setup for Payment Backend URL

This guide explains how to configure the payment backend URL using GitHub Actions variables and secrets.

## Overview

The payment backend URL is configured via GitHub Actions so that:
- You can change the backend URL without modifying code
- Different branches can use different backends (dev/staging/prod)
- The URL is securely managed in GitHub
- Apps are automatically built with the correct backend URL

## GitHub Actions Variable Name

**Variable Name:** `PAYMENT_BACKEND_URL`

**Format:** `https://payment.yourdomain.com`

**Example:** `https://payment.xibechat.app`

## Setup Instructions

### Step 1: Access Repository Settings

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**

### Step 2: Add Repository Variable

1. Click on the **Variables** tab
2. Click **New repository variable**
3. Fill in:
   - **Name**: `PAYMENT_BACKEND_URL`
   - **Value**: `https://payment.yourdomain.com` (your actual domain)
4. Click **Add variable**

### Step 3: Verify Variable

Your variable should now appear in the list:

```
PAYMENT_BACKEND_URL = https://payment.yourdomain.com
```

## Using the Variable in GitHub Actions

### Option 1: Automatic Build-Time Injection (Recommended)

The build process will automatically inject the backend URL at build time.

**Update `.github/workflows/build.yml`:**

```yaml
name: Build Xibe Chat

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  FLUTTER_VERSION: '3.16.0'
  PAYMENT_BACKEND_URL: ${{ vars.PAYMENT_BACKEND_URL }}

jobs:
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Configure Payment Backend URL
        run: |
          # Create build-time configuration
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Configure Payment Backend URL
        run: |
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps

  build-web:
    name: Build Web
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Configure Payment Backend URL
        run: |
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build Web
        run: flutter build web --release --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps

  build-windows:
    name: Build Windows
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Configure Payment Backend URL
        shell: bash
        run: |
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build Windows
        run: flutter build windows --release --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps

  build-macos:
    name: Build macOS
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Configure Payment Backend URL
        run: |
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build macOS
        run: flutter build macos --release --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps

  build-linux:
    name: Build Linux
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install Linux Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
      
      - name: Configure Payment Backend URL
        run: |
          mkdir -p lib/config
          cat > lib/config/payment_config.dart << EOF
          class PaymentConfig {
            static const String backendUrl = const String.fromEnvironment(
              'PAYMENT_BACKEND_URL',
              defaultValue: '${{ vars.PAYMENT_BACKEND_URL }}',
            );
          }
          EOF
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Build Linux
        run: flutter build linux --release --dart-define=PAYMENT_BACKEND_URL=${{ vars.PAYMENT_BACKEND_URL }}
      
      # ... rest of your build steps
```

### Option 2: Update Source Code

Alternatively, update the source code to read from the generated config file.

## Flutter Code Changes

### Step 1: Create Payment Config File

Create `lib/config/payment_config.dart`:

```dart
/// Payment backend configuration
/// This file is auto-generated during build by GitHub Actions
/// DO NOT EDIT MANUALLY - Changes will be overwritten
class PaymentConfig {
  /// Backend URL for payment processing
  /// Default is set during build time from PAYMENT_BACKEND_URL environment variable
  static const String backendUrl = String.fromEnvironment(
    'PAYMENT_BACKEND_URL',
    defaultValue: 'http://localhost:3000', // Fallback for local development
  );
  
  /// Check if using production backend
  static bool get isProduction => !backendUrl.contains('localhost');
  
  /// Check if using local backend
  static bool get isLocal => backendUrl.contains('localhost');
}
```

### Step 2: Update Payment Service

Update `lib/services/payment_service.dart`:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../config/payment_config.dart';

class PaymentService {
  // Use backend URL from build-time configuration
  static String get backendUrl => PaymentConfig.backendUrl;
  
  // For debugging
  static void printBackendUrl() {
    debugPrint('Payment Backend URL: $backendUrl');
    debugPrint('Is Production: ${PaymentConfig.isProduction}');
    debugPrint('Is Local: ${PaymentConfig.isLocal}');
  }
  
  // Create order on backend
  Future<Map<String, dynamic>?> createOrder({
    required int amount,
    String currency = 'INR',
  }) async {
    try {
      debugPrint('Creating order with backend: $backendUrl');
      
      final response = await http.post(
        Uri.parse('$backendUrl/api/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }
  
  // Rest of the methods remain the same...
  // Just replace _backendUrl with backendUrl
}
```

### Step 3: Add to .gitignore (Optional)

If you want to ignore the generated config file:

```gitignore
# Auto-generated payment config
lib/config/payment_config.dart
```

But it's better to keep a default version in Git with localhost URL.

## Domain Setup

### Recommended Domain Structure

**Option 1: Subdomain**
```
payment.yourdomain.com    → Payment Backend
app.yourdomain.com        → Flutter Web App
yourdomain.com           → Landing Page
```

**Option 2: API Path**
```
api.yourdomain.com/payment    → Payment Backend
api.yourdomain.com/chat       → Chat API
yourdomain.com               → App
```

**Option 3: Dedicated Domain**
```
payments.xibechat.app    → Payment Backend
xibechat.app            → Main App
```

### DNS Configuration

For subdomain `payment.yourdomain.com`:

```
Type: A
Name: payment
Value: YOUR_VPS_IP
TTL: 3600
```

## Environment-Specific Configuration

### Development

```yaml
vars:
  PAYMENT_BACKEND_URL: http://localhost:3000
```

### Staging

```yaml
vars:
  PAYMENT_BACKEND_URL: https://payment-staging.yourdomain.com
```

### Production

```yaml
vars:
  PAYMENT_BACKEND_URL: https://payment.yourdomain.com
```

## Testing the Configuration

### Local Testing

1. **Run backend locally:**
   ```bash
   cd payment-backend
   npm run dev
   ```

2. **Test with Flutter app:**
   ```bash
   flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000
   ```

3. **For Android emulator:**
   ```bash
   flutter run --dart-define=PAYMENT_BACKEND_URL=http://10.0.2.2:3000
   ```

### Production Testing

1. **After deploying backend to Coolify:**
   ```bash
   # Test health endpoint
   curl https://payment.yourdomain.com/health
   ```

2. **Test with Flutter app:**
   ```bash
   flutter run --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
   ```

3. **Build with production URL:**
   ```bash
   flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
   ```

## Verification Checklist

- [ ] GitHub Actions variable `PAYMENT_BACKEND_URL` is set
- [ ] Variable value starts with `https://` (production)
- [ ] Domain is correctly configured and accessible
- [ ] SSL certificate is valid
- [ ] Backend `/health` endpoint responds with 200
- [ ] GitHub Actions workflow includes backend URL configuration
- [ ] Flutter app builds successfully with the URL
- [ ] Payment flow works end-to-end

## Troubleshooting

### Issue 1: Variable Not Found in GitHub Actions

**Error:** `${{ vars.PAYMENT_BACKEND_URL }}` is empty

**Solutions:**
1. Check variable name is exactly `PAYMENT_BACKEND_URL`
2. Verify variable is set in repository (not organization)
3. Check workflow has access to repository variables
4. Try re-running the workflow

### Issue 2: Wrong URL in Built App

**Symptoms:** App connects to localhost instead of production

**Solutions:**
1. Verify `--dart-define=PAYMENT_BACKEND_URL=...` is in build command
2. Check PaymentConfig.dart is correctly generated
3. Rebuild the app with clean cache: `flutter clean && flutter build`

### Issue 3: CORS Error

**Symptoms:** Browser blocks requests to backend

**Solutions:**
1. Check CORS configuration in `server.js`
2. Verify domain is whitelisted
3. Ensure backend has proper SSL certificate

### Issue 4: Build Fails

**Error:** Cannot create payment_config.dart

**Solutions:**
1. Check workflow syntax
2. Verify directory permissions
3. Check shell/bash is available in runner

## Best Practices

1. **Use HTTPS in Production**
   - Always use `https://` for production
   - Use `http://localhost:3000` for local development only

2. **Separate Environments**
   - Use different domains for dev/staging/prod
   - Set up separate Razorpay keys for each environment

3. **Keep Fallback**
   - Always have a default URL (localhost) for local development
   - Makes development easier

4. **Document Your URLs**
   - Keep a record of all environment URLs
   - Share with team members

5. **Monitor Changes**
   - Log the backend URL in app for debugging
   - Check which URL is being used in production

## Quick Reference

```bash
# Set GitHub Actions variable (via web interface)
Variable Name: PAYMENT_BACKEND_URL
Variable Value: https://payment.yourdomain.com

# Build with specific URL (local testing)
flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000

# Build for Android emulator
flutter run --dart-define=PAYMENT_BACKEND_URL=http://10.0.2.2:3000

# Build for production
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com

# Test backend health
curl https://payment.yourdomain.com/health

# View backend URL in Flutter app
# Add this in your app:
print('Backend URL: ${PaymentConfig.backendUrl}');
```

## Example URLs for Different Scenarios

| Scenario | URL | Usage |
|----------|-----|-------|
| Local Development | `http://localhost:3000` | Running backend locally |
| Android Emulator | `http://10.0.2.2:3000` | Testing on Android emulator |
| Physical Device (same network) | `http://192.168.1.100:3000` | Testing on physical device |
| Staging | `https://payment-staging.yourdomain.com` | Staging environment |
| Production | `https://payment.yourdomain.com` | Live production |

## Your Recommended Setup

Based on your setup with Coolify, here's the recommended configuration:

**GitHub Actions Variable:**
```
PAYMENT_BACKEND_URL = https://payment.xibechat.app
```

Or if using subdomain:
```
PAYMENT_BACKEND_URL = https://api.xibechat.app
```

**DNS Setup:**
```
Type: A
Name: payment (or api)
Value: YOUR_VPS_IP
TTL: 3600
```

**Coolify Domain:**
```
payment.xibechat.app
```

**Flutter App Build:**
```bash
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.xibechat.app
```

---

## Next Steps

1. ✅ Deploy backend to Coolify (see COOLIFY_DEPLOYMENT.md)
2. ✅ Configure domain in Coolify
3. ✅ Set up GitHub Actions variable
4. ✅ Update Flutter app code
5. ✅ Test locally
6. ✅ Build and deploy
7. ✅ Test production payment flow

---

**Last Updated:** January 2024  
**GitHub Actions Variable:** `PAYMENT_BACKEND_URL`  
**Recommended Format:** `https://payment.yourdomain.com`

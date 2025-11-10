# Build Guide

Complete guide to building Xibe Chat from source for all platforms.

## Prerequisites

### Required
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Git**: For cloning the repository

### Platform-Specific

#### Android
- Android Studio or Android SDK
- JDK 11 or higher
- Android SDK Platform 33 or higher

#### iOS (macOS only)
- Xcode 14.0 or higher
- CocoaPods
- macOS 12.0 or higher

#### Windows
- Visual Studio 2022 with C++ development tools
- Windows 10 SDK (10.0.19041.0 or higher)

#### macOS
- Xcode 14.0 or higher
- CocoaPods
- macOS 12.0 or higher

#### Linux
- CMake 3.10 or higher
- GTK 3.0 development libraries
- pkg-config

---

## Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/iotserver24/xibe-chat-app.git
cd xibe-chat-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
```

Fix any issues reported by `flutter doctor`.

---

## Building for Android

### Debug Build

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build (Unsigned)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release Build (Signed)

1. Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

2. Build signed APK:
```bash
flutter build apk --release
```

3. Build signed AAB (for Play Store):
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Building for iOS

### Prerequisites
- macOS with Xcode installed
- Valid Apple Developer account (for release builds)

### Debug Build

```bash
flutter build ios --debug --no-codesign
```

### Release Build (Unsigned)

```bash
flutter build ios --release --no-codesign
```

### Release Build (Signed)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing in Xcode
3. Build from Xcode or:
```bash
flutter build ios --release
```

---

## Building for Windows

### Debug Build

```bash
flutter build windows --debug
```

### Release Build

```bash
flutter build windows --release
```

Output: `build/windows/x64/runner/Release/`

### Build MSIX Package

```bash
flutter build windows --release
msix pack
```

---

## Building for macOS

### Debug Build

```bash
flutter build macos --debug
```

### Release Build

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/`

### Create DMG

Use `create-dmg` or manually create DMG from the app bundle.

---

## Building for Linux

### Debug Build

```bash
flutter build linux --debug
```

### Release Build

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

### Create DEB Package

```bash
cd build/linux/x64/release/bundle
dpkg-deb --build xibe_chat
```

### Create AppImage

Use `linuxdeploy` or `appimagetool`.

---

## Build Scripts

### Manual Build Script

Use the provided script for quick builds:

```bash
# Linux/macOS
./MANUAL_BUILD.sh

# Windows
.\MANUAL_BUILD.ps1
```

---

## Troubleshooting

### Common Issues

1. **Build fails with "Gradle error"**
   - Clean build: `flutter clean`
   - Delete `android/.gradle` folder
   - Rebuild: `flutter pub get && flutter build apk`

2. **iOS build fails**
   - Run `pod install` in `ios/` directory
   - Clean Xcode derived data
   - Rebuild

3. **Windows build fails**
   - Ensure Visual Studio C++ tools are installed
   - Run `flutter doctor` to verify setup

4. **Linux build fails**
   - Install required packages:
     ```bash
     sudo apt-get install libgtk-3-dev
     ```

---

## CI/CD

### GitHub Actions

The repository includes GitHub Actions workflows for automated builds:

- **Android**: APK and AAB builds
- **Windows**: MSIX, NSIS, ZIP packages
- **macOS**: DMG and ZIP packages
- **Linux**: DEB, RPM, AppImage, ZIP packages

See `.github/workflows/` for workflow configurations.

---

## Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [Platform-Specific Build Guides](https://docs.flutter.dev/deployment)


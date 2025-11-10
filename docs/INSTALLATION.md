# Installation Guide

Complete guide to installing and setting up Xibe Chat on all supported platforms.

## Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/xibe-chat.git
cd xibe-chat

# Install dependencies
flutter pub get

# Run on your platform
flutter run
```

## Platform-Specific Installation

### Windows

#### Requirements
- Windows 10 or later (64-bit)
- Visual Studio 2022 or Visual Studio Build Tools
- Flutter SDK

#### Installation
1. Download installer from [Releases](https://github.com/yourusername/xibe-chat/releases)
2. Run `XibeChat-Setup.exe`
3. Follow installation wizard
4. Launch from Start Menu

#### Manual Build
```bash
flutter build windows --release
```

### macOS

#### Requirements
- macOS 10.14 or later
- Xcode 13 or later
- Flutter SDK

#### Installation
1. Download `.dmg` from [Releases](https://github.com/yourusername/xibe-chat/releases)
2. Open DMG file
3. Drag Xibe Chat to Applications
4. Launch from Applications folder

#### Manual Build
```bash
flutter build macos --release
```

### Linux

#### Requirements
- Ubuntu 20.04+ / Fedora 35+ / Debian 11+
- GTK 3.0
- Flutter SDK

#### Installation (Ubuntu/Debian)
```bash
# Download .deb package
wget https://github.com/yourusername/xibe-chat/releases/latest/download/xibe-chat-amd64.deb

# Install
sudo dpkg -i xibe-chat-amd64.deb
sudo apt-get install -f  # Fix dependencies
```

#### Installation (Fedora/RHEL)
```bash
# Download .rpm package
wget https://github.com/yourusername/xibe-chat/releases/latest/download/xibe-chat-x86_64.rpm

# Install
sudo rpm -i xibe-chat-x86_64.rpm
```

#### Manual Build
```bash
flutter build linux --release
```

### Android

#### Requirements
- Android 7.0 (API 24) or later
- ~50 MB free space

#### Installation
1. Download APK from [Releases](https://github.com/yourusername/xibe-chat/releases)
2. Enable "Install from Unknown Sources" in Settings
3. Tap APK file to install
4. Launch app

#### Manual Build
```bash
flutter build apk --release
```

### iOS

#### Requirements
- iOS 12.0 or later
- iPhone, iPad, or iPod touch

#### Installation
1. Download from App Store (Coming Soon)
2. Or use TestFlight for beta testing

#### Manual Build
```bash
flutter build ios --release
```

## Development Setup

### Prerequisites

1. **Flutter SDK** (>= 3.0.0)
   ```bash
   # Check Flutter installation
   flutter doctor
   ```

2. **Dart SDK** (>= 3.0.0)
   - Included with Flutter

3. **IDE** (Choose one)
   - VS Code + Flutter extension
   - Android Studio + Flutter plugin
   - IntelliJ IDEA + Flutter plugin

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/yourusername/xibe-chat.git
   cd xibe-chat
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on Device/Emulator**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   ```

4. **Hot Reload**
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart
   - Press `q` to quit

## Configuration

### Optional: Custom API Keys

Edit provider API keys in the app:
1. Open Settings
2. Navigate to Custom Providers
3. Edit provider
4. Enter your API key
5. Save

### Optional: E2B Backend

For code execution, configure E2B:
1. Get API key from [e2b.dev](https://e2b.dev)
2. Settings → Advanced
3. Enter E2B API key

## Troubleshooting

### Flutter Doctor Issues

```bash
flutter doctor -v
```

Fix common issues:
- Android licenses: `flutter doctor --android-licenses`
- Xcode setup: Install from App Store
- Visual Studio: Install Build Tools

### Build Failures

**Windows**
- Ensure Visual Studio 2022 installed
- Run `flutter clean` then rebuild

**macOS**
- Update Xcode from App Store
- Run `pod install` in ios/ directory

**Linux**
- Install GTK: `sudo apt-get install libgtk-3-dev`
- Install build essentials: `sudo apt-get install build-essential`

### Runtime Issues

**App won't start**
- Check Flutter version: `flutter --version`
- Clear cache: `flutter clean`
- Reinstall dependencies: `flutter pub get`

**Permission errors (Android)**
- Grant storage permission
- Grant camera permission (for image input)

## Updating

### App Updates

Desktop versions have auto-update:
1. Check for updates in Settings
2. Download and install automatically
3. Restart app

Mobile versions:
- Update from App Store/Play Store
- Or download latest APK/IPA

### Development Updates

```bash
git pull origin main
flutter pub get
flutter clean
flutter run
```

## Uninstallation

### Windows
- Settings → Apps → Xibe Chat → Uninstall
- Or use uninstaller in installation directory

### macOS
- Move app to Trash from Applications folder
- Delete: `~/Library/Application Support/xibe_chat`

### Linux
```bash
# Debian/Ubuntu
sudo apt-get remove xibe-chat

# Fedora/RHEL
sudo rpm -e xibe-chat
```

### Android
- Long press app icon → Uninstall
- Or Settings → Apps → Xibe Chat → Uninstall

### iOS
- Long press app icon → Remove App

## Data Location

### Chat History & Settings

- **Windows**: `%APPDATA%\xibe_chat`
- **macOS**: `~/Library/Application Support/xibe_chat`
- **Linux**: `~/.local/share/xibe_chat`
- **Android**: `/data/data/com.xibe.chat`
- **iOS**: App sandbox

## System Requirements

### Minimum

- **RAM**: 2 GB
- **Storage**: 100 MB
- **Internet**: Required for AI responses

### Recommended

- **RAM**: 4 GB or more
- **Storage**: 500 MB
- **Internet**: Broadband connection

## Next Steps

- Read [User Guide](USER_GUIDE.md)
- Configure [Custom Providers](CUSTOM_PROVIDERS.md)
- Explore [Features](FEATURES.md)
- Join community discussions

---

Need help? Check [Troubleshooting](TROUBLESHOOTING.md) or open an [issue](https://github.com/yourusername/xibe-chat/issues).

# Xibe Chat
//copilot made this lol
A modern AI chat application built with Flutter - available on Android, iOS, Windows, macOS, and Linux.

## 🎯 NEW: Android Build Fixed!

The GitHub Actions Android build issue has been fixed! 

**Quick Setup (5 minutes):** See [GITHUB_SECRET_SETUP.md](GITHUB_SECRET_SETUP.md) for GitHub Secrets setup with direct download URLs.

## 🔐 Android Release Signing

The app is now configured for signed Android releases! To build signed APKs/AABs:

- **🚀 GitHub Secrets Setup**: [GITHUB_SECRET_SETUP.md](GITHUB_SECRET_SETUP.md) - **Base64 URL included!**
- **Quick Start**: [QUICK_START.md](QUICK_START.md) - Fix the build in 3 steps!
- **For local builds**: Create `android/key.properties` with your keystore passwords
- **What Changed**: [FIX_SUMMARY.md](FIX_SUMMARY.md) - complete fix documentation
- **Detailed Guide**: [KEYSTORE_BASE64_INSTRUCTIONS.md](KEYSTORE_BASE64_INSTRUCTIONS.md)

**Base64 Direct Link:** https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt

Quick setup script: `./scripts/encode-keystore.sh` (Linux/macOS) or `.\scripts\encode-keystore.ps1` (Windows)

## Features

- 🤖 AI-powered chat interface with Xibe API integration
- 🔄 Real-time streaming responses for live chat
- 🎯 Multiple AI model selection (Gemini, OpenAI, DeepSeek, Mistral, and more)
- 💬 Multiple conversation threads
- 👋 Smart greetings based on time of day
- 🎨 **NEW:** 5 Beautiful themes (Dark, Light, Blue, Purple, Green)
- 🌐 **NEW:** Web search toggle for real-time information
- 🧠 **NEW:** Thinking indicator showing AI reasoning process
- ⚙️ **NEW:** Advanced AI controls (temperature, max tokens, top-p, penalties)
- 💻 **NEW:** E2B code execution sandbox integration
- 🔌 **NEW:** MCP (Model Context Protocol) server support
- 📸 **NEW:** Enhanced image upload with camera and gallery support
- 💰 **NEW:** Razorpay donation integration for supporting development
- 🌙 Multi-theme support with custom color schemes
- 📝 Markdown message rendering
- 💾 Local chat history with SQLite
- 📋 Copy message functionality
- ⚡ Real-time typing indicators
- 🔑 Configurable API key support
- 🎨 Beautiful animations and smooth transitions

> **See [FEATURES.md](FEATURES.md) for detailed feature documentation!**

## Screenshots

Coming soon!

## Installation

### Option 1: Download Pre-built Releases
Download the latest build for your platform from the [Releases](https://github.com/iotserver24/Flutterrrr/releases) page.

**Available Platforms:**
- 📱 **Android**: APK (universal) and AAB (Play Store)
- 💻 **Windows**: 
  - Universal MSIX for Microsoft Store (unsigned, ready for Store submission)
  - NSIS installers (x64, ARM64)
  - Portable ZIP (x64, ARM64)
- 🍎 **macOS**: DMG and ZIP for Intel (x64) and Apple Silicon (ARM64)
- 🐧 **Linux**: All architectures (x64, ARM64, ARMv7)
  - DEB packages (Debian/Ubuntu)
  - RPM packages (Fedora/RHEL)
  - AppImage (universal)
  - ZIP archives (portable)
- 📱 **iOS**: IPA (unsigned, requires signing)

**📖 Documentation:**
- [WORKFLOW_USAGE.md](WORKFLOW_USAGE.md) - Detailed installation instructions
- [MICROSOFT_STORE_SUBMISSION.md](MICROSOFT_STORE_SUBMISSION.md) - Submit to Microsoft Store without a certificate
- [LINUX_MULTI_ARCH_BUILD.md](LINUX_MULTI_ARCH_BUILD.md) - Linux multi-architecture guide

### Option 2: Build from Source
See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed build instructions.

Quick build for Android:
```bash
./MANUAL_BUILD.sh
```

Or build for any platform:
```bash
flutter pub get

# Android
flutter build apk --release

# Windows (on Windows)
flutter build windows --release

# macOS (on macOS)
flutter build macos --release

# Linux (on Linux)
flutter build linux --release

# iOS (on macOS)
flutter build ios --release --no-codesign
```

## Configuration

### API Key Setup

The app uses the Xibe API (https://api.xibe.app) for AI responses. You can configure the API key in two ways:

1. **Through the app settings**:
   - Open the app
   - Navigate to Settings (☰ menu → Settings icon)
   - Enter your Xibe API key in the "API Configuration" section
   - Click the save button

2. **Using environment variable**:
   - Set the `XIBE_API` environment variable with your API key
   - The app will automatically use this key if no key is set in settings

If no API key is configured, the app will attempt to use the default configuration.

### Available AI Models

The app automatically fetches available models from the Xibe API. You can switch between models using the robot icon (🤖) in the top right corner of the chat screen. Available models include:
- Gemini 2.5 Flash Lite
- OpenAI GPT-5 Nano
- DeepSeek V3.1
- Mistral Small 3.2
- Qwen 2.5 Coder
- And many more!

## Building from Source

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android SDK
- Android Studio or VS Code with Flutter extensions

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/iotserver24/Flutterrrr.git
   cd Flutterrrr
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. Build release APK:
   ```bash
   flutter build apk --release
   ```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Tech Stack

- **Framework**: Flutter (cross-platform)
- **State Management**: Provider
- **Local Storage**: SQLite (sqflite + sqflite_common_ffi for desktop)
- **HTTP Client**: http package
- **Markdown Rendering**: flutter_markdown
- **Payment Gateway**: Razorpay (Node.js backend)
- **Platforms**: Android, iOS, Windows, macOS, Linux

## 💰 Support Development

Xibe Chat is free and open source. If you find it useful, you can support its development through in-app donations!

### Donation Feature

- **In-App Donations**: Go to Settings → Support → Donate
- **Payment Methods**: Cards, UPI, Net Banking, Wallets
- **Secure**: Powered by Razorpay
- **Multi-Platform**: Works on all supported platforms

### For Developers

If you want to set up the donation feature in your fork:

**📚 Complete Documentation**: See [DONATION_DOCS_INDEX.md](DONATION_DOCS_INDEX.md) for all available docs

**Quick Links:**
1. **Quick Start**: [DONATION_QUICKSTART.md](DONATION_QUICKSTART.md) - Get started in 5 minutes
2. **Docker/Coolify Deploy**: [payment-backend/COOLIFY_DEPLOYMENT.md](payment-backend/COOLIFY_DEPLOYMENT.md) - Deploy with Docker
3. **GitHub Actions Setup**: [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) - Configure backend URL
4. **Complete Setup**: [DONATION_SETUP.md](DONATION_SETUP.md) - Comprehensive guide
5. **Technical Docs**: [RAZORPAY_INTEGRATION.md](RAZORPAY_INTEGRATION.md) - API reference
6. **FAQ**: [DONATION_FAQ.md](DONATION_FAQ.md) - Common questions and troubleshooting

**GitHub Actions Variable:**
- Variable Name: `PAYMENT_BACKEND_URL`
- Format: `https://payment.yourdomain.com`
- Used for: Configuring backend URL at build time

The donation system includes:
- Node.js backend for secure payment processing (with Dockerfile for easy deployment)
- Razorpay integration for payments
- Support for all major payment methods in India
- Multi-platform support (Android, iOS, Web, Desktop)
- Docker support for deployment with Coolify or any container platform
- GitHub Actions integration for automated builds with custom backend URL

## License

MIT License

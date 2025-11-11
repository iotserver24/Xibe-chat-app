# Xibe Chat

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

**A modern, cross-platform AI chat application built with Flutter**

[Features](#-features) • [Installation](#-installation) • [Documentation](#-documentation) • [Support](#-support-development) • [Contributing](#-contributing)

[![GitHub stars](https://img.shields.io/github/stars/iotserver24/xibe-chat-app?style=social)](https://github.com/iotserver24/xibe-chat-app/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/iotserver24/xibe-chat-app?style=social)](https://github.com/iotserver24/xibe-chat-app/network/members)
[![GitHub issues](https://img.shields.io/github/issues/iotserver24/xibe-chat-app)](https://github.com/iotserver24/xibe-chat-app/issues)
[![GitHub discussions](https://img.shields.io/github/discussions/iotserver24/xibe-chat-app)](https://github.com/iotserver24/xibe-chat-app/discussions)

</div>

---

## ✨ Features

### 🤖 AI Capabilities
- **Multiple AI Models**: Access various models from Xibe, OpenAI, Anthropic, DeepSeek, Mistral, and more
- **Custom Providers**: Add your own API providers with custom endpoints
- **Streaming Responses**: Real-time streaming for faster, interactive conversations
- **Vision Support**: Send images to vision-capable models for analysis
- **AI Profiles**: Pre-built personalities (Socratic Tutor, Creative Writer, Strict Coder, etc.)
- **Custom System Prompts**: Define AI behavior with custom instructions

### 💬 Chat Features
- **Multiple Conversations**: Manage multiple chat threads
- **Persistent Memory**: Long-term memory system across conversations
- **Markdown Support**: Rich text formatting with code highlighting
- **Message History**: Local SQLite database for chat persistence
- **Smart Greetings**: Time-based personalized greetings

### 💻 Code & Development
- **Code Execution (E2B)**: Run Python, JavaScript, TypeScript, Java, R, Bash code in secure sandbox
- **Live Previews (CodeSandbox)**: Preview React, Vue, Angular, Svelte components with live rendering
- **Multi-File Support**: Create complete projects with multiple files in single code blocks

### 🔌 Advanced Features
- **MCP Integration**: Model Context Protocol for tool/resource access
- **Web Search**: Real-time web search integration
- **Deep Links**: Custom URL scheme support
- **Auto Updates**: Automatic update checking

### 🎨 User Experience
- **Material 3 Design**: Modern, beautiful UI
- **Multiple Themes**: Dark, Light, Blue, Purple, Green themes
- **Cross-Platform**: Native experience on all platforms
- **Responsive Layout**: Optimized for mobile, tablet, and desktop

### 💰 Support
- **In-App Donations**: Support development via Razorpay
- **Multiple Payment Methods**: Cards, UPI, Net Banking, Wallets

---

## 📦 Installation

### Download Pre-built Releases

Download the latest build for your platform from the [Releases](https://github.com/iotserver24/xibe-chat-app/releases) page.

**Available Platforms:**
- 📱 **Android**: APK (universal) and AAB (Play Store)
- 💻 **Windows**: MSIX, NSIS installers, Portable ZIP (x64, ARM64)
- 🍎 **macOS**: DMG and ZIP for Intel (x64) and Apple Silicon (ARM64)
- 🐧 **Linux**: DEB, RPM, AppImage, ZIP (x64, ARM64, ARMv7)
- 📱 **iOS**: IPA (requires signing)

### Build from Source

**Prerequisites:**
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Platform-specific tools (Android SDK, Xcode, Visual Studio, etc.)

**Quick Start:**
```bash
# Clone the repository
git clone https://github.com/iotserver24/xibe-chat-app.git
cd xibe-chat-app

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for specific platform
flutter build apk --release          # Android
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
flutter build ios --release          # iOS
```

For detailed build instructions, see [docs/BUILD.md](docs/BUILD.md).

---

## 🚀 Quick Start

1. **Download** the app for your platform from [Releases](https://github.com/iotserver24/xibe-chat-app/releases)
2. **Install** and launch the app
3. **Start chatting** - No API key required for default Xibe models
4. **Configure** your API key in Settings (optional, for custom providers)

---

## 📚 Documentation

Complete documentation is available in the [`docs/`](docs/) folder:

- **[User Guide](docs/USER_GUIDE.md)** - Complete guide to using Xibe Chat
- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Custom Providers](docs/CUSTOM_PROVIDERS.md)** - Add your own AI providers
- **[Build Guide](docs/BUILD.md)** - Building from source
- **[Development Guide](docs/DEVELOPMENT.md)** - Contributing and development
- **[API Reference](docs/API.md)** - API integration documentation
- **[MCP Configuration](docs/MCP.md)** - Model Context Protocol setup
- **[Payment Setup](docs/PAYMENT.md)** - Donation system configuration
- **[E2B Code Execution](docs/E2B.md)** - Running code in secure sandbox
- **[CodeSandbox Preview](docs/CODESANDBOX.md)** - Visual web previews

---

## 🛠️ Tech Stack

- **Framework**: Flutter (cross-platform)
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SQLite (sqflite + sqflite_common_ffi)
- **HTTP Client**: http package
- **Markdown**: flutter_markdown
- **Payment**: Razorpay (Node.js backend)
- **Code Execution**: E2B Sandbox
- **Web Preview**: CodeSandbox

---

## 💰 Support Development

Xibe Chat is **100% free and open source**. If you find it useful, please consider supporting its development!

### Ways to Support

1. **⭐ Star the repository** - Show your appreciation
2. **💰 Donate via in-app** - Settings → Support → Donate
3. **🐛 Report bugs** - [GitHub Issues](https://github.com/iotserver24/xibe-chat-app/issues)
4. **💡 Suggest features** - [GitHub Discussions](https://github.com/iotserver24/xibe-chat-app/discussions)
5. **📢 Share with friends** - Help us grow!

### Donation

Support development through secure in-app donations powered by Razorpay:

- **Payment Methods**: Cards, UPI, Net Banking, Wallets
- **Secure**: Powered by Razorpay
- **Multi-Currency**: INR and USD supported

[![Donate](https://img.shields.io/badge/Donate-Support%20Development-green?style=for-the-badge)](https://github.com/iotserver24/xibe-chat-app)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Links

- **GitHub Repository**: [iotserver24/xibe-chat-app](https://github.com/iotserver24/xibe-chat-app)
- **Issues**: [Report a bug](https://github.com/iotserver24/xibe-chat-app/issues)
- **Discussions**: [Join discussions](https://github.com/iotserver24/xibe-chat-app/discussions)
- **Releases**: [Download latest](https://github.com/iotserver24/xibe-chat-app/releases)

---

## 👨‍💻 Developer

**R3AP3Reditz** (A.K.A Anish Kumar)
- 🌐 Portfolio: [anishkumar.tech](https://anishkumar.tech)
- 💻 GitHub: [@iotserver24](https://github.com/iotserver24)

---

<div align="center">

**Made with ❤️ in India**

[⭐ Star on GitHub](https://github.com/iotserver24/xibe-chat-app) • [🐛 Report Bug](https://github.com/iotserver24/xibe-chat-app/issues) • [💡 Request Feature](https://github.com/iotserver24/xibe-chat-app/discussions)

</div>
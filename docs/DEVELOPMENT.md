# Development Guide

Guide for contributing to Xibe Chat development.

## Getting Started

### Setup Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/xibe-chat-app.git
   cd xibe-chat-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run in Debug Mode**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── providers/       # State management (Provider)
├── screens/         # UI screens
├── services/        # Business logic services
└── widgets/         # Reusable widgets
```

---

## Code Style

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.

### Formatting

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze
```

### Linting

The project uses `analysis_options.yaml` for linting rules. Ensure all code passes:

```bash
flutter analyze
```

---

## Architecture

### State Management

**Provider Pattern**: Used for state management across the app.

- `ChatProvider`: Manages chat state, messages, models
- `SettingsProvider`: Manages app settings, preferences
- `ThemeProvider`: Manages theme state

### Data Flow

```
User Action → Provider → Service → API/DB → Provider → UI Update
```

### Key Services

- `DatabaseService`: SQLite database operations
- `ApiService`: Xibe API communication
- `UpdateService`: App update checking
- `PaymentService`: Razorpay integration
- `McpConfigService`: MCP server configuration

---

## Adding Features

### 1. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Implement Feature

- Follow existing code patterns
- Add tests if applicable
- Update documentation

### 3. Test

```bash
# Run tests
flutter test

# Run app
flutter run
```

### 4. Submit PR

- Write clear PR description
- Reference related issues
- Ensure CI passes

---

## Testing

### Unit Tests

```bash
flutter test test/
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

---

## Database Migrations

When modifying database schema:

1. Update `DatabaseService` version
2. Add migration logic in `_onUpgrade`
3. Test migration with existing data

Example:
```dart
if (oldVersion < 5) {
  await db.execute('ALTER TABLE messages ADD COLUMN response_time INTEGER');
}
```

---

## API Integration

### Adding New Provider

1. Create provider model in `models/custom_provider.dart`
2. Add provider service in `services/`
3. Update UI in `screens/custom_providers_screen.dart`
4. Integrate with `ChatProvider`

### API Key Management

- Never commit API keys
- Use environment variables or settings
- Validate keys before use

---

## Platform-Specific Code

### Platform Detection

```dart
import 'dart:io';

if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
} else if (Platform.isWindows) {
  // Windows-specific code
}
```

### Conditional Imports

```dart
// mobile.dart
export 'mobile_implementation.dart';

// desktop.dart
export 'desktop_implementation.dart';

// main.dart
import 'mobile.dart' if (dart.library.html) 'desktop.dart';
```

---

## Debugging

### Enable Debug Logging

```dart
debugPrint('Debug message');
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Platform-Specific Debugging

- **Android**: Android Studio, `adb logcat`
- **iOS**: Xcode console
- **Windows**: Visual Studio debugger
- **Linux**: GDB, Valgrind

---

## Performance

### Best Practices

1. **Avoid Rebuilds**: Use `const` widgets where possible
2. **Lazy Loading**: Load data on demand
3. **Image Optimization**: Compress images before including
4. **Database Queries**: Use indexes, limit results

### Profiling

```bash
flutter run --profile
```

Use Flutter DevTools Performance tab.

---

## Release Process

### Version Bumping

Update version in `pubspec.yaml`:
```yaml
version: 1.0.3+3  # version+build_number
```

### Changelog

Update `CHANGELOG.md` with changes.

### Release Checklist

- [ ] Update version
- [ ] Update changelog
- [ ] Run tests
- [ ] Build for all platforms
- [ ] Create GitHub release
- [ ] Tag release

---

## Contributing Guidelines

### Pull Request Process

1. Fork the repository
2. Create feature branch
3. Make changes
4. Write/update tests
5. Update documentation
6. Submit PR with clear description

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Code formatting
refactor: Code refactoring
test: Add tests
chore: Maintenance tasks
```

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/iotserver24/xibe-chat-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/iotserver24/xibe-chat-app/discussions)
- **Documentation**: See `docs/` folder


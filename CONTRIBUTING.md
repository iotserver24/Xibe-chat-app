# Contributing to Xibe Chat

Thank you for your interest in contributing to Xibe Chat! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/xibe-chat-app.git
   cd xibe-chat-app
   ```
3. **Install Flutter** (if not already installed)
   - Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)
4. **Install dependencies**
   ```bash
   flutter pub get
   ```
5. **Create a branch** for your changes
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Running the App

```bash
# Run in debug mode
flutter run

# Run with hot reload
flutter run --hot
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/path/to/test.dart
```

### Code Quality

Before submitting a PR, ensure your code passes all checks:

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── chat.dart
│   └── message.dart
├── providers/             # State management
│   ├── chat_provider.dart
│   └── theme_provider.dart
├── screens/               # UI screens
│   ├── chat_screen.dart
│   └── settings_screen.dart
├── services/              # Business logic & API
│   ├── api_service.dart
│   └── database_service.dart
└── widgets/               # Reusable UI components
    ├── chat_drawer.dart
    ├── chat_input.dart
    ├── message_bubble.dart
    └── typing_indicator.dart
```

## Code Style

### Dart Style Guide

Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style):

- Use `const` constructors where possible
- Prefer `final` over `var` when the variable won't be reassigned
- Use trailing commas for better formatting
- Keep functions small and focused

### Example

```dart
// Good
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(title),
    );
  }
}
```

## Adding Features

### New Screen

1. Create screen file in `lib/screens/`
2. Use stateless or stateful widget as appropriate
3. Connect to providers using `Consumer` or `Provider.of`
4. Add navigation in appropriate place

### New Widget

1. Create widget file in `lib/widgets/`
2. Make it reusable and customizable
3. Document parameters clearly
4. Use const constructors where possible

### New Model

1. Create model file in `lib/models/`
2. Include `toMap()` and `fromMap()` methods for database
3. Include `toJson()` and `fromJson()` if needed for API

### New Service

1. Create service file in `lib/services/`
2. Keep services focused on a single responsibility
3. Handle errors gracefully
4. Add documentation

## API Changes

If you modify the API integration:

1. Update `lib/services/api_service.dart`
2. Document the expected request/response format
3. Add error handling
4. Update README if the API endpoint changes

## Database Changes

If you modify the database schema:

1. Update `lib/services/database_service.dart`
2. Increment the database version
3. Add migration logic in `onCreate` or `onUpgrade`
4. Test migrations thoroughly

## UI/UX Guidelines

### Theme

- Use colors defined in `ThemeProvider`
- Dark mode is the default
- Ensure good contrast for readability

### Dark Mode Colors

- Background: `#0D0D0D`
- Surface: `#1A1A1A`
- User bubble: `#2563EB`
- AI bubble: `#1F1F1F`
- Primary: `#3B82F6`

### Accessibility

- Provide sufficient color contrast
- Use semantic widgets
- Support screen readers
- Add meaningful labels

## Submitting Changes

### Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure all tests pass**
   ```bash
   flutter test
   flutter analyze
   ```
4. **Format your code**
   ```bash
   flutter format .
   ```
5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request** from your fork to the main repository

### Commit Message Format

Use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Example:
```
feat: add voice input support to chat interface
fix: resolve message timestamp display issue
docs: update API configuration instructions
```

## Reporting Issues

When reporting issues, please include:

1. **Description** of the issue
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Screenshots** (if applicable)
6. **Environment**:
   - Flutter version
   - Android version
   - Device model

## Questions?

If you have questions about contributing, feel free to:

- Open an issue for discussion
- Check existing issues and PRs
- Review the code and documentation

Thank you for contributing! 🎉

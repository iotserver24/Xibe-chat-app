# Auto-Update Feature Guide

## Overview
The Xibe Chat app now includes an automatic update system that checks for new releases from GitHub and allows users to download and install updates seamlessly.

## Features

### For Users

#### Automatic Update Checks
- The app automatically checks for updates when it starts
- Update check happens after the splash screen (after ~3 seconds)
- Non-intrusive - silently fails if network is unavailable
- Only shows notification if an update is available

#### Manual Update Check
- Users can manually check for updates from Settings → About → "Check for Updates"
- Displays current version information
- Shows "You are using the latest version!" if no updates are available

#### Update Dialog
- Beautiful dialog showing:
  - New version number
  - Release type badge (Beta/Stable)
  - Full release notes with markdown rendering
  - Download and installation options
- Options:
  - **Update Now**: Downloads and opens the installer
  - **Later**: Dismisses the dialog (user can check again later)

#### Platform-Specific Installation
- **Windows**: Downloads NSIS installer (.exe) or MSIX package
- **macOS**: Downloads DMG installer (auto-detects Intel/Apple Silicon)
- **Linux**: Downloads AppImage, DEB, or TAR.GZ
- **Android**: Opens download link in browser for APK
- **iOS**: Opens download link for IPA

### For Developers

#### Workflow Configuration

The GitHub Actions workflow now supports three release types:

##### Draft Release
```yaml
release_type: draft
```
- Used for testing builds
- Not published publicly (draft flag set to true)
- Not visible to users' auto-update checks
- Only accessible to repository maintainers

##### Beta Release
```yaml
release_type: beta
```
- Pre-release version for beta testing
- Marked as prerelease in GitHub
- Visible to all users
- Shows "Beta Version" badge in update dialog
- Users can opt to install beta versions

##### Latest Release
```yaml
release_type: latest
```
- Stable production release
- Default for auto-update system
- No special badges
- Recommended for all users

#### Running the Workflow

1. Go to GitHub Actions → "Multi-Platform Build and Release"
2. Click "Run workflow"
3. Enter:
   - **Version**: Semantic version (e.g., `1.0.4`)
   - **Build Number**: Incremental build number (e.g., `1`)
   - **Release Type**: Choose from `draft`, `beta`, or `latest`
4. Click "Run workflow"

Example release tags:
- Draft: `v1.0.4-1` (draft: true)
- Beta: `v1.0.4-1` (prerelease: true)
- Latest: `v1.0.4-1` (normal release)

## Implementation Details

### Update Service (`lib/services/update_service.dart`)
- Fetches releases from GitHub API
- Compares current version with latest release
- Filters out draft releases from auto-update
- Platform detection for appropriate download URLs
- Version parsing and comparison logic

### Update Dialog (`lib/widgets/update_dialog.dart`)
- Material Design 3 dialog
- Markdown rendering for release notes
- Download progress indicator
- Error handling and user feedback
- Beta version warning badge

### Main App Integration (`lib/main.dart`)
- Startup update check in `SplashWrapper`
- Non-blocking asynchronous check
- Silent failure on errors

### Settings Integration (`lib/screens/settings_screen.dart`)
- Manual update check button
- Loading indicator during check
- Success/error feedback via SnackBar

## Version Comparison Logic

The app compares versions using semantic versioning:
1. Parse version string (e.g., `1.0.3` from tag `v1.0.3-3`)
2. Parse build number (e.g., `3` from tag `v1.0.3-3`)
3. Compare major.minor.patch versions
4. If versions are equal, compare build numbers
5. Update available if new version > current version

## Security Considerations

- Uses official GitHub API
- HTTPS for all downloads
- No sensitive data transmitted
- User has full control over when to update
- Can dismiss update notifications
- Downloads are verified by the operating system

## Testing

### Testing Auto-Update
1. Build the app with version `1.0.0`
2. Create a release `v1.0.1-1` with `release_type: latest`
3. Run the app
4. Should see update dialog after splash screen

### Testing Manual Update Check
1. Go to Settings → About
2. Click "Check for Updates"
3. Should show update dialog or "latest version" message

### Testing Release Types
1. Create a draft release → Should NOT appear in auto-update
2. Create a beta release → Should appear with Beta badge
3. Create a latest release → Should appear as normal update

## Troubleshooting

### Update check fails
- Check internet connection
- Verify GitHub API is accessible
- Check GitHub API rate limits (60 requests/hour unauthenticated)

### Download fails
- Check internet connection
- Verify download URL is valid
- Check file permissions
- Try manual download from GitHub releases page

### Wrong version detected
- Check version in `pubspec.yaml`
- Ensure version follows format: `major.minor.patch+buildNumber`
- Verify build was done with correct version

## Future Enhancements

Possible improvements:
- Download progress indicator
- Background download support
- Auto-install on some platforms
- Delta updates for smaller downloads
- Changelog viewing in-app
- Update scheduling
- Update rollback mechanism

# Code Preview Improvements

## Overview
Fixed the code execution preview system to provide better UX on desktop platforms and added external browser opening capability.

## Changes Made

### 1. Split-View for Desktop (New Feature)
- **File Created**: `lib/screens/split_view_preview_screen.dart`
- **Functionality**: 
  - On desktop platforms with screen width > 1000px, the code preview now opens in a split-view layout
  - Left half: Shows the chat interface (ChatScreen)
  - Right half: Shows the CodeSandbox preview
  - This allows users to continue interacting with the chat while viewing the preview
  - Fixes the blank page issue on Windows by properly initializing the WebView

### 2. Open External Button (New Feature)
- **Files Modified**: 
  - `lib/screens/codesandbox_preview_screen.dart`
  - `lib/screens/split_view_preview_screen.dart`
- **Functionality**:
  - Added "Open in Browser" button next to the close (X) button
  - Opens the CodeSandbox URL in the system's default browser
  - Uses `url_launcher` package with `LaunchMode.externalApplication`
  - Provides user feedback on success/failure

### 3. Enhanced CodeSandbox Preview Screen
- **File Modified**: `lib/screens/codesandbox_preview_screen.dart`
- **Changes**:
  - Added `previewUrl` parameter to pass the actual CodeSandbox URL (not just embed URL)
  - Added `_openInBrowser()` method for external browser launching
  - Updated header layout to include the new "Open in Browser" button
  - Added tooltips for better UX ("Open in Browser", "Close Preview")

### 4. Smart Preview Navigation
- **File Modified**: `lib/widgets/code_block.dart`
- **Changes**:
  - Updated `_runPreview()` method to detect screen size and platform
  - Desktop with width > 1000px: Uses `SplitViewPreviewScreen`
  - Mobile or narrow desktop: Uses `CodeSandboxPreviewScreen` (fullscreen modal)
  - Both modes now pass the `previewUrl` for external browser opening

## Technical Details

### Split-View Implementation
- Uses a `Row` widget with two `Expanded` children (flex: 1 each)
- Left side: Creates a new instance of `ChatScreen` with shared Provider state
- Right side: Shows preview with header controls
- Divider between panels for visual separation

### WebView Initialization
- Proper error handling with `onWebResourceError`
- Loading states managed with mounted checks
- JavaScript enabled for CodeSandbox functionality
- Delayed URL loading to ensure WebView is ready (fixes blank page issue)

### Platform Detection
```dart
final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
final screenWidth = MediaQuery.of(context).size.width;
final useSplitView = isDesktop && screenWidth > 1000;
```

## User Experience

### Desktop (Width > 1000px)
1. User clicks "Run Preview" on a code block
2. Preview opens in split-view mode
3. Chat remains accessible on the left
4. Preview shows on the right with controls
5. User can click "Open in Browser" to view in external browser
6. Click X or back button to close split-view

### Mobile / Narrow Desktop
1. User clicks "Run Preview" on a code block
2. Preview opens as fullscreen modal
3. Drag handle for easy dismissal (mobile only)
4. "Open in Browser" button available in header
5. Click X or drag down to close

## Benefits
- ✅ Fixes blank page issue on Windows
- ✅ Better multitasking on desktop (chat + preview simultaneously)
- ✅ External browser option for full-featured testing
- ✅ Maintains mobile-friendly fullscreen mode
- ✅ Consistent UI across all platforms
- ✅ Improved accessibility with tooltips

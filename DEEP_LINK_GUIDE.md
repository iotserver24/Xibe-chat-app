# Deep Link Implementation Guide

This document explains how deep linking works in Xibe Chat and how to use it.

## Overview

Xibe Chat supports deep linking through both custom URI schemes and HTTPS URLs. This allows users to:
- Open the app from web links
- Launch the app with pre-filled messages
- Navigate directly to specific app sections
- Share workflows and prompts via URLs

## Supported Deep Links

### Custom URI Scheme: `xibechat://`

The app registers a custom URI scheme that works across all platforms:

1. **New Chat**
   - `xibechat://new` - Opens a new chat

2. **Message with Prompt**
   - `xibechat://mes/{prompt}` - Opens a new chat with the prompt pre-filled
   - Example: `xibechat://mes/Tell%20me%20a%20joke`

3. **Settings**
   - `xibechat://settings` - Opens the settings screen

4. **Specific Chat** (future enhancement)
   - `xibechat://chat/{chatId}` - Opens a specific chat by ID

### HTTPS URLs: `https://xibechat.app/app/`

When hosted, the website can redirect to the app:

1. **New Chat**
   - `https://xibechat.app/app/new`
   - `https://xibechat.app/app`

2. **Message with Prompt**
   - `https://xibechat.app/app/mes/{prompt}`
   - Example: `https://xibechat.app/app/mes/What%20is%20AI?`

3. **Settings**
   - `https://xibechat.app/app/settings`

## Platform Support

### Android

Deep links are configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Custom URI scheme -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="xibechat"/>
</intent-filter>

<!-- HTTPS deep links -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="http"/>
    <data android:scheme="https"/>
    <data android:host="xibechat.app"/>
    <data android:pathPrefix="/app"/>
</intent-filter>
```

### iOS (To be implemented)

For iOS support, add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>xibechat</string>
        </array>
        <key>CFBundleURLName</key>
        <string>app.xibechat</string>
    </dict>
</array>

<!-- For Universal Links (HTTPS) -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:xibechat.app</string>
</array>
```

### Windows & Linux

Deep links work automatically through the `uni_links` and `app_links` packages on desktop platforms.

## Website Integration

The Nuxt.js website in the `/site` folder provides:

1. **Landing Page** (`/`)
   - Showcases app features
   - Download links
   - Deep link examples

2. **Deep Link Redirect Pages**
   - `/app/new` - Redirects to app for new chat
   - `/app/mes/[prompt]` - Redirects with pre-filled message
   - `/app/settings` - Redirects to settings

3. **Auto-Redirect**
   - Pages automatically attempt to open the app
   - Falls back to showing instructions if app isn't installed

## Technical Implementation

### Deep Link Service

The `DeepLinkService` class (`lib/services/deep_link_service.dart`) handles:
- Listening for incoming deep links
- Parsing deep link URIs
- Extracting parameters (prompts, chat IDs, etc.)
- Providing callbacks for deep link events

### Main App Integration

In `lib/main.dart`, the `SplashWrapper` widget:
- Initializes deep link handling on app start
- Processes initial deep links (when app is opened from a link)
- Handles deep links while app is running
- Creates new chats with pending prompts

### Chat Provider

The `ChatProvider` includes:
- `setPendingPrompt(String)` - Sets a prompt to be displayed in chat input
- `clearPendingPrompt()` - Clears the pending prompt after use
- `pendingPrompt` getter - Retrieves current pending prompt

### Chat Input

The `ChatInput` widget:
- Accepts an `initialText` parameter
- Pre-fills the text field when a pending prompt exists
- Allows users to edit or send the prompt

## App Behavior

### Always Open to New Chat

Per requirements, the app:
1. Does NOT auto-select any existing chat on startup
2. Always opens with a new chat state
3. Avoids duplicating chats
4. Allows deep links to create chats with prompts

### Optional AI Profiles

Users can now:
- Select "None" to use model defaults (no profile required)
- Choose specific profiles if desired
- Each AI model uses its own system prompt by default

## Testing Deep Links

### From Command Line (Android)

```bash
# Test custom URI scheme
adb shell am start -a android.intent.action.VIEW -d "xibechat://mes/Hello%20World"

# Test HTTPS URL
adb shell am start -a android.intent.action.VIEW -d "https://xibechat.app/app/mes/Hello%20World"
```

### From Web Browser

Simply click a deep link in a web page or enter it in the address bar:
- `xibechat://mes/Tell%20me%20a%20joke`
- `https://xibechat.app/app/mes/Tell%20me%20a%20joke`

### Programmatically

```dart
import 'package:url_launcher/url_launcher.dart';

final uri = Uri.parse('xibechat://mes/Hello%20World');
if (await canLaunchUrl(uri)) {
  await launchUrl(uri);
}
```

## Website Deployment

To deploy the website:

```bash
cd site
npm install
npm run generate
```

The static site will be in `.output/public` and can be deployed to:
- Vercel
- Netlify
- GitHub Pages
- Any static hosting provider

For the HTTPS deep links to work, the site should be hosted at `xibechat.app`.

## Security Considerations

1. **URL Validation**: All deep link URLs are parsed and validated
2. **Encoded Parameters**: Prompts are URL-encoded to prevent injection
3. **Scheme Verification**: Only registered schemes are accepted
4. **Domain Verification**: Android App Links require domain verification

## Future Enhancements

- [ ] Add support for opening specific chats by ID
- [ ] Implement sharing functionality (share chat via deep link)
- [ ] Add support for deep linking to AI profiles
- [ ] Support for authenticated deep links
- [ ] Analytics for deep link usage

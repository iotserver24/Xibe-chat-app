# Deep Link Quick Start Guide

Get started with Xibe Chat deep links in 5 minutes!

## For End Users

### Using Deep Links

Simply click any of these links (with app installed):

1. **Start a new chat:**
   - `xibechat://new`
   - Or visit: `https://xibechat.app/app/new`

2. **Send a quick message:**
   - `xibechat://mes/What is quantum computing?`
   - Or visit: `https://xibechat.app/app/mes/What%20is%20quantum%20computing?`

3. **Open settings:**
   - `xibechat://settings`
   - Or visit: `https://xibechat.app/app/settings`

### Creating Your Own Deep Links

Format: `xibechat://mes/YOUR_MESSAGE_HERE`

**Example:**
```
xibechat://mes/Explain React hooks in simple terms
```

**From a website:**
```html
<a href="xibechat://mes/Hello%20World">Open in Xibe Chat</a>
```

**Pro tip:** URL-encode spaces and special characters:
- Space → `%20`
- ? → `%3F`
- & → `%26`

## For Developers

### Testing Deep Links (Android)

```bash
# Install the app first
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk

# Test custom URI scheme
adb shell am start -a android.intent.action.VIEW \
  -d "xibechat://mes/Hello%20from%20terminal"

# Test HTTPS deep link (when deployed)
adb shell am start -a android.intent.action.VIEW \
  -d "https://xibechat.app/app/mes/Hello%20World"

# Test settings
adb shell am start -a android.intent.action.VIEW \
  -d "xibechat://settings"
```

### Testing the Website Locally

```bash
cd site
npm install
npm run dev
```

Visit http://localhost:3000 and test the deep link buttons.

### Integrating Deep Links in Your App

**1. Launch from Dart code:**
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openXibeChatWithPrompt(String prompt) async {
  final uri = Uri.parse('xibechat://mes/${Uri.encodeComponent(prompt)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// Usage
await openXibeChatWithPrompt('Tell me about Flutter');
```

**2. Launch from JavaScript:**
```javascript
function openXibeChat(prompt) {
  const encodedPrompt = encodeURIComponent(prompt);
  window.location.href = `xibechat://mes/${encodedPrompt}`;
}

// Usage
openXibeChat('What is machine learning?');
```

**3. Launch from Python:**
```python
import webbrowser
import urllib.parse

def open_xibe_chat(prompt):
    encoded = urllib.parse.quote(prompt)
    webbrowser.open(f'xibechat://mes/{encoded}')

# Usage
open_xibe_chat('Explain neural networks')
```

### Creating QR Codes for Deep Links

```python
import qrcode

# Create QR code for a deep link
prompt = "What is artificial intelligence?"
deep_link = f"xibechat://mes/{prompt}"

qr = qrcode.make(deep_link)
qr.save("xibe_chat_qr.png")
```

Scan the QR code with your phone to open the app with the prompt!

## Common Use Cases

### 1. Documentation Links
Add deep links in your documentation to let users ask AI about topics:

```markdown
Learn more about [API authentication](xibechat://mes/Explain%20API%20authentication)
```

### 2. Email Templates
Include helpful prompts in email signatures:

```html
<a href="xibechat://mes/Help%20me%20draft%20a%20response">
  Get AI writing help
</a>
```

### 3. Bookmarklets
Create browser bookmarks that send selected text to Xibe Chat:

```javascript
javascript:(function(){
  const text = window.getSelection().toString();
  window.location.href = 'xibechat://mes/' + encodeURIComponent(text);
})();
```

### 4. Workflow Automation
Use with automation tools like Tasker (Android) or Shortcuts (iOS):

```
When: User says "Ask AI about X"
Action: Open URL "xibechat://mes/X"
```

### 5. Smart Home Integration
Trigger AI conversations from smart home devices:

```yaml
# Home Assistant example
service: shell_command.open_xibe_chat
data:
  prompt: "What's the weather like today?"
```

## Troubleshooting

### Deep link not working?

1. **Check app installation:**
   ```bash
   adb shell pm list packages | grep xibe
   ```

2. **Verify intent filters (Android):**
   ```bash
   adb shell dumpsys package xibe_chat | grep -A5 "intent-filter"
   ```

3. **Test with simple link:**
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "xibechat://new"
   ```

### App not opening from web?

1. Make sure the app is installed
2. Check if the browser blocks app launches
3. Try the custom URI scheme instead of HTTPS
4. On iOS, ensure Info.plist is configured

### Message not appearing?

1. Check URL encoding of special characters
2. Verify the prompt format: `xibechat://mes/YOUR_MESSAGE`
3. Look at app logs for errors

## Advanced Features

### Deep Link Analytics

Track deep link usage in your app:

```dart
// In DeepLinkService
void _handleDeepLink(Uri uri) {
  // Log analytics
  analytics.logEvent('deep_link_opened', {
    'scheme': uri.scheme,
    'path': uri.path,
    'type': _parseDeepLink(uri)?.type.toString(),
  });
  
  // Continue with normal handling...
}
```

### Custom Deep Link Types

Extend the DeepLinkService to support custom actions:

```dart
// Add to DeepLinkType enum
enum DeepLinkType {
  newChat,
  message,
  settings,
  profile,      // New: Open specific AI profile
  share,        // New: Share chat
  import,       // New: Import conversation
}

// Add parsing logic
DeepLinkData? _parseCustomScheme(Uri uri) {
  // xibechat://profile/{profileId}
  if (path.startsWith('profile/')) {
    return DeepLinkData(
      type: DeepLinkType.profile,
      profileId: path.substring(8),
    );
  }
  // ... existing code
}
```

## Security Best Practices

1. **Always validate input:**
   ```dart
   if (prompt.length > 1000) {
     throw Exception('Prompt too long');
   }
   ```

2. **Sanitize URLs:**
   ```dart
   final sanitized = Uri.encodeComponent(userInput);
   ```

3. **Check deep link origin:**
   ```dart
   if (!allowedHosts.contains(uri.host)) {
     return; // Reject untrusted sources
   }
   ```

4. **Rate limit deep links:**
   ```dart
   if (lastDeepLinkTime.difference(now) < Duration(seconds: 1)) {
     return; // Too many requests
   }
   ```

## Resources

- Full Documentation: `DEEP_LINK_GUIDE.md`
- Implementation Details: `IMPLEMENTATION_SUMMARY_DEEPLINKS.md`
- Website Source: `site/`
- Service Code: `lib/services/deep_link_service.dart`

## Support

Need help? 
- Check the issues on GitHub
- Read the full documentation
- Test with the provided examples

Happy deep linking! 🚀

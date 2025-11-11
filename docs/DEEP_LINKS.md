# Deep Links Guide

Xibe Chat supports deep links that allow websites to open the app with pre-filled messages or navigate to specific screens.

## Supported Deep Link Formats

### 1. Custom Scheme (xibechat://)

#### Open New Chat with Pre-filled Message (Query Parameter - Recommended)
```
xibechat://new?message=Hello%20World
xibechat://new?text=Your%20message%20here
xibechat://new?prompt=Ask%20me%20anything
```

#### Open New Chat with Pre-filled Message (Path-based)
```
xibechat://mes/Hello%20World
xibechat://mes/Your%20message%20here
```

#### Open New Chat (Empty)
```
xibechat://new
xibechat://
```

#### Open Settings
```
xibechat://settings
```

#### Open Specific Chat
```
xibechat://chat/123
```

### 2. HTTPS Scheme (https://chat.xibe.app/app/...)

#### Open New Chat with Pre-filled Message (Query Parameter - Recommended)
```
https://chat.xibe.app/app/new?message=Hello%20World
https://chat.xibe.app/app/new?text=Your%20message%20here
https://chat.xibe.app/app/new?prompt=Ask%20me%20anything
https://chat.xibe.app/app?message=Hello%20World
```

#### Open New Chat with Pre-filled Message (Path-based)
```
https://chat.xibe.app/app/mes/Hello%20World
```

#### Open New Chat (Empty)
```
https://chat.xibe.app/app/new
https://chat.xibe.app/app
```

#### Open Settings
```
https://chat.xibe.app/app/settings
```

#### Open Specific Chat
```
https://chat.xibe.app/app/chat/123
```

## Website Button Examples

### HTML Button Examples

#### Simple Button with Custom Scheme
```html
<!-- Open new chat with pre-filled message -->
<a href="xibechat://new?message=Hello%20World" 
   class="btn btn-primary">
  Open in Xibe Chat
</a>

<!-- Open new chat (empty) -->
<a href="xibechat://new" 
   class="btn btn-secondary">
  Start New Chat
</a>
```

#### Button with HTTPS Fallback
```html
<!-- Recommended: Works on all platforms -->
<a href="https://chat.xibe.app/app/new?message=Hello%20World" 
   class="btn btn-primary"
   onclick="window.location.href = 'xibechat://new?message=Hello%20World'; return false;">
  Open in Xibe Chat
</a>
```

#### JavaScript Function for Better Cross-Platform Support
```html
<script>
function openXibeChat(message) {
  const encodedMessage = encodeURIComponent(message);
  
  // Try custom scheme first
  const customScheme = `xibechat://new?message=${encodedMessage}`;
  
  // Fallback to HTTPS
  const httpsLink = `https://chat.xibe.app/app/new?message=${encodedMessage}`;
  
  // Try to open custom scheme
  window.location.href = customScheme;
  
  // Fallback after a short delay if app doesn't open
  setTimeout(() => {
    window.location.href = httpsLink;
  }, 500);
}
</script>

<button onclick="openXibeChat('Hello World')" class="btn">
  Open in Xibe Chat
</button>
```

### React/Vue Component Examples

#### React Component
```jsx
function XibeChatButton({ message, children }) {
  const handleClick = () => {
    const encodedMessage = encodeURIComponent(message || '');
    const customScheme = `xibechat://new?message=${encodedMessage}`;
    const httpsLink = `https://chat.xibe.app/app/new?message=${encodedMessage}`;
    
    // Try custom scheme
    window.location.href = customScheme;
    
    // Fallback to HTTPS
    setTimeout(() => {
      window.location.href = httpsLink;
    }, 500);
  };
  
  return (
    <button onClick={handleClick} className="xibe-chat-button">
      {children || 'Open in Xibe Chat'}
    </button>
  );
}

// Usage
<XibeChatButton message="Hello World">
  Chat with AI
</XibeChatButton>
```

#### Vue Component
```vue
<template>
  <button @click="openChat" class="xibe-chat-button">
    {{ label || 'Open in Xibe Chat' }}
  </button>
</template>

<script>
export default {
  props: {
    message: {
      type: String,
      default: ''
    },
    label: {
      type: String,
      default: ''
    }
  },
  methods: {
    openChat() {
      const encodedMessage = encodeURIComponent(this.message || '');
      const customScheme = `xibechat://new?message=${encodedMessage}`;
      const httpsLink = `https://chat.xibe.app/app/new?message=${encodedMessage}`;
      
      // Try custom scheme
      window.location.href = customScheme;
      
      // Fallback to HTTPS
      setTimeout(() => {
        window.location.href = httpsLink;
      }, 500);
    }
  }
}
</script>
```

## URL Encoding

Always URL-encode your messages to handle special characters properly:

```javascript
// JavaScript
const message = "Hello World! How are you?";
const encoded = encodeURIComponent(message);
// Result: "Hello%20World%21%20How%20are%20you%3F"

// Example URLs
const url1 = `xibechat://new?message=${encoded}`;
const url2 = `https://chat.xibe.app/app/new?message=${encoded}`;
```

## Query Parameter Names

The following query parameter names are supported (checked in order):
1. `message` (recommended)
2. `text`
3. `prompt`

Example:
```
xibechat://new?message=Hello
xibechat://new?text=Hello
xibechat://new?prompt=Hello
```

All three will work the same way.

## Platform Support

Deep links work on all platforms:
- ✅ Android (APK/AAB)
- ✅ Windows (MSIX/NSIS/ZIP)
- ✅ macOS (DMG/ZIP)
- ✅ Linux (DEB/RPM/AppImage/ZIP)
- ✅ iOS (IPA)

## Best Practices

1. **Use Query Parameters**: Prefer `?message=` over path-based URLs for easier integration
2. **URL Encode**: Always encode your messages to handle special characters
3. **Provide Fallback**: Use HTTPS links as fallback for better cross-platform support
4. **User Experience**: Show a loading state or message when opening the app
5. **Error Handling**: Handle cases where the app might not be installed

## Example Use Cases

### 1. "Ask AI" Button on Blog Posts
```html
<button onclick="openXibeChat('Explain this article: [Article Title]')">
  Ask AI About This
</button>
```

### 2. Support Chat Button
```html
<a href="xibechat://new?message=I%20need%20help%20with...">
  Get Support
</a>
```

### 3. Product Inquiry Button
```html
<a href="https://chat.xibe.app/app/new?message=Tell%20me%20about%20Product%20X">
  Ask About Product X
</a>
```

## Testing

To test deep links:

1. **Desktop (Windows/macOS/Linux)**:
   - Open terminal/command prompt
   - Run: `xibechat://new?message=Test` (if protocol is registered)
   - Or use browser: Navigate to `https://chat.xibe.app/app/new?message=Test`

2. **Mobile (Android/iOS)**:
   - Use ADB (Android): `adb shell am start -W -a android.intent.action.VIEW -d "xibechat://new?message=Test"`
   - Use browser: Navigate to `https://chat.xibe.app/app/new?message=Test`

3. **Browser Testing**:
   - Simply navigate to the HTTPS URL in your browser
   - The app should open if installed, or redirect to download page

## Troubleshooting

### Deep link not working?
1. Ensure the app is installed
2. Check that the URL is properly encoded
3. Try the HTTPS fallback URL
4. Verify the app has proper permissions (especially on mobile)

### Message not appearing?
1. Check URL encoding
2. Verify the query parameter name (`message`, `text`, or `prompt`)
3. Ensure the app has finished loading before the deep link is processed


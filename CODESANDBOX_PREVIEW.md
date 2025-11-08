# CodeSandbox Preview Integration

This document describes the CodeSandbox preview functionality integrated into Xibe Chat.

## Overview

Users can ask the AI to generate single-page UI code (React, Vue, Svelte, etc.), and the app will automatically detect previewable code and show a "Run Preview" button. Clicking the button opens an embedded CodeSandbox preview in a WebView with Telegram-style swipe-to-dismiss functionality.

## Features

✨ **Automatic Detection**: AI wraps previewable code in `<codesandbox>` tags
🎨 **Framework Support**: React, Vue, Angular, Svelte, HTML/CSS/JS, and more
🚀 **One-Click Preview**: Beautiful "Run Preview" button in chat messages
📱 **Native WebView**: Embedded preview with swipe-to-dismiss gesture
🔄 **Smart Parsing**: Automatically structures code files for each framework

## Architecture

### Components

1. **Node.js Proxy Server** (`/codesandbox-proxy/`)
   - Express server that proxies requests to CodeSandbox API
   - Handles rate limiting and errors
   - No API key required for basic previews

2. **CodeSandbox Service** (`lib/services/codesandbox_service.dart`)
   - Detects `<codesandbox>` tags in AI responses
   - Extracts and parses code
   - Auto-detects frameworks
   - Creates appropriate file structure
   - Calls proxy server to create sandbox

3. **Preview Screen** (`lib/screens/codesandbox_preview_screen.dart`)
   - Full-screen WebView with custom app bar
   - Drag handle and swipe-to-dismiss gesture
   - Framework badge and close button
   - Loading indicator

4. **Message Bubble Integration** (`lib/widgets/message_bubble.dart`)
   - Detects previewable code
   - Shows "Run Preview" button
   - Handles preview creation and navigation

## Usage

### For Users

1. Ask the AI to create a single-page app:
   ```
   "Create a React todo app with Tailwind CSS"
   "Make a Vue.js calculator"
   "Build a simple HTML/CSS landing page"
   ```

2. The AI will wrap the code in `<codesandbox>` tags

3. A green "Run Preview" button appears below the code

4. Click to see the live preview

5. Swipe down or tap X to close

### For Developers

#### Starting the Proxy Server

```bash
cd codesandbox-proxy
npm install
npm start
```

The server runs on `http://localhost:3000` by default.

#### Configuration

Edit `lib/services/codesandbox_service.dart` to change the server URL:

```dart
class CodeSandboxService {
  // Change this to your deployed server URL
  static const String baseUrl = 'http://localhost:3000';
  // ...
}
```

For production, deploy the Node.js server and update this URL.

## Supported Frameworks

### 🧩 Frontend Frameworks (Browser Sandboxes)

These run directly in the browser with no API key needed:

- **React** (JavaScript / TypeScript)
- **Vue.js** (v2 and v3)
- **Angular**
- **Svelte / SvelteKit**
- **Preact**
- **SolidJS**
- **Next.js** (static/preview mode only)
- **Nuxt.js** (with Vite templates)
- **Astro**
- **Vanilla JS / HTML / CSS**
- **Tailwind CSS** (via postcss config)
- **Vite** (any frontend setup)
- **Lit**
- **Qwik**
- **Alpine.js**

### 📝 Supported File Types

- HTML
- CSS / SCSS / Less / Stylus
- JavaScript / JSX
- TypeScript / TSX
- Markdown (.md)
- JSON
- YAML

## AI Profile Configuration

The following AI profiles have been configured to use `<codesandbox>` tags:

- **Strict Coder**: Wraps code examples in codesandbox tags
- **Friendly Assistant**: Wraps UI code when appropriate

### Example AI Response

```
Here's a simple React counter app:

<codesandbox>
import React, { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div style={{ padding: '40px', textAlign: 'center' }}>
      <h1>Count: {count}</h1>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
}
</codesandbox>

Click "Run Preview" to see it in action!
```

## API Reference

### CodeSandboxService

#### `canPreview(String content) → bool`
Checks if content contains `<codesandbox>` tags.

#### `extractCode(String content) → String`
Extracts code from between `<codesandbox>` tags.

#### `detectFramework(String code) → String`
Auto-detects framework from code content.
Returns: `'react'`, `'vue'`, `'angular'`, `'svelte'`, `'html'`, or `'javascript'`

#### `createPreview({required String code, String? framework}) → Future<CodeSandboxPreview>`
Creates a CodeSandbox preview sandbox.
Throws `CodeSandboxException` on failure.

### Node.js Proxy Endpoints

#### `POST /preview/create`

Creates a browser preview sandbox.

**Request:**
```json
{
  "files": {
    "index.html": { "content": "..." },
    "index.js": { "content": "..." }
  },
  "framework": "react"
}
```

**Response:**
```json
{
  "success": true,
  "sandboxId": "abc123",
  "previewUrl": "https://codesandbox.io/s/abc123?view=preview",
  "embedUrl": "https://codesandbox.io/embed/abc123?view=preview&hidenavigation=1",
  "framework": "react"
}
```

**Error Response:**
```json
{
  "error": "Rate limit exceeded",
  "retryAfter": 60
}
```

#### `GET /health`

Health check endpoint.

## Deployment

### Node.js Server

#### Option 1: Local Development
```bash
cd codesandbox-proxy
npm install
npm start
```

#### Option 2: Production Server (PM2)
```bash
npm install -g pm2
cd codesandbox-proxy
npm install
pm2 start server.js --name codesandbox-proxy
pm2 save
pm2 startup
```

#### Option 3: Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY codesandbox-proxy/package*.json ./
RUN npm ci --only=production
COPY codesandbox-proxy/ ./
EXPOSE 3000
CMD ["node", "server.js"]
```

#### Option 4: Cloud Platforms
- **Vercel**: Deploy as a serverless function
- **Railway**: One-click deploy
- **Heroku**: Git push deployment
- **DigitalOcean App Platform**: GitHub integration

### Flutter App

Update the server URL before building:

```dart
// lib/services/codesandbox_service.dart
static const String baseUrl = 'https://your-server.com';
```

Then build normally:
```bash
flutter build apk
flutter build ios
flutter build windows
```

## Rate Limits

CodeSandbox's free tier has rate limits:
- ~100 sandbox creations per day
- Automatic hibernation after inactivity
- Browser sandboxes (what we use) have higher limits

If you hit rate limits:
1. The app shows a user-friendly error
2. Consider caching previously created sandboxes
3. Upgrade to CodeSandbox Pro for higher limits

## Security Considerations

✅ **Safe**: Browser preview sandboxes run in CodeSandbox's isolated environment
✅ **No API Key Needed**: Uses public Define API
✅ **CORS Enabled**: Server allows Flutter app requests
⚠️ **Production**: Add authentication to proxy server for production use
⚠️ **Rate Limiting**: Consider implementing per-user limits

## Troubleshooting

### Preview Button Not Showing

**Cause**: AI didn't wrap code in `<codesandbox>` tags

**Solution**: Ask AI explicitly: "Create a React app and wrap it in codesandbox tags"

### "Failed to create preview"

**Cause**: Proxy server not running or unreachable

**Solution**: 
1. Check proxy server is running: `curl http://localhost:3000/health`
2. Check `baseUrl` in `codesandbox_service.dart`
3. Check network connectivity

### WebView Not Loading

**Cause**: Platform-specific WebView issue

**Solution**:
- **Android**: Ensure WebView is installed and updated
- **iOS**: WebView should work out of the box
- **Desktop**: WebView support varies by platform

### Rate Limit Errors

**Cause**: Too many sandbox creations

**Solution**:
1. Wait for rate limit reset (usually 1 hour)
2. Implement client-side caching
3. Consider CodeSandbox Pro subscription

## Future Enhancements

### Planned Features

- [ ] Offline preview with local code execution
- [ ] Multi-file code editing before preview
- [ ] Sandbox favorites/history
- [ ] Share preview URLs
- [ ] Screenshot preview results
- [ ] Backend sandbox support (Node.js, Python)
- [ ] Real-time collaboration

### Advanced Usage

For backend/agent sandboxes (requires CodeSandbox API key):
- See `codesandbox-proxy/README.md` for VM sandbox setup
- Requires paid CodeSandbox plan
- Not implemented in current version

## Examples

### React Todo App

User: "Create a React todo app"

AI Response:
```jsx
<codesandbox>
import React, { useState } from 'react';

export default function TodoApp() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState('');

  const addTodo = () => {
    if (input.trim()) {
      setTodos([...todos, { id: Date.now(), text: input, done: false }]);
      setInput('');
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '500px', margin: '0 auto' }}>
      <h1>Todo List</h1>
      <div>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTodo()}
          placeholder="Add a todo..."
          style={{ padding: '8px', marginRight: '8px' }}
        />
        <button onClick={addTodo}>Add</button>
      </div>
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {todos.map((todo) => (
          <li key={todo.id} style={{ padding: '8px 0' }}>
            <input
              type="checkbox"
              checked={todo.done}
              onChange={() => {
                setTodos(todos.map(t =>
                  t.id === todo.id ? { ...t, done: !t.done } : t
                ));
              }}
            />
            <span style={{ marginLeft: '8px', textDecoration: todo.done ? 'line-through' : 'none' }}>
              {todo.text}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}
</codesandbox>
```

### Vue.js Calculator

User: "Make a simple calculator in Vue"

AI Response:
```vue
<codesandbox>
<template>
  <div class="calculator">
    <div class="display">{{ display }}</div>
    <div class="buttons">
      <button v-for="btn in buttons" :key="btn" @click="handleClick(btn)">
        {{ btn }}
      </button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      display: '0',
      buttons: ['7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', '0', '.', '=', '+', 'C'],
      currentValue: '',
    };
  },
  methods: {
    handleClick(btn) {
      if (btn === 'C') {
        this.display = '0';
        this.currentValue = '';
      } else if (btn === '=') {
        try {
          this.display = eval(this.currentValue).toString();
          this.currentValue = this.display;
        } catch {
          this.display = 'Error';
        }
      } else {
        this.currentValue += btn;
        this.display = this.currentValue;
      }
    },
  },
};
</script>

<style scoped>
.calculator {
  max-width: 300px;
  margin: 50px auto;
  padding: 20px;
  background: #333;
  border-radius: 10px;
}
.display {
  background: #111;
  color: #0f0;
  padding: 20px;
  text-align: right;
  font-size: 24px;
  margin-bottom: 10px;
}
.buttons {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}
button {
  padding: 20px;
  font-size: 18px;
  background: #555;
  color: white;
  border: none;
  cursor: pointer;
}
</style>
</codesandbox>
```

## Contributing

To add support for new frameworks:

1. Edit `lib/services/codesandbox_service.dart`
2. Add framework detection in `detectFramework()`
3. Add file structure creator (e.g., `_createNewFrameworkFiles()`)
4. Test with example code

## Support

For issues or questions:
- Check the [troubleshooting section](#troubleshooting)
- Review Node.js server logs
- Check CodeSandbox status: https://status.codesandbox.io

## License

This feature is part of Xibe Chat and follows the main project license.

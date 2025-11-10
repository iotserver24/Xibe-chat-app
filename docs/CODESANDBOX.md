# CodeSandbox Preview Guide

Complete guide to using CodeSandbox for visual web previews in Xibe Chat.

## Overview

CodeSandbox provides live preview environments for web frameworks. Xibe Chat integrates CodeSandbox to allow users to preview React, Vue, Angular, Svelte, and HTML/CSS/JS code directly in the app.

## Features

- **Multiple Frameworks**: React, Vue, Angular, Svelte, HTML/CSS/JS
- **Live Previews**: Real-time rendering in WebView
- **Multi-File Support**: Create projects with multiple files
- **No API Key Required**: Uses public CodeSandbox Define API
- **Automatic Detection**: Framework auto-detection from code

---

## How It Works

### Architecture

```
User Code → CodeSandbox API → Sandbox Created → Preview URL → WebView Display
```

The app:
1. Parses code into file structure
2. Sends to CodeSandbox Define API
3. Receives sandbox ID and preview URL
4. Displays preview in WebView overlay

### Supported Frameworks

| Framework | Code Tag | Auto-Detection |
|-----------|----------|----------------|
| React | `codesandbox-react` | ✅ |
| Vue | `codesandbox-vue` | ✅ |
| Angular | `codesandbox-angular` | ✅ |
| Svelte | `codesandbox-svelte` | ✅ |
| HTML/CSS/JS | `codesandbox-html` | ✅ |

---

## Usage

### Basic Single File

Use the `codesandbox-{framework}` language tag:

````markdown
```codesandbox-react
import React from 'react';

export default function App() {
  return (
    <div style={{ padding: '20px', background: '#f0f0f0' }}>
      <h1>Hello, World!</h1>
      <p>This is a React component preview.</p>
    </div>
  );
}
```
````

Click the "Run Preview" button to see the live preview.

### Multi-File Projects

Use `// File: filename.ext` markers to create multiple files in one code block:

````markdown
```codesandbox-react
// File: App.js
import React, { useState } from 'react';
import './styles.css';

export default function App() {
  const [count, setCount] = useState(0);
  
  return (
    <div className="container">
      <h1>Counter: {count}</h1>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

// File: styles.css
.container {
  padding: 20px;
  text-align: center;
  background: linear-gradient(to right, #667eea, #764ba2);
  color: white;
  border-radius: 8px;
}

button {
  padding: 10px 20px;
  font-size: 16px;
  background: white;
  color: #667eea;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```
````

---

## Framework Examples

### React

**Single Component**:
````markdown
```codesandbox-react
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
    </div>
  );
}

export default Counter;
```
````

**Multiple Components**:
````markdown
```codesandbox-react
// File: App.js
import React from 'react';
import Button from './Button';
import './App.css';

export default function App() {
  return (
    <div className="app">
      <h1>My App</h1>
      <Button label="Click Me" />
    </div>
  );
}

// File: Button.js
import React from 'react';

export default function Button({ label }) {
  return <button className="btn">{label}</button>;
}

// File: App.css
.app {
  padding: 20px;
}

.btn {
  padding: 10px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
}
```
````

### Vue

**Single Component**:
````markdown
```codesandbox-vue
<template>
  <div class="container">
    <h1>{{ message }}</h1>
    <button @click="increment">Count: {{ count }}</button>
  </div>
</template>

<script>
export default {
  data() {
    return {
      message: 'Hello Vue!',
      count: 0
    };
  },
  methods: {
    increment() {
      this.count++;
    }
  }
};
</script>

<style scoped>
.container {
  padding: 20px;
  text-align: center;
}
</style>
```
````

### HTML/CSS/JS

**Vanilla Web**:
````markdown
```codesandbox-html
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background: #f5f5f5;
    }
    .card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>Hello, World!</h1>
    <p>This is a simple HTML preview.</p>
  </div>
  <script>
    console.log('App loaded!');
  </script>
</body>
</html>
```
````

**Separate Files**:
````markdown
```codesandbox-html
// File: index.html
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    <h1>Hello</h1>
    <button id="btn">Click Me</button>
  </div>
  <script src="app.js"></script>
</body>
</html>

// File: styles.css
.container {
  padding: 20px;
  text-align: center;
}

button {
  padding: 10px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
}

// File: app.js
document.getElementById('btn').addEventListener('click', () => {
  alert('Button clicked!');
});
```
````

---

## File Structure

### React Project Structure

When you use `codesandbox-react`, the app creates:

```
package.json          # Dependencies and scripts
public/index.html     # HTML template
src/index.js          # Entry point
src/App.js            # Your component
```

### Vue Project Structure

When you use `codesandbox-vue`, the app creates:

```
package.json          # Dependencies
index.html            # HTML template
src/main.js           # Entry point
src/App.vue           # Your component
```

### Custom Files

You can add custom files using file markers:

- `// File: filename.js` - JavaScript files
- `// File: filename.css` - CSS files
- `// File: filename.json` - JSON files (package.json, etc.)
- `/* File: filename.css */` - CSS comment style (also supported)

---

## Advanced Usage

### Custom Package.json

Add dependencies:

````markdown
```codesandbox-react
// File: package.json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.0.0",
    "lodash": "^4.17.21"
  }
}

// File: App.js
import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function App() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    axios.get('https://api.github.com/users/octocat')
      .then(res => setData(res.data));
  }, []);
  
  return <div>{data ? data.name : 'Loading...'}</div>;
}
```
````

### Using External Libraries

CodeSandbox automatically installs dependencies from `package.json`:

````markdown
```codesandbox-react
// File: package.json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "styled-components": "^6.0.0"
  }
}

// File: App.js
import React from 'react';
import styled from 'styled-components';

const Button = styled.button`
  background: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
`;

export default function App() {
  return <Button>Styled Button</Button>;
}
```
````

---

## Preview Display

### Desktop (Wide Screens)

On desktop with screen width > 1000px:
- Preview opens in **right-side overlay**
- Chat remains visible on left
- Can resize overlay
- Can close overlay to return to chat

### Mobile / Narrow Screens

On mobile or narrow desktop:
- Preview opens in **fullscreen**
- Swipe down to close (mobile)
- Close button in header

### WebView Features

- **Zoom**: Pinch to zoom (mobile)
- **Scroll**: Scroll preview content
- **Refresh**: Pull to refresh (mobile)
- **Open in Browser**: Button to open in external browser

---

## Best Practices

### 1. Use Appropriate Framework Tag

Always use `codesandbox-{framework}`:
- ✅ `codesandbox-react`
- ✅ `codesandbox-vue`
- ❌ `react` (will try to execute, not preview)

### 2. Complete Components

Provide complete, runnable code:

```jsx
// Good: Complete component
export default function App() {
  return <div>Hello</div>;
}

// Bad: Incomplete
function App() {
  return <div>Hello</div>;  // Missing export
}
```

### 3. Multi-File Organization

Use file markers for clarity:

```jsx
// File: components/Button.js
export default function Button() { ... }

// File: components/Card.js
export default function Card() { ... }

// File: App.js
import Button from './components/Button';
import Card from './components/Card';
```

### 4. Include Styles

Always include styling:

```jsx
// Good: Includes styles
<div style={{ padding: '20px' }}>...</div>

// Better: Separate CSS file
// File: styles.css
.container { padding: 20px; }
```

---

## Limitations

### CodeSandbox API Limits

- **Rate Limiting**: Free tier has rate limits
- **Sandbox Lifetime**: Temporary sandboxes
- **File Size**: Maximum file size limits
- **Dependencies**: Some packages may not be available

### Framework Support

- **React**: Full support (JSX, hooks, etc.)
- **Vue**: Vue 3 supported
- **Angular**: Basic support
- **Svelte**: Full support
- **HTML/CSS/JS**: Full support

### Network Access

- Sandboxes can make HTTP requests
- CORS may block some requests
- Some APIs may require authentication

---

## Troubleshooting

### Preview Not Loading

1. Check framework tag is correct
2. Verify code is valid
3. Check network connection
4. Try refreshing preview

### Multi-File Not Working

1. Ensure file markers are correct: `// File: filename.ext`
2. Check file paths are relative
3. Verify imports match file names
4. Review console for errors

### Styling Not Applied

1. Check CSS file is included
2. Verify class names match
3. Check for CSS syntax errors
4. Ensure styles are in correct file

### Dependencies Not Installing

1. Verify `package.json` syntax
2. Check package names are correct
3. Ensure versions are valid
4. Wait for installation to complete

---

## CodeSandbox Proxy (Optional)

For production deployments, you can run a proxy server:

### Setup

```bash
cd codesandbox-proxy
npm install
npm start
```

### Configuration

Set proxy URL in app settings or environment variable.

See [codesandbox-proxy/README.md](../codesandbox-proxy/README.md) for details.

---

## Security

### Public API

- CodeSandbox Define API is public
- No authentication required
- Sandboxes are temporary
- Code is visible in sandbox URL

### Best Practices

- Don't include API keys in code
- Use environment variables (if supported)
- Don't include sensitive data
- Review code before sharing

---

## Additional Resources

- [CodeSandbox Documentation](https://codesandbox.io/docs)
- [CodeSandbox Define API](https://codesandbox.io/docs/api#define-api)
- [React Documentation](https://react.dev)
- [Vue Documentation](https://vuejs.org)

---

## Examples

### Interactive Form

````markdown
```codesandbox-react
import React, { useState } from 'react';

export default function Form() {
  const [formData, setFormData] = useState({ name: '', email: '' });
  
  const handleSubmit = (e) => {
    e.preventDefault();
    alert(`Submitted: ${JSON.stringify(formData)}`);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        placeholder="Name"
        value={formData.name}
        onChange={(e) => setFormData({...formData, name: e.target.value})}
      />
      <input
        type="email"
        placeholder="Email"
        value={formData.email}
        onChange={(e) => setFormData({...formData, email: e.target.value})}
      />
      <button type="submit">Submit</button>
    </form>
  );
}
```
````

### Data Visualization

````markdown
```codesandbox-react
// File: package.json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "recharts": "^2.8.0"
  }
}

// File: App.js
import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid } from 'recharts';

const data = [
  { name: 'Jan', value: 400 },
  { name: 'Feb', value: 300 },
  { name: 'Mar', value: 200 },
];

export default function App() {
  return (
    <LineChart width={400} height={300} data={data}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="name" />
      <YAxis />
      <Line type="monotone" dataKey="value" stroke="#8884d8" />
    </LineChart>
  );
}
```
````

---

**Note**: CodeSandbox is for visual web UI code. For computational code execution, use E2B instead.


# CodeSandbox Proxy Server

This Node.js server provides a proxy for creating CodeSandbox preview sandboxes from the Xibe Chat Flutter app.

## Features

- **Browser Preview Creation**: Creates ephemeral CodeSandbox sandboxes for quick UI previews
- **Framework Support**: React, Vue, Angular, Svelte, and more
- **Rate Limiting**: Handles CodeSandbox rate limits with exponential backoff
- **CORS Support**: Allows requests from Flutter app (web, mobile, desktop)

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` to configure:
- `PORT`: Server port (default: 3000)
- `NODE_ENV`: development or production

### 3. Run the Server

**Development mode** (with auto-reload):
```bash
npm run dev
```

**Production mode**:
```bash
npm start
```

## API Endpoints

### POST /preview/create

Creates a browser preview sandbox.

**Request Body**:
```json
{
  "files": {
    "index.html": {
      "content": "<!DOCTYPE html>..."
    },
    "index.js": {
      "content": "document.getElementById('root')..."
    },
    "package.json": {
      "content": "{\"dependencies\": {\"react\": \"^18.0.0\"}}"
    }
  },
  "framework": "react"
}
```

**Response**:
```json
{
  "success": true,
  "sandboxId": "abc123",
  "previewUrl": "https://codesandbox.io/s/abc123?view=preview",
  "embedUrl": "https://codesandbox.io/embed/abc123?view=preview&hidenavigation=1",
  "framework": "react"
}
```

### GET /health

Health check endpoint.

**Response**:
```json
{
  "status": "ok",
  "uptime": 123.45,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Supported Frameworks

- React (JavaScript / TypeScript)
- Vue.js
- Angular
- Svelte
- Preact
- SolidJS
- Next.js (static mode)
- Vanilla JS / HTML / CSS
- And more...

## Rate Limits

CodeSandbox may rate-limit requests. The server handles this by:
- Returning HTTP 429 with `retryAfter` seconds
- Client should implement exponential backoff

## Security Notes

- This server uses the **public Define API** (no API key required)
- For production, consider adding authentication
- Limit request size to prevent abuse (currently 10MB max)

## Deployment

For production deployment:

1. Set `NODE_ENV=production` in `.env`
2. Use a process manager (PM2, systemd, etc.)
3. Set up reverse proxy (nginx, Caddy)
4. Configure firewall rules
5. Enable HTTPS

Example with PM2:
```bash
npm install -g pm2
pm2 start server.js --name codesandbox-proxy
pm2 save
pm2 startup
```

## Troubleshooting

**Port already in use**:
- Change `PORT` in `.env`

**Rate limit errors**:
- CodeSandbox has rate limits on their free tier
- Implement client-side caching
- Consider upgrading to CodeSandbox Pro

**CORS errors**:
- Ensure the Flutter app domain is allowed
- Check CORS configuration in `server.js`

# Xibe Chat Server - MongoDB Backend

Backend server for Xibe Chat app using Node.js, Express, and MongoDB.

## Features

- ✅ RESTful API for chats, messages, and memories
- ✅ MongoDB database with Mongoose ODM
- ✅ 100 chats per user limit enforcement
- ✅ Cross-device sync support
- ✅ Rate limiting and security headers
- ✅ Soft delete for chats
- ✅ Optimized queries with indexes

## Prerequisites

- Node.js 16+ and npm
- MongoDB (local or MongoDB Atlas)

## Installation

1. **Clone and navigate to server directory:**
```bash
cd chat-server
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up environment variables:**
```bash
cp .env.example .env
```

4. **Edit `.env` file:**
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/xibe-chat
```

For MongoDB Atlas (cloud):
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/xibe-chat
```

## Running the Server

### Development (with auto-reload):
```bash
npm run dev
```

### Production:
```bash
npm start
```

Server will start on `http://localhost:3000`

## API Endpoints

### Chats

- `GET /api/chats` - Get all chats for authenticated user
- `GET /api/chats/:chatId` - Get a specific chat
- `POST /api/chats` - Create a new chat (enforces 100 limit)
- `PUT /api/chats/:chatId` - Update a chat
- `DELETE /api/chats/:chatId` - Delete a chat (soft delete)
- `DELETE /api/chats` - Delete all chats for user

### Messages

- `GET /api/messages/chat/:chatId` - Get all messages for a chat
- `POST /api/messages` - Create a new message
- `PUT /api/messages/:messageId` - Update a message (e.g., reactions)
- `DELETE /api/messages/:messageId` - Delete a message

### Memories

- `GET /api/memories` - Get all memories for user
- `POST /api/memories` - Create a memory
- `PUT /api/memories/:memoryId` - Update a memory
- `DELETE /api/memories/:memoryId` - Delete a memory

### Sync

- `GET /api/sync?since=timestamp` - Get changes since timestamp
- `POST /api/sync` - Push local changes to server

## Authentication

Currently uses a simplified auth middleware. For production, implement Firebase Admin SDK:

```javascript
// In middleware/auth.js
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  }),
});

const verifyFirebaseToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.userId = decodedToken.uid;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' });
  }
};
```

## Request Headers

All API requests require:
```
Authorization: Bearer <firebase-token>
X-User-Id: <user-id>  // Temporary for development
```

## Example Requests

### Create a chat:
```bash
curl -X POST http://localhost:3000/api/chats \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -H "X-User-Id: user123" \
  -d '{
    "title": "My New Chat",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }'
```

### Get all chats:
```bash
curl http://localhost:3000/api/chats \
  -H "Authorization: Bearer <token>" \
  -H "X-User-Id: user123"
```

### Create a message:
```bash
curl -X POST http://localhost:3000/api/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -H "X-User-Id: user123" \
  -d '{
    "chatId": 1,
    "role": "user",
    "content": "Hello, AI!",
    "timestamp": "2024-01-01T00:00:00Z"
  }'
```

## Database Schema

### Chats Collection
```javascript
{
  id: Number,           // Unique per user
  userId: String,       // Firebase UID
  title: String,
  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date      // null if active
}
```

### Messages Collection
```javascript
{
  id: Number,           // Unique per chat
  chatId: Number,
  userId: String,
  role: String,         // 'user' | 'assistant' | 'system'
  content: String,
  timestamp: Date,
  webSearchUsed: Boolean,
  imageBase64: String,
  // ... other fields
}
```

### Memories Collection
```javascript
{
  id: Number,           // Unique per user
  userId: String,
  content: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Performance Optimizations

- Indexes on `userId`, `chatId`, `timestamp` for fast queries
- Compound indexes for common query patterns
- Soft delete to preserve data
- Pagination support with `limit` and `offset`

## Deployment

### Using Docker:
```bash
docker build -t xibe-chat-server .
docker run -p 3000:3000 --env-file .env xibe-chat-server
```

### Using PM2:
```bash
npm install -g pm2
pm2 start server.js --name xibe-chat-server
pm2 save
pm2 startup
```

### Using Railway/Render:
1. Connect your GitHub repo
2. Set environment variables
3. Deploy!

## Health Check

```bash
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 123.45
}
```

## License

ISC


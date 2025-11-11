# Quick Setup Guide

## Step 1: Install Dependencies

```bash
cd chat-server
npm install
```

## Step 2: Environment Variables

The `.env` file is already configured with your MongoDB connection string:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb://root:18751Anish@193.24.208.154:4532/?directConnection=true

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**Note:** The `.env` file is gitignored for security. If you need to recreate it, copy the configuration above.

## Step 3: Start MongoDB

### Option A: Local MongoDB
```bash
# Install MongoDB locally, then:
mongod
```

### Option B: Docker (Easiest!)
```bash
docker-compose up -d mongodb
```

### Option C: MongoDB Atlas (Free Cloud)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free cluster
3. Get connection string
4. Update `MONGODB_URI` in `.env`

## Step 4: Start the Server

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server will be available at: `http://localhost:3000`

## Step 5: Test the API

```bash
# Health check
curl http://localhost:3000/health

# Get chats (replace with your user ID)
curl http://localhost:3000/api/chats \
  -H "X-User-Id: test-user-123"
```

## Using Docker Compose (All-in-One)

```bash
# Start MongoDB + Server together
docker-compose up

# Or in background:
docker-compose up -d
```

## Next Steps

1. Update Flutter app to use this API instead of Firestore
2. Implement proper Firebase Admin SDK auth (see README.md)
3. Deploy to Railway/Render/Heroku


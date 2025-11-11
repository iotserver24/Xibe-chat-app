# Testing MongoDB Server Connection

## Step 1: Check Server Status

The server should be running on `http://localhost:3000`

Test with:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 123.45
}
```

## Step 2: Test API Endpoints

### Create a Chat
```bash
curl -X POST http://localhost:3000/api/chats \
  -H "Content-Type: application/json" \
  -H "X-User-Id: test-user-123" \
  -d "{\"title\":\"Test Chat\",\"createdAt\":\"2024-01-01T00:00:00Z\",\"updatedAt\":\"2024-01-01T00:00:00Z\"}"
```

### Get All Chats
```bash
curl http://localhost:3000/api/chats \
  -H "X-User-Id: test-user-123"
```

### Create a Message
```bash
curl -X POST http://localhost:3000/api/messages \
  -H "Content-Type: application/json" \
  -H "X-User-Id: test-user-123" \
  -d "{\"chatId\":1,\"role\":\"user\",\"content\":\"Hello!\",\"timestamp\":\"2024-01-01T00:00:00Z\"}"
```

## Step 3: Test from Flutter App

1. Make sure `USE_MONGODB = true` in `lib/config/sync_config.dart`
2. Update `MONGODB_API_URL` if needed:
   - Local: `http://localhost:3000/api`
   - Android Emulator: `http://10.0.2.2:3000/api`
   - Physical Device: `http://YOUR_COMPUTER_IP:3000/api`

3. Run the Flutter app and check console logs for:
   - `📥 Fetching chats from cloud for user: ...`
   - `✅ Chat synced to MongoDB: ...`

## Troubleshooting

### Server not starting?
- Check MongoDB connection in `.env`
- Check if port 3000 is already in use
- Check server logs for errors

### Flutter can't connect?
- **Android Emulator**: Use `http://10.0.2.2:3000/api`
- **iOS Simulator**: Use `http://localhost:3000/api`
- **Physical Device**: Use your computer's IP address

### Get your computer's IP:
- Windows: `ipconfig` → Look for IPv4 Address
- Mac/Linux: `ifconfig` or `ip addr`

Then use: `http://YOUR_IP:3000/api`


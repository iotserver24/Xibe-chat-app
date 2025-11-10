# API Reference

API integration documentation for Xibe Chat.

## Xibe API

### Base URL

```
https://api.xibe.app
```

### Authentication

API key required for custom providers. Set via:
- App Settings → API Configuration
- Environment variable: `XIBE_API`

---

## Chat Completion API

### Endpoint

```
POST /chat/completions
```

### Request Headers

```http
Content-Type: application/json
Authorization: Bearer YOUR_API_KEY
```

### Request Body

```json
{
  "model": "gemini-2.5-flash-lite",
  "messages": [
    {
      "role": "user",
      "content": "Hello!"
    }
  ],
  "stream": true,
  "temperature": 0.7,
  "max_tokens": 2000
}
```

### Response (Streaming)

```
data: {"id":"chat-123","choices":[{"delta":{"content":"Hello"}}]}
data: {"id":"chat-123","choices":[{"delta":{"content":" there"}}]}
data: [DONE]
```

---

## Custom Providers

### OpenAI-Compatible

```dart
{
  "type": "openai",
  "baseUrl": "https://api.openai.com/v1",
  "apiKey": "sk-...",
  "models": [
    {
      "id": "gpt-4",
      "name": "GPT-4",
      "endpointUrl": "https://api.openai.com/v1/chat/completions"
    }
  ]
}
```

### Anthropic-Compatible

```dart
{
  "type": "anthropic",
  "baseUrl": "https://api.anthropic.com",
  "apiKey": "sk-ant-...",
  "models": [
    {
      "id": "claude-3-opus",
      "name": "Claude 3 Opus",
      "endpointUrl": "https://api.anthropic.com/v1/messages"
    }
  ]
}
```

---

## Model Selection

### Get Available Models

Models are fetched from Xibe API automatically. Custom models are stored locally.

### Model Properties

```dart
{
  "id": "model-id",
  "name": "Model Name",
  "provider": "Xibe",
  "supportsVision": false,
  "supportsStreaming": true,
  "supportsTools": false,
  "maxTokens": 4096
}
```

---

## Code Execution (E2B)

### Endpoint

```
POST https://api.e2b.dev/v1/code/execute
```

### Request

```json
{
  "code": "print('Hello, World!')",
  "language": "python3"
}
```

### Response

```json
{
  "output": "Hello, World!\n",
  "error": null,
  "executionTime": 0.123
}
```

---

## Payment API (Razorpay)

### Create Order

```
POST /api/create-order
```

### Request

```json
{
  "amount": 100,
  "currency": "INR"
}
```

### Response

```json
{
  "orderId": "order_123",
  "keyId": "rzp_test_...",
  "amount": 10000
}
```

### Verify Payment

```
POST /api/verify-payment
```

### Request

```json
{
  "orderId": "order_123",
  "paymentId": "pay_123",
  "signature": "signature_123"
}
```

---

## MCP (Model Context Protocol)

### Configuration

MCP servers configured in `lib/services/mcp_config_service.dart`.

### Server Definition

```json
{
  "name": "Server Name",
  "command": "node",
  "args": ["server.js"],
  "env": {
    "API_KEY": "value"
  }
}
```

---

## Error Handling

### API Errors

```dart
try {
  final response = await apiService.sendMessage(...);
} on ApiException catch (e) {
  // Handle API error
  print('API Error: ${e.message}');
} on NetworkException catch (e) {
  // Handle network error
  print('Network Error: ${e.message}');
}
```

### Error Codes

- `401`: Unauthorized (invalid API key)
- `429`: Rate limit exceeded
- `500`: Server error
- `503`: Service unavailable

---

## Rate Limiting

### Xibe API

- Default: 60 requests/minute
- Varies by plan

### Best Practices

- Implement exponential backoff
- Cache responses when possible
- Use streaming for long responses

---

## Webhooks

### Payment Webhook

```
POST /api/webhook/razorpay
```

### Headers

```http
X-Razorpay-Signature: signature
```

### Payload

```json
{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "id": "pay_123",
      "amount": 10000,
      "status": "captured"
    }
  }
}
```

---

## SDK Integration

### Flutter Package

```yaml
dependencies:
  http: ^1.1.0
```

### Example Usage

```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse('https://api.xibe.app/chat/completions'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  },
  body: jsonEncode({
    'model': 'gemini-2.5-flash-lite',
    'messages': messages,
    'stream': true,
  }),
);
```

---

## Additional Resources

- [Xibe API Documentation](https://api.xibe.app/docs)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [Anthropic API Reference](https://docs.anthropic.com/claude/reference)
- [Razorpay Documentation](https://razorpay.com/docs/)


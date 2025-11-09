# Razorpay Integration Documentation

Complete technical documentation for the Razorpay payment integration in Xibe Chat.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Backend API Reference](#backend-api-reference)
3. [Flutter Implementation](#flutter-implementation)
4. [Platform Support](#platform-support)
5. [Security](#security)
6. [Testing](#testing)
7. [Production Deployment](#production-deployment)

---

## Architecture Overview

### System Flow

```
User initiates payment in Flutter App
         ↓
Flutter calls backend /api/create-order
         ↓
Backend creates order with Razorpay API
         ↓
Backend returns order ID to Flutter
         ↓
Flutter opens Razorpay payment gateway
         ↓
User completes payment
         ↓
Razorpay sends payment response to Flutter
         ↓
Flutter calls backend /api/verify-payment
         ↓
Backend verifies payment signature
         ↓
Flutter shows success/error message
```

### Components

1. **Node.js Backend** (`payment-backend/`)
   - Express.js server
   - Razorpay SDK integration
   - Order creation and verification endpoints
   - Webhook handling

2. **Flutter Service** (`lib/services/payment_service.dart`)
   - API communication
   - Order creation
   - Payment verification

3. **Flutter UI** (`lib/screens/donate_screen.dart`)
   - Donation interface
   - Amount selection
   - Payment flow handling
   - Success/error states

---

## Backend API Reference

### Base URL
```
Development: http://localhost:3000
Production: https://your-backend-url.com
```

### Endpoints

#### 1. Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "message": "Xibe Payment Backend is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

#### 2. Create Order

```http
POST /api/create-order
Content-Type: application/json
```

**Request Body:**
```json
{
  "amount": 100,
  "currency": "INR",
  "receipt": "receipt_12345"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "orderId": "order_MBKcKpZBbfeQWb",
  "amount": 10000,
  "currency": "INR",
  "keyId": "rzp_test_xxxxxxxxxx"
}
```

**Response (Error - 400):**
```json
{
  "error": "Invalid amount",
  "message": "Amount must be greater than 0"
}
```

**Response (Error - 500):**
```json
{
  "error": "Failed to create order",
  "message": "API key is invalid"
}
```

---

#### 3. Verify Payment

```http
POST /api/verify-payment
Content-Type: application/json
```

**Request Body:**
```json
{
  "orderId": "order_MBKcKpZBbfeQWb",
  "paymentId": "pay_MBKdLwWQUJqcP2",
  "signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "verified": true,
  "message": "Payment verified successfully",
  "paymentId": "pay_MBKdLwWQUJqcP2"
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "verified": false,
  "message": "Invalid payment signature"
}
```

---

#### 4. Get Payment Details

```http
GET /api/payment/:paymentId
```

**Response (Success - 200):**
```json
{
  "success": true,
  "payment": {
    "id": "pay_MBKdLwWQUJqcP2",
    "amount": 100,
    "currency": "INR",
    "status": "captured",
    "method": "card",
    "email": "user@example.com",
    "contact": "9876543210",
    "createdAt": 1641024000
  }
}
```

---

#### 5. Webhook Endpoint

```http
POST /api/webhook
X-Razorpay-Signature: signature_here
Content-Type: application/json
```

**Webhook Events:**
- `payment.authorized` - Payment authorized
- `payment.captured` - Payment captured
- `payment.failed` - Payment failed
- `order.paid` - Order fully paid

**Request Body (Example):**
```json
{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_MBKdLwWQUJqcP2",
        "amount": 10000,
        "currency": "INR",
        "status": "captured",
        "order_id": "order_MBKcKpZBbfeQWb"
      }
    }
  }
}
```

---

## Flutter Implementation

### Payment Service

**File:** `lib/services/payment_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _backendUrl = 'http://localhost:3000';
  
  // Create order
  Future<Map<String, dynamic>?> createOrder({
    required int amount,
    String currency = 'INR',
  }) async {
    // Implementation...
  }
  
  // Verify payment
  Future<bool> verifyPaymentOnServer({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    // Implementation...
  }
  
  // Check backend health
  Future<bool> checkBackendHealth() async {
    // Implementation...
  }
}
```

### Donation Screen

**File:** `lib/screens/donate_screen.dart`

**Key Features:**
- Predefined donation amounts
- Custom amount input
- Platform-specific payment handling
- Success/error dialogs
- Payment verification

**Usage:**
```dart
// Navigate to donation screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DonateScreen(),
  ),
);
```

---

## Platform Support

### Android (✅ Fully Supported)

**Requirements:**
- Minimum SDK: API Level 21
- Razorpay Flutter SDK
- ProGuard rules included

**Payment Methods:**
- Credit/Debit Cards
- UPI
- Net Banking
- Wallets (PayTM, PhonePe, Google Pay)

**Implementation:**
```dart
// Uses native Razorpay SDK
_razorpay = Razorpay();
_razorpay.open(options);
```

---

### iOS (✅ Fully Supported)

**Requirements:**
- Minimum iOS: 10.0
- Razorpay Flutter SDK
- UPI apps intent handling

**Payment Methods:**
- Same as Android
- Apple Pay (if configured)

**Implementation:**
```dart
// Uses native Razorpay SDK
_razorpay = Razorpay();
_razorpay.open(options);
```

---

### Web (⚠️ Custom Implementation)

**Limitations:**
- Official razorpay_flutter doesn't support web
- Custom implementation required

**Current Implementation:**
- Shows payment instructions dialog
- Provides Razorpay payment link
- Alternative payment methods (UPI, Bank Transfer)

**Future Enhancement:**
```html
<!-- Add to web/index.html -->
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
```

```dart
// Use JS interop for web
import 'dart:js' as js;

js.context.callMethod('Razorpay', [options]);
```

---

### Desktop (Windows/Linux/macOS) (⚠️ Limited Support)

**Current Implementation:**
- Shows payment instructions dialog
- Opens payment link in browser
- Alternative payment methods displayed

**Recommended Approach:**
- Use WebView to show Razorpay checkout
- Or direct users to payment page
- Or show QR code for mobile payment

---

## Security

### Payment Signature Verification

Razorpay uses HMAC SHA256 for signature verification.

**Algorithm:**
```
signature = HMAC_SHA256(key_secret, orderId|paymentId)
```

**Server-Side Verification (Recommended):**
```javascript
const crypto = require('crypto');

const data = `${orderId}|${paymentId}`;
const expectedSignature = crypto
  .createHmac('sha256', keySecret)
  .update(data)
  .digest('hex');

const isValid = expectedSignature === signature;
```

**Client-Side Verification (Backup):**
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

bool verifySignature(String orderId, String paymentId, String signature, String keySecret) {
  String data = '$orderId|$paymentId';
  var key = utf8.encode(keySecret);
  var bytes = utf8.encode(data);
  var hmac = Hmac(sha256, key);
  var digest = hmac.convert(bytes);
  return digest.toString() == signature;
}
```

### Best Practices

1. **Never expose Key Secret in client code**
   - Always keep it on backend
   - Use environment variables

2. **Always verify payments on server**
   - Don't trust client-side verification
   - Server has the final say

3. **Use HTTPS in production**
   - Encrypt all API communication
   - Use SSL certificates

4. **Implement rate limiting**
   - Prevent API abuse
   - Limit requests per IP/user

5. **Secure environment variables**
   - Never commit `.env` files
   - Use secure key storage

6. **Validate all inputs**
   - Check amount ranges
   - Sanitize user inputs
   - Prevent injection attacks

---

## Testing

### Test Mode

Razorpay provides test mode for development:

**Test API Keys:**
- Start with `rzp_test_`
- No real money is charged
- Simulated payment flow

### Test Credentials

**Test Cards:**

| Card Number | CVV | Expiry | Result |
|------------|-----|--------|--------|
| 4111 1111 1111 1111 | Any 3 digits | Any future | Success |
| 4000 0000 0000 0002 | Any 3 digits | Any future | Failed |
| 5555 5555 5555 4444 | Any 3 digits | Any future | Success (Mastercard) |

**Test UPI IDs:**
- Success: `success@razorpay`
- Failure: `failure@razorpay`

**Test Wallets:**
- All wallets work in test mode
- No actual wallet is charged

### Testing Checklist

- [ ] Order creation works
- [ ] Payment gateway opens
- [ ] Successful payment flow
- [ ] Failed payment handling
- [ ] Payment verification works
- [ ] Backend health check works
- [ ] Error messages display correctly
- [ ] Loading states work properly
- [ ] Works on all target platforms

---

## Production Deployment

### Pre-Launch Checklist

#### 1. Razorpay Account Setup
- [ ] Complete KYC verification
- [ ] Get approval from Razorpay
- [ ] Generate Live API keys
- [ ] Configure payment methods
- [ ] Set up webhooks
- [ ] Add bank account for settlements

#### 2. Backend Deployment
- [ ] Choose hosting platform
- [ ] Set up production environment
- [ ] Add Live API keys to env vars
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS properly
- [ ] Set up monitoring/logging
- [ ] Test all endpoints

#### 3. Flutter App Configuration
- [ ] Update backend URL to production
- [ ] Remove test code/logs
- [ ] Test payment flow end-to-end
- [ ] Build release version
- [ ] Test on actual devices
- [ ] Submit to app stores

#### 4. Post-Launch
- [ ] Monitor payment success rate
- [ ] Check Razorpay Dashboard regularly
- [ ] Set up payment alerts
- [ ] Handle customer queries
- [ ] Track donation metrics

### Deployment Platforms

#### Heroku
```bash
heroku create xibe-payment
heroku config:set RAZORPAY_KEY_ID=rzp_live_xxx
heroku config:set RAZORPAY_KEY_SECRET=xxx
git subtree push --prefix payment-backend heroku main
```

#### Vercel
```bash
cd payment-backend
vercel
# Add env vars in dashboard
```

#### Railway
1. Connect GitHub repo
2. Select `payment-backend` folder
3. Add environment variables
4. Deploy

#### DigitalOcean/AWS/GCP
```bash
# Clone repo on server
git clone repo-url
cd repo/payment-backend
npm install
nano .env  # Add production keys
npm install -g pm2
pm2 start server.js --name xibe-payment
pm2 startup
pm2 save
```

### Monitoring

**Backend Logs:**
```bash
# View logs
pm2 logs xibe-payment

# Monitor status
pm2 status
```

**Razorpay Dashboard:**
- Monitor payment success rate
- Check settlement status
- View refunds
- Track disputes

**Webhooks:**
- Set up webhook endpoint
- Verify webhook signature
- Log all webhook events
- Handle failed webhooks

---

## Webhook Configuration

### Setup in Razorpay Dashboard

1. Go to Settings → Webhooks
2. Add webhook URL: `https://your-backend.com/api/webhook`
3. Select events:
   - payment.authorized
   - payment.captured
   - payment.failed
   - order.paid
4. Set up authentication (optional)
5. Copy webhook secret
6. Add to backend `.env`:
   ```env
   RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
   ```

### Webhook Verification

```javascript
app.post('/api/webhook', (req, res) => {
  const signature = req.headers['x-razorpay-signature'];
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
  
  const body = JSON.stringify(req.body);
  const expectedSignature = crypto
    .createHmac('sha256', webhookSecret)
    .update(body)
    .digest('hex');
  
  if (expectedSignature === signature) {
    // Process event
    const event = req.body.event;
    const payload = req.body.payload;
    
    // Handle different events
    switch(event) {
      case 'payment.captured':
        // Update database, send email, etc.
        break;
    }
    
    res.status(200).send('OK');
  } else {
    res.status(400).send('Invalid signature');
  }
});
```

---

## Troubleshooting

### Common Issues

1. **Payment verification fails**
   - Check signature calculation
   - Verify key secret is correct
   - Ensure order ID matches

2. **Backend not reachable**
   - Check backend is running
   - Verify URL is correct
   - Check firewall/CORS settings

3. **Razorpay not opening on mobile**
   - Check minSdkVersion (Android)
   - Run `flutter clean`
   - Rebuild app

4. **Web payment issues**
   - Web requires custom implementation
   - Consider using WebView
   - Or direct to payment page

---

## Support Resources

- **Razorpay Documentation:** https://razorpay.com/docs/
- **Razorpay Support:** support@razorpay.com
- **Flutter Razorpay Package:** https://pub.dev/packages/razorpay_flutter
- **Xibe Chat GitHub:** https://github.com/iotserver24/xibe-chat

---

## License

This integration is part of Xibe Chat. See LICENSE file for details.

---

**Last Updated:** January 2024  
**Razorpay SDK Version:** 1.3.7  
**Flutter Version:** 3.0+

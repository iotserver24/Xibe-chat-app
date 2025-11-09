# Xibe Chat Payment Backend

Node.js backend for handling Razorpay payment integration for Xibe Chat donations.

## Features

- Create Razorpay orders
- Verify payment signatures
- Webhook support for payment events
- CORS enabled for cross-origin requests
- Secure payment processing

## Setup

### 1. Install Dependencies

```bash
cd payment-backend
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your Razorpay credentials:

```bash
cp .env.example .env
```

Edit `.env` with your Razorpay API keys:

```env
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx
PORT=3000
NODE_ENV=development
```

### 3. Get Razorpay API Keys

1. Sign up at [Razorpay Dashboard](https://dashboard.razorpay.com)
2. Navigate to **Settings → API Keys**
3. Generate Test Mode keys for development
4. Use Live Mode keys for production

## Running the Server

### Development Mode (with auto-reload)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### 1. Health Check

```
GET /health
```

Response:
```json
{
  "status": "ok",
  "message": "Xibe Payment Backend is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 2. Create Order

```
POST /api/create-order
Content-Type: application/json

{
  "amount": 100,
  "currency": "INR",
  "receipt": "receipt_001"
}
```

Response:
```json
{
  "success": true,
  "orderId": "order_xxxxxxxxxxxxx",
  "amount": 10000,
  "currency": "INR",
  "keyId": "rzp_test_xxxxxxxxxx"
}
```

### 3. Verify Payment

```
POST /api/verify-payment
Content-Type: application/json

{
  "orderId": "order_xxxxxxxxxxxxx",
  "paymentId": "pay_xxxxxxxxxxxxx",
  "signature": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

Response:
```json
{
  "success": true,
  "verified": true,
  "message": "Payment verified successfully",
  "paymentId": "pay_xxxxxxxxxxxxx"
}
```

### 4. Get Payment Details

```
GET /api/payment/:paymentId
```

Response:
```json
{
  "success": true,
  "payment": {
    "id": "pay_xxxxxxxxxxxxx",
    "amount": 100,
    "currency": "INR",
    "status": "captured",
    "method": "card",
    "email": "user@example.com",
    "contact": "9876543210",
    "createdAt": 1234567890
  }
}
```

### 5. Webhook (for Razorpay events)

```
POST /api/webhook
X-Razorpay-Signature: signature_here
Content-Type: application/json

{
  "event": "payment.captured",
  "payload": { ... }
}
```

## Deployment

### Deploy to any Node.js hosting platform:

1. **Heroku**
   ```bash
   heroku create xibe-payment-backend
   heroku config:set RAZORPAY_KEY_ID=your_key
   heroku config:set RAZORPAY_KEY_SECRET=your_secret
   git push heroku main
   ```

2. **Vercel**
   - Install Vercel CLI: `npm i -g vercel`
   - Run: `vercel`
   - Add environment variables in Vercel dashboard

3. **Railway**
   - Connect your GitHub repo
   - Add environment variables
   - Deploy automatically

4. **DigitalOcean/AWS/GCP**
   - Set up Node.js server
   - Install dependencies: `npm install`
   - Set environment variables
   - Run with PM2: `pm2 start server.js`

### Update Flutter App

After deployment, update the Flutter app's payment service with your backend URL:

```dart
// lib/services/payment_service.dart
static const String _backendUrl = 'https://your-backend-url.com';
```

## Testing

### Test Payment Flow

1. Start the backend server
2. Use Razorpay test cards:
   - Success: `4111 1111 1111 1111`
   - Failure: `4000 0000 0000 0002`
3. Test UPI IDs:
   - Success: `success@razorpay`
   - Failure: `failure@razorpay`

## Security Notes

- Never commit `.env` file to version control
- Use environment variables for all sensitive data
- Enable webhook signature verification in production
- Use HTTPS in production
- Implement rate limiting for API endpoints
- Add authentication if needed

## Support

For issues or questions:
- Razorpay Documentation: https://razorpay.com/docs/
- Razorpay Support: support@razorpay.com

## License

MIT

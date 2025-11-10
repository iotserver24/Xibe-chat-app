# Payment Setup Guide

Complete guide to setting up the Razorpay donation system.

## Overview

Xibe Chat includes an integrated donation system powered by Razorpay, allowing users to support development through secure in-app payments.

## Features

- **Multiple Payment Methods**: Cards, UPI, Net Banking, Wallets
- **Multi-Currency**: INR and USD supported
- **Secure**: Powered by Razorpay
- **Cross-Platform**: Works on all platforms

---

## Quick Setup (5 Minutes)

### 1. Get Razorpay API Keys

1. Sign up at [Razorpay Dashboard](https://dashboard.razorpay.com)
2. Complete KYC verification
3. Get your API keys:
   - Key ID: `rzp_test_...` or `rzp_live_...`
   - Key Secret: `...`

### 2. Deploy Payment Backend

**Option A: Using Docker/Coolify**

See [payment-backend/COOLIFY_DEPLOYMENT.md](../payment-backend/COOLIFY_DEPLOYMENT.md)

**Option B: Manual Deployment**

1. Clone payment backend:
   ```bash
   cd payment-backend
   npm install
   ```

2. Set environment variables:
   ```bash
   export RAZORPAY_KEY_ID=rzp_test_...
   export RAZORPAY_KEY_SECRET=...
   export RAZORPAY_WEBHOOK_SECRET=whsec_...
   ```

3. Start server:
   ```bash
   node server.js
   ```

### 3. Configure App

Set `PAYMENT_BACKEND_URL` environment variable or build-time variable:

```bash
flutter run --dart-define=PAYMENT_BACKEND_URL=https://your-backend-url.com
```

Or set in GitHub Actions secrets.

---

## Backend Configuration

### Environment Variables

```bash
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxx
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxx
PORT=3000
```

### API Endpoints

- `POST /api/create-order` - Create payment order
- `POST /api/verify-payment` - Verify payment
- `GET /health` - Health check
- `POST /api/webhook/razorpay` - Webhook handler

---

## Webhook Setup

### 1. Configure Webhook in Razorpay Dashboard

1. Go to Settings → Webhooks
2. Add webhook URL: `https://your-backend-url.com/api/webhook/razorpay`
3. Select events:
   - `payment.captured`
   - `payment.failed`
4. Copy webhook secret

### 2. Set Webhook Secret

```bash
export RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxx
```

---

## Testing

### Test Mode

Use Razorpay test keys:
- Key ID: `rzp_test_...`
- Test cards: See Razorpay test cards documentation

### Test Payment Flow

1. Open app → Settings → Support → Donate
2. Select amount
3. Complete test payment
4. Verify in Razorpay Dashboard

---

## Production Deployment

### 1. Switch to Live Keys

Update environment variables with live keys:
```bash
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxx
```

### 2. Update Webhook URL

Set production webhook URL in Razorpay Dashboard.

### 3. Update App Backend URL

Set `PAYMENT_BACKEND_URL` to production URL.

---

## Security

### Best Practices

- Never commit API keys
- Use environment variables
- Enable HTTPS only
- Validate webhook signatures
- Monitor transactions

### Webhook Security

Always verify webhook signatures:

```javascript
const crypto = require('crypto');

const signature = req.headers['x-razorpay-signature'];
const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

const expectedSignature = crypto
  .createHmac('sha256', webhookSecret)
  .update(JSON.stringify(req.body))
  .digest('hex');

if (signature !== expectedSignature) {
  return res.status(400).send('Invalid signature');
}
```

---

## Troubleshooting

### Payment Not Processing

1. Check backend URL is correct
2. Verify API keys are valid
3. Check backend logs
4. Verify webhook is configured

### Webhook Not Receiving Events

1. Check webhook URL is accessible
2. Verify webhook secret matches
3. Check Razorpay Dashboard webhook logs
4. Review backend logs

---

## Additional Resources

- [Razorpay Documentation](https://razorpay.com/docs/)
- [Payment Backend README](../payment-backend/README.md)
- [Razorpay Integration Guide](../RAZORPAY_INTEGRATION.md)


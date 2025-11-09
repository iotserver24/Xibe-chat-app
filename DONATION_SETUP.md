# Razorpay Donation Feature Setup Guide

This guide will help you set up the Razorpay donation feature in Xibe Chat.

## Overview

The donation feature allows users to support Xibe Chat development through Razorpay payment gateway. It includes:

- **Node.js Backend** - Handles order creation and payment verification
- **Flutter Frontend** - Cross-platform donation UI
- **Multi-OS Support** - Works on Android, iOS, Web, Windows, macOS, and Linux

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│  Flutter App    │ ──────> │  Node.js Backend │ ──────> │  Razorpay   │
│  (All Platforms)│ <────── │  (Payment Server)│ <────── │  API        │
└─────────────────┘         └──────────────────┘         └─────────────┘
```

## Prerequisites

1. **Razorpay Account**
   - Sign up at [Razorpay Dashboard](https://dashboard.razorpay.com)
   - Complete KYC verification
   - Get API keys (Test & Live)

2. **Node.js Environment**
   - Node.js v14 or higher
   - npm or yarn package manager

3. **Flutter Environment**
   - Flutter SDK 3.0+
   - Android SDK (for Android builds)

## Setup Instructions

### Part 1: Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd payment-backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```

4. **Edit `.env` file with your Razorpay credentials:**
   ```env
   RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxxxxxx
   RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx
   PORT=3000
   NODE_ENV=development
   ```

   **Get your API keys:**
   - Login to [Razorpay Dashboard](https://dashboard.razorpay.com)
   - Go to Settings → API Keys
   - Generate Test Mode keys (for development)
   - Generate Live Mode keys (for production)

5. **Start the backend server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev
   
   # Production mode
   npm start
   ```

6. **Test the backend:**
   ```bash
   curl http://localhost:3000/health
   ```

   Expected response:
   ```json
   {
     "status": "ok",
     "message": "Xibe Payment Backend is running",
     "timestamp": "2024-01-01T00:00:00.000Z"
   }
   ```

### Part 2: Deploy Backend (Production)

You need to deploy the backend to a hosting service. Here are some options:

#### Option A: Heroku (Free tier available)

```bash
# Install Heroku CLI
npm install -g heroku

# Login to Heroku
heroku login

# Create new app
heroku create xibe-payment-backend

# Set environment variables
heroku config:set RAZORPAY_KEY_ID=your_live_key_id
heroku config:set RAZORPAY_KEY_SECRET=your_live_key_secret

# Deploy
git subtree push --prefix payment-backend heroku main

# Open app
heroku open
```

#### Option B: Vercel (Free tier available)

```bash
# Install Vercel CLI
npm i -g vercel

# Navigate to backend directory
cd payment-backend

# Deploy
vercel

# Follow prompts and add environment variables in Vercel dashboard
```

#### Option C: Railway (Free tier available)

1. Go to [Railway.app](https://railway.app)
2. Connect your GitHub repository
3. Select the `payment-backend` folder
4. Add environment variables in Railway dashboard
5. Deploy automatically

#### Option D: DigitalOcean/AWS/GCP

```bash
# SSH into your server
ssh user@your-server-ip

# Clone repository
git clone https://github.com/your-username/xibe-chat.git
cd xibe-chat/payment-backend

# Install dependencies
npm install

# Set up environment variables
nano .env
# (Add your Razorpay keys)

# Install PM2 for process management
npm install -g pm2

# Start the server
pm2 start server.js --name xibe-payment

# Make it run on startup
pm2 startup
pm2 save
```

### Part 3: Flutter App Configuration

1. **Update backend URL in Flutter app:**

   Edit `lib/services/payment_service.dart`:
   ```dart
   // Change this line from:
   static const String _backendUrl = 'http://localhost:3000';
   
   // To your deployed backend URL:
   static const String _backendUrl = 'https://your-backend-url.com';
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Test on different platforms:**

   **Android:**
   ```bash
   flutter run -d android
   ```

   **iOS:** (if on macOS)
   ```bash
   flutter run -d ios
   ```

   **Web:**
   ```bash
   flutter run -d chrome
   ```

   **Desktop:**
   ```bash
   flutter run -d windows  # or macos or linux
   ```

## Platform-Specific Notes

### Android
- Minimum SDK: API Level 21 (Android 5.0)
- ProGuard rules included for Razorpay
- Works with all payment methods (Cards, UPI, Wallets, Net Banking)

### iOS
- Minimum iOS version: 10.0
- UPI intent support included
- Works with all payment methods

### Web
- Custom implementation for web payments
- Opens Razorpay checkout in browser
- Alternative: Shows payment instructions with UPI details

### Desktop (Windows/Linux/macOS)
- Shows payment instructions dialog
- Provides payment link to open in browser
- Alternative payment methods displayed (UPI, Bank Transfer)

## Testing Payments

### Test Mode Credentials

**Test Cards:**
- **Success:** 4111 1111 1111 1111
- **Failure:** 4000 0000 0000 0002
- CVV: Any 3 digits
- Expiry: Any future date

**Test UPI IDs:**
- **Success:** success@razorpay
- **Failure:** failure@razorpay

**Test Wallets:**
- All wallets work in test mode
- No real money is deducted

### Verify Test Payments

1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com)
2. Navigate to Transactions → Payments
3. Check payment status (should be "Captured" for success)

## Going Live

### Pre-Launch Checklist

1. **Complete KYC in Razorpay Dashboard**
   - Submit required documents
   - Wait for approval

2. **Generate Live API Keys**
   - Switch to Live Mode in Dashboard
   - Generate and save Live keys securely

3. **Update Environment Variables**
   - Update backend `.env` with Live keys
   - Redeploy backend

4. **Configure Payment Methods**
   - Enable/disable payment methods in Dashboard
   - Some methods require approval

5. **Set Up Webhooks** (Optional but recommended)
   - Add webhook URL: `https://your-backend.com/api/webhook`
   - Select events: payment.authorized, payment.failed, order.paid
   - Copy webhook secret to backend `.env`

6. **Test Live Payments**
   - Make a small real payment (₹10)
   - Verify payment is captured
   - Test refund functionality

### Security Best Practices

1. **Never expose API secrets in client code**
   - Always create orders on backend
   - Verify payments on backend

2. **Use HTTPS for all API calls**
   - Backend must use HTTPS in production
   - Use SSL certificates

3. **Implement rate limiting**
   - Prevent abuse of payment API
   - Add rate limiting to backend endpoints

4. **Verify payment signatures**
   - Always verify on server-side
   - Don't trust client-side verification alone

5. **Store sensitive data securely**
   - Use environment variables
   - Never commit API keys to Git

## Customization

### Changing Donation Amounts

Edit `lib/screens/donate_screen.dart`:

```dart
// Line ~32
final List<String> _predefinedAmounts = ['50', '100', '200', '500', '1000'];

// Add or modify amounts as needed
final List<String> _predefinedAmounts = ['25', '50', '100', '250', '500', '1000', '2000'];
```

### Customizing Payment UI

The donation screen can be customized:
- Theme colors
- Logo/branding
- Payment method display
- Success/error messages
- Support options

### Adding Payment Success Actions

Edit the `_handlePaymentSuccess` method in `donate_screen.dart` to:
- Send confirmation emails
- Store payment in database
- Unlock premium features
- Track analytics

## Troubleshooting

### Backend Issues

**Problem:** Backend not starting
```bash
# Check if port is in use
netstat -ano | findstr :3000  # Windows
lsof -i :3000  # Linux/macOS

# Change port in .env
PORT=3001
```

**Problem:** API keys not working
- Verify keys are correct (no extra spaces)
- Check if using Test keys in test mode
- Ensure keys are not expired

### Flutter Issues

**Problem:** Razorpay not working on Android
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Problem:** Web payment not opening
- Check if backend URL is correct
- Verify CORS is enabled on backend
- Test backend health endpoint

### Payment Issues

**Problem:** Payment verification fails
- Check backend logs for signature mismatch
- Verify webhook secret is correct
- Ensure order ID matches

**Problem:** Payment success but not credited
- Check Razorpay Dashboard for payment status
- Verify webhook is configured correctly
- Check backend logs for errors

## Support

### Razorpay Support
- Documentation: https://razorpay.com/docs/
- Email: support@razorpay.com
- Dashboard Support: Available in Razorpay Dashboard

### Xibe Chat Support
- GitHub Issues: https://github.com/iotserver24/xibe-chat/issues
- Email: anishkumar.tech

## License

This donation feature is part of Xibe Chat and follows the same license.

---

**Note:** Replace placeholder URLs, UPI IDs, and other details with your actual information before going live.

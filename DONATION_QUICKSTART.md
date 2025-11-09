# Donation Feature Quick Start

Get your Razorpay donation feature up and running in 5 minutes!

## Quick Setup

### 1. Get Razorpay API Keys (2 minutes)

1. Sign up at [Razorpay](https://dashboard.razorpay.com)
2. Go to **Settings → API Keys**
3. Click **Generate Test Key** (for testing)
4. Save your `Key ID` and `Key Secret`

### 2. Setup Backend (2 minutes)

```bash
# Navigate to backend folder
cd payment-backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your keys
nano .env  # or use any text editor
```

Add your keys to `.env`:
```env
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxx
PORT=3000
```

Start the server:
```bash
npm run dev
```

You should see:
```
🚀 Xibe Payment Backend running on port 3000
```

### 3. Update Flutter App (1 minute)

Edit `lib/services/payment_service.dart`:

```dart
// For local testing, use:
static const String _backendUrl = 'http://localhost:3000';

// For Android emulator, use:
static const String _backendUrl = 'http://10.0.2.2:3000';

// For production, use your deployed URL:
static const String _backendUrl = 'https://your-backend.com';
```

Run the app:
```bash
flutter run
```

### 4. Test Donation Flow

1. Open the app
2. Go to **Settings → Support → Donate**
3. Select amount (e.g., ₹100)
4. Click **Proceed to Payment**
5. Use test card: `4111 1111 1111 1111`
6. CVV: `123`, Expiry: Any future date
7. Click **Pay**

✅ Success! You should see a "Thank You" message.

## Android Emulator Setup

If testing on Android emulator, the backend URL should be:
```dart
static const String _backendUrl = 'http://10.0.2.2:3000';
```

`10.0.2.2` is the special IP that Android emulator uses to access host machine's localhost.

## Physical Device Testing

If testing on a physical device connected to the same network:

1. Find your computer's local IP:
   ```bash
   # Windows
   ipconfig
   
   # Linux/macOS
   ifconfig
   ```

2. Update backend URL:
   ```dart
   static const String _backendUrl = 'http://192.168.x.x:3000';
   ```

3. Make sure your firewall allows connections on port 3000

## Deploy for Production

### Quick Deploy Options

**Option 1: Vercel (Easiest)**
```bash
cd payment-backend
npm i -g vercel
vercel
# Follow prompts, add env vars in dashboard
```

**Option 2: Heroku**
```bash
heroku create xibe-payment
heroku config:set RAZORPAY_KEY_ID=rzp_live_xxx
heroku config:set RAZORPAY_KEY_SECRET=xxx
git subtree push --prefix payment-backend heroku main
```

**Option 3: Railway**
1. Go to [Railway.app](https://railway.app)
2. Connect GitHub repo
3. Select `payment-backend` folder
4. Add environment variables
5. Deploy!

After deployment, update Flutter app with production URL.

## Going Live

1. **Get Live API Keys**
   - Complete KYC in Razorpay Dashboard
   - Generate Live Mode keys
   - Update backend `.env` with Live keys

2. **Update Flutter App**
   - Change `_backendUrl` to your production URL
   - Rebuild and release app

3. **Test with Real Payment**
   - Make a small payment (₹10)
   - Verify it appears in Razorpay Dashboard

## Troubleshooting

### "Backend not reachable"
- Check if backend is running: `curl http://localhost:3000/health`
- Verify URL in `payment_service.dart`
- Check firewall settings

### "Payment verification failed"
- Check backend logs
- Verify API keys are correct
- Ensure no spaces in environment variables

### "Razorpay not opening on Android"
- Run `flutter clean && flutter pub get`
- Check minSdkVersion is 21+ in `android/app/build.gradle`
- Rebuild app

### "Web payment not working"
- Web uses custom implementation
- Shows payment instructions dialog
- User can open payment link in browser

## Need Help?

- **Razorpay Docs**: https://razorpay.com/docs/
- **Razorpay Support**: support@razorpay.com
- **GitHub Issues**: https://github.com/iotserver24/xibe-chat/issues

## Next Steps

- Customize donation amounts in `donate_screen.dart`
- Add your own branding and colors
- Set up webhooks for payment notifications
- Add analytics to track donations
- Implement premium features for donors

Happy fundraising! 🎉

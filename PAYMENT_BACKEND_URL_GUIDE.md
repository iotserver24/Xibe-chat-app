# Payment Backend URL Configuration Guide

## 📍 The URL You Need

Your payment backend will be hosted at a domain you choose. Here's everything you need to know about configuring it.

---

## 🌐 Recommended URL Structure

### Option 1: Subdomain (Recommended)

```
Backend URL: https://payment.yourdomain.com
Example: https://payment.xibechat.app
```

**Pros:**
- Clean separation
- Easy to remember
- Standard practice

**DNS Setup:**
```
Type: A
Name: payment
Value: YOUR_VPS_IP
TTL: 3600
```

### Option 2: API Subdomain

```
Backend URL: https://api.yourdomain.com
Example: https://api.xibechat.app
```

**Pros:**
- Can host multiple APIs
- Professional looking
- Scalable

**DNS Setup:**
```
Type: A
Name: api
Value: YOUR_VPS_IP
TTL: 3600
```

### Option 3: Separate Domain

```
Backend URL: https://payments.xibechat.app
Example: https://payments.xibechat.app
```

**Pros:**
- Complete isolation
- Can be on different server
- Clear purpose

---

## ⚙️ GitHub Actions Variable

### Variable Configuration

**Name (EXACT):** `PAYMENT_BACKEND_URL`

**Value Format:** `https://payment.yourdomain.com`

**Examples:**
- `https://payment.xibechat.app`
- `https://api.xibechat.app`
- `https://payments.xibechat.app`

### How to Set It

1. **Go to GitHub Repository**
   - Navigate to your Xibe Chat repository
   - URL: `https://github.com/yourusername/xibe-chat`

2. **Access Settings**
   - Click the "Settings" tab (top menu)

3. **Navigate to Secrets and Variables**
   - In left sidebar: "Secrets and variables" → "Actions"

4. **Add Variable**
   - Click "Variables" tab (not Secrets)
   - Click "New repository variable"
   - Name: `PAYMENT_BACKEND_URL`
   - Value: `https://payment.yourdomain.com` (your actual URL)
   - Click "Add variable"

5. **Verify**
   - You should see it in the list
   - Shows as: `PAYMENT_BACKEND_URL = https://payment.yourdomain.com`

---

## 🐳 Coolify Configuration

### Step 1: Create Application

1. **Log into Coolify**
   - URL: `http://your-vps-ip:8000`

2. **Create New Resource**
   - Click "New Resource"
   - Select "Application"

3. **Configure Source**
   - **Type**: Public Git Repository
   - **URL**: `https://github.com/yourusername/xibe-chat.git`
   - **Branch**: `main`
   - **Base Directory**: `payment-backend`

4. **Build Settings**
   - **Build Pack**: Docker
   - **Dockerfile Path**: `./Dockerfile` (auto-detected)
   - **Port**: `3000`

### Step 2: Environment Variables

Add these in Coolify's "Environment Variables" section:

```env
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx
NODE_ENV=production
PORT=3000
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxx
```

**Mark as Secret:**
- `RAZORPAY_KEY_ID` ✅
- `RAZORPAY_KEY_SECRET` ✅
- `RAZORPAY_WEBHOOK_SECRET` ✅

### Step 3: Configure Domain

1. **In Coolify Domain Settings**
   - Add domain: `payment.yourdomain.com`
   - Enable "Generate SSL Certificate"

2. **In Your DNS Provider**
   - Add A record:
     ```
     Type: A
     Name: payment
     Value: YOUR_VPS_IP
     TTL: 3600
     ```

3. **Wait for SSL**
   - Coolify will automatically get Let's Encrypt SSL
   - Usually takes 1-5 minutes
   - Green checkmark when ready

### Step 4: Deploy

1. Click "Deploy" button
2. Monitor build logs
3. Wait for "Running" status
4. Test: `curl https://payment.yourdomain.com/health`

---

## 🔄 How It All Works Together

### Build Process Flow

```
1. You push code to GitHub
   ↓
2. GitHub Actions triggers
   ↓
3. Reads PAYMENT_BACKEND_URL variable
   ↓
4. Creates lib/config/payment_config.dart with your URL
   ↓
5. Builds Flutter app with --dart-define=PAYMENT_BACKEND_URL=...
   ↓
6. App is built with your production backend URL
   ↓
7. Users download app → connects to your backend → makes payments
```

### At Runtime

```
User opens Donate screen
   ↓
Flutter app reads PaymentConfig.backendUrl
   ↓
Calls: https://payment.yourdomain.com/api/create-order
   ↓
Your backend (on Coolify) receives request
   ↓
Backend talks to Razorpay
   ↓
Returns order ID to Flutter app
   ↓
User completes payment
   ↓
Flutter app verifies with backend
   ↓
Backend verifies signature
   ↓
Success!
```

---

## 🧪 Testing Different URLs

### Local Development

```bash
flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000
```

Backend runs on your machine.

### Android Emulator

```bash
flutter run --dart-define=PAYMENT_BACKEND_URL=http://10.0.2.2:3000
```

`10.0.2.2` = localhost from Android emulator's perspective.

### Production Testing

```bash
flutter run --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
```

Uses your live backend.

### Production Build

```bash
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
```

Builds APK with production URL baked in.

---

## ✅ Complete Setup Example

Let's say your domain is `xibechat.app`:

### 1. DNS Configuration

```
Type: A
Name: payment
Value: 123.45.67.89 (your VPS IP)
TTL: 3600
```

Result: `payment.xibechat.app` points to your VPS

### 2. Coolify Setup

- **Application Name**: xibe-payment-backend
- **Domain**: payment.xibechat.app
- **Base Directory**: payment-backend
- **Environment Variables**: (Razorpay keys)

### 3. GitHub Actions Variable

```
Name: PAYMENT_BACKEND_URL
Value: https://payment.xibechat.app
```

### 4. Test Backend

```bash
curl https://payment.xibechat.app/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "Xibe Payment Backend is running",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### 5. Build Flutter App

GitHub Actions automatically builds with:
```bash
--dart-define=PAYMENT_BACKEND_URL=https://payment.xibechat.app
```

### 6. Test in App

Open app → Settings → Support → Donate
- Backend URL should be: `https://payment.xibechat.app`
- Payment flow should work end-to-end

---

## 🔍 Verifying Your Configuration

### Check Backend URL in App

Add this code to print current configuration:

```dart
import 'package:xibe_chat/services/payment_service.dart';

// In your app's main or debug screen:
PaymentService.printConfiguration();
```

Output should show:
```
=== Payment Service Configuration ===
Backend URL: https://payment.xibechat.app
Environment: production
Is Production: true
Is Local: false
====================================
```

### Check If Backend Is Accessible

```bash
# Health check
curl https://payment.yourdomain.com/health

# Should return 200 OK with JSON

# Test order creation (with your Razorpay keys set up)
curl -X POST https://payment.yourdomain.com/api/create-order \
  -H "Content-Type: application/json" \
  -d '{"amount": 10, "currency": "INR"}'

# Should return order details
```

---

## 🚨 Common Mistakes to Avoid

### 1. Wrong Variable Name

❌ Wrong:
- `BACKEND_URL`
- `PAYMENT_URL`
- `RAZORPAY_BACKEND_URL`

✅ Correct:
- `PAYMENT_BACKEND_URL`

### 2. Missing HTTPS

❌ Wrong:
- `http://payment.yourdomain.com` (in production)

✅ Correct:
- `https://payment.yourdomain.com`

### 3. Trailing Slash

❌ Wrong:
- `https://payment.yourdomain.com/`

✅ Correct:
- `https://payment.yourdomain.com`

### 4. Wrong Port

❌ Wrong:
- `https://payment.yourdomain.com:3000`

✅ Correct:
- `https://payment.yourdomain.com` (Coolify handles ports internally)

### 5. DNS Not Propagated

- Wait 1-24 hours for DNS propagation
- Check with: `nslookup payment.yourdomain.com`
- Should show your VPS IP

---

## 📋 Quick Reference

### The Three Places You Configure the URL

1. **Coolify Domain Settings**
   - `payment.yourdomain.com`
   - For SSL and routing

2. **GitHub Actions Variable**
   - Name: `PAYMENT_BACKEND_URL`
   - Value: `https://payment.yourdomain.com`
   - For building app

3. **DNS Provider**
   - A record: `payment` → `YOUR_VPS_IP`
   - For domain resolution

### Commands Cheat Sheet

```bash
# Test backend locally
curl http://localhost:3000/health

# Test backend in production
curl https://payment.yourdomain.com/health

# Run Flutter with local backend
flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000

# Run Flutter with production backend
flutter run --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com

# Build for production
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com

# Check DNS
nslookup payment.yourdomain.com

# Check SSL
curl -I https://payment.yourdomain.com

# View Coolify logs
docker logs -f coolify-container-name
```

---

## 🎯 Your Action Items

1. **Choose Your URL**
   - [ ] Decide on subdomain (e.g., `payment.yourdomain.com`)
   - [ ] Write it down: `https://___________________`

2. **Configure DNS**
   - [ ] Log into DNS provider
   - [ ] Add A record: `payment` → `YOUR_VPS_IP`
   - [ ] Wait for propagation (check with `nslookup`)

3. **Deploy to Coolify**
   - [ ] Create application
   - [ ] Set environment variables
   - [ ] Configure domain
   - [ ] Deploy and wait for SSL

4. **Set GitHub Variable**
   - [ ] Go to GitHub repository settings
   - [ ] Add variable: `PAYMENT_BACKEND_URL`
   - [ ] Value: `https://payment.yourdomain.com`

5. **Test Everything**
   - [ ] Test backend: `curl https://payment.yourdomain.com/health`
   - [ ] Build app with new URL
   - [ ] Test payment flow end-to-end

---

## 📞 Need Help?

- **Full Coolify Guide**: See [payment-backend/COOLIFY_DEPLOYMENT.md](payment-backend/COOLIFY_DEPLOYMENT.md)
- **GitHub Actions Guide**: See [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)
- **All Documentation**: See [DONATION_DOCS_INDEX.md](DONATION_DOCS_INDEX.md)

---

**Remember:**
- Variable Name: `PAYMENT_BACKEND_URL`
- Format: `https://payment.yourdomain.com`
- No trailing slash
- Must use HTTPS in production

🚀 You're all set!

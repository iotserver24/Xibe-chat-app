# Payment Backend Deployment - Quick Summary

## 🎯 What You Need to Know

### GitHub Actions Variable

**Variable Name:** `PAYMENT_BACKEND_URL`

**Your URL will be:** `https://payment.yourdomain.com` (or whatever subdomain you choose)

**Where to set it:**
1. Go to GitHub Repository → Settings
2. Click "Secrets and variables" → "Actions"
3. Click "Variables" tab
4. Add new variable:
   - Name: `PAYMENT_BACKEND_URL`
   - Value: `https://payment.yourdomain.com`

---

## 🐳 Docker Deployment (Coolify)

### Files Created for You:

1. **`payment-backend/Dockerfile`** - Docker image configuration
2. **`payment-backend/docker-compose.yml`** - For local testing
3. **`payment-backend/.dockerignore`** - Optimizes build

### Deployment Steps:

1. **Push to GitHub** (files are ready)

2. **In Coolify:**
   - Create new application
   - Point to your repository
   - Set base directory: `payment-backend`
   - Coolify will auto-detect Dockerfile

3. **Set Environment Variables in Coolify:**
   ```
   RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxx
   RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxx
   NODE_ENV=production
   PORT=3000
   ```

4. **Configure Domain:**
   - In Coolify, set domain: `payment.yourdomain.com`
   - Add DNS A record pointing to your VPS IP
   - Wait for SSL (automatic via Coolify)

5. **Deploy!**
   - Click "Deploy" in Coolify
   - Monitor logs
   - Test: `curl https://payment.yourdomain.com/health`

---

## 📱 Flutter App Configuration

### Automatic via GitHub Actions

Your builds will automatically use the `PAYMENT_BACKEND_URL` variable when you:

1. Set the GitHub Actions variable (as shown above)
2. Build will automatically inject the URL

### Manual Testing

```bash
# Local development
flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000

# Production testing
flutter run --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com

# Build for production
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
```

---

## 📚 Complete Documentation

| What You Need | Document | Time |
|---------------|----------|------|
| Quick local setup | [DONATION_QUICKSTART.md](DONATION_QUICKSTART.md) | 5 min |
| Docker/Coolify deployment | [payment-backend/COOLIFY_DEPLOYMENT.md](payment-backend/COOLIFY_DEPLOYMENT.md) | 30 min |
| GitHub Actions setup | [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) | 10 min |
| All documentation | [DONATION_DOCS_INDEX.md](DONATION_DOCS_INDEX.md) | - |

---

## ✅ Your Checklist

### Backend Deployment

- [ ] Get Razorpay API keys (from dashboard.razorpay.com)
- [ ] Create Coolify application
- [ ] Point to your repository (`payment-backend` folder)
- [ ] Set environment variables in Coolify
- [ ] Configure domain (`payment.yourdomain.com`)
- [ ] Add DNS A record
- [ ] Deploy and wait for SSL
- [ ] Test: `curl https://payment.yourdomain.com/health`

### Flutter App Configuration

- [ ] Set GitHub Actions variable `PAYMENT_BACKEND_URL`
- [ ] Value: `https://payment.yourdomain.com`
- [ ] Push changes (if any)
- [ ] GitHub Actions will build with correct URL
- [ ] Download and test built APK/app

### Testing

- [ ] Backend health endpoint responds
- [ ] Create test order works
- [ ] Flutter app connects to backend
- [ ] Test payment with test card
- [ ] Verify payment success flow

---

## 🚀 Quick Start Commands

### Backend (Local Testing)

```bash
cd payment-backend
npm install
cp .env.example .env
# Edit .env with your Razorpay test keys
npm run dev
```

### Test Backend

```bash
curl http://localhost:3000/health
```

### Flutter (Local Testing)

```bash
flutter run --dart-define=PAYMENT_BACKEND_URL=http://localhost:3000
```

### Docker (Local Testing)

```bash
cd payment-backend
docker build -t xibe-payment .
docker run -p 3000:3000 \
  -e RAZORPAY_KEY_ID=rzp_test_xxx \
  -e RAZORPAY_KEY_SECRET=xxx \
  xibe-payment
```

### Production Build

```bash
flutter build apk --release --dart-define=PAYMENT_BACKEND_URL=https://payment.yourdomain.com
```

---

## 🌐 Recommended Setup

### Domain Structure

```
payment.yourdomain.com    → Payment Backend (Coolify)
yourdomain.com           → Main App/Website
```

### DNS Configuration

```
Type: A
Name: payment
Value: YOUR_VPS_IP
TTL: 3600
```

### GitHub Actions Variable

```
Name: PAYMENT_BACKEND_URL
Value: https://payment.yourdomain.com
```

---

## 🔧 What's Been Set Up

### Backend Features

- ✅ Express.js server with Razorpay integration
- ✅ Order creation endpoint
- ✅ Payment verification endpoint
- ✅ Webhook support
- ✅ Health check endpoint
- ✅ CORS enabled
- ✅ Dockerfile ready
- ✅ Docker Compose for testing
- ✅ Comprehensive error handling

### Flutter Integration

- ✅ Payment service with API communication
- ✅ Donation screen with UI
- ✅ Build-time configuration support
- ✅ Payment flow handling
- ✅ Multi-platform support
- ✅ Success/error dialogs

### Documentation

- ✅ Quick start guide (5 minutes)
- ✅ Complete setup guide
- ✅ Docker/Coolify deployment guide
- ✅ GitHub Actions setup guide
- ✅ Technical API documentation
- ✅ FAQ and troubleshooting
- ✅ Deployment guide for multiple platforms

---

## 💡 Pro Tips

1. **Use Test Mode First**
   - Get test keys from Razorpay
   - Test everything locally
   - Then switch to Live mode

2. **Monitor Your Backend**
   - Check Coolify dashboard
   - View Docker logs: `docker logs -f container-name`
   - Monitor Razorpay Dashboard

3. **Keep Secrets Secret**
   - Never commit `.env` files
   - Use Coolify's secret management
   - Mark sensitive variables as "Secret"

4. **Test End-to-End**
   - Backend health check
   - Create test order
   - Complete test payment
   - Verify in Razorpay Dashboard

---

## 🆘 Quick Troubleshooting

### Backend not accessible

```bash
# Check if container is running
docker ps | grep payment

# Check logs
docker logs container-name

# Test locally
curl http://localhost:3000/health
```

### Flutter can't connect

```bash
# Print configuration in app
PaymentService.printConfiguration();

# Check if URL is correct
# Should show your production URL, not localhost
```

### CORS errors

- Check `server.js` has `cors()` middleware enabled
- Verify domain is correct
- Ensure HTTPS is working

---

## 📞 Need Help?

1. **Documentation**: Check [DONATION_DOCS_INDEX.md](DONATION_DOCS_INDEX.md)
2. **FAQ**: See [DONATION_FAQ.md](DONATION_FAQ.md)
3. **Coolify**: See [payment-backend/COOLIFY_DEPLOYMENT.md](payment-backend/COOLIFY_DEPLOYMENT.md)
4. **GitHub Actions**: See [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

---

## ✨ What's Next?

1. Deploy backend to Coolify
2. Set GitHub Actions variable
3. Push code to GitHub
4. GitHub Actions builds app with correct URL
5. Download and test
6. Go live!

---

**Backend URL Variable**: `PAYMENT_BACKEND_URL`  
**Your URL Format**: `https://payment.yourdomain.com`  
**Docker**: Ready with Dockerfile  
**Coolify**: Fully compatible  
**GitHub Actions**: Integrated

🎉 Everything is ready for deployment!

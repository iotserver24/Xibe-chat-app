# Payment Backend Deployment Guide

Detailed guide for deploying the Xibe Chat payment backend to various platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Heroku Deployment](#heroku-deployment)
3. [Vercel Deployment](#vercel-deployment)
4. [Railway Deployment](#railway-deployment)
5. [DigitalOcean Deployment](#digitalocean-deployment)
6. [AWS Deployment](#aws-deployment)
7. [Google Cloud Deployment](#google-cloud-deployment)
8. [Docker Deployment](#docker-deployment)
9. [Post-Deployment](#post-deployment)

---

## Prerequisites

Before deploying, ensure you have:

- [ ] Razorpay account with KYC completed
- [ ] Live API keys from Razorpay Dashboard
- [ ] Payment backend code tested locally
- [ ] Git repository set up
- [ ] Domain name (optional but recommended)

---

## Heroku Deployment

### Step 1: Install Heroku CLI

```bash
# macOS
brew install heroku/brew/heroku

# Ubuntu/Debian
curl https://cli-assets.heroku.com/install.sh | sh

# Windows
# Download from https://devcenter.heroku.com/articles/heroku-cli
```

### Step 2: Login to Heroku

```bash
heroku login
```

### Step 3: Create Heroku App

```bash
# Create new app
heroku create xibe-payment-backend

# Or with custom name
heroku create your-custom-name
```

### Step 4: Set Environment Variables

```bash
heroku config:set RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxx
heroku config:set RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxx
heroku config:set NODE_ENV=production
heroku config:set RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxx
```

### Step 5: Deploy

```bash
# If backend is in subfolder (payment-backend/)
git subtree push --prefix payment-backend heroku main

# If backend is in root
git push heroku main
```

### Step 6: Verify Deployment

```bash
# Open app in browser
heroku open

# Check logs
heroku logs --tail

# Test health endpoint
curl https://your-app.herokuapp.com/health
```

### Heroku Configuration

Create `Procfile` in payment-backend/:
```
web: node server.js
```

Update `package.json`:
```json
{
  "engines": {
    "node": "18.x",
    "npm": "9.x"
  }
}
```

### Heroku Pricing

- **Free Tier**: Sleeps after 30 min inactivity
- **Hobby ($7/month)**: Never sleeps, custom domain
- **Standard ($25/month)**: Better performance, metrics

---

## Vercel Deployment

### Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

### Step 2: Login to Vercel

```bash
vercel login
```

### Step 3: Deploy

```bash
cd payment-backend
vercel
```

Follow the prompts:
- Setup and deploy? `Y`
- Which scope? `Your account`
- Link to existing project? `N`
- Project name? `xibe-payment-backend`
- In which directory is your code? `./`
- Override settings? `N`

### Step 4: Set Environment Variables

**Option A: Via CLI**
```bash
vercel env add RAZORPAY_KEY_ID
# Enter value when prompted

vercel env add RAZORPAY_KEY_SECRET
vercel env add NODE_ENV
vercel env add RAZORPAY_WEBHOOK_SECRET
```

**Option B: Via Dashboard**
1. Go to https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Environment Variables
4. Add all variables

### Step 5: Deploy to Production

```bash
vercel --prod
```

### Vercel Configuration

Create `vercel.json`:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "server.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "server.js"
    }
  ]
}
```

### Vercel Pricing

- **Hobby (Free)**: 100GB bandwidth, serverless functions
- **Pro ($20/month)**: Unlimited bandwidth, better support

---

## Railway Deployment

### Step 1: Sign Up

1. Go to https://railway.app
2. Sign up with GitHub

### Step 2: Create New Project

1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your repository
4. Railway will auto-detect Node.js

### Step 3: Configure Root Directory

If your backend is in a subfolder:
1. Go to Settings
2. Set Root Directory to `payment-backend`

### Step 4: Add Environment Variables

1. Go to Variables tab
2. Add:
   - `RAZORPAY_KEY_ID`
   - `RAZORPAY_KEY_SECRET`
   - `NODE_ENV` = `production`
   - `RAZORPAY_WEBHOOK_SECRET`

### Step 5: Deploy

Railway will automatically deploy on every push to main branch.

### Railway Configuration

Create `railway.json`:
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm start",
    "restartPolicyType": "ON_FAILURE"
  }
}
```

### Railway Pricing

- **Developer ($5/month)**: 500 hours, $5 usage credit
- **Usage-based**: Pay for what you use

---

## DigitalOcean Deployment

### Step 1: Create Droplet

1. Go to https://www.digitalocean.com
2. Create → Droplets
3. Choose:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic ($6/month)
   - **CPU options**: Regular Intel/AMD
   - Add SSH key

### Step 2: Connect to Droplet

```bash
ssh root@your-droplet-ip
```

### Step 3: Install Node.js

```bash
# Update packages
apt update && apt upgrade -y

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Verify installation
node --version
npm --version
```

### Step 4: Install Git

```bash
apt install git -y
```

### Step 5: Clone Repository

```bash
cd /var/www
git clone https://github.com/your-username/xibe-chat.git
cd xibe-chat/payment-backend
```

### Step 6: Install Dependencies

```bash
npm install
```

### Step 7: Configure Environment

```bash
nano .env
```

Add:
```env
RAZORPAY_KEY_ID=rzp_live_xxxx
RAZORPAY_KEY_SECRET=xxxx
PORT=3000
NODE_ENV=production
RAZORPAY_WEBHOOK_SECRET=whsec_xxxx
```

### Step 8: Install PM2

```bash
npm install -g pm2
```

### Step 9: Start Application

```bash
pm2 start server.js --name xibe-payment
pm2 startup
pm2 save
```

### Step 10: Configure Nginx

```bash
apt install nginx -y
nano /etc/nginx/sites-available/payment-backend
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable site:
```bash
ln -s /etc/nginx/sites-available/payment-backend /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### Step 11: Setup SSL with Let's Encrypt

```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d your-domain.com
```

### Step 12: Configure Firewall

```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
```

---

## AWS Deployment

### Using AWS Elastic Beanstalk

1. Install AWS CLI and EB CLI:
   ```bash
   pip install awsebcli
   ```

2. Initialize:
   ```bash
   cd payment-backend
   eb init
   ```

3. Create environment:
   ```bash
   eb create payment-backend-env
   ```

4. Set environment variables:
   ```bash
   eb setenv RAZORPAY_KEY_ID=xxx RAZORPAY_KEY_SECRET=xxx
   ```

5. Deploy:
   ```bash
   eb deploy
   ```

---

## Google Cloud Deployment

### Using Cloud Run

1. Install gcloud CLI

2. Build container:
   ```bash
   gcloud builds submit --tag gcr.io/YOUR_PROJECT/payment-backend
   ```

3. Deploy:
   ```bash
   gcloud run deploy payment-backend \
     --image gcr.io/YOUR_PROJECT/payment-backend \
     --platform managed \
     --allow-unauthenticated \
     --set-env-vars RAZORPAY_KEY_ID=xxx,RAZORPAY_KEY_SECRET=xxx
   ```

---

## Docker Deployment

### Create Dockerfile

Create `Dockerfile` in payment-backend/:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

### Create .dockerignore

```
node_modules
.env
npm-debug.log
.git
.gitignore
README.md
```

### Build and Run

```bash
# Build image
docker build -t xibe-payment-backend .

# Run container
docker run -d \
  -p 3000:3000 \
  -e RAZORPAY_KEY_ID=xxx \
  -e RAZORPAY_KEY_SECRET=xxx \
  --name xibe-payment \
  xibe-payment-backend
```

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  payment-backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAZORPAY_KEY_ID=${RAZORPAY_KEY_ID}
      - RAZORPAY_KEY_SECRET=${RAZORPAY_KEY_SECRET}
      - NODE_ENV=production
    restart: unless-stopped
```

Run:
```bash
docker-compose up -d
```

---

## Post-Deployment

### 1. Test Endpoints

```bash
# Health check
curl https://your-backend.com/health

# Create order (test)
curl -X POST https://your-backend.com/api/create-order \
  -H "Content-Type: application/json" \
  -d '{"amount": 10, "currency": "INR"}'
```

### 2. Update Flutter App

Edit `lib/services/payment_service.dart`:
```dart
static const String _backendUrl = 'https://your-backend.com';
```

### 3. Configure Webhooks

1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-backend.com/api/webhook`
3. Select events
4. Copy webhook secret
5. Add to backend environment variables

### 4. Monitor Application

**PM2 (for VPS):**
```bash
pm2 status
pm2 logs xibe-payment
pm2 monit
```

**Heroku:**
```bash
heroku logs --tail
heroku ps
```

**Cloud Platforms:**
- Check platform-specific dashboards
- Set up logging and monitoring
- Configure alerts

### 5. Set Up Backups

- Database backups (if using database)
- Regular server snapshots
- Environment variables backup

### 6. Performance Optimization

- Enable caching
- Use CDN for static assets
- Implement rate limiting
- Monitor response times

### 7. Security Checklist

- [ ] HTTPS enabled
- [ ] Environment variables secured
- [ ] CORS configured properly
- [ ] Rate limiting implemented
- [ ] Webhook signature verification enabled
- [ ] Firewall rules configured
- [ ] Regular security updates

---

## Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Find process using port 3000
lsof -i :3000
# Kill process
kill -9 <PID>
```

**PM2 not starting:**
```bash
pm2 delete all
pm2 start server.js --name xibe-payment
```

**Nginx configuration error:**
```bash
nginx -t  # Test configuration
journalctl -xe  # Check logs
```

**SSL certificate renewal:**
```bash
certbot renew --dry-run
```

---

## Support

- **Heroku**: https://help.heroku.com/
- **Vercel**: https://vercel.com/support
- **Railway**: https://railway.app/help
- **DigitalOcean**: https://www.digitalocean.com/community
- **Razorpay**: https://razorpay.com/docs/

---

**Last Updated:** January 2024

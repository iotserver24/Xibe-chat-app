# Coolify Deployment Guide for Xibe Payment Backend

This guide will help you deploy the payment backend to your VPS using Coolify.

## Prerequisites

- VPS with Coolify installed
- Domain name pointed to your VPS
- Razorpay API keys (Test or Live)
- GitHub repository access

## Deployment Steps

### Step 1: Prepare Your VPS

1. **Install Coolify** (if not already installed)
   ```bash
   curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
   ```

2. **Access Coolify Dashboard**
   - Open your browser and go to `http://your-vps-ip:8000`
   - Complete initial setup
   - Set up your domain

### Step 2: Create New Application in Coolify

1. **Go to Coolify Dashboard**
   - Click on "New Resource"
   - Select "Application"

2. **Choose Deployment Method**
   - Select "Public Git Repository"
   - Or "Private Git Repository" (if using SSH key)

3. **Configure Repository**
   - **Git Repository URL**: `https://github.com/your-username/xibe-chat.git`
   - **Branch**: `main` (or your deployment branch)
   - **Base Directory**: `payment-backend`
   - **Build Pack**: Docker

4. **Configure Build Settings**
   - **Dockerfile Location**: `./Dockerfile` (auto-detected)
   - **Port**: `3000`
   - **Health Check Path**: `/health`

### Step 3: Configure Environment Variables

Add the following environment variables in Coolify:

#### Required Variables

```env
# Razorpay API Keys
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx

# Server Configuration
NODE_ENV=production
PORT=3000

# Optional: Webhook Secret
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxx
```

**How to add in Coolify:**
1. Go to your application settings
2. Click on "Environment Variables"
3. Add each variable with its value
4. Mark sensitive variables (like API keys) as "Secret"

### Step 4: Configure Domain

1. **Add Domain in Coolify**
   - Go to "Domains" section
   - Add your domain: `payment.yourdomain.com`
   - Or subdomain: `api.yourdomain.com`

2. **DNS Configuration**
   - Add an A record pointing to your VPS IP:
   ```
   Type: A
   Name: payment (or api)
   Value: your-vps-ip
   TTL: 3600
   ```

3. **SSL Certificate**
   - Coolify automatically provisions Let's Encrypt SSL
   - Wait for SSL to be ready (shows green checkmark)

### Step 5: Deploy

1. **Click "Deploy" Button**
   - Coolify will:
     - Clone repository
     - Build Docker image
     - Start container
     - Configure reverse proxy
     - Set up SSL

2. **Monitor Deployment**
   - Watch the logs in real-time
   - Check for any errors

3. **Verify Deployment**
   ```bash
   # Test health endpoint
   curl https://payment.yourdomain.com/health
   
   # Expected response:
   # {"status":"ok","message":"Xibe Payment Backend is running","timestamp":"..."}
   ```

### Step 6: Test Payment Flow

1. **Test Order Creation**
   ```bash
   curl -X POST https://payment.yourdomain.com/api/create-order \
     -H "Content-Type: application/json" \
     -d '{"amount": 10, "currency": "INR"}'
   ```

2. **Update Flutter App**
   - Set GitHub Actions variable (see GITHUB_ACTIONS_SETUP.md)
   - Rebuild and deploy your Flutter app

## Coolify Features Used

### Auto-Deploy on Git Push

1. **Enable Auto-Deploy**
   - Go to application settings
   - Enable "Auto Deploy"
   - Coolify will watch your repository
   - Deploys automatically on push to main branch

### Logs & Monitoring

1. **View Real-time Logs**
   ```bash
   # In Coolify dashboard, click "Logs"
   # Or via CLI:
   docker logs -f coolify-app-name
   ```

2. **Health Checks**
   - Coolify automatically monitors `/health` endpoint
   - Restarts container if health check fails

### Scaling

1. **Vertical Scaling**
   - Increase VPS resources (CPU, RAM)
   - Restart application

2. **Horizontal Scaling** (Advanced)
   - Use Coolify's load balancer
   - Deploy multiple instances

## Docker Commands (Manual Operations)

If you need to manage the container manually:

```bash
# View running containers
docker ps

# View logs
docker logs -f container-name

# Restart container
docker restart container-name

# Execute commands in container
docker exec -it container-name sh

# View environment variables
docker exec container-name env

# Stop container
docker stop container-name

# Start container
docker start container-name

# Remove container (will be recreated by Coolify)
docker rm -f container-name
```

## Backup & Restore

### Backup Environment Variables

1. **Export from Coolify**
   - Go to application settings
   - Click "Export Environment Variables"
   - Save securely

2. **Manual Backup**
   ```bash
   # Save to file
   docker exec container-name env > backup-env.txt
   ```

### Restore

1. **Import in Coolify**
   - Create new application
   - Import environment variables
   - Deploy

## Troubleshooting

### Issue 1: Deployment Fails

**Symptoms:** Build fails or container won't start

**Solutions:**
1. Check build logs in Coolify
2. Verify Dockerfile is correct
3. Check environment variables are set
4. Ensure port 3000 is not blocked

```bash
# Check if port is accessible
nc -zv your-vps-ip 3000

# Check container logs
docker logs container-name
```

### Issue 2: Health Check Fails

**Symptoms:** Container keeps restarting

**Solutions:**
1. Check if `/health` endpoint responds
2. Verify PORT environment variable is 3000
3. Check application logs

```bash
# Test health endpoint locally
curl http://localhost:3000/health

# Check container health
docker inspect --format='{{.State.Health.Status}}' container-name
```

### Issue 3: SSL Certificate Issues

**Symptoms:** HTTPS not working

**Solutions:**
1. Verify DNS is pointing to correct IP
2. Check domain configuration in Coolify
3. Wait for DNS propagation (can take 24-48 hours)
4. Force SSL renewal in Coolify

### Issue 4: API Keys Not Working

**Symptoms:** Razorpay API errors

**Solutions:**
1. Verify keys are correctly set in Coolify
2. Check for trailing spaces in variables
3. Ensure using correct mode (Test vs Live)
4. Verify keys in Razorpay Dashboard

```bash
# Check environment variables in container
docker exec container-name printenv | grep RAZORPAY
```

### Issue 5: CORS Errors

**Symptoms:** Flutter app can't connect

**Solutions:**
1. Check CORS configuration in `server.js`
2. Verify domain is whitelisted
3. Check if HTTPS is enforced

## Security Best Practices

1. **Use SSL/HTTPS Always**
   - Coolify handles this automatically
   - Never expose HTTP port

2. **Secure Environment Variables**
   - Mark sensitive vars as "Secret" in Coolify
   - Never commit to Git

3. **Regular Updates**
   - Keep Coolify updated
   - Update Node.js base image
   - Update npm packages regularly

4. **Firewall Configuration**
   ```bash
   # Allow only necessary ports
   ufw allow 80/tcp   # HTTP (redirects to HTTPS)
   ufw allow 443/tcp  # HTTPS
   ufw allow 22/tcp   # SSH
   ufw enable
   ```

5. **Rate Limiting**
   - Configure in Coolify reverse proxy
   - Or implement in application

## Monitoring & Alerts

### Set Up Monitoring

1. **Coolify Built-in Monitoring**
   - CPU usage
   - Memory usage
   - Disk usage
   - Container status

2. **External Monitoring** (Optional)
   - Use UptimeRobot or similar
   - Monitor https://payment.yourdomain.com/health
   - Send alerts if down

### Log Management

1. **View Logs in Coolify**
   - Real-time log viewer
   - Search and filter

2. **Export Logs**
   ```bash
   docker logs container-name > logs.txt
   ```

3. **Log Rotation** (Automatic)
   - Docker handles log rotation
   - Configure in daemon.json if needed

## Performance Optimization

### 1. Enable Compression

Already enabled in Express with `cors()` middleware.

### 2. Use PM2 (Optional)

For better process management:

1. Update Dockerfile:
   ```dockerfile
   RUN npm install -g pm2
   CMD ["pm2-runtime", "start", "server.js"]
   ```

### 3. Database Connection Pooling

If adding database later, configure connection pooling.

### 4. CDN for Static Assets

Use CDN for any static files (currently none).

## Updating the Application

### Via Coolify Auto-Deploy

1. Push changes to GitHub
2. Coolify automatically:
   - Pulls latest code
   - Rebuilds Docker image
   - Deploys new version
   - Zero-downtime deployment

### Manual Update

1. **In Coolify Dashboard**
   - Click "Redeploy"
   - Or "Force Rebuild"

2. **Via Git**
   ```bash
   git add .
   git commit -m "Update payment backend"
   git push origin main
   ```

## Cost Estimation

### VPS Requirements

**Minimum (Development/Testing):**
- 1 CPU core
- 1 GB RAM
- 10 GB storage
- Cost: ~$5-6/month (Hetzner, DigitalOcean)

**Recommended (Production):**
- 2 CPU cores
- 2 GB RAM
- 20 GB storage
- Cost: ~$12-15/month

**Popular VPS Providers:**
- Hetzner Cloud (cheapest, Europe)
- DigitalOcean (easy to use)
- Linode (reliable)
- Vultr (global locations)

### Domain Costs

- Domain: ~$10-15/year
- SSL: Free (Let's Encrypt via Coolify)

### Total Estimated Cost

- **Development**: ~$5/month + domain
- **Production**: ~$12/month + domain

## Migration Guide

### From Other Hosting to Coolify

1. **Export Environment Variables**
   - From Heroku: `heroku config`
   - From Vercel: Export from dashboard

2. **Create New App in Coolify**
   - Follow deployment steps above
   - Import environment variables

3. **Update DNS**
   - Point domain to new VPS IP
   - Wait for DNS propagation

4. **Test Thoroughly**
   - Verify all endpoints work
   - Test payment flow

5. **Update Flutter App**
   - Update backend URL
   - Deploy new version

## Support Resources

- **Coolify Documentation**: https://coolify.io/docs
- **Coolify Discord**: https://discord.gg/coolify
- **Docker Documentation**: https://docs.docker.com/
- **Razorpay Support**: support@razorpay.com

## Quick Reference Commands

```bash
# View container status
docker ps | grep payment

# Follow logs
docker logs -f $(docker ps -q --filter ancestor=payment-backend)

# Restart application
# (Use Coolify dashboard - click Restart)

# Check health
curl https://payment.yourdomain.com/health

# Test order creation
curl -X POST https://payment.yourdomain.com/api/create-order \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "INR"}'

# View environment variables
docker exec container-name printenv

# Access container shell
docker exec -it container-name sh

# View container resource usage
docker stats container-name
```

---

## Next Steps

1. ✅ Deploy backend to Coolify
2. ✅ Verify health endpoint works
3. ✅ Test payment creation
4. 📝 Set up GitHub Actions variable (see GITHUB_ACTIONS_SETUP.md)
5. 🔧 Update Flutter app with new backend URL
6. 🚀 Deploy Flutter app
7. ✅ Test complete payment flow

---

**Last Updated:** January 2024  
**Coolify Version:** Latest  
**Docker Version:** 20.10+

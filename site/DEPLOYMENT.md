# Website Deployment Guide

This guide explains how to deploy the Xibe Chat website.

## Prerequisites

- Node.js 18+ and npm
- Git
- Access to hosting provider (Vercel, Netlify, etc.)

## Local Development

```bash
# Navigate to site directory
cd site

# Install dependencies
npm install

# Start development server
npm run dev
```

The site will be available at http://localhost:3000

## Building for Production

### Static Site Generation (Recommended)

Generate a static site that can be hosted anywhere:

```bash
npm run generate
```

Output will be in `.output/public/` directory.

### Server-Side Rendering

Build for SSR deployment:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## Deployment Options

### Option 1: Vercel (Recommended)

1. **Via Vercel CLI:**
   ```bash
   npm i -g vercel
   vercel
   ```

2. **Via GitHub:**
   - Push to GitHub
   - Import project at https://vercel.com/new
   - Vercel auto-detects Nuxt.js
   - Deploy!

**Configuration:**
- Root Directory: `site`
- Build Command: `npm run generate`
- Output Directory: `.output/public`

### Option 2: Netlify

1. **Via Netlify CLI:**
   ```bash
   npm i -g netlify-cli
   netlify deploy --prod
   ```

2. **Via GitHub:**
   - Push to GitHub
   - New site from Git at https://app.netlify.com
   - Base directory: `site`
   - Build command: `npm run generate`
   - Publish directory: `.output/public`

**netlify.toml** (create in site directory):
```toml
[build]
  command = "npm run generate"
  publish = ".output/public"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Option 3: GitHub Pages

1. **Build the site:**
   ```bash
   npm run generate
   ```

2. **Deploy to gh-pages:**
   ```bash
   npm i -g gh-pages
   gh-pages -d .output/public -b gh-pages
   ```

3. **Configure GitHub:**
   - Settings → Pages
   - Source: Deploy from branch
   - Branch: gh-pages

4. **Update base URL** in `nuxt.config.ts`:
   ```typescript
   export default defineNuxtConfig({
     app: {
       baseURL: '/Xibe-chat-app/', // Replace with your repo name
     }
   })
   ```

### Option 4: Static Hosting (S3, Azure, etc.)

1. **Build:**
   ```bash
   npm run generate
   ```

2. **Upload `.output/public/` to your host**

For S3:
```bash
aws s3 sync .output/public/ s3://your-bucket-name
```

## Domain Configuration

### For Deep Links to Work

The website should be hosted at `xibechat.app` for HTTPS deep links to work properly.

**DNS Configuration:**
```
Type: A
Name: @
Value: [Your host's IP]

Type: CNAME
Name: www
Value: xibechat.app
```

**SSL Certificate:**
Most hosting providers (Vercel, Netlify) provide automatic SSL certificates.

## Environment Variables

No environment variables required by default.

Optional configurations in `.env`:
```bash
# Analytics (if added)
NUXT_PUBLIC_GA_ID=G-XXXXXXXXXX

# API endpoint (if using backend)
NUXT_PUBLIC_API_URL=https://api.xibechat.app
```

## Custom Domain Setup

### Vercel
1. Go to project settings
2. Add domain: `xibechat.app`
3. Add DNS records as instructed
4. Wait for SSL certificate

### Netlify
1. Domain settings → Add custom domain
2. Follow DNS configuration steps
3. Enable HTTPS

## Monitoring & Analytics

### Add Google Analytics

1. **Install module:**
   ```bash
   npm install @nuxtjs/google-analytics
   ```

2. **Update nuxt.config.ts:**
   ```typescript
   export default defineNuxtConfig({
     modules: ['@nuxtjs/google-analytics'],
     googleAnalytics: {
       id: 'G-XXXXXXXXXX'
     }
   })
   ```

### Add Plausible Analytics

```typescript
export default defineNuxtConfig({
  app: {
    head: {
      script: [
        {
          src: 'https://plausible.io/js/script.js',
          'data-domain': 'xibechat.app',
          defer: true
        }
      ]
    }
  }
})
```

## Performance Optimization

### Image Optimization

Images are automatically optimized by Nuxt.

For additional optimization:
```bash
npm install @nuxt/image
```

```typescript
export default defineNuxtConfig({
  modules: ['@nuxt/image']
})
```

### Caching Headers

Add to your host configuration:

**Netlify** (_headers file):
```
/*
  Cache-Control: public, max-age=0, must-revalidate

/logo.png
  Cache-Control: public, max-age=31536000, immutable

/_nuxt/*
  Cache-Control: public, max-age=31536000, immutable
```

**Vercel** (vercel.json):
```json
{
  "headers": [
    {
      "source": "/_nuxt/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

## Testing Deployment

1. **Check all pages load:**
   - Homepage: `/`
   - New chat: `/app/new`
   - Message: `/app/mes/test`
   - Settings: `/app/settings`

2. **Test deep link redirects:**
   - Click "Try Quick Link" button
   - Should attempt to open app

3. **Test responsive design:**
   - Mobile view
   - Tablet view
   - Desktop view

4. **Check performance:**
   - Use Lighthouse in Chrome DevTools
   - Aim for 90+ scores

## Troubleshooting

### Build fails with module not found

```bash
rm -rf node_modules package-lock.json
npm install
npm run generate
```

### Routes not working (404s)

Add redirect rules to hosting provider (see netlify.toml example above).

### Deep links not working

1. Check that app is installed
2. Verify custom URI scheme is registered
3. Test with simple link: `xibechat://new`

### Slow build times

- Use `npm run generate` for static generation
- Enable caching in CI/CD
- Reduce image sizes

## CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Website

on:
  push:
    branches: [main]
    paths:
      - 'site/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: site/package-lock.json
      
      - name: Install dependencies
        working-directory: ./site
        run: npm ci
      
      - name: Generate static site
        working-directory: ./site
        run: npm run generate
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./site
```

## Maintenance

### Update Dependencies

```bash
npm update
npm audit fix
```

### Check for vulnerabilities

```bash
npm audit
```

### Update Nuxt

```bash
npm install nuxt@latest
```

## Support

For issues:
1. Check build logs
2. Test locally first
3. Verify all files are committed
4. Check hosting provider status

## Next Steps

After deployment:
1. ✅ Verify all pages work
2. ✅ Test deep links with installed app
3. ✅ Set up analytics
4. ✅ Configure custom domain
5. ✅ Add SSL certificate
6. ✅ Monitor performance

Your website is now live! 🎉

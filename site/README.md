# Nuxt Minimal Starter

# Xibe Chat Website

This is the official website for Xibe Chat, built with Nuxt 3.

## Features

- 📱 **Deep Link Integration**: Handles deep links to open the Xibe Chat app
- 🎨 **Modern UI**: Built with Tailwind CSS
- 🔗 **URL Routing**: 
  - `/app/new` - Open app with new chat
  - `/app/mes/{prompt}` - Open app with pre-filled message
  - `/app/settings` - Open app settings
- 📖 **App Information**: Showcases all features of Xibe Chat

## Setup

Install dependencies:

```bash
npm install
```

## Development

Start the development server on `http://localhost:3000`:

```bash
npm run dev
```

## Production

Build the application for production:

```bash
npm run build
```

Generate static site:

```bash
npm run generate
```

Preview production build:

```bash
npm run preview
```

## Deep Link Examples

When the app is installed, these URLs will open the app:

- `https://xibechat.app/app/new` - New chat
- `https://xibechat.app/app/mes/Tell%20me%20a%20joke` - New chat with prompt
- `https://xibechat.app/app/settings` - Settings screen
- `xibechat://mes/What%20is%20AI?` - Custom URI scheme

## Deployment

This site can be deployed to:
- Vercel
- Netlify
- GitHub Pages (with static generation)
- Any static hosting provider

For static generation, use:
```bash
npm run generate
```

The output will be in the `.output/public` directory.

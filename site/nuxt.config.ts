// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  
  modules: ['@nuxtjs/tailwindcss'],
  
  app: {
    head: {
      title: 'Xibe Chat - Free AI Chat App with Multi-Model Support | Download Now',
      htmlAttrs: {
        lang: 'en'
      },
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { 
          name: 'description', 
          content: 'Xibe Chat - 100% free AI chat application with support for Gemini, OpenAI, Claude, DeepSeek and more. Features deep linking, customizable profiles, and multi-platform support. Download for Windows, macOS, Linux, Android & iOS.' 
        },
        { name: 'keywords', content: 'AI chat, free AI app, Gemini, OpenAI, Claude, DeepSeek, multi-model AI, chat assistant, deep linking, AI profiles, cross-platform, Windows, macOS, Linux, Android, iOS' },
        { name: 'author', content: 'iotserver24' },
        { name: 'theme-color', content: '#6366f1' },
        
        // Open Graph / Facebook
        { property: 'og:type', content: 'website' },
        { property: 'og:url', content: 'https://xibechat.app' },
        { property: 'og:title', content: 'Xibe Chat - Free AI Chat App with Multi-Model Support' },
        { property: 'og:description', content: 'Free AI chat application with support for Gemini, OpenAI, Claude, DeepSeek and more. Available for Windows, macOS, Linux, Android & iOS.' },
        { property: 'og:image', content: 'https://xibechat.app/og-image.png' },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        
        // Twitter
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:url', content: 'https://xibechat.app' },
        { name: 'twitter:title', content: 'Xibe Chat - Free AI Chat App with Multi-Model Support' },
        { name: 'twitter:description', content: 'Free AI chat application with support for Gemini, OpenAI, Claude, DeepSeek and more. Available for Windows, macOS, Linux, Android & iOS.' },
        { name: 'twitter:image', content: 'https://xibechat.app/og-image.png' },
        
        // Additional SEO
        { name: 'robots', content: 'index, follow' },
        { name: 'googlebot', content: 'index, follow' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo.png' },
        { rel: 'apple-touch-icon', href: '/logo.png' },
        { rel: 'canonical', href: 'https://xibechat.app' },
      ],
    },
  },
})

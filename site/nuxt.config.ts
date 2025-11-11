// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  
  modules: ['@nuxtjs/tailwindcss'],
  
  app: {
    head: {
      title: 'Xibe Chat - Free AI Chat Application | Multi-Model AI Assistant',
      htmlAttrs: {
        lang: 'en'
      },
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { 
          name: 'description', 
          content: 'Xibe Chat - 100% free and open-source AI chat application. Chat with Gemini, OpenAI GPT, Claude, DeepSeek, and more AI models. Features customizable AI profiles, local data storage, code execution, and cross-platform support for Windows, macOS, Linux, Android & iOS. Download now!' 
        },
        { name: 'keywords', content: 'Xibe Chat, AI chat, free AI app, AI assistant, Gemini chat, OpenAI chat, Claude AI, DeepSeek, ChatGPT alternative, free chat app, multi-model AI, AI chatbot, conversational AI, cross-platform chat, Windows AI app, macOS AI app, Linux AI app, Android AI app, iOS AI app, AI profiles, local AI storage, privacy-focused AI, open source AI chat, AI conversation app' },
        { name: 'author', content: 'iotserver24' },
        { name: 'theme-color', content: '#6366f1' },
        { name: 'application-name', content: 'Xibe Chat' },
        { name: 'apple-mobile-web-app-title', content: 'Xibe Chat' },
        { name: 'apple-mobile-web-app-capable', content: 'yes' },
        { name: 'mobile-web-app-capable', content: 'yes' },
        
        // Open Graph / Facebook
        { property: 'og:type', content: 'website' },
        { property: 'og:url', content: 'https://chat.xibe.app' },
        { property: 'og:site_name', content: 'Xibe Chat' },
        { property: 'og:title', content: 'Xibe Chat - Free AI Chat Application with Multi-Model Support' },
        { property: 'og:description', content: 'Free and open-source AI chat application supporting Gemini, OpenAI, Claude, DeepSeek and more. Cross-platform, privacy-focused, and feature-rich. Download for Windows, macOS, Linux, Android & iOS.' },
        { property: 'og:image', content: 'https://chat.xibe.app/og-image.png' },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        { property: 'og:image:alt', content: 'Xibe Chat - AI Chat Application' },
        { property: 'og:locale', content: 'en_US' },
        
        // Twitter
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:url', content: 'https://chat.xibe.app' },
        { name: 'twitter:title', content: 'Xibe Chat - Free AI Chat Application | Multi-Model AI Assistant' },
        { name: 'twitter:description', content: 'Free and open-source AI chat with Gemini, OpenAI, Claude, DeepSeek and more. Cross-platform support for all devices.' },
        { name: 'twitter:image', content: 'https://chat.xibe.app/og-image.png' },
        { name: 'twitter:image:alt', content: 'Xibe Chat - AI Chat Application' },
        { name: 'twitter:creator', content: '@iotserver24' },
        
        // Additional SEO
        { name: 'robots', content: 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1' },
        { name: 'googlebot', content: 'index, follow' },
        { name: 'bingbot', content: 'index, follow' },
        { name: 'rating', content: 'general' },
        { name: 'referrer', content: 'no-referrer-when-downgrade' },
        { name: 'format-detection', content: 'telephone=no' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo.png' },
        { rel: 'apple-touch-icon', href: '/logo.png' },
        { rel: 'canonical', href: 'https://chat.xibe.app' },
      ],
    },
  },
})

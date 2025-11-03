<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-white">
    <!-- Animated background -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
      <div class="absolute top-1/2 -left-40 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse" style="animation-delay: 1s;"></div>
    </div>

    <!-- Header -->
    <header class="relative z-10 border-b border-white/10 backdrop-blur-xl bg-slate-950/50">
      <nav class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <NuxtLink to="/" class="flex items-center space-x-3">
            <div class="relative">
              <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg blur opacity-75"></div>
              <img src="/logo.png" alt="Xibe Chat" class="relative h-10 w-10 rounded-lg" />
            </div>
            <span class="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">Xibe Chat</span>
          </NuxtLink>
          <div class="flex items-center space-x-6">
            <NuxtLink to="/" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Home</NuxtLink>
            <NuxtLink to="/features" class="text-sm font-medium text-white">Features</NuxtLink>
            <NuxtLink to="/docs" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Docs</NuxtLink>
            <NuxtLink to="/download" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Download</NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="relative z-10 container mx-auto px-4 py-20">
      <!-- Hero -->
      <div class="text-center mb-20">
        <h1 class="text-5xl md:text-6xl font-black mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
          Comprehensive Features
        </h1>
        <p class="text-xl text-slate-400 max-w-3xl mx-auto">
          Discover everything Xibe Chat has to offer. Built with cutting-edge technology for the ultimate AI experience.
        </p>
      </div>

      <!-- Feature Sections -->
      <div class="space-y-32">
        <!-- AI Models -->
        <section>
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-4">Multiple AI Models</h2>
            <p class="text-lg text-slate-400 max-w-2xl mx-auto">
              Access a diverse range of AI models, each optimized for different tasks
            </p>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">Google Gemini</h3>
              <p class="text-slate-400 mb-4">
                Google's most capable AI model with advanced reasoning and multimodal capabilities
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• Gemini 1.5 Pro</li>
                <li>• Gemini 1.5 Flash</li>
                <li>• Vision support</li>
              </ul>
            </div>

            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">OpenAI GPT</h3>
              <p class="text-slate-400 mb-4">
                Industry-leading language models from OpenAI with exceptional performance
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• GPT-4 Turbo</li>
                <li>• GPT-3.5 Turbo</li>
                <li>• Function calling</li>
              </ul>
            </div>

            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">Anthropic Claude</h3>
              <p class="text-slate-400 mb-4">
                Advanced AI assistant focused on safety and helpful, honest responses
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• Claude 3 Opus</li>
                <li>• Claude 3 Sonnet</li>
                <li>• Large context window</li>
              </ul>
            </div>

            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-cyan-500 to-cyan-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">DeepSeek</h3>
              <p class="text-slate-400 mb-4">
                Cost-effective models with competitive performance for various tasks
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• DeepSeek Chat</li>
                <li>• DeepSeek Coder</li>
                <li>• Affordable pricing</li>
              </ul>
            </div>

            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">Ollama (Local)</h3>
              <p class="text-slate-400 mb-4">
                Run AI models locally on your machine for complete privacy and offline access
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• Llama 2, Mistral, etc.</li>
                <li>• 100% private</li>
                <li>• No internet required</li>
              </ul>
            </div>

            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50">
              <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-pink-500 to-pink-600 flex items-center justify-center mb-4">
                <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-white mb-2">Custom Models</h3>
              <p class="text-slate-400 mb-4">
                Connect to any OpenAI-compatible API endpoint for maximum flexibility
              </p>
              <ul class="space-y-2 text-sm text-slate-500">
                <li>• Custom endpoints</li>
                <li>• Self-hosted models</li>
                <li>• Full control</li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Deep Linking -->
        <section>
          <div class="flex flex-col md:flex-row items-center gap-12">
            <div class="flex-1">
              <h2 class="text-4xl font-bold text-white mb-6">Deep Link Integration</h2>
              <p class="text-lg text-slate-400 mb-6">
                Share prompts and workflows seamlessly with deep linking support. Perfect for documentation, tutorials, and team collaboration.
              </p>
              <ul class="space-y-4">
                <li class="flex items-start gap-3">
                  <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-semibold text-white mb-1">Custom URI Scheme</h4>
                    <p class="text-slate-400 text-sm">Launch the app with <code class="px-2 py-1 rounded bg-slate-800 text-blue-400">xibechat://</code> links</p>
                  </div>
                </li>
                <li class="flex items-start gap-3">
                  <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-semibold text-white mb-1">HTTPS Deep Links</h4>
                    <p class="text-slate-400 text-sm">Universal links that work from any web page</p>
                  </div>
                </li>
                <li class="flex items-start gap-3">
                  <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                    <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <div>
                    <h4 class="font-semibold text-white mb-1">Pre-filled Prompts</h4>
                    <p class="text-slate-400 text-sm">Share conversations with prompts ready to send</p>
                  </div>
                </li>
              </ul>
            </div>
            <div class="flex-1">
              <div class="p-6 rounded-2xl bg-gradient-to-br from-blue-500/10 to-purple-500/10 border border-blue-500/20 backdrop-blur-sm">
                <div class="space-y-3">
                  <div class="p-4 rounded-xl bg-slate-900/50">
                    <p class="text-xs text-slate-500 mb-2">New chat</p>
                    <code class="text-blue-400 text-sm break-all">xibechat://new</code>
                  </div>
                  <div class="p-4 rounded-xl bg-slate-900/50">
                    <p class="text-xs text-slate-500 mb-2">With prompt</p>
                    <code class="text-purple-400 text-sm break-all">xibechat://mes/Explain quantum computing</code>
                  </div>
                  <div class="p-4 rounded-xl bg-slate-900/50">
                    <p class="text-xs text-slate-500 mb-2">HTTPS link</p>
                    <code class="text-cyan-400 text-sm break-all">https://xibechat.app/app/mes/Hello</code>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- AI Profiles -->
        <section>
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-4">Customizable AI Profiles</h2>
            <p class="text-lg text-slate-400 max-w-2xl mx-auto">
              Create and manage AI personalities tailored to your specific needs
            </p>
          </div>
          <div class="grid md:grid-cols-2 gap-8">
            <div class="p-8 rounded-2xl bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20">
              <h3 class="text-2xl font-bold text-white mb-4">Profile System</h3>
              <ul class="space-y-3">
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-purple-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-slate-300">Create unlimited custom profiles with unique system prompts</span>
                </li>
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-purple-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-slate-300">Switch between profiles instantly during conversations</span>
                </li>
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-purple-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-slate-300">Optional - use model defaults without any profile</span>
                </li>
              </ul>
            </div>

            <div class="p-8 rounded-2xl bg-gradient-to-br from-cyan-500/10 to-blue-500/10 border border-cyan-500/20">
              <h3 class="text-2xl font-bold text-white mb-4">Use Cases</h3>
              <ul class="space-y-3">
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-cyan-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                  </svg>
                  <span class="text-slate-300">Code Assistant - specialized for programming tasks</span>
                </li>
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-cyan-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                  </svg>
                  <span class="text-slate-300">Creative Writer - optimized for content creation</span>
                </li>
                <li class="flex items-start gap-3">
                  <svg class="w-5 h-5 text-cyan-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                  </svg>
                  <span class="text-slate-300">Business Analyst - focused on data and insights</span>
                </li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Privacy & Performance -->
        <section>
          <div class="grid md:grid-cols-2 gap-8">
            <div class="p-8 rounded-2xl bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/20">
              <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center mb-6">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h3 class="text-2xl font-bold text-white mb-4">Privacy First</h3>
              <ul class="space-y-3 text-slate-300">
                <li>• All conversations stored locally on your device</li>
                <li>• No cloud synchronization by default</li>
                <li>• Your data never leaves your control</li>
                <li>• Support for local AI models (Ollama)</li>
                <li>• Optional encryption for sensitive chats</li>
              </ul>
            </div>

            <div class="p-8 rounded-2xl bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border border-yellow-500/20">
              <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-yellow-500 to-yellow-600 flex items-center justify-center mb-6">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 class="text-2xl font-bold text-white mb-4">Lightning Fast</h3>
              <ul class="space-y-3 text-slate-300">
                <li>• Real-time streaming responses</li>
                <li>• Optimized for low latency</li>
                <li>• Smooth animations and transitions</li>
                <li>• Instant chat switching</li>
                <li>• Minimal resource usage</li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Platform Support -->
        <section>
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-4">Cross-Platform Excellence</h2>
            <p class="text-lg text-slate-400 max-w-2xl mx-auto">
              One app, everywhere. Built with Flutter for native performance on every platform.
            </p>
          </div>
          <div class="grid md:grid-cols-3 lg:grid-cols-5 gap-6">
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50 text-center">
              <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-green-500/20 flex items-center justify-center">
                <svg class="w-8 h-8 text-green-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.523 15.341c-.126-.406-.183-.61-.183-.915 0-.304.057-.508.183-.915l.97-3.123c.126-.406.183-.61.183-.915 0-.609-.305-1.015-.915-1.015-.304 0-.508.102-.711.305l-9.141 9.141c-.203.203-.305.406-.305.711 0 .609.406.915 1.015.915.304 0 .508-.057.915-.183l3.123-.97c.406-.126.61-.183.915-.183.304 0 .508.057.915.183l3.123.97c.406.126.61.183.915.183.609 0 1.015-.305 1.015-.915 0-.304-.057-.508-.183-.915l-.97-3.123z"/>
                </svg>
              </div>
              <h4 class="font-semibold text-white">Android</h4>
            </div>
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50 text-center">
              <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-blue-500/20 flex items-center justify-center">
                <svg class="w-8 h-8 text-blue-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M0 12v12h6V11.333h12V0H6C2.6867 0 0 2.6867 0 6v6z"/>
                </svg>
              </div>
              <h4 class="font-semibold text-white">Windows</h4>
            </div>
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50 text-center">
              <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-purple-500/20 flex items-center justify-center">
                <svg class="w-8 h-8 text-purple-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0z"/>
                </svg>
              </div>
              <h4 class="font-semibold text-white">macOS</h4>
            </div>
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50 text-center">
              <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-yellow-500/20 flex items-center justify-center">
                <svg class="w-8 h-8 text-yellow-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0z"/>
                </svg>
              </div>
              <h4 class="font-semibold text-white">Linux</h4>
            </div>
            <div class="p-6 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 border border-slate-700/50 text-center">
              <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-cyan-500/20 flex items-center justify-center">
                <svg class="w-8 h-8 text-cyan-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0z"/>
                </svg>
              </div>
              <h4 class="font-semibold text-white">iOS</h4>
            </div>
          </div>
        </section>

        <!-- Additional Features -->
        <section>
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-4">And Much More</h2>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Code Execution</h4>
              <p class="text-sm text-slate-400">Run Python, JavaScript, and shell commands securely</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">MCP Servers</h4>
              <p class="text-sm text-slate-400">Extend functionality with Model Context Protocol</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Memory System</h4>
              <p class="text-sm text-slate-400">AI remembers context across conversations</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Dark Mode</h4>
              <p class="text-sm text-slate-400">Beautiful interface optimized for your eyes</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Image Analysis</h4>
              <p class="text-sm text-slate-400">Upload and analyze images with vision models</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Export Chats</h4>
              <p class="text-sm text-slate-400">Save conversations as markdown or text</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Search History</h4>
              <p class="text-sm text-slate-400">Find past conversations instantly</p>
            </div>
            <div class="p-6 rounded-xl bg-slate-800/30 border border-slate-700/50">
              <h4 class="font-semibold text-white mb-2">Keyboard Shortcuts</h4>
              <p class="text-sm text-slate-400">Navigate efficiently with hotkeys</p>
            </div>
          </div>
        </section>

        <!-- CTA -->
        <section class="text-center">
          <div class="relative p-1 rounded-2xl bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 inline-block">
            <div class="rounded-2xl bg-slate-950 px-12 py-10">
              <h2 class="text-3xl font-bold text-white mb-4">Ready to Experience It?</h2>
              <p class="text-slate-400 mb-8 max-w-lg mx-auto">
                Download Xibe Chat now and discover the future of AI conversations
              </p>
              <NuxtLink to="/download" 
                        class="inline-flex items-center gap-2 px-8 py-4 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 text-white font-bold hover:scale-105 transition-all">
                Download Now
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </NuxtLink>
            </div>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
useHead({
  title: 'Features - Xibe Chat',
  meta: [
    {
      name: 'description',
      content: 'Explore all the powerful features of Xibe Chat: multiple AI models, deep linking, customizable profiles, privacy-first architecture, and cross-platform support.',
    },
  ],
})
</script>

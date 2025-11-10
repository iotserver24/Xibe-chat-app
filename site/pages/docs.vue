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
            <NuxtLink to="/features" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Features</NuxtLink>
            <NuxtLink to="/docs" class="text-sm font-medium text-white">Docs</NuxtLink>
            <NuxtLink to="/download" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Download</NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <div class="relative z-10 flex">
      <!-- Sidebar -->
      <aside class="hidden lg:block w-64 border-r border-white/10 bg-slate-950/30 backdrop-blur-xl h-[calc(100vh-73px)] sticky top-[73px] overflow-y-auto">
        <nav class="p-6 space-y-6">
          <div>
            <h3 class="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Getting Started</h3>
            <ul class="space-y-2">
              <li><a href="#installation" class="block text-sm text-slate-300 hover:text-white transition-colors">Installation</a></li>
              <li><a href="#quick-start" class="block text-sm text-slate-300 hover:text-white transition-colors">Quick Start</a></li>
              <li><a href="#configuration" class="block text-sm text-slate-300 hover:text-white transition-colors">Configuration</a></li>
            </ul>
          </div>
          <div>
            <h3 class="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Features</h3>
            <ul class="space-y-2">
              <li><a href="#ai-models" class="block text-sm text-slate-300 hover:text-white transition-colors">AI Models</a></li>
              <li><a href="#profiles" class="block text-sm text-slate-300 hover:text-white transition-colors">Profiles</a></li>
              <li><a href="#code-execution" class="block text-sm text-slate-300 hover:text-white transition-colors">Code Execution</a></li>
              <li><a href="#privacy" class="block text-sm text-slate-300 hover:text-white transition-colors">Privacy & Security</a></li>
            </ul>
          </div>
          <div>
            <h3 class="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Advanced</h3>
            <ul class="space-y-2">
              <li><a href="#custom-providers" class="block text-sm text-slate-300 hover:text-white transition-colors">Custom Providers</a></li>
              <li><a href="#mcp-servers" class="block text-sm text-slate-300 hover:text-white transition-colors">MCP Servers</a></li>
              <li><a href="#custom-endpoints" class="block text-sm text-slate-300 hover:text-white transition-colors">Custom Endpoints</a></li>
              <li><a href="#ollama" class="block text-sm text-slate-300 hover:text-white transition-colors">Local Models</a></li>
            </ul>
          </div>
          <div>
            <h3 class="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Development</h3>
            <ul class="space-y-2">
              <li><a href="#building" class="block text-sm text-slate-300 hover:text-white transition-colors">Building from Source</a></li>
              <li><a href="#contributing" class="block text-sm text-slate-300 hover:text-white transition-colors">Contributing</a></li>
            </ul>
          </div>
        </nav>
      </aside>

      <!-- Main Content -->
      <main class="flex-1 container mx-auto px-4 md:px-8 py-12 max-w-4xl">
        <!-- Hero -->
        <div class="mb-16">
          <h1 class="text-5xl md:text-6xl font-black mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
            Documentation
          </h1>
          <p class="text-xl text-slate-400">
            Complete guide to using Xibe Chat. Learn how to get started, configure models, and leverage advanced features.
          </p>
        </div>

        <!-- Content -->
        <div class="prose prose-invert prose-lg max-w-none space-y-16">
          <!-- Installation -->
          <section id="installation">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-blue-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
              </span>
              Installation
            </h2>
            
            <div class="space-y-6">
              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-3">Download from GitHub</h3>
                <p class="text-slate-400 mb-4">Visit the <a href="https://github.com/iotserver24/Xibe-chat-app/releases" class="text-blue-400 hover:text-blue-300">Releases page</a> and download the appropriate version for your platform.</p>
                <div class="grid md:grid-cols-2 gap-4">
                  <div class="p-4 rounded-lg bg-slate-800/50">
                    <h4 class="font-semibold text-green-400 mb-2">Windows</h4>
                    <p class="text-sm text-slate-400">Download <code class="px-2 py-1 rounded bg-slate-900 text-green-400">.exe</code> or <code class="px-2 py-1 rounded bg-slate-900 text-green-400">.zip</code></p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50">
                    <h4 class="font-semibold text-blue-400 mb-2">Android</h4>
                    <p class="text-sm text-slate-400">Download <code class="px-2 py-1 rounded bg-slate-900 text-blue-400">.apk</code> file</p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50">
                    <h4 class="font-semibold text-yellow-400 mb-2">Linux</h4>
                    <p class="text-sm text-slate-400">Download <code class="px-2 py-1 rounded bg-slate-900 text-yellow-400">.deb</code> or <code class="px-2 py-1 rounded bg-slate-900 text-yellow-400">.AppImage</code></p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50">
                    <h4 class="font-semibold text-purple-400 mb-2">macOS</h4>
                    <p class="text-sm text-slate-400">Download <code class="px-2 py-1 rounded bg-slate-900 text-purple-400">.dmg</code> file</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <!-- Quick Start -->
          <section id="quick-start">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-green-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </span>
              Quick Start
            </h2>
            
            <div class="space-y-6">
              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-4">1. Configure API Keys</h3>
                <p class="text-slate-400 mb-4">Navigate to Settings → AI Models and add your API keys:</p>
                <div class="space-y-3">
                  <div class="flex items-start gap-3">
                    <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                      <span class="text-xs text-blue-400 font-bold">1</span>
                    </div>
                    <div>
                      <p class="text-white font-medium">Open Settings</p>
                      <p class="text-sm text-slate-400">Click the gear icon in the top right</p>
                    </div>
                  </div>
                  <div class="flex items-start gap-3">
                    <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                      <span class="text-xs text-blue-400 font-bold">2</span>
                    </div>
                    <div>
                      <p class="text-white font-medium">Add API Keys</p>
                      <p class="text-sm text-slate-400">Enter keys for OpenAI, Anthropic, Google, etc.</p>
                    </div>
                  </div>
                  <div class="flex items-start gap-3">
                    <div class="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-1">
                      <span class="text-xs text-blue-400 font-bold">3</span>
                    </div>
                    <div>
                      <p class="text-white font-medium">Select Default Model</p>
                      <p class="text-sm text-slate-400">Choose your preferred model</p>
                    </div>
                  </div>
                </div>
              </div>

              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-4">2. Start Chatting</h3>
                <p class="text-slate-400 mb-4">Click "New Chat" and start your conversation. The app automatically:</p>
                <ul class="space-y-2 text-slate-400">
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Streams responses in real-time
                  </li>
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Saves conversations locally
                  </li>
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Maintains conversation history
                  </li>
                </ul>
              </div>
            </div>
          </section>

          <!-- Configuration -->
          <section id="configuration">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </span>
              Configuration
            </h2>
            
            <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
              <h3 class="text-xl font-semibold text-white mb-4">API Keys Configuration</h3>
              <p class="text-slate-400 mb-4">Configure API keys for different providers:</p>
              
              <div class="space-y-4">
                <div class="p-4 rounded-lg bg-slate-800/50">
                  <h4 class="font-semibold text-white mb-2">OpenAI</h4>
                  <p class="text-sm text-slate-400 mb-2">Get your API key from <a href="https://platform.openai.com/api-keys" class="text-blue-400 hover:text-blue-300">platform.openai.com</a></p>
                  <code class="block p-3 rounded bg-slate-900 text-green-400 text-sm">Settings → AI Models → OpenAI → Add API Key</code>
                </div>

                <div class="p-4 rounded-lg bg-slate-800/50">
                  <h4 class="font-semibold text-white mb-2">Anthropic Claude</h4>
                  <p class="text-sm text-slate-400 mb-2">Get your API key from <a href="https://console.anthropic.com/" class="text-blue-400 hover:text-blue-300">console.anthropic.com</a></p>
                  <code class="block p-3 rounded bg-slate-900 text-purple-400 text-sm">Settings → AI Models → Anthropic → Add API Key</code>
                </div>

                <div class="p-4 rounded-lg bg-slate-800/50">
                  <h4 class="font-semibold text-white mb-2">Google Gemini</h4>
                  <p class="text-sm text-slate-400 mb-2">Get your API key from <a href="https://makersuite.google.com/app/apikey" class="text-blue-400 hover:text-blue-300">Google AI Studio</a></p>
                  <code class="block p-3 rounded bg-slate-900 text-blue-400 text-sm">Settings → AI Models → Google → Add API Key</code>
                </div>
              </div>
            </div>
          </section>

          <!-- AI Models -->
          <section id="ai-models">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-cyan-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </span>
              AI Models
            </h2>
            
            <p class="text-slate-400 mb-6">Xibe Chat supports multiple AI providers. Each model has unique strengths:</p>
            
            <div class="grid md:grid-cols-2 gap-6">
              <div class="p-6 rounded-xl bg-gradient-to-br from-blue-500/10 to-blue-600/5 border border-blue-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">GPT-4 Turbo</h3>
                <p class="text-slate-400 text-sm mb-3">Best for: Complex reasoning, creative writing, detailed analysis</p>
                <ul class="text-sm text-slate-500 space-y-1">
                  <li>• 128K context window</li>
                  <li>• Vision capabilities</li>
                  <li>• Function calling</li>
                </ul>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-purple-500/10 to-purple-600/5 border border-purple-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">Claude 3 Opus</h3>
                <p class="text-slate-400 text-sm mb-3">Best for: Long documents, nuanced conversations, coding</p>
                <ul class="text-sm text-slate-500 space-y-1">
                  <li>• 200K context window</li>
                  <li>• Enhanced safety</li>
                  <li>• Code generation</li>
                </ul>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-green-500/10 to-green-600/5 border border-green-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">Gemini 1.5 Pro</h3>
                <p class="text-slate-400 text-sm mb-3">Best for: Multimodal tasks, large contexts, fast responses</p>
                <ul class="text-sm text-slate-500 space-y-1">
                  <li>• 1M+ context window</li>
                  <li>• Video understanding</li>
                  <li>• Efficient processing</li>
                </ul>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-orange-500/10 to-orange-600/5 border border-orange-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">Local Models (Ollama)</h3>
                <p class="text-slate-400 text-sm mb-3">Best for: Privacy, offline usage, no API costs</p>
                <ul class="text-sm text-slate-500 space-y-1">
                  <li>• 100% private</li>
                  <li>• No internet needed</li>
                  <li>• Free to use</li>
                </ul>
              </div>
            </div>
          </section>

          <!-- Profiles -->
          <section id="profiles">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-pink-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </span>
              AI Profiles
            </h2>
            
            <p class="text-slate-400 mb-6">Profiles let you customize AI behavior with system prompts. They're completely optional!</p>
            
            <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800 mb-6">
              <h3 class="text-xl font-semibold text-white mb-4">Creating a Profile</h3>
              <ol class="space-y-3 text-slate-400">
                <li class="flex items-start gap-3">
                  <span class="w-6 h-6 rounded-full bg-pink-500/20 flex items-center justify-center flex-shrink-0 text-xs text-pink-400 font-bold">1</span>
                  <span>Navigate to Settings → AI Profiles</span>
                </li>
                <li class="flex items-start gap-3">
                  <span class="w-6 h-6 rounded-full bg-pink-500/20 flex items-center justify-center flex-shrink-0 text-xs text-pink-400 font-bold">2</span>
                  <span>Click "Create New Profile"</span>
                </li>
                <li class="flex items-start gap-3">
                  <span class="w-6 h-6 rounded-full bg-pink-500/20 flex items-center justify-center flex-shrink-0 text-xs text-pink-400 font-bold">3</span>
                  <span>Give it a name and description</span>
                </li>
                <li class="flex items-start gap-3">
                  <span class="w-6 h-6 rounded-full bg-pink-500/20 flex items-center justify-center flex-shrink-0 text-xs text-pink-400 font-bold">4</span>
                  <span>Write your system prompt (how the AI should behave)</span>
                </li>
              </ol>
            </div>

            <div class="p-6 rounded-xl bg-gradient-to-br from-pink-500/10 to-purple-500/10 border border-pink-500/20">
              <h3 class="text-lg font-semibold text-white mb-3">Example: Code Assistant Profile</h3>
              <div class="p-4 rounded-lg bg-slate-900/50">
                <p class="text-xs text-slate-500 mb-2">System Prompt:</p>
                <code class="block text-sm text-slate-300 leading-relaxed">
                  You are an expert programmer. Provide concise, well-commented code examples. Focus on best practices, clean architecture, and performance. Explain your reasoning when helpful.
                </code>
              </div>
            </div>
          </section>

          <!-- Privacy & Security -->
          <section id="privacy">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-indigo-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </span>
              Privacy & Security
            </h2>
            
            <p class="text-slate-400 mb-6">Xibe Chat is designed with privacy as a core principle. Your data stays on your device.</p>
            
            <div class="space-y-6">
              <div class="p-6 rounded-xl bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/20">
                <h3 class="text-xl font-semibold text-white mb-4">Local-First Architecture</h3>
                <ul class="space-y-3 text-slate-400">
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                    All conversations stored locally in SQLite database
                  </li>
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                    No cloud sync or external data collection
                  </li>
                  <li class="flex items-start gap-2">
                    <svg class="w-5 h-5 text-green-400 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                    Complete control over your data - export or delete anytime
                  </li>
                </ul>
              </div>

              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-4">API Key Security</h3>
                <p class="text-slate-400 mb-4">Your API keys are stored securely on your device:</p>
                <ul class="space-y-2 text-slate-400">
                  <li class="flex items-start gap-2">
                    <span class="text-blue-400">•</span>
                    Never transmitted to Xibe Chat servers (we don't have any!)
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-blue-400">•</span>
                    Used only to authenticate directly with AI providers
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-blue-400">•</span>
                    Stored in encrypted local storage
                  </li>
                </ul>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-indigo-500/10 to-purple-500/10 border border-indigo-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">Open Source Transparency</h3>
                <p class="text-slate-400">
                  Xibe Chat is 100% open source. You can review the code on <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="text-blue-400 hover:text-blue-300 underline">GitHub</a> to verify our privacy claims. 
                  Read our full <NuxtLink to="/privacy" class="text-blue-400 hover:text-blue-300 underline">Privacy Policy</NuxtLink>.
                </p>
              </div>
            </div>
          </section>

          <!-- Code Execution -->
          <section id="code-execution">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-yellow-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                </svg>
              </span>
              Code Execution
            </h2>
            
            <p class="text-slate-400 mb-6">Execute code directly in the chat using the E2B sandbox environment.</p>
            
            <div class="p-6 rounded-xl bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border border-yellow-500/20">
              <h3 class="text-lg font-semibold text-white mb-4">Supported Languages</h3>
              <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                <div class="p-3 rounded-lg bg-slate-900/50 text-center">
                  <div class="text-2xl mb-1">🐍</div>
                  <p class="text-sm font-medium text-white">Python</p>
                </div>
                <div class="p-3 rounded-lg bg-slate-900/50 text-center">
                  <div class="text-2xl mb-1">📜</div>
                  <p class="text-sm font-medium text-white">JavaScript</p>
                </div>
                <div class="p-3 rounded-lg bg-slate-900/50 text-center">
                  <div class="text-2xl mb-1">💻</div>
                  <p class="text-sm font-medium text-white">Bash</p>
                </div>
              </div>
            </div>
          </section>

          <!-- Custom Providers -->
          <section id="custom-providers">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-indigo-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z" />
                </svg>
              </span>
              Custom API Providers
            </h2>
            
            <p class="text-slate-400 mb-6">Add your own API providers to use custom AI models with your API keys. Xibe Chat supports OpenAI, Anthropic, OpenRouter, and any OpenAI-compatible API.</p>
            
            <div class="space-y-6">
              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-4">Built-in Providers</h3>
                <div class="grid md:grid-cols-2 gap-4">
                  <div class="p-4 rounded-lg bg-slate-800/50 border border-blue-500/20">
                    <h4 class="font-semibold text-blue-400 mb-2">OpenAI</h4>
                    <p class="text-sm text-slate-400">GPT-4, GPT-3.5, and other OpenAI models</p>
                    <p class="text-xs text-slate-500 mt-2">https://api.openai.com/v1</p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50 border border-purple-500/20">
                    <h4 class="font-semibold text-purple-400 mb-2">Anthropic</h4>
                    <p class="text-sm text-slate-400">Claude 3.5 Sonnet, Haiku, and more</p>
                    <p class="text-xs text-slate-500 mt-2">https://api.anthropic.com/v1</p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50 border border-green-500/20">
                    <h4 class="font-semibold text-green-400 mb-2">OpenRouter</h4>
                    <p class="text-sm text-slate-400">Access to 100+ models from various providers</p>
                    <p class="text-xs text-slate-500 mt-2">https://openrouter.ai/api/v1</p>
                  </div>
                  <div class="p-4 rounded-lg bg-slate-800/50 border border-yellow-500/20">
                    <h4 class="font-semibold text-yellow-400 mb-2">Groq</h4>
                    <p class="text-sm text-slate-400">Ultra-fast inference for open models</p>
                    <p class="text-xs text-slate-500 mt-2">https://api.groq.com/openai/v1</p>
                  </div>
                </div>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-indigo-500/10 to-purple-500/10 border border-indigo-500/20">
                <h3 class="text-xl font-semibold text-white mb-4">How to Add a Provider</h3>
                <ol class="space-y-3 text-slate-300">
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">1</span>
                    <span>Navigate to <strong>Settings → Custom Providers → API Providers</strong></span>
                  </li>
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">2</span>
                    <span>Select a built-in provider or click <strong>+</strong> to add custom one</span>
                  </li>
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">3</span>
                    <span>Enter your <strong>API key</strong> for the provider</span>
                  </li>
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">4</span>
                    <span>Click the <strong>list icon</strong> to add models</span>
                  </li>
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">5</span>
                    <span>Configure model details: <strong>name, ID, capabilities</strong></span>
                  </li>
                  <li class="flex gap-3">
                    <span class="flex-shrink-0 w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-sm font-semibold text-indigo-400">6</span>
                    <span>Use your custom model in any chat!</span>
                  </li>
                </ol>
              </div>

              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <h3 class="text-xl font-semibold text-white mb-4">Example: Adding OpenAI GPT-4</h3>
                <div class="space-y-4">
                  <div>
                    <p class="text-sm text-slate-500 mb-2">1. Edit OpenAI provider and add your API key</p>
                    <div class="p-3 rounded-lg bg-slate-800/50">
                      <code class="text-sm text-slate-300">API Key: sk-proj-xxxxxxxxxxxxx</code>
                    </div>
                  </div>
                  <div>
                    <p class="text-sm text-slate-500 mb-2">2. Add a model:</p>
                    <div class="p-3 rounded-lg bg-slate-800/50 space-y-2 text-sm">
                      <div><span class="text-slate-500">Display Name:</span> <span class="text-slate-300">GPT-4 Turbo</span></div>
                      <div><span class="text-slate-500">Model ID:</span> <span class="text-green-400">gpt-4-turbo-preview</span></div>
                      <div><span class="text-slate-500">Description:</span> <span class="text-slate-300">Most capable GPT-4 model</span></div>
                      <div><span class="text-slate-500">Supports Vision:</span> <span class="text-blue-400">✓</span></div>
                      <div><span class="text-slate-500">Supports Streaming:</span> <span class="text-blue-400">✓</span></div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="p-6 rounded-xl bg-amber-500/10 border border-amber-500/20">
                <div class="flex gap-3">
                  <svg class="w-6 h-6 text-amber-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                  <div>
                    <h4 class="font-semibold text-amber-400 mb-2">Security Note</h4>
                    <p class="text-sm text-slate-300">API keys are stored locally and encrypted. Never share your API keys with others.</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <!-- MCP Servers -->
          <section id="mcp-servers">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-emerald-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" />
                </svg>
              </span>
              MCP Servers
            </h2>
            
            <p class="text-slate-400 mb-6">Model Context Protocol (MCP) servers extend AI capabilities with custom tools and data sources.</p>
            
            <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
              <h3 class="text-xl font-semibold text-white mb-4">Configuration</h3>
              <p class="text-slate-400 mb-4">Configure MCP servers in Settings → MCP Servers</p>
              <div class="p-4 rounded-lg bg-slate-800/50">
                <p class="text-xs text-slate-500 mb-2">Example configuration:</p>
                <pre class="text-sm text-slate-300 overflow-x-auto"><code>{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
  }
}</code></pre>
              </div>
            </div>
          </section>

          <!-- Building from Source -->
          <section id="building">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-red-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
              </span>
              Building from Source
            </h2>
            
            <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
              <h3 class="text-xl font-semibold text-white mb-4">Prerequisites</h3>
              <ul class="space-y-2 text-slate-400 mb-6">
                <li>• Flutter SDK (3.0+)</li>
                <li>• Dart SDK</li>
                <li>• Android SDK (for Android builds)</li>
                <li>• Xcode (for macOS/iOS builds)</li>
              </ul>

              <h3 class="text-xl font-semibold text-white mb-4">Build Commands</h3>
              <div class="space-y-3">
                <div>
                  <p class="text-sm text-slate-500 mb-2">Android:</p>
                  <code class="block p-3 rounded bg-slate-800/50 text-green-400">flutter build apk --release</code>
                </div>
                <div>
                  <p class="text-sm text-slate-500 mb-2">Windows:</p>
                  <code class="block p-3 rounded bg-slate-800/50 text-blue-400">flutter build windows --release</code>
                </div>
                <div>
                  <p class="text-sm text-slate-500 mb-2">Linux:</p>
                  <code class="block p-3 rounded bg-slate-800/50 text-yellow-400">flutter build linux --release</code>
                </div>
                <div>
                  <p class="text-sm text-slate-500 mb-2">macOS:</p>
                  <code class="block p-3 rounded bg-slate-800/50 text-purple-400">flutter build macos --release</code>
                </div>
              </div>
            </div>
          </section>

          <!-- Contributing -->
          <section id="contributing">
            <h2 class="text-3xl font-bold text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-lg bg-teal-500/20 flex items-center justify-center">
                <svg class="w-5 h-5 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </span>
              Contributing
            </h2>
            
            <p class="text-slate-400 mb-6">Contributions are welcome! Here's how to get started:</p>
            
            <div class="space-y-4">
              <div class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <ol class="space-y-3 text-slate-400">
                  <li class="flex items-start gap-3">
                    <span class="w-6 h-6 rounded-full bg-teal-500/20 flex items-center justify-center flex-shrink-0 text-xs text-teal-400 font-bold">1</span>
                    <span>Fork the repository on GitHub</span>
                  </li>
                  <li class="flex items-start gap-3">
                    <span class="w-6 h-6 rounded-full bg-teal-500/20 flex items-center justify-center flex-shrink-0 text-xs text-teal-400 font-bold">2</span>
                    <span>Create a feature branch: <code class="px-2 py-1 rounded bg-slate-800 text-teal-400">git checkout -b feature/amazing-feature</code></span>
                  </li>
                  <li class="flex items-start gap-3">
                    <span class="w-6 h-6 rounded-full bg-teal-500/20 flex items-center justify-center flex-shrink-0 text-xs text-teal-400 font-bold">3</span>
                    <span>Make your changes and commit: <code class="px-2 py-1 rounded bg-slate-800 text-teal-400">git commit -m 'Add amazing feature'</code></span>
                  </li>
                  <li class="flex items-start gap-3">
                    <span class="w-6 h-6 rounded-full bg-teal-500/20 flex items-center justify-center flex-shrink-0 text-xs text-teal-400 font-bold">4</span>
                    <span>Push to your fork and submit a Pull Request</span>
                  </li>
                </ol>
              </div>

              <div class="p-6 rounded-xl bg-gradient-to-br from-teal-500/10 to-cyan-500/10 border border-teal-500/20">
                <h3 class="text-lg font-semibold text-white mb-3">Resources</h3>
                <ul class="space-y-2 text-slate-400">
                  <li>
                    <a href="https://github.com/iotserver24/Xibe-chat-app" class="text-teal-400 hover:text-teal-300 flex items-center gap-2">
                      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
                      GitHub Repository
                    </a>
                  </li>
                  <li>
                    <a href="https://github.com/iotserver24/Xibe-chat-app/issues" class="text-teal-400 hover:text-teal-300 flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Report Issues
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </section>

          <!-- Get Help -->
          <section class="text-center pt-12">
            <div class="p-8 rounded-2xl bg-gradient-to-br from-blue-500/10 to-purple-500/10 border border-blue-500/20">
              <h2 class="text-2xl font-bold text-white mb-4">Need More Help?</h2>
              <p class="text-slate-400 mb-6">
                Can't find what you're looking for? Check out our GitHub repository or open an issue.
              </p>
              <div class="flex flex-col sm:flex-row gap-4 justify-center">
                <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" 
                   class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-white font-semibold transition-all">
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
                  GitHub
                </a>
                <NuxtLink to="/download" 
                          class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 text-white font-bold hover:scale-105 transition-all">
                  Download Now
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
                  </svg>
                </NuxtLink>
              </div>
            </div>
          </section>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
useHead({
  title: 'Documentation - Xibe Chat | User Guide & Tutorials',
  meta: [
    {
      name: 'description',
      content: 'Complete documentation for Xibe Chat. Learn how to install, configure, and use all features including AI models, profiles, code execution, privacy settings, and more.',
    },
    {
      name: 'keywords',
      content: 'Xibe Chat documentation, AI chat guide, user manual, setup guide, API configuration, AI models tutorial',
    },
  ],
})
</script>

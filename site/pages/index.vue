<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-white overflow-hidden">
    <!-- Animated background -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
      <div class="absolute top-1/2 -left-40 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse" style="animation-delay: 1s;"></div>
      <div class="absolute -bottom-40 right-1/3 w-96 h-96 bg-cyan-500/20 rounded-full blur-3xl animate-pulse" style="animation-delay: 2s;"></div>
    </div>

    <!-- Header -->
    <header class="relative z-10 border-b border-white/10 backdrop-blur-xl bg-slate-950/50">
      <nav class="container mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-2 sm:space-x-3">
            <div class="relative">
              <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg blur opacity-75"></div>
              <img src="/logo.png" alt="Xibe Chat" class="relative h-8 w-8 sm:h-10 sm:w-10 rounded-lg" />
            </div>
            <span class="text-xl sm:text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">Xibe Chat</span>
          </div>
          <div class="hidden md:flex items-center space-x-6 lg:space-x-8">
            <a href="#features" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Features</a>
            <a href="#examples" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Examples</a>
            <a href="#download" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Download</a>
            <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 hover:bg-white/20 border border-white/20 text-sm font-medium transition-all">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
              GitHub
            </a>
          </div>
          <!-- Mobile menu button -->
          <div class="md:hidden">
            <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="inline-flex items-center gap-2 px-3 py-2 rounded-full bg-white/10 hover:bg-white/20 border border-white/20 text-xs font-medium transition-all">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
            </a>
          </div>
        </div>
      </nav>
    </header>

    <!-- Hero Section -->
    <section class="relative z-10 container mx-auto px-4 sm:px-6 lg:px-8 pt-12 sm:pt-16 md:pt-20 pb-20 sm:pb-24 md:pb-32">
      <div class="max-w-5xl mx-auto text-center">
        <!-- Badge -->
        <div class="inline-flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full bg-gradient-to-r from-blue-500/10 to-purple-500/10 border border-blue-500/20 mb-6 sm:mb-8 backdrop-blur-sm">
          <span class="relative flex h-2 w-2">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
            <span class="relative inline-flex rounded-full h-2 w-2 bg-blue-500"></span>
          </span>
          <span class="text-xs sm:text-sm font-medium text-slate-200">Now with Deep Link Support</span>
        </div>

        <!-- Heading -->
        <h1 class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl xl:text-8xl font-black mb-4 sm:mb-6 leading-tight px-2">
          Your AI Assistant,
          <br />
          <span class="bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent animate-gradient">
            Reimagined
          </span>
        </h1>

        <!-- Description -->
        <p class="text-base sm:text-lg md:text-xl lg:text-2xl text-slate-400 mb-8 sm:mb-10 md:mb-12 max-w-3xl mx-auto leading-relaxed px-4">
          Experience the future of AI chat with multi-model support, seamless deep linking,
          and customizable profiles. Built for <span class="text-slate-200 font-semibold">every platform</span>.
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row justify-center gap-4 mb-16">
          <a
            href="#download"
            class="group relative inline-flex items-center justify-center gap-2 px-8 py-4 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold shadow-2xl shadow-blue-500/50 hover:shadow-blue-500/70 hover:scale-105 transition-all duration-300"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
            </svg>
            Download Now
            <span class="absolute -top-1 -right-1 flex h-3 w-3">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
              <span class="relative inline-flex rounded-full h-3 w-3 bg-white"></span>
            </span>
          </a>
          <a
            href="/app/mes/Tell%20me%20about%20Xibe%20Chat"
            class="inline-flex items-center justify-center gap-2 px-8 py-4 rounded-xl bg-slate-800/50 backdrop-blur-sm border border-slate-700/50 text-white font-semibold hover:bg-slate-800 hover:border-slate-600 transition-all duration-300"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            Try Deep Link
          </a>
        </div>

        <!-- Platform Icons -->
        <div class="flex flex-wrap justify-center items-center gap-4 sm:gap-6 md:gap-8 text-slate-500 px-4">
          <div class="flex items-center gap-2">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M17.523 15.341c-.126-.406-.183-.61-.183-.915 0-.304.057-.508.183-.915l.97-3.123c.126-.406.183-.61.183-.915 0-.609-.305-1.015-.915-1.015-.304 0-.508.102-.711.305l-9.141 9.141c-.203.203-.305.406-.305.711 0 .609.406.915 1.015.915.304 0 .508-.057.915-.183l3.123-.97c.406-.126.61-.183.915-.183.304 0 .508.057.915.183l3.123.97c.406.126.61.183.915.183.609 0 1.015-.305 1.015-.915 0-.304-.057-.508-.183-.915l-.97-3.123zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"/></svg>
            <span class="text-xs sm:text-sm font-medium">Android</span>
          </div>
          <div class="flex items-center gap-2">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"/></svg>
            <span class="text-xs sm:text-sm font-medium">Windows</span>
          </div>
          <div class="flex items-center gap-2">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2z"/></svg>
            <span class="text-xs sm:text-sm font-medium">macOS</span>
          </div>
          <div class="flex items-center gap-2">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2z"/></svg>
            <span class="text-xs sm:text-sm font-medium">Linux</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="relative z-10 py-16 sm:py-20 md:py-24 lg:py-32 bg-gradient-to-b from-transparent via-slate-950/50 to-transparent">
      <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12 sm:mb-16 md:mb-20">
          <h2 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black mb-4 sm:mb-6 bg-gradient-to-r from-slate-200 to-slate-400 bg-clip-text text-transparent">
            Powerful Features
          </h2>
          <p class="text-base sm:text-lg md:text-xl text-slate-400 max-w-2xl mx-auto px-4">
            Everything you need for an exceptional AI chat experience
          </p>
        </div>

        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5 md:gap-6">
          <!-- Feature Card 1 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-blue-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-blue-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-blue-600/0 to-purple-600/0 group-hover:from-blue-600/10 group-hover:to-purple-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Multiple AI Models</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                Switch seamlessly between Gemini, OpenAI, DeepSeek, Claude, and more. Find the perfect model for every task.
              </p>
            </div>
          </div>

          <!-- Feature Card 2 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-purple-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-purple-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-purple-600/0 to-pink-600/0 group-hover:from-purple-600/10 group-hover:to-pink-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Deep Link Magic</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                Share prompts via links that open directly in the app. Perfect for workflows, documentation, and collaboration.
              </p>
            </div>
          </div>

          <!-- Feature Card 3 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-cyan-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-cyan-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-cyan-600/0 to-blue-600/0 group-hover:from-cyan-600/10 group-hover:to-blue-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-cyan-500 to-cyan-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Customizable Profiles</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                Create AI personalities tailored to your needs. Or go profile-free and let models shine with their defaults.
              </p>
            </div>
          </div>

          <!-- Feature Card 4 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-green-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-green-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-green-600/0 to-emerald-600/0 group-hover:from-green-600/10 group-hover:to-emerald-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Cross-Platform</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                One app, every device. Seamlessly sync across Android, iOS, Windows, macOS, and Linux.
              </p>
            </div>
          </div>

          <!-- Feature Card 5 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-orange-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-orange-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-orange-600/0 to-red-600/0 group-hover:from-orange-600/10 group-hover:to-red-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Privacy First</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                Your conversations stay yours. All data stored locally on your device with no cloud dependency.
              </p>
            </div>
          </div>

          <!-- Feature Card 6 -->
          <div class="group relative p-6 sm:p-7 md:p-8 rounded-xl sm:rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-yellow-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-yellow-500/20 hover:-translate-y-1">
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-yellow-600/0 to-orange-600/0 group-hover:from-yellow-600/10 group-hover:to-orange-600/10 transition-all duration-300"></div>
            <div class="relative">
              <div class="w-12 h-12 sm:w-14 sm:h-14 rounded-lg sm:rounded-xl bg-gradient-to-br from-yellow-500 to-yellow-600 flex items-center justify-center mb-4 sm:mb-5 md:mb-6 group-hover:scale-110 transition-transform duration-300">
                <svg class="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 class="text-xl sm:text-2xl font-bold mb-2 sm:mb-3 text-slate-100">Lightning Fast</h3>
              <p class="text-sm sm:text-base text-slate-400 leading-relaxed">
                Real-time streaming responses, buttery-smooth animations, and a UI that feels alive.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Deep Link Examples -->
    <section id="examples" class="relative z-10 py-16 sm:py-20 md:py-24 lg:py-32">
      <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="max-w-4xl mx-auto">
          <div class="text-center mb-12 sm:mb-14 md:mb-16">
            <h2 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black mb-4 sm:mb-6 bg-gradient-to-r from-slate-200 to-slate-400 bg-clip-text text-transparent">
              Try Deep Links
            </h2>
            <p class="text-base sm:text-lg md:text-xl text-slate-400 px-4">
              Experience the power of instant app launching with pre-filled prompts
            </p>
          </div>

          <div class="space-y-3 sm:space-y-4">
            <!-- Example 1 -->
            <div class="group relative p-6 rounded-2xl bg-gradient-to-r from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-blue-500/50 transition-all duration-300">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center">
                  <svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-slate-400 mb-2">Open app with a new chat</p>
                  <a href="https://chat.xibe.app/app/new" class="inline-flex items-center gap-2 text-blue-400 hover:text-blue-300 font-mono text-sm break-all group-hover:underline">
                    https://chat.xibe.app/app/new
                    <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                </div>
              </div>
            </div>

            <!-- Example 2 -->
            <div class="group relative p-6 rounded-2xl bg-gradient-to-r from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-purple-500/50 transition-all duration-300">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center">
                  <svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-slate-400 mb-2">Open with a pre-filled message</p>
                  <a href="https://chat.xibe.app/app/mes/Tell%20me%20a%20joke" class="inline-flex items-center gap-2 text-purple-400 hover:text-purple-300 font-mono text-sm break-all group-hover:underline">
                    https://chat.xibe.app/app/mes/Tell me a joke
                    <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                </div>
              </div>
            </div>

            <!-- Example 3 -->
            <div class="group relative p-6 rounded-2xl bg-gradient-to-r from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-cyan-500/50 transition-all duration-300">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-cyan-500/10 flex items-center justify-center">
                  <svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-slate-400 mb-2">Open app settings</p>
                  <a href="https://chat.xibe.app/app/settings" class="inline-flex items-center gap-2 text-cyan-400 hover:text-cyan-300 font-mono text-sm break-all group-hover:underline">
                    https://chat.xibe.app/app/settings
                    <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                </div>
              </div>
            </div>

            <!-- Example 4 -->
            <div class="group relative p-6 rounded-2xl bg-gradient-to-r from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-pink-500/50 transition-all duration-300">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-pink-500/10 flex items-center justify-center">
                  <svg class="w-6 h-6 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-slate-400 mb-2">Custom URI scheme</p>
                  <a href="xibechat://mes/What%20is%20AI?" class="inline-flex items-center gap-2 text-pink-400 hover:text-pink-300 font-mono text-sm break-all group-hover:underline">
                    xibechat://mes/What is AI?
                    <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                </div>
              </div>
            </div>
          </div>

          <p class="text-center mt-12 text-slate-500 text-sm">
            💡 Click any link above to test deep linking (requires app to be installed)
          </p>
        </div>
      </div>
    </section>

    <!-- Download Section -->
    <section id="download" class="relative z-10 py-16 sm:py-20 md:py-24 lg:py-32">
      <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="max-w-4xl mx-auto">
          <div class="relative rounded-2xl sm:rounded-3xl bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 p-1">
            <div class="rounded-2xl sm:rounded-3xl bg-slate-950 p-6 sm:p-8 md:p-12 lg:p-16 text-center">
              <h2 class="text-3xl sm:text-4xl md:text-5xl font-black mb-4 sm:mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
                Ready to Get Started?
              </h2>
              <p class="text-base sm:text-lg md:text-xl text-slate-400 mb-8 sm:mb-10 max-w-2xl mx-auto px-2">
                Download Xibe Chat for your platform and experience the future of AI conversations
              </p>
              <div class="flex flex-col sm:flex-row justify-center gap-3 sm:gap-4">
                <NuxtLink
                  to="/download"
                  class="group inline-flex items-center justify-center gap-2 px-8 py-4 rounded-xl bg-white text-slate-900 font-bold hover:bg-slate-100 transition-all duration-300 hover:scale-105"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
                  </svg>
                  Download Now
                  <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </NuxtLink>
                <a
                  href="https://github.com/iotserver24/Xibe-chat-app"
                  target="_blank"
                  class="inline-flex items-center justify-center gap-2 px-8 py-4 rounded-xl bg-slate-800/50 backdrop-blur-sm border border-slate-700 text-white font-semibold hover:bg-slate-800 hover:border-slate-600 transition-all duration-300"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                  </svg>
                  View Source
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="relative z-10 border-t border-white/10 backdrop-blur-xl bg-slate-950/50">
      <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10 md:py-12">
        <div class="grid sm:grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8 mb-6 sm:mb-8">
          <div class="sm:col-span-2">
            <div class="flex items-center space-x-2 sm:space-x-3 mb-3 sm:mb-4">
              <div class="relative">
                <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg blur opacity-75"></div>
                <img src="/logo.png" alt="Xibe Chat" class="relative h-8 w-8 sm:h-10 sm:w-10 rounded-lg" />
              </div>
              <span class="text-lg sm:text-xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">Xibe Chat</span>
            </div>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed max-w-md">
              A modern AI chat application with multi-model support, deep linking, and customizable profiles. Built with Flutter for every platform.
            </p>
          </div>
          <div>
            <h3 class="font-semibold text-slate-200 mb-4">Links</h3>
            <ul class="space-y-2 text-sm">
              <li><a href="#features" class="text-slate-400 hover:text-white transition-colors">Features</a></li>
              <li><a href="#examples" class="text-slate-400 hover:text-white transition-colors">Examples</a></li>
              <li><a href="#download" class="text-slate-400 hover:text-white transition-colors">Download</a></li>
            </ul>
          </div>
          <div>
            <h3 class="font-semibold text-slate-200 mb-4">Resources</h3>
            <ul class="space-y-2 text-sm">
              <li><a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="text-slate-400 hover:text-white transition-colors">GitHub</a></li>
              <li><a href="https://github.com/iotserver24/Xibe-chat-app/releases" target="_blank" class="text-slate-400 hover:text-white transition-colors">Releases</a></li>
              <li><a href="https://github.com/iotserver24/Xibe-chat-app/issues" target="_blank" class="text-slate-400 hover:text-white transition-colors">Issues</a></li>
            </ul>
          </div>
        </div>
        <div class="pt-8 border-t border-white/10 flex flex-col md:flex-row justify-between items-center gap-4">
          <p class="text-slate-500 text-sm">
            &copy; 2025 Xibe Chat. 100% Free & Open Source. Built with <span class="text-red-400">❤️</span> by <a href="https://github.com/iotserver24" target="_blank" class="text-slate-400 hover:text-white transition-colors underline">iotserver24</a>
          </p>
          <div class="flex items-center gap-4">
            <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="text-slate-400 hover:text-white transition-colors">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
            </a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
useHead({
  title: 'Xibe Chat - Your AI Assistant, Reimagined',
  meta: [
    {
      name: 'description',
      content:
        'Modern AI chat application with multi-model support, deep link integration, and customizable AI profiles. Available on Android, iOS, Windows, macOS, and Linux.',
    },
  ],
});
</script>

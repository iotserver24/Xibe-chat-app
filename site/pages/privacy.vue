<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-white">
    <!-- Animated background -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
      <div class="absolute top-1/2 -left-40 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse" style="animation-delay: 1s;"></div>
    </div>

    <!-- Header -->
    <header class="relative z-10 border-b border-white/10 backdrop-blur-xl bg-slate-950/50">
      <nav class="container mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div class="flex items-center justify-between">
          <NuxtLink to="/" class="flex items-center space-x-2 sm:space-x-3">
            <div class="relative">
              <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg blur opacity-75"></div>
              <img src="/logo.png" alt="Xibe Chat" class="relative h-8 w-8 sm:h-10 sm:w-10 rounded-lg" />
            </div>
            <span class="text-xl sm:text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">Xibe Chat</span>
          </NuxtLink>
          <div class="hidden md:flex items-center space-x-4 lg:space-x-6">
            <NuxtLink to="/" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Home</NuxtLink>
            <NuxtLink to="/features" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Features</NuxtLink>
            <NuxtLink to="/docs" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Docs</NuxtLink>
            <NuxtLink to="/download" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Download</NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="relative z-10 container mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-20 max-w-4xl">
      <!-- Header -->
      <div class="mb-12">
        <h1 class="text-4xl sm:text-5xl md:text-6xl font-black mb-4 sm:mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
          Privacy Policy
        </h1>
        <p class="text-lg text-slate-400">
          Last updated: January 2025
        </p>
      </div>

      <!-- Content -->
      <div class="prose prose-invert prose-lg max-w-none space-y-8">
        <!-- Introduction -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Introduction</h2>
          <p class="text-slate-300 leading-relaxed">
            At Xibe Chat, we take your privacy seriously. This Privacy Policy explains how we handle your data when you use our application. 
            Xibe Chat is designed with privacy as a core principle - your conversations and data remain on your device and are never transmitted to our servers.
          </p>
        </section>

        <!-- Data Collection -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Data Collection and Storage</h2>
          <div class="space-y-4 text-slate-300">
            <div>
              <h3 class="text-xl font-semibold text-blue-400 mb-2">Local Data Storage</h3>
              <p class="leading-relaxed">
                All your chat conversations, AI profiles, settings, and preferences are stored locally on your device using SQLite database. 
                This data never leaves your device unless you explicitly choose to share it.
              </p>
            </div>
            <div>
              <h3 class="text-xl font-semibold text-blue-400 mb-2">What We Store Locally</h3>
              <ul class="list-disc list-inside space-y-2 pl-4">
                <li>Chat history and conversations</li>
                <li>Custom AI profiles and personalities</li>
                <li>Application settings and preferences</li>
                <li>AI model configurations</li>
                <li>User memories and context information</li>
                <li>MCP (Model Context Protocol) server configurations</li>
              </ul>
            </div>
            <div>
              <h3 class="text-xl font-semibold text-blue-400 mb-2">What We Don't Collect</h3>
              <ul class="list-disc list-inside space-y-2 pl-4">
                <li>Personal identification information</li>
                <li>Location data</li>
                <li>Device identifiers or tracking cookies</li>
                <li>Usage analytics or telemetry</li>
                <li>Cloud backups of your conversations</li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Third-Party Services -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Third-Party AI Services</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Xibe Chat connects to various AI service providers (such as OpenAI, Google Gemini, Anthropic Claude, DeepSeek, etc.) 
              to generate responses. When you use these services:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li>Your messages are sent directly to the AI provider's API using your own API keys</li>
              <li>We do not store, log, or have access to these communications</li>
              <li>Each AI provider has their own privacy policy and data handling practices</li>
              <li>You maintain full control over which services you use and when</li>
            </ul>
            <p class="leading-relaxed mt-4">
              We recommend reviewing the privacy policies of the AI services you choose to use:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li><a href="https://openai.com/privacy" target="_blank" class="text-blue-400 hover:text-blue-300 underline">OpenAI Privacy Policy</a></li>
              <li><a href="https://policies.google.com/privacy" target="_blank" class="text-blue-400 hover:text-blue-300 underline">Google Privacy Policy</a></li>
              <li><a href="https://www.anthropic.com/privacy" target="_blank" class="text-blue-400 hover:text-blue-300 underline">Anthropic Privacy Policy</a></li>
              <li><a href="https://www.deepseek.com/privacy" target="_blank" class="text-blue-400 hover:text-blue-300 underline">DeepSeek Privacy Policy</a></li>
            </ul>
          </div>
        </section>

        <!-- API Keys -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">API Key Security</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Your API keys for various AI services are stored locally on your device in encrypted form. These keys are:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li>Never transmitted to Xibe Chat servers (we don't have servers for this purpose)</li>
              <li>Only used to authenticate your requests directly to the AI provider</li>
              <li>Stored securely in your device's local storage</li>
              <li>Never shared with third parties</li>
            </ul>
          </div>
        </section>

        <!-- Code Execution & Preview -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Code Execution and Preview Services</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Xibe Chat offers code execution and preview features through third-party services:
            </p>
            <div>
              <h3 class="text-xl font-semibold text-blue-400 mb-2">E2B Code Execution</h3>
              <p class="leading-relaxed">
                Code execution functionality uses E2B's sandboxed environment through our backend wrapper. When you execute code, 
                it is sent to the E2B service for processing. No code or execution results are stored by us.
              </p>
            </div>
            <div>
              <h3 class="text-xl font-semibold text-blue-400 mb-2">CodeSandbox Preview</h3>
              <p class="leading-relaxed">
                UI code previews use CodeSandbox's API to create temporary sandboxes. These previews are temporary and 
                automatically cleaned up according to CodeSandbox's policies.
              </p>
            </div>
          </div>
        </section>

        <!-- Data Control -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Your Data Rights and Control</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Since all data is stored locally on your device, you have complete control:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li><strong>Access:</strong> You can access all your data through the application interface</li>
              <li><strong>Delete:</strong> You can delete individual chats, profiles, or all data from the settings</li>
              <li><strong>Export:</strong> Your data is stored in standard SQLite format and can be exported</li>
              <li><strong>Control:</strong> Uninstalling the application removes all locally stored data</li>
            </ul>
          </div>
        </section>

        <!-- Payments -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Payment Information</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              If you choose to support Xibe Chat through donations via the in-app donation feature:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li>Payment processing is handled by Razorpay, a secure payment gateway</li>
              <li>We do not store or have access to your credit card or banking information</li>
              <li>Payment data is subject to <a href="https://razorpay.com/privacy/" target="_blank" class="text-blue-400 hover:text-blue-300 underline">Razorpay's Privacy Policy</a></li>
              <li>We only receive confirmation of successful transactions, not your payment details</li>
            </ul>
          </div>
        </section>

        <!-- Updates -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">App Updates</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              The application checks for updates by querying the GitHub Releases API. This request:
            </p>
            <ul class="list-disc list-inside space-y-2 pl-4">
              <li>Only transmits your current app version number</li>
              <li>Does not include any personal information</li>
              <li>Is made directly to GitHub's public API</li>
              <li>Can be disabled in settings if preferred</li>
            </ul>
          </div>
        </section>

        <!-- Open Source -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Open Source Transparency</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Xibe Chat is 100% open source. You can review our source code on 
              <a href="https://github.com/iotserver24/Xibe-chat-app" target="_blank" class="text-blue-400 hover:text-blue-300 underline">GitHub</a> 
              to verify our privacy claims and see exactly how your data is handled.
            </p>
          </div>
        </section>

        <!-- Children's Privacy -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Children's Privacy</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              Xibe Chat is not intended for children under the age of 13. We do not knowingly collect personal information 
              from children. If you believe a child has provided information through our app, please contact us.
            </p>
          </div>
        </section>

        <!-- Changes to Policy -->
        <section class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
          <h2 class="text-2xl font-bold text-white mb-4">Changes to This Privacy Policy</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new 
              Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy 
              periodically for any changes.
            </p>
          </div>
        </section>

        <!-- Contact -->
        <section class="p-6 rounded-xl bg-gradient-to-r from-blue-500/10 to-purple-500/10 border border-blue-500/20">
          <h2 class="text-2xl font-bold text-white mb-4">Contact Us</h2>
          <div class="space-y-4 text-slate-300">
            <p class="leading-relaxed">
              If you have any questions or concerns about this Privacy Policy or our data practices, please contact us:
            </p>
            <ul class="space-y-2">
              <li><strong>GitHub:</strong> <a href="https://github.com/iotserver24/Xibe-chat-app/issues" target="_blank" class="text-blue-400 hover:text-blue-300 underline">Open an issue</a></li>
              <li><strong>Email:</strong> <a href="mailto:n9292dev@gmail.com" class="text-blue-400 hover:text-blue-300 underline">n9292dev@gmail.com</a></li>
            </ul>
          </div>
        </section>

        <!-- Summary -->
        <section class="p-8 rounded-xl bg-gradient-to-r from-green-500/10 to-emerald-500/10 border border-green-500/20">
          <div class="flex items-start gap-4">
            <div class="flex-shrink-0 w-12 h-12 rounded-xl bg-green-500/20 flex items-center justify-center">
              <svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <div>
              <h3 class="text-xl font-bold text-white mb-3">Privacy-First Summary</h3>
              <p class="text-slate-300 leading-relaxed">
                <strong>Your privacy is guaranteed:</strong> Xibe Chat stores all data locally on your device. We don't have servers 
                to collect your data, we don't track you, and we don't sell your information. Your conversations, API keys, and 
                settings never leave your device unless you explicitly choose to share them with AI service providers.
              </p>
            </div>
          </div>
        </section>
      </div>
    </main>

    <!-- Footer -->
    <footer class="relative z-10 border-t border-white/10 backdrop-blur-xl bg-slate-950/50 mt-20">
      <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10 md:py-12">
        <div class="flex flex-col md:flex-row justify-between items-center gap-4">
          <p class="text-slate-500 text-sm text-center md:text-left">
            &copy; 2025 Xibe Chat. 100% Free & Open Source. Built with <span class="text-red-400">❤️</span> by <a href="https://github.com/iotserver24" target="_blank" class="text-slate-400 hover:text-white transition-colors underline">iotserver24</a>
          </p>
          <div class="flex items-center gap-4">
            <NuxtLink to="/" class="text-sm text-slate-400 hover:text-white transition-colors">Home</NuxtLink>
            <NuxtLink to="/privacy" class="text-sm text-slate-400 hover:text-white transition-colors">Privacy</NuxtLink>
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
  title: 'Privacy Policy - Xibe Chat',
  meta: [
    {
      name: 'description',
      content: 'Xibe Chat Privacy Policy - Learn how we protect your privacy with local-only data storage. Your conversations never leave your device.',
    },
    {
      name: 'keywords',
      content: 'Xibe Chat privacy, privacy policy, data protection, local storage, private AI chat, secure chat application',
    },
  ],
});
</script>

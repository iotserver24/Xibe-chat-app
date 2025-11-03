<template>
  <div class="min-h-screen bg-gradient-to-b from-gray-900 to-black text-white">
    <!-- Header -->
    <header class="container mx-auto px-4 py-6">
      <nav class="flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <img src="/logo.png" alt="Xibe Chat" class="h-10 w-10" />
          <span class="text-2xl font-bold">Xibe Chat</span>
        </div>
        <div class="space-x-4">
          <a href="#features" class="hover:text-blue-400">Features</a>
          <a href="#download" class="hover:text-blue-400">Download</a>
          <a href="#about" class="hover:text-blue-400">About</a>
        </div>
      </nav>
    </header>

    <!-- Hero Section -->
    <section class="container mx-auto px-4 py-20 text-center">
      <h1 class="text-6xl font-bold mb-6">
        Your AI Assistant, <br />
        <span class="bg-gradient-to-r from-blue-400 to-purple-600 bg-clip-text text-transparent">
          Reimagined
        </span>
      </h1>
      <p class="text-xl text-gray-400 mb-8 max-w-2xl mx-auto">
        A modern AI chat application with multi-model support, deep link integration,
        and customizable AI profiles. Available on Android, iOS, Windows, macOS, and Linux.
      </p>
      <div class="flex justify-center gap-4">
        <a
          href="#download"
          class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-lg transition"
        >
          Download Now
        </a>
        <a
          href="/app/new"
          class="bg-gray-800 hover:bg-gray-700 text-white font-bold py-3 px-8 rounded-lg transition"
        >
          Try Quick Link
        </a>
      </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="container mx-auto px-4 py-20">
      <h2 class="text-4xl font-bold text-center mb-12">Features</h2>
      <div class="grid md:grid-cols-3 gap-8">
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">🤖</div>
          <h3 class="text-xl font-bold mb-2">Multiple AI Models</h3>
          <p class="text-gray-400">
            Choose from various AI models including Gemini, OpenAI, DeepSeek, Claude, and more.
          </p>
        </div>
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">🔗</div>
          <h3 class="text-xl font-bold mb-2">Deep Link Support</h3>
          <p class="text-gray-400">
            Open the app with pre-filled prompts using web links. Perfect for sharing workflows.
          </p>
        </div>
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">🎨</div>
          <h3 class="text-xl font-bold mb-2">Customizable Profiles</h3>
          <p class="text-gray-400">
            Create and switch between AI behavior profiles, or use model defaults.
          </p>
        </div>
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">💬</div>
          <h3 class="text-xl font-bold mb-2">Multi-Platform</h3>
          <p class="text-gray-400">
            Available on Android, iOS, Windows, macOS, and Linux. One app, everywhere.
          </p>
        </div>
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">🔒</div>
          <h3 class="text-xl font-bold mb-2">Privacy First</h3>
          <p class="text-gray-400">
            All chats stored locally on your device. Your data stays with you.
          </p>
        </div>
        <div class="bg-gray-800 p-6 rounded-lg">
          <div class="text-4xl mb-4">⚡</div>
          <h3 class="text-xl font-bold mb-2">Fast & Responsive</h3>
          <p class="text-gray-400">
            Real-time streaming responses with beautiful animations and smooth UI.
          </p>
        </div>
      </div>
    </section>

    <!-- Deep Link Examples -->
    <section class="container mx-auto px-4 py-20 bg-gray-900 rounded-lg my-20">
      <h2 class="text-4xl font-bold text-center mb-12">Deep Link Examples</h2>
      <div class="max-w-3xl mx-auto space-y-4">
        <div class="bg-gray-800 p-4 rounded-lg">
          <p class="text-sm text-gray-400 mb-2">Open app with a new chat</p>
          <code class="text-blue-400">https://xibechat.app/app/new</code>
        </div>
        <div class="bg-gray-800 p-4 rounded-lg">
          <p class="text-sm text-gray-400 mb-2">Open app with a pre-filled message</p>
          <code class="text-blue-400">https://xibechat.app/app/mes/Tell me a joke</code>
        </div>
        <div class="bg-gray-800 p-4 rounded-lg">
          <p class="text-sm text-gray-400 mb-2">Open app settings</p>
          <code class="text-blue-400">https://xibechat.app/app/settings</code>
        </div>
        <div class="bg-gray-800 p-4 rounded-lg">
          <p class="text-sm text-gray-400 mb-2">Custom URI scheme</p>
          <code class="text-blue-400">xibechat://mes/What is AI?</code>
        </div>
      </div>
      <p class="text-center mt-8 text-gray-400">
        Click any link above to test deep linking (requires app installed)
      </p>
    </section>

    <!-- Download Section -->
    <section id="download" class="container mx-auto px-4 py-20">
      <h2 class="text-4xl font-bold text-center mb-12">Download</h2>
      <div class="max-w-2xl mx-auto">
        <div class="bg-gray-800 p-8 rounded-lg text-center">
          <p class="text-gray-400 mb-6">
            Download the latest version for your platform from GitHub Releases
          </p>
          <a
            href="https://github.com/iotserver24/Xibe-chat-app/releases"
            target="_blank"
            class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-lg transition"
          >
            View Releases
          </a>
        </div>
      </div>
    </section>

    <!-- About Section -->
    <section id="about" class="container mx-auto px-4 py-20">
      <h2 class="text-4xl font-bold text-center mb-12">About</h2>
      <div class="max-w-3xl mx-auto text-gray-400">
        <p class="mb-4">
          Xibe Chat is a modern AI chat application built with Flutter, offering a seamless
          experience across all major platforms. With support for multiple AI models, deep
          linking, and customizable behavior profiles, it's designed to be your perfect AI
          companion.
        </p>
        <p class="mb-4">
          Whether you're a developer looking to integrate AI into your workflow or just
          someone who wants a better chat experience, Xibe Chat has you covered.
        </p>
        <p class="text-center mt-8">
          <a
            href="https://github.com/iotserver24/Xibe-chat-app"
            target="_blank"
            class="text-blue-400 hover:text-blue-300"
          >
            View on GitHub →
          </a>
        </p>
      </div>
    </section>

    <!-- Footer -->
    <footer class="container mx-auto px-4 py-8 text-center text-gray-500 border-t border-gray-800">
      <p>&copy; 2025 Xibe Chat. Open source and built with ❤️</p>
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

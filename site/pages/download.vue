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
            <NuxtLink to="/docs" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">Docs</NuxtLink>
            <NuxtLink to="/download" class="text-sm font-medium text-white">Download</NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="relative z-10 container mx-auto px-4 py-20">
      <!-- Hero -->
      <div class="text-center mb-16">
        <h1 class="text-5xl md:text-6xl font-black mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
          Download Xibe Chat
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          Choose your platform and release channel. Available for all major operating systems.
        </p>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-blue-500"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="text-center py-20">
        <div class="inline-flex items-center gap-3 px-6 py-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{{ error }}</span>
        </div>
      </div>

      <!-- Release Channels -->
      <div v-else class="space-y-8">
        <!-- Stable Release -->
        <div v-if="stableRelease" class="relative p-1 rounded-2xl bg-gradient-to-r from-green-500 to-emerald-500">
          <div class="rounded-2xl bg-slate-950 p-8">
            <div class="flex items-center justify-between mb-6">
              <div>
                <div class="flex items-center gap-3 mb-2">
                  <h2 class="text-3xl font-bold text-white">Stable Release</h2>
                  <span class="px-3 py-1 rounded-full bg-green-500/20 text-green-400 text-sm font-semibold">Recommended</span>
                </div>
                <p class="text-slate-400">{{ stableRelease.name || stableRelease.tag_name }}</p>
              </div>
              <div class="text-right">
                <div class="text-2xl font-bold text-white">{{ stableRelease.tag_name }}</div>
                <div class="text-sm text-slate-500">{{ formatDate(stableRelease.published_at) }}</div>
              </div>
            </div>

            <!-- Release Notes -->
            <div v-if="stableRelease.body" class="mb-6 p-4 rounded-xl bg-slate-900/50 border border-slate-800">
              <h3 class="text-lg font-semibold text-white mb-2">Release Notes</h3>
              <div class="text-slate-400 text-sm prose prose-invert max-w-none" v-html="formatMarkdown(stableRelease.body)"></div>
            </div>

            <!-- Download Options -->
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div v-for="asset in stableRelease.assets" :key="asset.id" 
                   class="group relative p-6 rounded-xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50 hover:border-green-500/50 transition-all duration-300">
                <div class="flex items-start justify-between mb-4">
                  <div class="flex-1">
                    <div class="flex items-center gap-2 mb-2">
                      <component :is="getPlatformIcon(asset.name)" class="w-6 h-6 text-green-400" />
                      <h4 class="font-semibold text-white">{{ getPlatformName(asset.name) }}</h4>
                    </div>
                    <p class="text-sm text-slate-500 truncate">{{ asset.name }}</p>
                  </div>
                </div>
                <div class="flex items-center justify-between text-sm text-slate-400 mb-4">
                  <span>{{ formatSize(asset.size) }}</span>
                  <span>{{ asset.download_count }} downloads</span>
                </div>
                <a :href="asset.browser_download_url" 
                   class="block w-full py-2 px-4 rounded-lg bg-green-600 hover:bg-green-700 text-white font-semibold text-center transition-colors">
                  Download
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Beta/Pre-release -->
        <div v-if="betaReleases.length > 0" class="relative p-1 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500">
          <div class="rounded-2xl bg-slate-950 p-8">
            <div class="flex items-center justify-between mb-6">
              <div>
                <div class="flex items-center gap-3 mb-2">
                  <h2 class="text-3xl font-bold text-white">Beta Releases</h2>
                  <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-sm font-semibold">Experimental</span>
                </div>
                <p class="text-slate-400">Preview upcoming features (may be unstable)</p>
              </div>
            </div>

            <!-- Beta Releases List -->
            <div class="space-y-6">
              <div v-for="release in betaReleases.slice(0, 3)" :key="release.id" 
                   class="p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <div class="flex items-center justify-between mb-4">
                  <div>
                    <h3 class="text-xl font-bold text-white">{{ release.name || release.tag_name }}</h3>
                    <p class="text-sm text-slate-500">{{ formatDate(release.published_at) }}</p>
                  </div>
                  <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-sm font-semibold">{{ release.tag_name }}</span>
                </div>

                <!-- Assets -->
                <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-3">
                  <a v-for="asset in release.assets" :key="asset.id" 
                     :href="asset.browser_download_url"
                     class="flex items-center gap-3 p-3 rounded-lg bg-slate-800/50 border border-slate-700/50 hover:border-blue-500/50 transition-all">
                    <component :is="getPlatformIcon(asset.name)" class="w-5 h-5 text-blue-400 flex-shrink-0" />
                    <div class="flex-1 min-w-0">
                      <div class="text-sm font-medium text-white truncate">{{ getPlatformName(asset.name) }}</div>
                      <div class="text-xs text-slate-500">{{ formatSize(asset.size) }}</div>
                    </div>
                  </a>
                </div>
              </div>
            </div>

            <!-- View All Beta Releases -->
            <div class="text-center mt-6">
              <a href="https://github.com/iotserver24/Xibe-chat-app/releases" target="_blank"
                 class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-slate-800/50 hover:bg-slate-800 border border-slate-700 text-white font-semibold transition-all">
                View All Releases on GitHub
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            </div>
          </div>
        </div>

        <!-- Installation Guide -->
        <div class="p-8 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50">
          <h2 class="text-2xl font-bold text-white mb-6">Installation Guide</h2>
          <div class="grid md:grid-cols-2 gap-6">
            <div>
              <h3 class="text-lg font-semibold text-blue-400 mb-3">Windows</h3>
              <ol class="space-y-2 text-slate-400 text-sm">
                <li>1. Download the Windows installer (.exe or .zip)</li>
                <li>2. Run the installer and follow the setup wizard</li>
                <li>3. Launch Xibe Chat from the Start menu</li>
              </ol>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-green-400 mb-3">Android</h3>
              <ol class="space-y-2 text-slate-400 text-sm">
                <li>1. Download the APK file</li>
                <li>2. Allow installation from unknown sources</li>
                <li>3. Install and open the app</li>
              </ol>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-purple-400 mb-3">Linux</h3>
              <ol class="space-y-2 text-slate-400 text-sm">
                <li>1. Download the appropriate package (.deb, .rpm, or .AppImage)</li>
                <li>2. Install using your package manager</li>
                <li>3. Run from applications menu or terminal</li>
              </ol>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-cyan-400 mb-3">macOS</h3>
              <ol class="space-y-2 text-slate-400 text-sm">
                <li>1. Download the macOS package</li>
                <li>2. Open and drag to Applications folder</li>
                <li>3. Launch Xibe Chat from Applications</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

useHead({
  title: 'Download - Xibe Chat',
  meta: [
    {
      name: 'description',
      content: 'Download Xibe Chat for your platform. Available for Windows, macOS, Linux, and Android with stable and beta releases.',
    },
  ],
})

const stableRelease = ref(null)
const betaReleases = ref([])
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    const response = await fetch('https://api.github.com/repos/iotserver24/Xibe-chat-app/releases')
    if (!response.ok) throw new Error('Failed to fetch releases')
    
    const releases = await response.json()
    
    // Find stable release (not prerelease)
    stableRelease.value = releases.find(r => !r.prerelease && !r.draft) || releases[0]
    
    // Find beta releases (prerelease)
    betaReleases.value = releases.filter(r => r.prerelease && !r.draft)
    
    loading.value = false
  } catch (e) {
    error.value = 'Unable to load releases. Please visit GitHub directly.'
    loading.value = false
  }
})

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

function formatSize(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

function getPlatformName(filename) {
  const lower = filename.toLowerCase()
  if (lower.includes('windows') || lower.endsWith('.exe') || lower.endsWith('.msi')) return 'Windows'
  if (lower.includes('android') || lower.endsWith('.apk')) return 'Android'
  if (lower.includes('linux') || lower.endsWith('.deb') || lower.endsWith('.rpm') || lower.endsWith('.appimage')) return 'Linux'
  if (lower.includes('macos') || lower.includes('darwin') || lower.endsWith('.dmg')) return 'macOS'
  return 'Other'
}

function getPlatformIcon(filename) {
  const platform = getPlatformName(filename)
  return `icon-${platform.toLowerCase()}`
}

function formatMarkdown(text) {
  if (!text) return ''
  // Simple markdown to HTML conversion
  return text
    .replace(/### (.*)/g, '<h4 class="font-semibold mt-3 mb-1">$1</h4>')
    .replace(/## (.*)/g, '<h3 class="font-bold mt-4 mb-2">$1</h3>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br>')
    .substring(0, 500) + (text.length > 500 ? '...' : '')
}
</script>

<style scoped>
/* Platform Icons as inline SVG via pseudo-elements would be complex, using component approach */
</style>

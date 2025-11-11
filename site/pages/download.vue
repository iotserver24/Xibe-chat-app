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
            <NuxtLink to="/download" class="text-sm font-medium text-white">Download</NuxtLink>
          </div>
          <!-- Mobile menu -->
          <div class="md:hidden">
            <NuxtLink to="/" class="text-sm font-medium text-slate-300 hover:text-white transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
              </svg>
            </NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="relative z-10 container mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16 lg:py-20">
      <!-- Hero -->
      <div class="text-center mb-12 sm:mb-16">
        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-500/10 border border-green-500/20 mb-6">
          <svg class="w-5 h-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <span class="text-sm font-semibold text-green-400">100% Free & Open Source</span>
        </div>
        <h1 class="text-4xl sm:text-5xl md:text-6xl font-black mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent px-4">
          Download Xibe Chat
        </h1>
        <p class="text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto px-4">
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
      <div v-else class="space-y-6 sm:space-y-8">
        <!-- Stable Release -->
        <div v-if="stableRelease" class="relative p-1 rounded-2xl bg-gradient-to-r from-green-500 to-emerald-500">
          <div class="rounded-2xl bg-slate-950 p-4 sm:p-6 lg:p-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
              <div class="min-w-0">
                <div class="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-3 mb-2">
                  <h2 class="text-2xl sm:text-3xl font-bold text-white">Stable Release</h2>
                  <span class="px-3 py-1 rounded-full bg-green-500/20 text-green-400 text-xs sm:text-sm font-semibold w-fit">Recommended</span>
                </div>
                <p class="text-slate-400 text-sm sm:text-base truncate">{{ stableRelease.name || stableRelease.tag_name }}</p>
              </div>
              <div class="text-left sm:text-right flex-shrink-0">
                <div class="text-xl sm:text-2xl font-bold text-white">{{ stableRelease.tag_name }}</div>
                <div class="text-sm text-slate-500">{{ formatDate(stableRelease.published_at) }}</div>
              </div>
            </div>

            <!-- Release Notes -->
            <div v-if="stableRelease.body" class="mb-6 p-3 sm:p-4 rounded-xl bg-slate-900/50 border border-slate-800 overflow-hidden">
              <h3 class="text-base sm:text-lg font-semibold text-white mb-2">Release Notes</h3>
              <div class="text-slate-400 text-xs sm:text-sm prose prose-invert max-w-none overflow-x-auto" v-html="formatMarkdown(stableRelease.body)"></div>
            </div>

            <!-- Download Options -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
              <div v-for="(asset, index) in stableRelease.assets" :key="asset.id" 
                   :class="[
                     'group relative p-4 sm:p-6 rounded-xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border transition-all duration-300 overflow-hidden',
                     index === 0 && getPlatformName(asset.name).toLowerCase() === userOS ? 'border-blue-500/70 shadow-lg shadow-blue-500/20' : 'border-slate-700/50 hover:border-green-500/50'
                   ]">
                <!-- Recommended Badge -->
                <div v-if="index === 0 && getPlatformName(asset.name).toLowerCase() === userOS" class="absolute -top-3 left-1/2 transform -translate-x-1/2 z-10">
                  <span class="px-3 py-1 rounded-full bg-blue-500 text-white text-xs font-semibold shadow-lg whitespace-nowrap">
                    Recommended for You
                  </span>
                </div>
                <div class="flex items-start justify-between mb-4 min-w-0">
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 mb-2">
                      <component :is="getPlatformIcon(asset.name)" class="w-5 h-5 sm:w-6 sm:h-6 text-green-400 flex-shrink-0" />
                      <div class="min-w-0">
                        <h4 class="font-semibold text-white text-sm sm:text-base truncate">{{ getPlatformName(asset.name) }}</h4>
                        <span v-if="getArchitecture(asset.name)" class="text-xs text-green-400 font-medium">{{ getArchitecture(asset.name) }}</span>
                      </div>
                    </div>
                    <p class="text-xs sm:text-sm text-slate-500 truncate">{{ asset.name }}</p>
                  </div>
                </div>
                <div class="flex items-center justify-between text-xs sm:text-sm text-slate-400 mb-4 gap-2">
                  <span class="truncate">{{ formatSize(asset.size) }}</span>
                  <span class="truncate flex-shrink-0">{{ asset.download_count }} downloads</span>
                </div>
                <a :href="asset.browser_download_url" 
                   class="block w-full py-2 px-4 rounded-lg bg-green-600 hover:bg-green-700 text-white font-semibold text-center transition-colors text-sm sm:text-base">
                  Download
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Beta/Pre-release -->
        <div v-if="betaReleases.length > 0" class="relative p-1 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500">
          <div class="rounded-2xl bg-slate-950 p-4 sm:p-6 lg:p-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
              <div class="min-w-0">
                <div class="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-3 mb-2">
                  <h2 class="text-2xl sm:text-3xl font-bold text-white">Beta Releases</h2>
                  <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-xs sm:text-sm font-semibold w-fit">Experimental</span>
                </div>
                <p class="text-slate-400 text-sm sm:text-base">Preview upcoming features (may be unstable)</p>
              </div>
            </div>

            <!-- Beta Releases List -->
            <div class="space-y-4 sm:space-y-6">
              <div v-for="release in betaReleases.slice(0, 3)" :key="release.id" 
                   class="p-4 sm:p-6 rounded-xl bg-slate-900/50 border border-slate-800">
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                  <div class="min-w-0">
                    <h3 class="text-lg sm:text-xl font-bold text-white truncate">{{ release.name || release.tag_name }}</h3>
                    <p class="text-xs sm:text-sm text-slate-500">{{ formatDate(release.published_at) }}</p>
                  </div>
                  <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-xs sm:text-sm font-semibold w-fit">{{ release.tag_name }}</span>
                </div>

                <!-- Assets -->
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3">
                  <a v-for="asset in release.assets" :key="asset.id" 
                     :href="asset.browser_download_url"
                     class="flex items-center gap-2 sm:gap-3 p-3 rounded-lg bg-slate-800/50 border border-slate-700/50 hover:border-blue-500/50 transition-all overflow-hidden">
                    <component :is="getPlatformIcon(asset.name)" class="w-5 h-5 text-blue-400 flex-shrink-0" />
                    <div class="flex-1 min-w-0">
                      <div class="text-xs sm:text-sm font-medium text-white truncate">
                        {{ getPlatformName(asset.name) }}
                        <span v-if="getArchitecture(asset.name)" class="text-blue-400 ml-1">({{ getArchitecture(asset.name) }})</span>
                      </div>
                      <div class="text-xs text-slate-500 truncate">{{ formatSize(asset.size) }}</div>
                    </div>
                  </a>
                </div>
              </div>
            </div>

            <!-- View All Beta Releases -->
            <div class="text-center mt-6">
              <a href="https://github.com/iotserver24/Xibe-chat-app/releases" target="_blank"
                 class="inline-flex items-center gap-2 px-4 sm:px-6 py-2 sm:py-3 rounded-xl bg-slate-800/50 hover:bg-slate-800 border border-slate-700 text-white font-semibold transition-all text-sm sm:text-base">
                View All Releases on GitHub
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            </div>
          </div>
        </div>

        <!-- Free & Open Source Notice -->
        <div class="p-6 sm:p-8 rounded-2xl bg-gradient-to-r from-green-500/10 via-emerald-500/10 to-teal-500/10 backdrop-blur-sm border border-green-500/30">
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-green-500/20 mb-4">
              <svg class="w-7 h-7 sm:w-8 sm:h-8 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7" />
              </svg>
            </div>
            <h2 class="text-2xl sm:text-3xl font-bold text-white mb-4">100% Free & Open Source</h2>
            <p class="text-base sm:text-lg text-slate-300 max-w-2xl mx-auto px-4">
              Xibe Chat is completely free to use with no hidden costs, subscriptions, or premium features. 
              Download and enjoy all features without limitations!
            </p>
          </div>
        </div>

        <!-- Installation Guide -->
        <div class="p-4 sm:p-6 lg:p-8 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50">
          <h2 class="text-xl sm:text-2xl font-bold text-white mb-4 sm:mb-6">Installation Guide</h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6">
            <div class="p-3 sm:p-0">
              <h3 class="text-base sm:text-lg font-semibold text-blue-400 mb-3">Windows</h3>
              <ol class="space-y-2 text-slate-400 text-xs sm:text-sm">
                <li>1. Download the Windows installer (.exe or .zip)</li>
                <li>2. Run the installer and follow the setup wizard</li>
                <li>3. Launch Xibe Chat from the Start menu</li>
              </ol>
            </div>
            <div class="p-3 sm:p-0">
              <h3 class="text-base sm:text-lg font-semibold text-green-400 mb-3">Android</h3>
              <ol class="space-y-2 text-slate-400 text-xs sm:text-sm">
                <li>1. Download the APK file</li>
                <li>2. Allow installation from unknown sources</li>
                <li>3. Install and open the app</li>
              </ol>
            </div>
            <div class="p-3 sm:p-0">
              <h3 class="text-base sm:text-lg font-semibold text-purple-400 mb-3">Linux</h3>
              <ol class="space-y-2 text-slate-400 text-xs sm:text-sm">
                <li>1. Download the appropriate package (.deb, .rpm, or .AppImage)</li>
                <li>2. Install using your package manager</li>
                <li>3. Run from applications menu or terminal</li>
              </ol>
            </div>
            <div class="p-3 sm:p-0">
              <h3 class="text-base sm:text-lg font-semibold text-cyan-400 mb-3">macOS</h3>
              <ol class="space-y-2 text-slate-400 text-xs sm:text-sm">
                <li>1. Download the macOS package</li>
                <li>2. Open and drag to Applications folder</li>
                <li>3. Launch Xibe Chat from Applications</li>
              </ol>
            </div>
          </div>
        </div>

        <!-- Credits -->
        <div class="p-4 sm:p-6 lg:p-8 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-900/50 backdrop-blur-sm border border-slate-700/50">
          <div class="text-center">
            <h2 class="text-xl sm:text-2xl font-bold text-white mb-4">Created By</h2>
            <div class="flex items-center justify-center gap-4">
              <a href="https://github.com/iotserver24" target="_blank" class="group inline-flex items-center gap-2 sm:gap-3 px-4 sm:px-6 py-2 sm:py-3 rounded-xl bg-slate-800/50 hover:bg-slate-800 border border-slate-700 transition-all">
                <svg class="w-5 h-5 sm:w-6 sm:h-6 text-slate-400 group-hover:text-white flex-shrink-0" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                </svg>
                <div class="text-left">
                  <div class="text-xs sm:text-sm font-semibold text-white">iotserver24</div>
                  <div class="text-xs text-slate-400">Creator & Maintainer</div>
                </div>
              </a>
            </div>
            <p class="text-slate-400 text-xs sm:text-sm mt-4 px-4">
              Special thanks to all contributors and the open source community
            </p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

useHead({
  title: 'Download Xibe Chat - Free AI Chat App for All Platforms',
  meta: [
    {
      name: 'description',
      content: 'Download Xibe Chat for free - available for Windows, macOS, Linux, Android & iOS. Get the latest stable or beta releases of this open-source AI chat application.',
    },
    {
      name: 'keywords',
      content: 'download Xibe Chat, download AI chat app, free AI app download, Windows AI app, macOS AI app, Linux AI app, Android AI app, iOS AI app',
    },
  ],
})

const stableRelease = ref(null)
const betaReleases = ref([])
const loading = ref(true)
const error = ref(null)
const userOS = ref('')
const userArch = ref('')

// Detect user's OS and architecture
function detectUserPlatform() {
  const ua = navigator.userAgent.toLowerCase()
  const platform = navigator.platform.toLowerCase()
  
  // Detect OS
  if (ua.includes('android')) {
    userOS.value = 'android'
  } else if (ua.includes('iphone') || ua.includes('ipad')) {
    userOS.value = 'ios'
  } else if (ua.includes('win')) {
    userOS.value = 'windows'
  } else if (ua.includes('mac')) {
    userOS.value = 'macos'
  } else if (ua.includes('linux')) {
    userOS.value = 'linux'
  }
  
  // Detect architecture
  if (ua.includes('arm64') || ua.includes('aarch64') || platform.includes('arm')) {
    userArch.value = 'arm64'
  } else if (ua.includes('x86_64') || ua.includes('amd64') || ua.includes('wow64') || platform.includes('win64') || platform.includes('x86_64')) {
    userArch.value = 'x64'
  } else {
    userArch.value = 'x64' // Default to x64
  }
}

// Sort assets to show user's platform first
function sortAssetsByUserPlatform(assets) {
  if (!assets) return []
  
  return [...assets].sort((a, b) => {
    const aPlatform = getPlatformName(a.name).toLowerCase()
    const bPlatform = getPlatformName(b.name).toLowerCase()
    const aArch = getArchitecture(a.name).toLowerCase()
    const bArch = getArchitecture(b.name).toLowerCase()
    
    // Check if matches user's OS
    const aMatchesOS = aPlatform === userOS.value
    const bMatchesOS = bPlatform === userOS.value
    
    // Check if matches user's architecture
    const aMatchesArch = aArch.includes(userArch.value) || aArch === 'universal'
    const bMatchesArch = bArch.includes(userArch.value) || bArch === 'universal'
    
    // Prioritize exact matches (OS + Arch)
    if (aMatchesOS && aMatchesArch && !(bMatchesOS && bMatchesArch)) return -1
    if (bMatchesOS && bMatchesArch && !(aMatchesOS && aMatchesArch)) return 1
    
    // Then OS matches
    if (aMatchesOS && !bMatchesOS) return -1
    if (bMatchesOS && !aMatchesOS) return 1
    
    return 0
  })
}

onMounted(async () => {
  detectUserPlatform()
  
  try {
    const response = await fetch('https://api.github.com/repos/iotserver24/Xibe-chat-app/releases')
    if (!response.ok) throw new Error('Failed to fetch releases')
    
    const releases = await response.json()
    
    // Find stable release (not prerelease)
    const stable = releases.find(r => !r.prerelease && !r.draft) || releases[0]
    if (stable) {
      stable.assets = sortAssetsByUserPlatform(stable.assets)
      stableRelease.value = stable
    }
    
    // Find beta releases (prerelease)
    betaReleases.value = releases.filter(r => r.prerelease && !r.draft).map(release => ({
      ...release,
      assets: sortAssetsByUserPlatform(release.assets)
    }))
    
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
  if (lower.includes('ios') || lower.endsWith('.ipa')) return 'iOS'
  return 'Other'
}

function getArchitecture(filename) {
  const lower = filename.toLowerCase()
  if (lower.includes('arm64') || lower.includes('aarch64')) return 'ARM64'
  if (lower.includes('x64') || lower.includes('x86_64') || lower.includes('amd64')) return 'x64'
  if (lower.includes('x86') || lower.includes('i386') || lower.includes('i686')) return 'x86'
  if (lower.includes('universal')) return 'Universal'
  // For APK/AAB without architecture specified, it's usually universal
  if (lower.endsWith('.apk') || lower.endsWith('.aab')) return 'Universal'
  return ''
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

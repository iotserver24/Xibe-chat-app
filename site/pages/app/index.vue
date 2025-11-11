<template>
  <div class="min-h-screen bg-gray-900 text-white flex items-center justify-center">
    <div class="text-center max-w-md p-8">
      <div class="mb-8">
        <div class="inline-block p-4 bg-blue-600 rounded-full mb-4">
          <svg
            class="w-16 h-16"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
            />
          </svg>
        </div>
        <h1 class="text-3xl font-bold mb-2">Opening Xibe Chat...</h1>
        <p class="text-gray-400">
          Creating a new chat for you. If the app doesn't open automatically, please make
          sure it's installed.
        </p>
      </div>

      <div class="space-y-4">
        <a
          :href="deepLinkUrl"
          class="block bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition"
        >
          Open in App
        </a>
        <NuxtLink
          to="/"
          class="block bg-gray-800 hover:bg-gray-700 text-white font-bold py-3 px-6 rounded-lg transition"
        >
          Back to Home
        </NuxtLink>
      </div>

      <p class="text-sm text-gray-500 mt-8">
        Don't have the app?
        <a href="/#download" class="text-blue-400 hover:text-blue-300">Download it here</a>
      </p>
    </div>
  </div>
</template>

<script setup>
const route = useRoute();

// Check for query parameters (message, text, or prompt)
const messageParam = route.query.message || route.query.text || route.query.prompt;

// Create deep link URL
const deepLinkUrl = computed(() => {
  if (messageParam) {
    const encodedMessage = encodeURIComponent(messageParam);
    return `xibechat://new?message=${encodedMessage}`;
  }
  return 'xibechat://new';
});

// HTTPS fallback URL
const httpsLinkUrl = computed(() => {
  if (messageParam) {
    const encodedMessage = encodeURIComponent(messageParam);
    return `https://chat.xibe.app/app/new?message=${encodedMessage}`;
  }
  return 'https://chat.xibe.app/app/new';
});

// Auto-redirect on mount
onMounted(() => {
  // Try to open the custom scheme deep link
  window.location.href = deepLinkUrl.value;
  
  // Fallback to HTTPS after a delay if app doesn't open
  setTimeout(() => {
    if (document.visibilityState === 'visible') {
      window.location.href = httpsLinkUrl.value;
    }
  }, 1000);
});

useHead({
  title: 'Opening Xibe Chat...',
  meta: [
    {
      name: 'description',
      content: 'Redirecting to Xibe Chat application',
    },
  ],
});
</script>

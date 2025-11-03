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
        <p class="text-gray-400 mb-4">
          Preparing your message in the app. If the app doesn't open automatically, please
          make sure it's installed.
        </p>
        <div v-if="promptText" class="bg-gray-800 p-4 rounded-lg text-left">
          <p class="text-sm text-gray-500 mb-2">Your message:</p>
          <p class="text-white">{{ promptText }}</p>
        </div>
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
const promptParam = route.params.prompt;

// Handle array or string prompt
const promptText = Array.isArray(promptParam) ? promptParam.join('/') : promptParam;

// Create deep link URL with encoded prompt
const deepLinkUrl = computed(() => {
  return `xibechat://mes/${encodeURIComponent(promptText)}`;
});

// Auto-redirect on mount
onMounted(() => {
  // Try to open the deep link
  window.location.href = deepLinkUrl.value;
});

useHead({
  title: 'Opening Xibe Chat with Message...',
  meta: [
    {
      name: 'description',
      content: 'Redirecting to Xibe Chat application with a pre-filled message',
    },
  ],
});
</script>

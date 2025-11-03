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
              d="M12 6v6m0 0v6m0-6h6m-6 0H6"
            />
          </svg>
        </div>
        <h1 class="text-3xl font-bold mb-2">Opening New Chat...</h1>
        <p class="text-gray-400">
          Creating a fresh conversation. If the app doesn't open automatically, please make
          sure it's installed.
        </p>
      </div>

      <div class="space-y-4">
        <a
          :href="deepLinkUrl"
          class="block bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition"
        >
          Open New Chat
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
const deepLinkUrl = 'xibechat://new';

// Auto-redirect on mount
onMounted(() => {
  // Try to open the deep link
  window.location.href = deepLinkUrl;
});

useHead({
  title: 'Opening New Chat - Xibe Chat',
  meta: [
    {
      name: 'description',
      content: 'Opening a new chat in Xibe Chat application',
    },
  ],
});
</script>

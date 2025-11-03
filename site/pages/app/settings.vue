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
              d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
            />
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
        </div>
        <h1 class="text-3xl font-bold mb-2">Opening Settings...</h1>
        <p class="text-gray-400">
          Opening Xibe Chat settings. If the app doesn't open automatically, please make
          sure it's installed.
        </p>
      </div>

      <div class="space-y-4">
        <a
          :href="deepLinkUrl"
          class="block bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition"
        >
          Open Settings in App
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
const deepLinkUrl = 'xibechat://settings';

// Auto-redirect on mount
onMounted(() => {
  // Try to open the deep link
  window.location.href = deepLinkUrl;
});

useHead({
  title: 'Opening Xibe Chat Settings...',
  meta: [
    {
      name: 'description',
      content: 'Redirecting to Xibe Chat application settings',
    },
  ],
});
</script>

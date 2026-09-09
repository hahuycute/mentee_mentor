<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full text-center">
      <div class="mx-auto h-24 w-24 bg-primary-100 rounded-full flex items-center justify-center mb-6">
        <svg class="h-12 w-12 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <h1 class="text-4xl font-bold text-gray-900 mb-2">404</h1>
      <h2 class="text-2xl font-semibold text-gray-700 mb-4">Page Not Found</h2>
      <p class="text-gray-500 mb-8">Sorry, we couldn't find the page you're looking for.</p>
      <div class="flex justify-center space-x-4">
        <router-link
          to="/dashboard"
          class="px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium"
        >
          Go to Dashboard
        </router-link>
        <router-link
          to="/"
          class="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
        >
          Back Home
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts>
</script>

<style scoped>
</style>
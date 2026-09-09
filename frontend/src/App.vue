<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <router-view v-slot="{ Component }">
      <component :is="Component" />
    </router-view>
    <ToastContainer :options="toastContainerOptions" />
  </div>
</template>

<script setup lang="ts">
// Provide toast globally
const toastContainerOptions: Record<string, any> = {
  position: 'top-right',
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: 'button',
  icon: true,
  rtl: false,
}
</script>

<style scoped>
/* Global styles are in assets/main.css */
</style>
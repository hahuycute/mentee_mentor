<template>
  <div class="min-h-screen bg-gray-50">
    <aside
      v-if="!isAuthPage"
      class="fixed inset-y-0 left-0 z-50 w-64 bg-white border-r border-gray-200 transform transition-transform duration-300 lg:translate-x-0"
      :class="{ '-translate-x-full': sidebarOpen }"
    >
      <Sidebar @close="sidebarOpen = false" />
    </aside>

    <div
      v-if="!isAuthPage && sidebarOpen"
      class="fixed inset-0 z-40 bg-gray-900/50 lg:hidden"
      @click="sidebarOpen = false"
    />

    <div class="lg:pl-64 min-h-screen">
      <header
        v-if="!isAuthPage"
        class="sticky top-0 z-30 bg-white border-b border-gray-200"
      >
        <slot name="header">
          <Header />
        </slot>
      </header>

      <main class="py-6">
        <slot name="content" />
      </main>
    </div>

    <div v-else class="min-h-screen">
      <slot name="content" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import Sidebar from './Sidebar.vue'
import Header from './Header.vue'

const route = useRoute()
const sidebarOpen = ref(false)

const isAuthPage = computed(() => {
  const authPages = ['Login', 'Register', 'VerifyEmail', 'ForgotPassword', 'ResetPassword']
  return authPages.includes(route.name as string)
})

</script>

<style scoped>
</style>
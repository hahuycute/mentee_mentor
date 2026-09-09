<template>
  <header class="bg-white border-b border-gray-200">
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <div class="flex items-center">
          <button
            @click="$emit('toggle-sidebar')"
            class="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500"
            aria-label="Toggle menu"
          >
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <router-link to="/dashboard" class="ml-4 flex items-center">
            <span class="text-xl font-bold text-primary-600">MenteeMentor</span>
          </router-link>
        </div>

        <div class="flex items-center space-x-4">
          <!-- Search -->
          <div class="hidden md:block">
            <div class="relative">
              <input
                type="text"
                placeholder="Search..."
                class="w-64 pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
              <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>

          <!-- Notifications -->
          <div class="relative">
            <button
              @click="$router.push({ name: 'Notifications' })"
              class="p-2 rounded-full text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500 relative"
            >
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
              <span v-if="unreadCount > 0" class="absolute top-1 right-1 h-4 w-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">{{ unreadCount }}</span>
            </button>
          </div>

          <!-- User Menu -->
          <div class="relative" ref="userMenu">
            <button
              @click="showUserMenu = !showUserMenu"
              class="flex items-center space-x-2 p-2 rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <img
                :src="authStore.user?.avatar || defaultAvatar"
                :alt="authStore.user?.fullName || 'User'"
                class="h-8 w-8 rounded-full"
              />
              <span class="hidden md:block text-sm font-medium text-gray-700">{{ authStore.user?.fullName }}</span>
              <svg class="hidden md:block h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <Transition enter-active-class="transition ease-out duration-100" enter-from-class="transform opacity-0 scale-95" leave-active-class="transition ease-in duration-75" leave-to-class="transform opacity-0 scale-95">
              <div v-if="showUserMenu" class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border border-gray-200 py-1 z-50">
                <div class="px-4 py-2 border-b border-gray-100">
                  <p class="text-sm font-medium text-gray-900">{{ authStore.user?.fullName }}</p>
                  <p class="text-sm text-gray-500 truncate">{{ authStore.user?.email }}</p>
                  <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium" :class="getRoleBadgeClass(authStore.user?.role)">
                    {{ authStore.user?.role }}
                  </span>
                </div>
                <router-link to="/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" @click="showUserMenu = false">
                  <svg class="inline h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  Profile
                </router-link>
                <router-link v-if="authStore.hasRole('MENTOR')" to="/schedules" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" @click="showUserMenu = false">
                  <svg class="inline h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  My Schedules
                </router-link>
                <router-link to="/bookings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" @click="showUserMenu = false">
                  <svg class="inline h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                  </svg>
                  My Bookings
                </router-link>
                <div class="border-t border-gray-100 mt-1 pt-1">
                  <button @click="handleLogout" class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                    <svg class="inline h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                    </svg>
                    Logout
                  </button>
                </div>
              </div>
            </Transition>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

const emit = defineEmits(['toggle-sidebar'])
const router = useRouter()
const authStore = useAuthStore()

const showUserMenu = ref(false)
const unreadCount = ref(0)
const userMenu = ref<HTMLElement | null>(null)

const defaultAvatar = 'https://ui-avatars.com/api/?name=User&background=0ea5e9&color=fff&size=128'

const getRoleBadgeClass = (role?: string) => {
  switch (role) {
    case 'ADMIN': return 'bg-purple-100 text-purple-800'
    case 'MENTOR': return 'bg-blue-100 text-blue-800'
    case 'MENTEE': return 'bg-green-100 text-green-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const handleLogout = async () => {
  await authStore.logout()
  router.push({ name: 'Login' })
}

const loadUnreadCount = async () => {
  try {
    const response = await api.get('/api/notifications/unread-count')
    unreadCount.value = response.data.count
  } catch (error) {
    console.error('Failed to load unread count:', error)
  }
}

const handleClickOutside = (event: MouseEvent) => {
  if (userMenu.value && !userMenu.value.contains(event.target as Node)) {
    showUserMenu.value = false
  }
}

onMounted(() => {
  loadUnreadCount()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
</style>
<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Notifications'" :showSearch="false">
          <template #actions>
            <button
              v-if="unreadCount > 0"
              @click="markAllAsRead"
              :disabled="markingAll"
              class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium text-sm disabled:opacity-50"
            >
              <span v-if="markingAll">Marking...</span>
              <span v-else>Mark all as read</span>
            </button>
          </template>
        </Header>
      </template>

      <template #content>
        <div class="p-6 max-w-3xl mx-auto">
          <!-- Filter Tabs -->
          <div class="mb-6 flex space-x-2 border-b border-gray-200">
            <button
              v-for="tab in tabs"
              :key="tab.value"
              @click="activeTab = tab.value"
              class="px-4 py-2 text-sm font-medium border-b-2 transition-colors"
              :class="activeTab === tab.value ? 'border-primary-600 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
            >
              {{ tab.label }}
            </button>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Empty State -->
          <div v-else-if="filteredNotifications.length === 0" class="text-center py-12 bg-white rounded-xl shadow-sm border border-gray-100">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <BellIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">
              {{ activeTab === 'unread' ? 'All caught up!' : 'No notifications yet' }}
            </h3>
            <p class="text-gray-500">
              {{ activeTab === 'unread' ? 'You have no unread notifications.' : 'Notifications about bookings, sessions, and more will appear here.' }}
            </p>
          </div>

          <!-- Notification List -->
          <div v-else class="bg-white rounded-xl shadow-sm border border-gray-100 divide-y divide-gray-100">
            <NotificationItem
              v-for="notification in filteredNotifications"
              :key="notification.id"
              :notification="notification"
              @mark-read="markAsRead"
            />
          </div>

          <!-- Pagination -->
          <div v-if="totalPages > 1" class="mt-8 flex items-center justify-center space-x-2">
            <button
              @click="changePage(currentPage - 1)"
              :disabled="currentPage === 1"
              class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <span class="px-3 py-2 text-sm text-gray-700">
              Page {{ currentPage }} of {{ totalPages }}
            </span>
            <button
              @click="changePage(currentPage + 1)"
              :disabled="currentPage === totalPages"
              class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { BellIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import NotificationItem from '@/components/ui/NotificationItem.vue'
import api from '@/services/api'

interface Notification {
  id: number
  type: string
  message: string
  readAt?: string | null
  createdAt: string
}

const notifications = ref<Notification[]>([])
const loading = ref(false)
const markingAll = ref(false)
const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(20)
const totalPages = ref(1)

const tabs = [
  { value: 'all', label: 'All' },
  { value: 'unread', label: 'Unread' },
]

const filteredNotifications = computed(() => {
  if (activeTab.value === 'all') return notifications.value
  return notifications.value.filter(n => !n.readAt)
})

const unreadCount = computed(() => notifications.value.filter(n => !n.readAt).length)

const loadNotifications = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/notifications', {
      params: { page: currentPage.value - 1, size: pageSize.value }
    })
    notifications.value = response.data.content || response.data
    totalPages.value = response.data.totalPages || 1
  } catch (error) {
    console.error('Failed to load notifications:', error)
  } finally {
    loading.value = false
  }
}

const markAsRead = async (notificationId: number) => {
  try {
    await api.patch(`/api/notifications/${notificationId}/read`)
    const notification = notifications.value.find(n => n.id === notificationId)
    if (notification) {
      notification.readAt = new Date().toISOString()
    }
  } catch (error) {
    console.error('Failed to mark notification as read:', error)
  }
}

const markAllAsRead = async () => {
  markingAll.value = true
  try {
    await api.patch('/api/notifications/read-all')
    await loadNotifications()
  } catch (error) {
    console.error('Failed to mark all notifications as read:', error)
  } finally {
    markingAll.value = false
  }
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadNotifications()
  }
}

onMounted(() => {
  loadNotifications()
})
</script>

<style scoped>
</style>
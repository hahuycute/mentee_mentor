<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'My Sessions'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Filter Tabs -->
          <div class="mb-6 flex flex-wrap space-x-2 border-b border-gray-200">
            <button
              v-for="tab in tabs"
              :key="tab.value"
              @click="activeTab = tab.value"
              class="px-4 py-2 text-sm font-medium border-b-2 transition-colors"
              :class="activeTab === tab.value ? 'border-primary-600 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
            >
              {{ tab.label }} ({{ tab.count }})
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
          <div v-else-if="filteredSessions.length === 0" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <ClockIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">{{ emptyTitle }}</h3>
            <p class="text-gray-500 mb-6">{{ emptyMessage }}</p>
          </div>

          <!-- Session List -->
          <div v-else class="space-y-4">
            <SessionCard
              v-for="session in filteredSessions"
              :key="session.id"
              :session="session"
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
import { ClockIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import SessionCard from '@/components/ui/SessionCard.vue'
import api from '@/services/api'

interface Session {
  id: number
  status: string
  scheduledAt: string
  topic?: { name: string }
  mentor?: { fullName: string }
  mentee?: { fullName: string }
}

const sessions = ref<Session[]>([])
const loading = ref(false)
const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const totalPages = ref(1)

const tabs = ref([
  { value: 'all', label: 'All', count: 0 },
  { value: 'scheduled', label: 'Scheduled', count: 0 },
  { value: 'confirmed', label: 'Confirmed', count: 0 },
  { value: 'in_progress', label: 'In Progress', count: 0 },
  { value: 'completed', label: 'Completed', count: 0 },
  { value: 'cancelled', label: 'Cancelled', count: 0 },
])

const filteredSessions = computed(() => {
  if (activeTab.value === 'all') return sessions.value
  return sessions.value.filter(s => s.status.toLowerCase() === activeTab.value.toUpperCase().replace('_', ''))
})

const emptyTitle = computed(() => {
  switch (activeTab.value) {
    case 'scheduled': return 'No scheduled sessions'
    case 'confirmed': return 'No confirmed sessions'
    case 'in_progress': return 'No sessions in progress'
    case 'completed': return 'No completed sessions'
    case 'cancelled': return 'No cancelled sessions'
    default: return 'No sessions yet'
  }
})

const emptyMessage = computed(() => {
  switch (activeTab.value) {
    case 'scheduled': return 'You don\'t have any scheduled sessions at the moment.'
    case 'confirmed': return 'You don\'t have any confirmed sessions at the moment.'
    case 'in_progress': return 'You don\'t have any sessions currently in progress.'
    case 'completed': return 'You don\'t have any completed sessions yet.'
    case 'cancelled': return 'You don\'t have any cancelled sessions.'
    default: return 'Book a session with a mentor to get started.'
  }
})

const loadSessions = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/sessions/my', {
      params: { page: currentPage.value - 1, size: pageSize.value }
    })
    sessions.value = response.data.content || response.data

    // Update tab counts
    tabs.value[0].count = sessions.value.length
    tabs.value[1].count = sessions.value.filter(s => s.status === 'SCHEDULED').length
    tabs.value[2].count = sessions.value.filter(s => s.status === 'CONFIRMED').length
    tabs.value[3].count = sessions.value.filter(s => s.status === 'IN_PROGRESS').length
    tabs.value[4].count = sessions.value.filter(s => s.status === 'COMPLETED').length
    tabs.value[5].count = sessions.value.filter(s => s.status === 'CANCELLED').length

    totalPages.value = response.data.totalPages || 1
  } catch (error) {
    console.error('Failed to load sessions:', error)
  } finally {
    loading.value = false
  }
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadSessions()
  }
}

onMounted(() => {
  loadSessions()
})
</script>

<style scoped>
</style>
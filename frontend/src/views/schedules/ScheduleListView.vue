<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'My Schedules'" :showSearch="false">
          <template #actions>
            <router-link to="/schedules/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium flex items-center space-x-2">
              <PlusIcon class="h-5 w-5" />
              <span>Create Schedule</span>
            </router-link>
          </template>
        </Header>
      </template>

      <template #content>
        <div class="p-6">
          <!-- Filter Tabs -->
          <div class="mb-6 flex space-x-2 border-b border-gray-200">
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
          <div v-else-if="filteredSchedules.length === 0" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <CalendarIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No schedules found</h3>
            <p class="text-gray-500 mb-6">{{ emptyMessage }}</p>
            <router-link to="/schedules/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium inline-flex items-center space-x-2">
              <PlusIcon class="h-5 w-5" />
              <span>Create your first schedule</span>
            </router-link>
          </div>

          <!-- Schedule List -->
          <div v-else class="space-y-4">
            <div
              v-for="schedule in filteredSchedules"
              :key="schedule.id"
              class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
            >
              <div class="p-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                  <div class="flex items-center space-x-4">
                    <div class="flex-shrink-0 w-16 h-16 bg-primary-50 rounded-xl flex items-center justify-center">
                      <CalendarIcon class="h-8 w-8 text-primary-600" />
                    </div>
                    <div>
                      <div class="flex items-center space-x-2">
                        <h3 class="text-lg font-semibold text-gray-900">{{ formatDay(schedule.dayOfWeek) }}</h3>
                        <span
                          class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                          :class="getStatusClass(schedule.status)"
                        >
                          {{ formatStatus(schedule.status) }}
                        </span>
                      </div>
                      <p class="text-gray-500 text-sm mt-1">
                        {{ formatTime(schedule.startTime) }} - {{ formatTime(schedule.endTime) }}
                      </p>
                    </div>
                  </div>

                  <div class="flex items-center space-x-3">
                    <div class="hidden sm:block text-right">
                      <p class="text-sm font-medium text-gray-900">{{ schedule.bookingsCount || 0 }} bookings</p>
                      <p class="text-sm text-gray-500">{{ schedule.maxBookings }} max</p>
                    </div>
                    <router-link
                      :to="`/schedules/${schedule.id}`"
                      class="px-4 py-2 text-primary-600 hover:text-primary-500 font-medium text-sm"
                    >
                      View Details
                    </router-link>
                    <button
                      v-if="schedule.status === 'AVAILABLE'"
                      @click="toggleScheduleStatus(schedule.id, 'UNAVAILABLE')"
                      class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium text-sm"
                    >
                      Disable
                    </button>
                    <button
                      v-else-if="schedule.status === 'UNAVAILABLE'"
                      @click="toggleScheduleStatus(schedule.id, 'AVAILABLE')"
                      class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium text-sm"
                    >
                      Enable
                    </button>
                  </div>
                </div>
              </div>
            </div>
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
import { CalendarIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

interface Schedule {
  id: number
  dayOfWeek: string
  startTime: string
  endTime: string
  status: string
  maxBookings: number
  bookingsCount?: number
}

const schedules = ref<Schedule[]>([])
const loading = ref(false)
const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const totalPages = ref(1)

const tabs = ref([
  { value: 'all', label: 'All', count: 0 },
  { value: 'available', label: 'Available', count: 0 },
  { value: 'unavailable', label: 'Unavailable', count: 0 },
])

const filteredSchedules = computed(() => {
  if (activeTab.value === 'all') return schedules.value
  return schedules.value.filter(s => s.status.toLowerCase() === activeTab.value)
})

const emptyMessage = computed(() => {
  switch (activeTab.value) {
    case 'available': return 'No available schedules. Create one to start accepting bookings.'
    case 'unavailable': return 'No unavailable schedules.'
    default: return 'You haven\'t created any schedules yet.'
  }
})

const loadSchedules = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/schedules/my', {
      params: { page: currentPage.value - 1, size: pageSize.value }
    })
    schedules.value = response.data.content || response.data
    totalPages.value = response.data.totalPages || 1

    // Update tab counts
    tabs.value[0].count = schedules.value.length
    tabs.value[1].count = schedules.value.filter(s => s.status === 'AVAILABLE').length
    tabs.value[2].count = schedules.value.filter(s => s.status === 'UNAVAILABLE').length
  } catch (error) {
    console.error('Failed to load schedules:', error)
  } finally {
    loading.value = false
  }
}

const toggleScheduleStatus = async (scheduleId: number, newStatus: string) => {
  try {
    await api.patch(`/api/schedules/${scheduleId}/status`, { status: newStatus })
    await loadSchedules()
  } catch (error) {
    console.error('Failed to update schedule status:', error)
  }
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadSchedules()
  }
}

const formatDay = (day: string) => {
  return day.charAt(0) + day.slice(1).toLowerCase()
}

const formatTime = (time: string) => {
  const [hours, minutes] = time.split(':')
  const hour = parseInt(hours)
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour % 12 || 12
  return `${displayHour}:${minutes} ${ampm}`
}

const getStatusClass = (status: string) => {
  switch (status) {
    case 'AVAILABLE': return 'bg-green-100 text-green-800'
    case 'UNAVAILABLE': return 'bg-gray-100 text-gray-800'
    case 'FULL': return 'bg-yellow-100 text-yellow-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatStatus = (status: string) => {
  return status.charAt(0) + status.slice(1).toLowerCase()
}

onMounted(() => {
  loadSchedules()
})
</script>

<style scoped>
</style>
<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'My Bookings'" :showSearch="false" />
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
          <div v-else-if="filteredBookings.length === 0" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <CalendarIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">{{ emptyTitle }}</h3>
            <p class="text-gray-500 mb-6">{{ emptyMessage }}</p>
            <router-link v-if="authStore.user?.role === 'MENTEE'" to="/schedules" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium inline-flex items-center space-x-2">
              <CalendarIcon class="h-5 w-5" />
              <span>Browse Available Schedules</span>
            </router-link>
          </div>

          <!-- Booking List -->
          <div v-else class="space-y-4">
            <div
              v-for="booking in filteredBookings"
              :key="booking.id"
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
                        <h3 class="text-lg font-semibold text-gray-900">
                          {{ authStore.user?.role === 'MENTOR' ? (booking.mentee?.fullName || 'Mentee') : (booking.mentor?.fullName || 'Mentor') }}
                        </h3>
                        <span
                          class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                          :class="getStatusClass(booking.status)"
                        >
                          {{ formatStatus(booking.status) }}
                        </span>
                      </div>
                      <p class="text-gray-500 text-sm mt-1">
                        {{ formatDay(booking.schedule?.dayOfWeek || '') }} at {{ formatTime(booking.schedule?.startTime || '') }} - {{ formatTime(booking.schedule?.endTime || '') }}
                      </p>
                      <p v-if="booking.topic" class="text-primary-600 text-sm mt-1">{{ booking.topic.name }}</p>
                    </div>
                  </div>

                  <div class="flex items-center space-x-3">
                    <router-link
                      :to="`/bookings/${booking.id}`"
                      class="px-4 py-2 text-primary-600 hover:text-primary-500 font-medium text-sm"
                    >
                      View Details
                    </router-link>

                    <!-- Actions based on role and status -->
                    <div v-if="authStore.user?.role === 'MENTOR'" class="flex items-center space-x-2">
                      <button
                        v-if="booking.status === 'PENDING'"
                        @click="updateBookingStatus(booking.id, 'CONFIRMED')"
                        class="px-3 py-1.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium text-sm"
                      >
                        Confirm
                      </button>
                      <button
                        v-if="booking.status === 'PENDING'"
                        @click="updateBookingStatus(booking.id, 'CANCELLED')"
                        class="px-3 py-1.5 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium text-sm"
                      >
                        Reject
                      </button>
                      <button
                        v-else-if="booking.status === 'CONFIRMED'"
                        @click="updateBookingStatus(booking.id, 'CANCELLED')"
                        class="px-3 py-1.5 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium text-sm"
                      >
                        Cancel
                      </button>
                    </div>

                    <div v-else-if="authStore.user?.role === 'MENTEE'" class="flex items-center space-x-2">
                      <button
                        v-if="booking.status === 'PENDING' || booking.status === 'CONFIRMED'"
                        @click="cancelBooking(booking.id)"
                        class="px-3 py-1.5 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium text-sm"
                      >
                        Cancel
                      </button>
                    </div>
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
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

interface Booking {
  id: number
  status: string
  schedule?: {
    dayOfWeek: string
    startTime: string
    endTime: string
  }
  mentor?: { fullName: string }
  mentee?: { fullName: string }
  topic?: { name: string }
}

const bookings = ref<Booking[]>([])
const loading = ref(false)
const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const totalPages = ref(1)

const tabs = ref([
  { value: 'all', label: 'All', count: 0 },
  { value: 'pending', label: 'Pending', count: 0 },
  { value: 'confirmed', label: 'Confirmed', count: 0 },
  { value: 'cancelled', label: 'Cancelled', count: 0 },
  { value: 'completed', label: 'Completed', count: 0 },
])

const filteredBookings = computed(() => {
  if (activeTab.value === 'all') return bookings.value
  return bookings.value.filter(b => b.status.toLowerCase() === activeTab.value.toUpperCase())
})

const emptyTitle = computed(() => {
  switch (activeTab.value) {
    case 'pending': return 'No pending bookings'
    case 'confirmed': return 'No confirmed bookings'
    case 'cancelled': return 'No cancelled bookings'
    case 'completed': return 'No completed bookings'
    default: return authStore.user?.role === 'MENTEE' ? 'No bookings yet' : 'No incoming bookings'
  }
})

const emptyMessage = computed(() => {
  switch (activeTab.value) {
    case 'pending': return 'You don\'t have any pending bookings at the moment.'
    case 'confirmed': return 'You don\'t have any confirmed bookings at the moment.'
    case 'cancelled': return 'You don\'t have any cancelled bookings.'
    case 'completed': return 'You don\'t have any completed bookings yet.'
    default:
      return authStore.user?.role === 'MENTEE'
        ? 'Start by browsing available mentor schedules and booking a session.'
        : 'Your available schedules will appear here when mentees book them.'
  }
})

const loadBookings = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/bookings/my', {
      params: { page: currentPage.value - 1, size: pageSize.value }
    })
    bookings.value = response.data.content || response.data

    // Update tab counts
    tabs.value[0].count = bookings.value.length
    tabs.value[1].count = bookings.value.filter(b => b.status === 'PENDING').length
    tabs.value[2].count = bookings.value.filter(b => b.status === 'CONFIRMED').length
    tabs.value[3].count = bookings.value.filter(b => b.status === 'CANCELLED').length
    tabs.value[4].count = bookings.value.filter(b => b.status === 'COMPLETED').length

    totalPages.value = response.data.totalPages || 1
  } catch (error) {
    console.error('Failed to load bookings:', error)
  } finally {
    loading.value = false
  }
}

const updateBookingStatus = async (bookingId: number, status: string) => {
  try {
    await api.patch(`/api/bookings/${bookingId}/status`, { status })
    await loadBookings()
  } catch (error) {
    console.error('Failed to update booking status:', error)
  }
}

const cancelBooking = async (bookingId: number) => {
  if (!confirm('Are you sure you want to cancel this booking?')) return
  await updateBookingStatus(bookingId, 'CANCELLED')
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadBookings()
  }
}

const formatDay = (day: string) => {
  if (!day) return ''
  return day.charAt(0) + day.slice(1).toLowerCase()
}

const formatTime = (time: string) => {
  if (!time) return ''
  const [hours, minutes] = time.split(':')
  const hour = parseInt(hours)
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour % 12 || 12
  return `${displayHour}:${minutes} ${ampm}`
}

const getStatusClass = (status: string) => {
  switch (status) {
    case 'PENDING': return 'bg-yellow-100 text-yellow-800'
    case 'CONFIRMED': return 'bg-green-100 text-green-800'
    case 'CANCELLED': return 'bg-red-100 text-red-800'
    case 'COMPLETED': return 'bg-gray-100 text-gray-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatStatus = (status: string) => {
  return status.charAt(0) + status.slice(1).toLowerCase()
}

onMounted(() => {
  loadBookings()
})
</script>

<style scoped>
</style>
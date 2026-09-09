<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Booking Details'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Loading -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Not Found -->
          <div v-else-if="!booking" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <CalendarIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Booking not found</h3>
            <p class="text-gray-500 mb-6">The booking you're looking for doesn't exist or has been removed.</p>
            <router-link to="/bookings" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Back to Bookings
            </router-link>
          </div>

          <!-- Booking Details -->
          <div v-else class="max-w-3xl mx-auto space-y-6">
            <!-- Status Banner -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                  <div class="flex-shrink-0 w-16 h-16 bg-primary-50 rounded-xl flex items-center justify-center">
                    <CalendarIcon class="h-8 w-8 text-primary-600" />
                  </div>
                  <div>
                    <h1 class="text-2xl font-bold text-gray-900">
                      {{ isMentor ? (booking.mentee?.fullName || 'Mentee') : (booking.mentor?.fullName || 'Mentor') }}
                    </h1>
                    <p class="text-gray-500 mt-1">{{ isMentor ? 'Mentee' : 'Mentor' }}</p>
                  </div>
                </div>
                <span
                  class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                  :class="getStatusClass(booking.status)"
                >
                  {{ formatStatus(booking.status) }}
                </span>
              </div>
            </div>

            <!-- Schedule Information -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Schedule Information</h2>
              </div>
              <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 class="text-sm font-medium text-gray-500 uppercase tracking-wider mb-2">Day</h3>
                  <p class="text-lg font-semibold text-gray-900">{{ formatDay(booking.schedule?.dayOfWeek) }}</p>
                </div>
                <div>
                  <h3 class="text-sm font-medium text-gray-500 uppercase tracking-wider mb-2">Time</h3>
                  <p class="text-lg font-semibold text-gray-900">
                    {{ formatTime(booking.schedule?.startTime) }} - {{ formatTime(booking.schedule?.endTime) }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Session Topic -->
            <div v-if="booking.topic" class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Topic</h2>
              </div>
              <div class="p-6">
                <span class="inline-flex items-center px-3 py-1 bg-primary-50 text-primary-700 rounded-full text-sm font-medium">
                  {{ booking.topic.name }}
                </span>
              </div>
            </div>

            <!-- Notes -->
            <div v-if="booking.notes" class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Notes</h2>
              </div>
              <div class="p-6">
                <p class="text-gray-600 whitespace-pre-line">{{ booking.notes }}</p>
              </div>
            </div>

            <!-- Actions -->
            <div v-if="canTakeAction" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 class="text-lg font-semibold text-gray-900 mb-4">Actions</h2>
              <div class="flex flex-wrap gap-3">
                <!-- Mentor Actions -->
                <template v-if="isMentor">
                  <button
                    v-if="booking.status === 'PENDING'"
                    @click="updateStatus('CONFIRMED')"
                    :disabled="updating"
                    class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium disabled:opacity-50"
                  >
                    Confirm Booking
                  </button>
                  <button
                    v-if="booking.status === 'PENDING'"
                    @click="updateStatus('CANCELLED')"
                    :disabled="updating"
                    class="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium disabled:opacity-50"
                  >
                    Reject Booking
                  </button>
                  <button
                    v-else-if="booking.status === 'CONFIRMED'"
                    @click="updateStatus('CANCELLED')"
                    :disabled="updating"
                    class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium disabled:opacity-50"
                  >
                    Cancel Booking
                  </button>
                </template>

                <!-- Mentee Actions -->
                <template v-else>
                  <button
                    v-if="booking.status === 'PENDING' || booking.status === 'CONFIRMED'"
                    @click="cancelBooking"
                    :disabled="updating"
                    class="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium disabled:opacity-50"
                  >
                    Cancel Booking
                  </button>
                </template>

                <!-- Feedback for completed bookings -->
                <router-link
                  v-if="booking.status === 'COMPLETED' && !isMentor"
                  :to="`/feedbacks/create/${booking.id}`"
                  class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium"
                >
                  Leave Feedback
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { CalendarIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const authStore = useAuthStore()

const bookingId = computed(() => route.params.id as string)
const booking = ref<any>(null)
const loading = ref(true)
const updating = ref(false)

const isMentor = computed(() => authStore.user?.role === 'MENTOR')

const canTakeAction = computed(() => {
  if (!booking.value) return false
  if (isMentor.value) {
    return booking.value.status === 'PENDING' || booking.value.status === 'CONFIRMED'
  } else {
    return booking.value.status === 'PENDING' || booking.value.status === 'CONFIRMED'
  }
})

const loadBooking = async () => {
  loading.value = true
  try {
    const response = await api.get(`/api/bookings/${bookingId.value}`)
    booking.value = response.data
  } catch (error) {
    console.error('Failed to load booking:', error)
  } finally {
    loading.value = false
  }
}

const updateStatus = async (status: string) => {
  updating.value = true
  try {
    await api.patch(`/api/bookings/${bookingId.value}/status`, { status })
    await loadBooking()
  } catch (error) {
    console.error('Failed to update booking status:', error)
  } finally {
    updating.value = false
  }
}

const cancelBooking = async () => {
  if (!confirm('Are you sure you want to cancel this booking?')) return
  await updateStatus('CANCELLED')
}

const formatDay = (day: string) => {
  if (!day) return 'Not specified'
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
  loadBooking()
})
</script>

<style scoped>
</style>
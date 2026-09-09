<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Schedule Details'" :showSearch="false">
          <template #actions>
            <router-link
              v-if="schedule && canEdit"
              :to="`/schedules/${schedule.id}/edit`"
              class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Edit
            </router-link>
            <button
              v-if="schedule && canEdit"
              @click="deleteSchedule"
              :disabled="deleting"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium disabled:opacity-50"
            >
              <span v-if="deleting">Deleting...</span>
              <span v-else>Delete</span>
            </button>
          </template>
        </Header>
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
          <div v-else-if="!schedule" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <CalendarIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Schedule not found</h3>
            <p class="text-gray-500 mb-6">The schedule you're looking for doesn't exist or has been removed.</p>
            <router-link to="/schedules" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Back to Schedules
            </router-link>
          </div>

          <!-- Schedule Details -->
          <div v-else class="max-w-3xl mx-auto space-y-6">
            <!-- Main Info Card -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-8">
                <div class="flex items-center space-x-4">
                  <div class="flex-shrink-0 w-16 h-16 bg-white/20 rounded-xl flex items-center justify-center">
                    <CalendarIcon class="h-8 w-8 text-white" />
                  </div>
                  <div>
                    <h1 class="text-2xl font-bold text-white">{{ formatDay(schedule.dayOfWeek) }}</h1>
                    <p class="text-primary-100 mt-1">{{ formatTime(schedule.startTime) }} - {{ formatTime(schedule.endTime) }}</p>
                  </div>
                  <div class="ml-auto">
                    <span
                      class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                      :class="getStatusClass(schedule.status)"
                    >
                      {{ formatStatus(schedule.status) }}
                    </span>
                  </div>
                </div>
              </div>

              <div class="p-6 space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h3 class="text-sm font-medium text-gray-500 uppercase tracking-wider mb-2">Max Bookings</h3>
                    <p class="text-2xl font-bold text-gray-900">{{ schedule.maxBookings }}</p>
                  </div>
                  <div>
                    <h3 class="text-sm font-medium text-gray-500 uppercase tracking-wider mb-2">Current Bookings</h3>
                    <p class="text-2xl font-bold text-gray-900">{{ schedule.bookingsCount || 0 }}</p>
                  </div>
                </div>

                <div class="border-t border-gray-200 pt-6">
                  <h3 class="text-sm font-medium text-gray-500 uppercase tracking-wider mb-3">Status Actions</h3>
                  <div class="flex flex-wrap gap-3">
                    <button
                      @click="updateStatus('AVAILABLE')"
                      :disabled="schedule.status === 'AVAILABLE' || updatingStatus"
                      class="px-4 py-2 rounded-lg font-medium transition-colors"
                      :class="schedule.status === 'AVAILABLE' ? 'bg-green-100 text-green-800' : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'"
                    >
                      <span v-if="updatingStatus && schedule.status !== 'AVAILABLE'" class="flex items-center space-x-1">
                        <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                        <span>Enabling...</span>
                      </span>
                      <span v-else>Make Available</span>
                    </button>
                    <button
                      @click="updateStatus('UNAVAILABLE')"
                      :disabled="schedule.status === 'UNAVAILABLE' || updatingStatus"
                      class="px-4 py-2 rounded-lg font-medium transition-colors"
                      :class="schedule.status === 'UNAVAILABLE' ? 'bg-gray-100 text-gray-800' : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'"
                    >
                      <span v-if="updatingStatus && schedule.status !== 'UNAVAILABLE'" class="flex items-center space-x-1">
                        <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                        <span>Disabling...</span>
                      </span>
                      <span v-else>Make Unavailable</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Bookings Section -->
            <div v-if="schedule.bookings && schedule.bookings.length > 0" class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Bookings ({{ schedule.bookings.length }})</h2>
              </div>
              <div class="divide-y divide-gray-100">
                <div
                  v-for="booking in schedule.bookings"
                  :key="booking.id"
                  class="px-6 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4"
                >
                  <div class="flex items-center space-x-4">
                    <img
                      :src="booking.mentee?.avatar || defaultAvatar(booking.mentee?.fullName || 'User')"
                      :alt="booking.mentee?.fullName || 'Mentee'"
                      class="h-10 w-10 rounded-full"
                    />
                    <div>
                      <p class="font-medium text-gray-900">{{ booking.mentee?.fullName || 'Unknown Mentee' }}</p>
                      <p class="text-sm text-gray-500">{{ booking.mentee?.email || '' }}</p>
                    </div>
                  </div>
                  <div class="flex items-center space-x-3">
                    <span
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getBookingStatusClass(booking.status)"
                    >
                      {{ formatBookingStatus(booking.status) }}
                    </span>
                    <router-link
                      :to="`/bookings/${booking.id}`"
                      class="text-sm text-primary-600 hover:text-primary-500 font-medium"
                    >
                      View
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <!-- No Bookings Message -->
            <div v-else class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
              <CalendarIcon class="h-12 w-12 text-gray-300 mx-auto mb-3" />
              <h3 class="text-lg font-medium text-gray-900 mb-1">No bookings yet</h3>
              <p class="text-gray-500">This schedule doesn't have any bookings.</p>
            </div>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { CalendarIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const scheduleId = computed(() => route.params.id as string)
const schedule = ref<any>(null)
const loading = ref(true)
const updatingStatus = ref(false)
const deleting = ref(false)

const canEdit = computed(() => {
  return authStore.user?.role === 'MENTOR' && schedule.value?.mentor?.id === authStore.user?.id
})

const loadSchedule = async () => {
  loading.value = true
  try {
    const response = await api.get(`/api/schedules/${scheduleId.value}`)
    schedule.value = response.data
  } catch (error) {
    console.error('Failed to load schedule:', error)
  } finally {
    loading.value = false
  }
}

const updateStatus = async (status: string) => {
  updatingStatus.value = true
  try {
    await api.patch(`/api/schedules/${scheduleId.value}/status`, { status })
    await loadSchedule()
  } catch (error) {
    console.error('Failed to update status:', error)
  } finally {
    updatingStatus.value = false
  }
}

const deleteSchedule = async () => {
  if (!confirm('Are you sure you want to delete this schedule? This action cannot be undone.')) {
    return
  }

  deleting.value = true
  try {
    await api.delete(`/api/schedules/${scheduleId.value}`)
    router.push('/schedules')
  } catch (error) {
    console.error('Failed to delete schedule:', error)
  } finally {
    deleting.value = false
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

const getBookingStatusClass = (status: string) => {
  switch (status) {
    case 'PENDING': return 'bg-yellow-100 text-yellow-800'
    case 'CONFIRMED': return 'bg-green-100 text-green-800'
    case 'CANCELLED': return 'bg-red-100 text-red-800'
    case 'COMPLETED': return 'bg-gray-100 text-gray-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatBookingStatus = (status: string) => {
  return status.charAt(0) + status.slice(1).toLowerCase()
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadSchedule()
})
</script>

<style scoped>
</style>
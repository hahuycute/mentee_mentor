<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Session Details'" :showSearch="false" />
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
          <div v-else-if="!session" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <ClockIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Session not found</h3>
            <p class="text-gray-500 mb-6">The session you're looking for doesn't exist or has been removed.</p>
            <router-link to="/sessions" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Back to Sessions
            </router-link>
          </div>

          <!-- Session Details -->
          <div v-else class="max-w-3xl mx-auto space-y-6">
            <!-- Main Info -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-8">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-4">
                    <div class="flex-shrink-0 w-16 h-16 bg-white/20 rounded-xl flex items-center justify-center">
                      <ClockIcon class="h-8 w-8 text-white" />
                    </div>
                    <div>
                      <h1 class="text-2xl font-bold text-white">{{ session.topic?.name || 'Mentoring Session' }}</h1>
                      <p class="text-primary-100 mt-1">{{ formatDateTime(session.scheduledAt) }}</p>
                    </div>
                  </div>
                  <span
                    class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                    :class="getStatusClass(session.status)"
                  >
                    {{ formatStatus(session.status) }}
                  </span>
                </div>
              </div>

              <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="flex items-center space-x-4">
                  <img
                    :src="session.mentor?.avatar || defaultAvatar(session.mentor?.fullName || 'Mentor')"
                    class="h-12 w-12 rounded-full"
                    alt="Mentor"
                  />
                  <div>
                    <p class="text-sm text-gray-500">Mentor</p>
                    <router-link
                      v-if="session.mentor?.id"
                      :to="`/profile/${session.mentor.id}`"
                      class="font-semibold text-gray-900 hover:text-primary-600"
                    >
                      {{ session.mentor?.fullName }}
                    </router-link>
                    <p v-else class="font-semibold text-gray-900">{{ session.mentor?.fullName || 'Unknown' }}</p>
                  </div>
                </div>
                <div class="flex items-center space-x-4">
                  <img
                    :src="session.mentee?.avatar || defaultAvatar(session.mentee?.fullName || 'Mentee')"
                    class="h-12 w-12 rounded-full"
                    alt="Mentee"
                  />
                  <div>
                    <p class="text-sm text-gray-500">Mentee</p>
                    <router-link
                      v-if="session.mentee?.id"
                      :to="`/profile/${session.mentee.id}`"
                      class="font-semibold text-gray-900 hover:text-primary-600"
                    >
                      {{ session.mentee?.fullName }}
                    </router-link>
                    <p v-else class="font-semibold text-gray-900">{{ session.mentee?.fullName || 'Unknown' }}</p>
                  </div>
                </div>
                <div>
                  <p class="text-sm text-gray-500">Duration</p>
                  <p class="font-semibold text-gray-900">{{ session.duration ? `${session.duration} minutes` : '-' }}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-500">Meeting Link</p>
                  <a
                    v-if="session.meetingLink"
                    :href="session.meetingLink"
                    target="_blank"
                    class="font-semibold text-primary-600 hover:text-primary-500"
                  >
                    Join Meeting
                  </a>
                  <p v-else class="font-semibold text-gray-900">-</p>
                </div>
              </div>
            </div>

            <!-- Notes -->
            <div v-if="session.notes" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 class="text-lg font-semibold text-gray-900 mb-3">Session Notes</h2>
              <p class="text-gray-600 whitespace-pre-line">{{ session.notes }}</p>
            </div>

            <!-- Actions -->
            <div v-if="canTakeAction" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 class="text-lg font-semibold text-gray-900 mb-4">Actions</h2>
              <div class="flex flex-wrap gap-3">
                <button
                  v-if="session.status === 'SCHEDULED' || session.status === 'CONFIRMED'"
                  @click="updateStatus('IN_PROGRESS')"
                  :disabled="updating"
                  class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium disabled:opacity-50"
                >
                  Start Session
                </button>
                <button
                  v-if="session.status === 'IN_PROGRESS'"
                  @click="updateStatus('COMPLETED')"
                  :disabled="updating"
                  class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium disabled:opacity-50"
                >
                  End Session
                </button>
                <button
                  v-if="session.status === 'SCHEDULED' || session.status === 'CONFIRMED'"
                  @click="cancelSession"
                  :disabled="updating"
                  class="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium disabled:opacity-50"
                >
                  Cancel Session
                </button>
              </div>
            </div>

            <!-- Feedback for completed sessions (mentees) -->
            <div
              v-if="session.status === 'COMPLETED' && authStore.user?.role === 'MENTEE'"
              class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center"
            >
              <h2 class="text-lg font-semibold text-gray-900 mb-2">How was your session?</h2>
              <p class="text-gray-500 mb-4">Leave feedback to help other mentees and support your mentor.</p>
              <router-link to="/feedbacks/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium inline-block">
                Leave Feedback
              </router-link>
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
import { ClockIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const authStore = useAuthStore()

const sessionId = computed(() => route.params.id as string)
const session = ref<any>(null)
const loading = ref(true)
const updating = ref(false)

const canTakeAction = computed(() => {
  if (!session.value) return false
  return ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'].includes(session.value.status)
})

const loadSession = async () => {
  loading.value = true
  try {
    const response = await api.get(`/api/sessions/${sessionId.value}`)
    session.value = response.data
  } catch (error) {
    console.error('Failed to load session:', error)
  } finally {
    loading.value = false
  }
}

const updateStatus = async (status: string) => {
  updating.value = true
  try {
    await api.patch(`/api/sessions/${sessionId.value}/status`, { status })
    await loadSession()
  } catch (error) {
    console.error('Failed to update session status:', error)
  } finally {
    updating.value = false
  }
}

const cancelSession = async () => {
  if (!confirm('Are you sure you want to cancel this session?')) return
  await updateStatus('CANCELLED')
}

const formatDateTime = (dateString: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const getStatusClass = (status: string) => {
  switch (status) {
    case 'SCHEDULED': return 'bg-blue-100 text-blue-800'
    case 'CONFIRMED': return 'bg-green-100 text-green-800'
    case 'IN_PROGRESS': return 'bg-yellow-100 text-yellow-800'
    case 'COMPLETED': return 'bg-gray-100 text-gray-800'
    case 'CANCELLED': return 'bg-red-100 text-red-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatStatus = (status: string) => {
  return status.replace(/_/g, ' ').charAt(0) + status.replace(/_/g, ' ').slice(1).toLowerCase()
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadSession()
})
</script>

<style scoped>
</style>
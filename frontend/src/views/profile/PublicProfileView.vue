<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="user?.fullName || 'Profile'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Loading -->
          <div v-if="loading" class="max-w-4xl mx-auto">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 animate-pulse">
              <div class="flex items-center space-x-4">
                <div class="h-24 w-24 bg-gray-200 rounded-full" />
                <div class="flex-1">
                  <div class="h-8 bg-gray-200 rounded w-1/4 mb-2" />
                  <div class="h-4 bg-gray-200 rounded w-1/3 mb-2" />
                  <div class="h-4 bg-gray-200 rounded w-1/2" />
                </div>
              </div>
            </div>
          </div>

          <!-- Not Found -->
          <div v-else-if="!user" class="text-center py-12 max-w-4xl mx-auto">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <UserCircleIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">User not found</h3>
            <p class="text-gray-500 mb-6">The profile you're looking for doesn't exist or has been removed.</p>
            <router-link to="/dashboard" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Back to Dashboard
            </router-link>
          </div>

          <!-- Profile Content -->
          <div v-else class="max-w-4xl mx-auto space-y-6">
            <!-- Profile Header -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-12">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                  <div class="flex items-center space-x-4">
                    <img
                      :src="user.avatar || defaultAvatar(user.fullName)"
                      :alt="user.fullName"
                      class="h-24 w-24 rounded-full border-4 border-white"
                    />
                    <div>
                      <h1 class="text-2xl font-bold text-white">{{ user.fullName }}</h1>
                      <p class="text-primary-100 mt-1">{{ user.email }}</p>
                      <div class="flex items-center space-x-3 mt-2">
                        <span
                          class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white/20 text-white"
                        >
                          {{ formatRole(user.role) }}
                        </span>
                        <span v-if="user.isEmailVerified" class="flex items-center text-sm text-primary-100">
                          <CheckCircleIcon class="h-4 w-4 mr-1 text-green-300" />
                          Email verified
                        </span>
                      </div>
                    </div>
                  </div>
                  <div class="flex space-x-3">
                    <router-link
                      v-if="authStore.user?.id === user.id"
                      to="/profile/edit"
                      class="px-4 py-2 bg-white/20 text-white rounded-lg hover:bg-white/30 transition-colors font-medium"
                    >
                      Edit Profile
                    </router-link>
                    <button
                      v-else-if="authStore.user && authStore.user.role === 'MENTEE' && user.role === 'MENTOR'"
                      @click="bookSession"
                      class="px-4 py-2 bg-white text-primary-600 rounded-lg hover:bg-gray-100 transition-colors font-medium"
                    >
                      Book Session
                    </button>
                  </div>
                </div>
              </div>

              <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div class="md:col-span-2 space-y-6">
                    <section>
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">About</h2>
                      <p class="text-gray-600 whitespace-pre-line">{{ user.bio || 'No bio provided.' }}</p>
                    </section>

                    <section v-if="user.skills && user.skills.length > 0">
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">Skills</h2>
                      <div class="flex flex-wrap gap-2">
                        <span
                          v-for="skill in user.skills"
                          :key="skill"
                          class="px-3 py-1 bg-primary-50 text-primary-700 rounded-full text-sm"
                        >
                          {{ skill }}
                        </span>
                      </div>
                    </section>

                    <section v-if="user.education">
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">Education</h2>
                      <p class="text-gray-600">{{ user.education }}</p>
                    </section>

                    <section v-if="user.experience">
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">Experience</h2>
                      <p class="text-gray-600 whitespace-pre-line">{{ user.experience }}</p>
                    </section>
                  </div>

                  <div class="space-y-6">
                    <div class="bg-gray-50 rounded-xl p-6">
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">Contact Info</h2>
                      <dl class="space-y-4">
                        <div>
                          <dt class="text-sm text-gray-500">Phone</dt>
                          <dd class="text-sm text-gray-900">{{ user.phone || 'Not provided' }}</dd>
                        </div>
                        <div>
                          <dt class="text-sm text-gray-500">Email</dt>
                          <dd class="text-sm text-gray-900">{{ user.email }}</dd>
                        </div>
                        <div v-if="user.linkedin">
                          <dt class="text-sm text-gray-500">LinkedIn</dt>
                          <dd class="text-sm text-gray-900">
                            <a :href="user.linkedin" target="_blank" class="text-primary-600 hover:text-primary-500">
                              View Profile
                            </a>
                          </dd>
                        </div>
                        <div v-if="user.github">
                          <dt class="text-sm text-gray-500">GitHub</dt>
                          <dd class="text-sm text-gray-900">
                            <a :href="user.github" target="_blank" class="text-primary-600 hover:text-primary-500">
                              View Profile
                            </a>
                          </dd>
                        </div>
                        <div v-if="user.website">
                          <dt class="text-sm text-gray-500">Website</dt>
                          <dd class="text-sm text-gray-900">
                            <a :href="user.website" target="_blank" class="text-primary-600 hover:text-primary-500">
                              Visit
                            </a>
                          </dd>
                        </div>
                      </dl>
                    </div>

                    <div class="bg-gray-50 rounded-xl p-6">
                      <h2 class="text-lg font-semibold text-gray-900 mb-4">Statistics</h2>
                      <dl class="space-y-4">
                        <div class="flex justify-between">
                          <dt class="text-sm text-gray-500">Sessions Completed</dt>
                          <dd class="text-sm font-medium text-gray-900">{{ stats.completedSessions }}</dd>
                        </div>
                        <div class="flex justify-between">
                          <dt class="text-sm text-gray-500">Average Rating</dt>
                          <dd class="text-sm font-medium text-gray-900">{{ stats.averageRating.toFixed(1) }}</dd>
                        </div>
                        <div class="flex justify-between">
                          <dt class="text-sm text-gray-500">Total Reviews</dt>
                          <dd class="text-sm font-medium text-gray-900">{{ stats.totalReviews }}</dd>
                        </div>
                        <div class="flex justify-between">
                          <dt class="text-sm text-gray-500">Member Since</dt>
                          <dd class="text-sm font-medium text-gray-900">{{ formatDate(user.createdAt) }}</dd>
                        </div>
                      </dl>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Mentor Profile Section -->
            <div v-if="mentorProfile" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 class="text-lg font-semibold text-gray-900 mb-4">Mentor Profile</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 class="font-medium text-gray-900 mb-2">Hourly Rate</h3>
                  <p class="text-2xl font-bold text-primary-600">${{ mentorProfile.hourlyRate }}/hr</p>
                </div>
                <div>
                  <h3 class="font-medium text-gray-900 mb-2">Availability</h3>
                  <p class="text-gray-600">{{ mentorProfile.availability }}</p>
                </div>
                <div class="md:col-span-2">
                  <h3 class="font-medium text-gray-900 mb-2">Expertise</h3>
                  <div class="flex flex-wrap gap-2">
                    <span
                      v-for="topic in mentorProfile.topics"
                      :key="topic.id"
                      class="px-3 py-1 bg-blue-50 text-blue-700 rounded-full text-sm"
                    >
                      {{ topic.name }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Mentee Profile Section -->
            <div v-if="menteeProfile" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 class="text-lg font-semibold text-gray-900 mb-4">Learning Goals</h2>
              <p class="text-gray-600 whitespace-pre-line">{{ menteeProfile.learningGoals || 'No learning goals set yet.' }}</p>
              <div class="mt-4">
                <h3 class="font-medium text-gray-900 mb-2">Preferred Topics</h3>
                <div class="flex flex-wrap gap-2">
                  <span
                    v-for="topic in menteeProfile.topics"
                    :key="topic.id"
                    class="px-3 py-1 bg-green-50 text-green-700 rounded-full text-sm"
                  >
                    {{ topic.name }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Recent Activity -->
            <div v-if="recentActivity.length > 0" class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Recent Activity</h2>
              </div>
              <div class="divide-y divide-gray-100">
                <div
                  v-for="activity in recentActivity"
                  :key="activity.id"
                  class="px-6 py-4 flex items-center space-x-4"
                >
                  <div class="flex-shrink-0 w-10 h-10 bg-primary-50 rounded-lg flex items-center justify-center">
                    <component :is="getActivityIcon(activity.type)" class="h-5 w-5 text-primary-600" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900">{{ activity.description }}</p>
                    <p class="text-xs text-gray-500">{{ formatDateTime(activity.createdAt) }}</p>
                  </div>
                </div>
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
import { useRouter, useRoute } from 'vue-router'
import { UserCircleIcon, CalendarIcon, ChatBubbleLeftRightIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const userId = computed(() => route.params.userId as string)
const user = ref<any>(null)
const mentorProfile = ref<any>(null)
const menteeProfile = ref<any>(null)
const stats = ref({
  completedSessions: 0,
  averageRating: 0,
  totalReviews: 0,
})
const recentActivity = ref<any[]>([])
const loading = ref(true)

const loadProfile = async () => {
  loading.value = true
  try {
    const [userRes, statsRes, activityRes] = await Promise.all([
      api.get(`/api/users/${userId.value}`),
      api.get(`/api/profiles/${userId.value}/stats`),
      api.get(`/api/users/${userId.value}/activity`, { params: { size: 10 } }),
    ])

    user.value = userRes.data

    if (user.value.role === 'MENTOR') {
      const mentorRes = await api.get(`/api/profiles/mentor/${userId.value}`)
      mentorProfile.value = mentorRes.data
    } else if (user.value.role === 'MENTEE') {
      const menteeRes = await api.get(`/api/profiles/mentee/${userId.value}`)
      menteeProfile.value = menteeRes.data
    }

    stats.value = statsRes.data
    recentActivity.value = activityRes.data.content || activityRes.data
  } catch (error) {
    console.error('Failed to load profile:', error)
  } finally {
    loading.value = false
  }
}

const bookSession = () => {
  router.push('/schedules')
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long' })
}

const formatDateTime = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

const formatRole = (role: string) => {
  return role.charAt(0) + role.slice(1).toLowerCase()
}

const getActivityIcon = (type: string) => {
  const icons: Record<string, any> = {
    'BOOKING_CREATED': CalendarIcon,
    'SESSION_COMPLETED': CheckCircleIcon,
    'FEEDBACK_RECEIVED': ChatBubbleLeftRightIcon,
    'POST_CREATED': ChatBubbleLeftRightIcon,
    'SESSION_BOOKED': CalendarIcon,
  }
  return icons[type] || CalendarIcon
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=128`
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
</style>
<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'My Profile'" />
      </template>

      <template #content>
        <div class="p-6 space-y-6">
          <!-- Profile Header -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-12">
              <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div class="flex items-center space-x-4">
                  <img
                    :src="user.avatar || defaultAvatar"
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
                        {{ user.role }}
                      </span>
                      <span v-if="user.isEmailVerified" class="flex items-center text-sm text-primary-100">
                        <svg class="h-4 w-4 mr-1 text-green-300" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                        </svg>
                        Email verified
                      </span>
                    </div>
                  </div>
                </div>
                <div class="flex space-x-3">
                  <router-link
                    to="/profile/edit"
                    class="px-4 py-2 bg-white/20 text-white rounded-lg hover:bg-white/30 transition-colors font-medium"
                  >
                    Edit Profile
                  </router-link>
                  <button
                    @click="changeAvatar"
                    class="px-4 py-2 bg-white/20 text-white rounded-lg hover:bg-white/30 transition-colors font-medium"
                  >
                    Change Avatar
                  </button>
                </div>
              </div>
            </div>

            <div class="p-6">
              <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="md:col-span-2 space-y-6">
                  <section>
                    <h2 class="text-lg font-semibold text-gray-900 mb-4">About</h2>
                    <p class="text-gray-600 whitespace-pre-line">{{ user.bio || 'No bio yet. Edit your profile to add one.' }}</p>
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
                        <dd class="text-sm text-gray-900">{{ user.phone }}</dd>
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

          <!-- Mentor/Mentee specific sections -->
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
                <h3 class="font-medium text-gray-900 mb-2">Topics</h3>
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
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'

const authStore = useAuthStore()

const user = ref<any>(null)
const mentorProfile = ref<any>(null)
const menteeProfile = ref<any>(null)
const stats = ref({
  completedSessions: 0,
  averageRating: 0,
  totalReviews: 0,
})

const defaultAvatar = computed(() => `https://ui-avatars.com/api/?name=${encodeURIComponent(authStore.user?.fullName || 'User')}&background=0ea5e9&color=fff&size=128`)

const loadProfile = async () => {
  try {
    const [userRes, statsRes] = await Promise.all([
      api.get('/api/auth/me'),
      api.get('/api/profiles/me/stats'),
    ])
    user.value = userRes.data.user

    if (userRes.data.user.role === 'MENTOR') {
      const mentorRes = await api.get('/api/profiles/mentor/me')
      mentorProfile.value = mentorRes.data
    } else if (userRes.data.user.role === 'MENTEE') {
      const menteeRes = await api.get('/api/profiles/mentee/me')
      menteeProfile.value = menteeRes.data
    }

    stats.value = statsRes.data
  } catch (error) {
    console.error('Failed to load profile:', error)
  }
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long' })
}

const changeAvatar = () => {
  // TODO: Implement avatar upload
  alert('Avatar upload coming soon!')
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
</style>
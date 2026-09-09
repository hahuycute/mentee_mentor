<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Feedbacks'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Summary Card -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-6">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div class="flex items-center space-x-6">
                <div class="text-center">
                  <p class="text-4xl font-bold text-gray-900">{{ summary.averageRating.toFixed(1) }}</p>
                  <div class="flex justify-center mt-1">
                    <StarIcon
                      v-for="i in 5"
                      :key="i"
                      class="h-5 w-5"
                      :class="i <= Math.round(summary.averageRating) ? 'text-yellow-400' : 'text-gray-300'"
                      fill="currentColor"
                    />
                  </div>
                </div>
                <div class="border-l border-gray-200 pl-6">
                  <p class="text-2xl font-bold text-gray-900">{{ summary.totalFeedbacks }}</p>
                  <p class="text-sm text-gray-500">Total feedbacks</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Empty State -->
          <div v-else-if="feedbacks.length === 0" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <ChatBubbleLeftRightIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No feedbacks yet</h3>
            <p class="text-gray-500 mb-6">Feedbacks from completed sessions will appear here.</p>
          </div>

          <!-- Feedback List -->
          <div v-else class="space-y-4">
            <div
              v-for="feedback in feedbacks"
              :key="feedback.id"
              class="bg-white rounded-xl shadow-sm border border-gray-100 p-6"
            >
              <div class="flex items-start space-x-4">
                <img
                  :src="feedback.reviewer?.avatar || defaultAvatar(feedback.reviewer?.fullName || 'User')"
                  :alt="feedback.reviewer?.fullName"
                  class="h-12 w-12 rounded-full"
                />
                <div class="flex-1 min-w-0">
                  <div class="flex items-center justify-between flex-wrap gap-2">
                    <div>
                      <p class="font-medium text-gray-900">{{ feedback.reviewer?.fullName || 'Anonymous' }}</p>
                      <div class="flex items-center mt-1">
                        <StarIcon
                          v-for="i in 5"
                          :key="i"
                          class="h-4 w-4"
                          :class="i <= feedback.rating ? 'text-yellow-400' : 'text-gray-300'"
                          fill="currentColor"
                        />
                        <span class="ml-2 text-sm text-gray-500">{{ formatDateTime(feedback.createdAt) }}</span>
                      </div>
                    </div>
                  </div>
                  <p class="mt-3 text-gray-600">{{ feedback.comment }}</p>

                  <!-- Mentor reply -->
                  <div v-if="feedback.reply" class="mt-3 ml-4 pl-4 border-l-2 border-primary-200">
                    <p class="text-xs font-medium text-primary-600">Reply from mentor</p>
                    <p class="text-sm text-gray-600 mt-1">{{ feedback.reply }}</p>
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
import { ref, onMounted } from 'vue'
import { StarIcon, ChatBubbleLeftRightIcon } from '@heroicons/vue/24/solid'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

interface Feedback {
  id: number
  rating: number
  comment: string
  reply?: string | null
  createdAt: string
  reviewer?: { fullName: string; avatar?: string }
}

const feedbacks = ref<Feedback[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const totalPages = ref(1)

const summary = ref({
  averageRating: 0,
  totalFeedbacks: 0,
})

const loadFeedbacks = async () => {
  loading.value = true
  try {
    const [listRes, statsRes] = await Promise.all([
      api.get('/api/feedbacks/my', { params: { page: currentPage.value - 1, size: pageSize.value } }),
      api.get('/api/feedbacks/my/stats').catch(() => ({ data: null })),
    ])
    feedbacks.value = listRes.data.content || listRes.data
    totalPages.value = listRes.data.totalPages || 1

    if (statsRes.data) {
      summary.value = {
        averageRating: statsRes.data.averageRating ?? 0,
        totalFeedbacks: statsRes.data.total ?? feedbacks.value.length,
      }
    }
  } catch (error) {
    console.error('Failed to load feedbacks:', error)
  } finally {
    loading.value = false
  }
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadFeedbacks()
  }
}

const formatDateTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadFeedbacks()
})
</script>

<style scoped>
</style>
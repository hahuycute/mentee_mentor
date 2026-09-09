<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Find a Mentor'" :showSearch="true" :searchPlaceholder="'Search mentors by name, skill...'" :searchQuery="searchQuery" @search="handleSearch" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Filters -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
            <div class="flex flex-wrap items-center gap-4">
              <div class="flex-1 min-w-[200px]">
                <label for="topicFilter" class="block text-sm font-medium text-gray-700 mb-1">Topic</label>
                <select
                  id="topicFilter"
                  v-model="topicFilter"
                  @change="applyFilters"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">All Topics</option>
                  <option v-for="topic in topics" :key="topic.id" :value="topic.id">{{ topic.name }}</option>
                </select>
              </div>
              <div class="flex-1 min-w-[150px]">
                <label for="sortBy" class="block text-sm font-medium text-gray-700 mb-1">Sort by</label>
                <select
                  id="sortBy"
                  v-model="sortBy"
                  @change="applyFilters"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="rating">Highest Rated</option>
                  <option value="reviews">Most Reviews</option>
                  <option value="rate_asc">Lowest Rate</option>
                  <option value="rate_desc">Highest Rate</option>
                  <option value="newest">Newest</option>
                </select>
              </div>
              <button
                @click="clearFilters"
                class="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm font-medium"
              >
                Clear Filters
              </button>
            </div>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div v-for="i in 6" :key="i" class="bg-white rounded-xl border border-gray-100 p-6 animate-pulse">
              <div class="h-24 w-24 bg-gray-200 rounded-full mx-auto mb-4" />
              <div class="h-6 bg-gray-200 rounded w-3/4 mx-auto mb-2" />
              <div class="h-4 bg-gray-200 rounded w-1/2 mx-auto mb-4" />
              <div class="h-4 bg-gray-200 rounded w-full mb-2" />
              <div class="h-4 bg-gray-200 rounded w-2/3" />
            </div>
          </div>

          <!-- Empty State -->
          <div v-else-if="mentors.length === 0" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <UserCircleIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No mentors found</h3>
            <p class="text-gray-500 mb-6">Try adjusting your search or filters.</p>
            <button @click="clearFilters" class="text-primary-600 hover:text-primary-500 font-medium">Clear all filters</button>
          </div>

          <!-- Mentor Grid -->
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              v-for="mentor in mentors"
              :key="mentor.id"
              class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
            >
              <div class="p-6">
                <div class="flex items-start space-x-4">
                  <img
                    :src="mentor.avatar || defaultAvatar(mentor.fullName)"
                    :alt="mentor.fullName"
                    class="h-16 w-16 rounded-full"
                  />
                  <div class="flex-1 min-w-0">
                    <router-link :to="`/profile/${mentor.id}`" class="font-semibold text-gray-900 hover:text-primary-600">
                      {{ mentor.fullName }}
                    </router-link>
                    <p class="text-sm text-gray-500 mt-1">{{ mentor.title || 'Mentor' }}</p>

                    <div class="flex items-center space-x-2 mt-2">
                      <StarIcon class="h-4 w-4 text-yellow-400" fill="currentColor" />
                      <span class="text-sm font-medium text-gray-900">{{ mentor.averageRating?.toFixed(1) || 'N/A' }}</span>
                      <span class="text-sm text-gray-400">({{ mentor.totalReviews || 0 }})</span>
                    </div>

                    <div class="flex flex-wrap gap-2 mt-3">
                      <span
                        v-for="topic in mentor.topics?.slice(0, 3)"
                        :key="topic.id"
                        class="px-2 py-0.5 bg-primary-50 text-primary-700 rounded-full text-xs"
                      >
                        {{ topic.name }}
                      </span>
                      <span v-if="mentor.topics && mentor.topics.length > 3" class="px-2 py-0.5 bg-gray-50 text-gray-600 rounded-full text-xs">
                        +{{ mentor.topics.length - 3 }} more
                      </span>
                    </div>

                    <div class="mt-4 flex items-center space-x-4 text-sm text-gray-500">
                      <span class="flex items-center space-x-1">
                        <CurrencyDollarIcon class="h-4 w-4" />
                        <span>{{ mentor.hourlyRate }}/hr</span>
                      </span>
                      <span class="flex items-center space-x-1">
                        <CheckCircleIcon class="h-4 w-4 text-green-500" fill="currentColor" />
                        <span>{{ mentor.completedSessions || 0 }} sessions</span>
                      </span>
                    </div>
                  </div>
                </div>

                <router-link
                  :to="`/profile/${mentor.id}`"
                  class="block mt-4 text-center py-2 bg-primary-50 text-primary-600 rounded-lg hover:bg-primary-100 transition-colors font-medium"
                >
                  View Profile
                </router-link>
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
import { StarIcon, UserCircleIcon, CurrencyDollarIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

interface Mentor {
  id: number
  fullName: string
  avatar?: string
  title?: string
  averageRating?: number
  totalReviews: number
  hourlyRate: number
  completedSessions: number
  topics?: Array<{ id: number; name: string }>
}

interface Topic {
  id: number
  name: string
}

const mentors = ref<Mentor[]>([])
const topics = ref<Topic[]>([])
const loading = ref(false)
const searchQuery = ref('')
const topicFilter = ref('')
const sortBy = ref('rating')
const currentPage = ref(1)
const pageSize = ref(12)
const totalPages = ref(1)
const debounceTimer = ref<number | null>(null)

const loadMentors = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      page: currentPage.value - 1,
      size: pageSize.value,
      sort: sortBy.value,
    }
    if (searchQuery.value) params.search = searchQuery.value
    if (topicFilter.value) params.topicId = topicFilter.value

    const response = await api.get('/api/mentors', { params })
    mentors.value = response.data.content || response.data
    totalPages.value = response.data.totalPages || 1
  } catch (error) {
    console.error('Failed to load mentors:', error)
  } finally {
    loading.value = false
  }
}

const loadTopics = async () => {
  try {
    const response = await api.get('/api/topics')
    topics.value = response.data.content || response.data
  } catch (error) {
    console.error('Failed to load topics:', error)
  }
}

const handleSearch = (query: string) => {
  searchQuery.value = query
  if (debounceTimer.value) clearTimeout(debounceTimer.value)
  debounceTimer.value = window.setTimeout(() => {
    currentPage.value = 1
    loadMentors()
  }, 300)
}

const applyFilters = () => {
  currentPage.value = 1
  loadMentors()
}

const clearFilters = () => {
  searchQuery.value = ''
  topicFilter.value = ''
  sortBy.value = 'rating'
  currentPage.value = 1
  loadMentors()
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadMentors()
  }
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=128`
}

onMounted(() => {
  loadMentors()
  loadTopics()
})
</script>

<style scoped>
</style>
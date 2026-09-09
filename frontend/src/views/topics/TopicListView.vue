<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Topics'" :showSearch="false">
          <template #actions>
            <router-link v-if="canManage" to="/topics/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium flex items-center space-x-2">
              <PlusIcon class="h-5 w-5" />
              <span>Create Topic</span>
            </router-link>
          </template>
        </Header>
      </template>

      <template #content>
        <div class="p-6">
          <!-- Loading State -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Topic Grid -->
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            <div
              v-for="topic in topics"
              :key="topic.id"
              class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition-shadow"
            >
              <div class="flex items-start space-x-4">
                <div
                  class="flex-shrink-0 w-12 h-12 rounded-xl flex items-center justify-center"
                  :style="{ backgroundColor: topic.color + '20', color: topic.color }"
                >
                  <component :is="getIcon(topic.icon)" class="h-6 w-6" />
                </div>
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-gray-900 truncate">{{ topic.name }}</h3>
                  <p class="text-sm text-gray-500 mt-1 truncate">{{ topic.description }}</p>
                  <div class="flex items-center space-x-4 mt-3">
                    <span class="text-xs text-gray-400">{{ topic.mentorsCount || 0 }} mentors</span>
                    <span class="text-xs text-gray-400">{{ topic.sessionsCount || 0 }} sessions</span>
                  </div>
                </div>
                <div v-if="canManage" class="flex items-center space-x-1">
                  <router-link :to="`/topics/${topic.id}/edit`" class="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100" title="Edit">
                    <PencilIcon class="h-5 w-5" />
                  </router-link>
                  <button @click="deleteTopic(topic.id)" class="p-2 text-gray-500 hover:text-red-600 rounded-lg hover:bg-gray-100" title="Delete">
                    <TrashIcon class="h-5 w-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="topics.length === 0 && !loading" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <BookOpenIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No topics found</h3>
            <p class="text-gray-500 mb-6">Create your first topic to get started.</p>
            <router-link v-if="canManage" to="/topics/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Create Topic
            </router-link>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { PlusIcon, PencilIcon, TrashIcon, BookOpenIcon } from '@heroicons/vue/24/outline'
import { AcademicCapIcon, CodeBracketIcon, BriefcaseIcon, ChartBarIcon, GlobeAltIcon, PaintBrushIcon, CameraIcon, MusicalNoteIcon, CpuChipIcon, BeakerIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

interface Topic {
  id: number
  name: string
  description: string
  icon: string
  color: string
  mentorsCount?: number
  sessionsCount?: number
}

const topics = ref<Topic[]>([])
const loading = ref(true)

const canManage = computed(() => authStore.user?.role === 'ADMIN')

const loadTopics = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/topics')
    topics.value = response.data.content || response.data
  } catch (error) {
    console.error('Failed to load topics:', error)
  } finally {
    loading.value = false
  }
}

const deleteTopic = async (topicId: number) => {
  if (!confirm('Are you sure you want to delete this topic?')) return
  try {
    await api.delete(`/api/topics/${topicId}`)
    topics.value = topics.value.filter(t => t.id !== topicId)
  } catch (error) {
    console.error('Failed to delete topic:', error)
  }
}

const getIcon = (iconName: string) => {
  const icons: Record<string, any> = {
    'academic-cap': AcademicCapIcon,
    'code-bracket': CodeBracketIcon,
    'briefcase': BriefcaseIcon,
    'chart-bar': ChartBarIcon,
    'globe-alt': GlobeAltIcon,
    'paint-brush': PaintBrushIcon,
    'camera': CameraIcon,
    'musical-note': MusicalNoteIcon,
    'cpu-chip': CpuChipIcon,
    'beaker': BeakerIcon,
  }
  return icons[iconName] || BookOpenIcon
}

onMounted(() => {
  loadTopics()
})
</script>

<style scoped>
</style>
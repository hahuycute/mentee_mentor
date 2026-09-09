<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Community Posts'" :showSearch="false">
          <template #actions>
            <router-link to="/posts/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium flex items-center space-x-2">
              <PlusIcon class="h-5 w-5" />
              <span>Create Post</span>
            </router-link>
          </template>
        </Header>
      </template>

      <template #content>
        <div class="p-6 max-w-3xl mx-auto">
          <!-- Create Post Quick Form (optional, shown at top) -->
          <div v-if="showCreateForm" class="mb-6">
            <CreatePostForm @posted="handlePostCreated" @cancel="showCreateForm = false" />
          </div>

          <button
            v-else
            @click="showCreateForm = true"
            class="w-full mb-6 p-4 bg-white rounded-xl border border-gray-200 text-left hover:border-primary-300 hover:shadow-md transition-all"
          >
            <div class="flex items-center space-x-3">
              <img
                :src="authStore.user?.avatar || defaultAvatar(authStore.user?.fullName || 'User')"
                class="h-10 w-10 rounded-full"
              />
              <div class="flex-1">
                <p class="text-gray-400">What's on your mind?</p>
                <div class="h-0.5 bg-gray-200 mt-1 rounded-full w-1/4" />
              </div>
            </div>
          </button>

          <!-- Loading State -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Post Feed -->
          <div v-else class="space-y-4">
            <div
              v-for="post in posts"
              :key="post.id"
              class="bg-white rounded-xl shadow-sm border border-gray-100"
            >
              <div class="p-4">
                <!-- Post Header -->
                <div class="flex items-center space-x-3 mb-3">
                  <img
                    :src="post.author?.avatar || defaultAvatar(post.author?.fullName || 'User')"
                    :alt="post.author?.fullName"
                    class="h-10 w-10 rounded-full"
                  />
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center space-x-2">
                      <router-link
                        v-if="post.author?.id"
                        :to="`/profile/${post.author.id}`"
                        class="font-medium text-gray-900 hover:text-primary-600"
                      >
                        {{ post.author?.fullName }}
                      </router-link>
                      <span v-else class="font-medium text-gray-900">{{ post.author?.fullName }}</span>
                      <span class="text-gray-400">{{ formatRole(post.author?.role) }}</span>
                    </div>
                    <p class="text-sm text-gray-500">{{ formatDateTime(post.createdAt) }}</p>
                  </div>
                  <div v-if="canManagePost(post)" class="flex items-center space-x-1">
                    <router-link
                      :to="`/posts/${post.id}/edit`"
                      class="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100"
                      title="Edit"
                    >
                      <PencilIcon class="h-5 w-5" />
                    </router-link>
                    <button
                      @click="deletePost(post.id)"
                      class="p-2 text-gray-500 hover:text-red-600 rounded-lg hover:bg-gray-100"
                      title="Delete"
                    >
                      <TrashIcon class="h-5 w-5" />
                    </button>
                  </div>
                </div>

                <!-- Post Content -->
                <p class="text-gray-700 whitespace-pre-line mb-4">{{ post.content }}</p>

                <!-- Post Images -->
                <div v-if="post.images && post.images.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2 mb-4">
                  <img
                    v-for="image in post.images"
                    :key="image.id"
                    :src="image.url"
                    :alt="`Post image ${image.id}`"
                    class="w-full h-48 object-cover rounded-lg cursor-pointer"
                  />
                </div>

                <!-- Post Actions -->
                <div class="flex items-center space-x-6 border-t border-gray-100 pt-3">
                  <button
                    @click="toggleLike(post)"
                    :class="post.liked ? 'text-red-500' : 'text-gray-500'"
                    class="flex items-center space-x-1 font-medium transition-colors"
                  >
                    <HeartIcon
                      :class="post.liked ? 'fill-current' : ''"
                      class="h-5 w-5"
                    />
                    <span>{{ post.likesCount || 0 }}</span>
                  </button>

                  <router-link
                    :to="`/posts/${post.id}`"
                    class="flex items-center space-x-1 text-gray-500 font-medium"
                  >
                    <ChatBubbleLeftRightIcon class="h-5 w-5" />
                    <span>{{ post.commentsCount || 0 }}</span>
                  </router-link>

                  <span class="ml-auto text-sm text-gray-400">{{ post.sharesCount || 0 }} shares</span>
                </div>
              </div>

              <!-- Comments Preview -->
              <div v-if="post.comments && post.comments.length > 0" class="border-t border-gray-100 px-4 pb-4">
                <div v-for="comment in post.comments.slice(0, 2)" :key="comment.id" class="py-2 flex items-start space-x-3">
                  <img
                    :src="comment.author?.avatar || defaultAvatar(comment.author?.fullName || 'User')"
                    class="h-8 w-8 rounded-full"
                  />
                  <div class="flex-1 min-w-0">
                    <p class="font-medium text-gray-900 text-sm">{{ comment.author?.fullName }}</p>
                    <p class="text-gray-600 text-sm">{{ comment.content }}</p>
                    <p class="text-xs text-gray-400 mt-1">{{ formatDateTime(comment.createdAt) }}</p>
                  </div>
                </div>
                <router-link
                  v-if="post.comments.length > 2"
                  :to="`/posts/${post.id}`"
                  class="block text-center text-sm text-primary-600 hover:text-primary-500 py-2"
                >
                  View all {{ post.comments.length }} comments
                </router-link>
              </div>
            </div>
          </div>

          <!-- Load More / Pagination -->
          <div v-if="hasMore && !loading" class="text-center mt-8">
            <button
              @click="loadMore"
              class="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium"
            >
              Load more posts
            </button>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { PlusIcon, HeartIcon, ChatBubbleLeftRightIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

interface Post {
  id: number
  content: string
  author?: { id: number; fullName: string; avatar?: string; role?: string }
  images?: Array<{ id: number; url: string }>
  likesCount: number
  commentsCount: number
  sharesCount: number
  liked: boolean
  createdAt: string
  comments?: Array<{ id: number; content: string; author?: { fullName: string; avatar?: string }; createdAt: string }>
}

const posts = ref<Post[]>([])
const loading = ref(false)
const hasMore = ref(true)
const showCreateForm = ref(false)
const page = ref(0)
const pageSize = ref(10)

const loadPosts = async (append = false) => {
  loading.value = true
  try {
    const response = await api.get('/api/posts', {
      params: { page: page.value, size: pageSize.value }
    })
    const newPosts = response.data.content || response.data
    if (append) {
      posts.value.push(...newPosts)
    } else {
      posts.value = newPosts
    }
    hasMore.value = newPosts.length === pageSize.value
    if (hasMore.value) page.value++
  } catch (error) {
    console.error('Failed to load posts:', error)
  } finally {
    loading.value = false
  }
}

const loadMore = async () => {
  await loadPosts(true)
}

const toggleLike = async (post: Post) => {
  const originalLiked = post.liked
  const originalCount = post.likesCount
  post.liked = !post.liked
  post.likesCount += post.liked ? 1 : -1

  try {
    if (post.liked) {
      await api.post(`/api/posts/${post.id}/like`)
    } else {
      await api.delete(`/api/posts/${post.id}/like`)
    }
  } catch (error) {
    post.liked = originalLiked
    post.likesCount = originalCount
    console.error('Failed to toggle like:', error)
  }
}

const deletePost = async (postId: number) => {
  if (!confirm('Are you sure you want to delete this post?')) return
  try {
    await api.delete(`/api/posts/${postId}`)
    posts.value = posts.value.filter(p => p.id !== postId)
  } catch (error) {
    console.error('Failed to delete post:', error)
  }
}

const handlePostCreated = async () => {
  showCreateForm.value = false
  page.value = 0
  await loadPosts()
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

const formatRole = (role?: string) => {
  if (!role) return ''
  return role.charAt(0) + role.slice(1).toLowerCase()
}

const canManagePost = (post: Post) => {
  return authStore.user?.id === post.author?.id || authStore.user?.role === 'ADMIN'
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

// Load initial posts
loadPosts()
</script>

<style scoped>
</style>
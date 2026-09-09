<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Post'" :showSearch="false">
          <template #actions>
            <div v-if="canManagePost" class="flex items-center space-x-2">
              <router-link
                :to="`/posts/${post.id}/edit`"
                class="px-3 py-1.5 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium text-sm"
              >
                Edit
              </router-link>
              <button
                @click="deletePost"
                :disabled="deleting"
                class="px-3 py-1.5 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium text-sm disabled:opacity-50"
              >
                <span v-if="deleting">Deleting...</span>
                <span v-else>Delete</span>
              </button>
            </div>
          </template>
        </Header>
      </template>

      <template #content>
        <div class="p-6 max-w-3xl mx-auto">
          <!-- Loading -->
          <div v-if="loading" class="flex justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
          </div>

          <!-- Not Found -->
          <div v-else-if="!post" class="text-center py-12">
            <div class="mx-auto h-16 w-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <ChatBubbleLeftRightIcon class="h-8 w-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Post not found</h3>
            <p class="text-gray-500 mb-6">The post you're looking for doesn't exist or has been removed.</p>
            <router-link to="/posts" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium">
              Back to Posts
            </router-link>
          </div>

          <!-- Post Detail -->
          <div v-else class="space-y-6">
            <!-- Post Card -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="p-6">
                <!-- Post Header -->
                <div class="flex items-center space-x-3 mb-4">
                  <img
                    :src="post.author?.avatar || defaultAvatar(post.author?.fullName || 'User')"
                    :alt="post.author?.fullName"
                    class="h-12 w-12 rounded-full"
                  />
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center space-x-2 flex-wrap">
                      <router-link
                        v-if="post.author?.id"
                        :to="`/profile/${post.author.id}`"
                        class="font-semibold text-gray-900 hover:text-primary-600"
                      >
                        {{ post.author?.fullName }}
                      </router-link>
                      <span v-else class="font-semibold text-gray-900">{{ post.author?.fullName }}</span>
                      <span class="px-2 py-0.5 bg-primary-50 text-primary-700 rounded-full text-xs font-medium">
                        {{ formatRole(post.author?.role) }}
                      </span>
                    </div>
                    <p class="text-sm text-gray-500">{{ formatDateTime(post.createdAt) }}</p>
                  </div>
                </div>

                <!-- Post Content -->
                <p class="text-gray-700 whitespace-pre-line text-lg mb-6">{{ post.content }}</p>

                <!-- Post Images -->
                <div v-if="post.images && post.images.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mb-6">
                  <img
                    v-for="image in post.images"
                    :key="image.id"
                    :src="image.url"
                    :alt="`Post image ${image.id}`"
                    class="w-full h-64 object-cover rounded-lg cursor-pointer"
                  />
                </div>

                <!-- Post Actions -->
                <div class="flex items-center space-x-6 border-t border-gray-100 pt-4">
                  <button
                    @click="toggleLike"
                    :class="post.liked ? 'text-red-500' : 'text-gray-500'"
                    class="flex items-center space-x-2 font-medium transition-colors hover:text-red-500"
                  >
                    <HeartIcon
                      :class="post.liked ? 'fill-current' : ''"
                      class="h-6 w-6"
                    />
                    <span>{{ post.likesCount || 0 }} likes</span>
                  </button>

                  <div class="flex items-center space-x-2 text-gray-500 font-medium">
                    <ChatBubbleLeftRightIcon class="h-6 w-6" />
                    <span>{{ post.commentsCount || 0 }} comments</span>
                  </div>

                  <span class="ml-auto text-sm text-gray-400">{{ post.sharesCount || 0 }} shares</span>
                </div>
              </div>
            </div>

            <!-- Comments Section -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold text-gray-900">Comments</h2>
              </div>

              <!-- Add Comment Form -->
              <div class="p-6 border-b border-gray-100">
                <form @submit.prevent="submitComment" class="flex items-start space-x-3">
                  <img
                    :src="authStore.user?.avatar || defaultAvatar(authStore.user?.fullName || 'User')"
                    class="h-10 w-10 rounded-full"
                  />
                  <div class="flex-1">
                    <textarea
                      v-model="newComment"
                      rows="2"
                      placeholder="Write a comment..."
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
                    ></textarea>
                    <div class="flex justify-end mt-2">
                      <button
                        type="submit"
                        :disabled="!newComment.trim() || submittingComment"
                        class="px-4 py-1.5 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Comment
                      </button>
                    </div>
                  </div>
                </form>
              </div>

              <!-- Comments List -->
              <div class="divide-y divide-gray-100">
                <div
                  v-for="comment in comments"
                  :key="comment.id"
                  class="p-6 flex items-start space-x-3"
                >
                  <img
                    :src="comment.author?.avatar || defaultAvatar(comment.author?.fullName || 'User')"
                    class="h-10 w-10 rounded-full"
                  />
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-2">
                        <router-link
                          v-if="comment.author?.id"
                          :to="`/profile/${comment.author.id}`"
                          class="font-medium text-gray-900 hover:text-primary-600"
                        >
                          {{ comment.author?.fullName }}
                        </router-link>
                        <span v-else class="font-medium text-gray-900">{{ comment.author?.fullName }}</span>
                      </div>
                      <p class="text-xs text-gray-400">{{ formatDateTime(comment.createdAt) }}</p>
                    </div>
                    <p class="text-gray-600 mt-1">{{ comment.content }}</p>

                    <!-- Reply actions -->
                    <div class="flex items-center space-x-4 mt-2">
                      <button
                        @click="toggleReply(comment.id)"
                        class="text-sm text-gray-500 hover:text-primary-600"
                      >
                        Reply
                      </button>
                      <button
                        v-if="canManageComment(comment)"
                        @click="deleteComment(comment.id)"
                        class="text-sm text-gray-500 hover:text-red-600"
                      >
                        Delete
                      </button>
                    </div>

                    <!-- Reply Form -->
                    <div v-if="replyTo === comment.id" class="mt-3 ml-10">
                      <form @submit.prevent="submitReply(comment.id)" class="flex items-start space-x-3">
                        <img
                          :src="authStore.user?.avatar || defaultAvatar(authStore.user?.fullName || 'User')"
                          class="h-8 w-8 rounded-full"
                        />
                        <div class="flex-1">
                          <input
                            v-model="replies[comment.id]"
                            type="text"
                            placeholder="Write a reply..."
                            class="w-full px-3 py-1.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm"
                          />
                          <div class="flex justify-end mt-1 space-x-2">
                            <button
                              type="button"
                              @click="toggleReply(comment.id)"
                              class="px-3 py-1 text-sm text-gray-500 hover:text-gray-700"
                            >
                              Cancel
                            </button>
                            <button
                              type="submit"
                              class="px-3 py-1 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700"
                            >
                              Reply
                            </button>
                          </div>
                        </div>
                      </form>
                    </div>

                    <!-- Replies -->
                    <div v-if="comment.replies && comment.replies.length > 0" class="ml-10 mt-3 space-y-3 border-l-2 border-gray-100 pl-3">
                      <div
                        v-for="reply in comment.replies"
                        :key="reply.id"
                        class="flex items-start space-x-3"
                      >
                        <img
                          :src="reply.author?.avatar || defaultAvatar(reply.author?.fullName || 'User')"
                          class="h-8 w-8 rounded-full"
                        />
                        <div class="flex-1">
                          <div class="flex items-center space-x-2">
                            <router-link
                              v-if="reply.author?.id"
                              :to="`/profile/${reply.author.id}`"
                              class="font-medium text-gray-900 hover:text-primary-600 text-sm"
                            >
                              {{ reply.author?.fullName }}
                            </router-link>
                            <span v-else class="font-medium text-gray-900 text-sm">{{ reply.author?.fullName }}</span>
                          </div>
                          <p class="text-gray-600 text-sm mt-0.5">{{ reply.content }}</p>
                          <p class="text-xs text-gray-400 mt-1">{{ formatDateTime(reply.createdAt) }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- No comments -->
                <div v-if="comments.length === 0" class="p-6 text-center text-gray-500">
                  <ChatBubbleLeftRightIcon class="h-12 w-12 mx-auto mb-2 text-gray-300" />
                  <p>No comments yet. Be the first to comment!</p>
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
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { HeartIcon, ChatBubbleLeftRightIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const postId = computed(() => route.params.id as string)
const post = ref<any>(null)
const loading = ref(true)
const deleting = ref(false)

const comments = ref<any[]>([])
const newComment = ref('')
const submittingComment = ref(false)
const replyTo = ref<number | null>(null)
const replies = ref<Record<number, string>>({})

const canManagePost = computed(() => {
  return authStore.user?.id === post.value?.author?.id || authStore.user?.role === 'ADMIN'
})

const canManageComment = (comment: any) => {
  return authStore.user?.id === comment.author?.id || authStore.user?.role === 'ADMIN'
}

const loadPost = async () => {
  loading.value = true
  try {
    const response = await api.get(`/api/posts/${postId.value}`)
    post.value = response.data
    comments.value = response.data.comments || []
  } catch (error) {
    console.error('Failed to load post:', error)
  } finally {
    loading.value = false
  }
}

const toggleLike = async () => {
  if (!post.value) return
  const originalLiked = post.value.liked
  const originalCount = post.value.likesCount
  post.value.liked = !post.value.liked
  post.value.likesCount += post.value.liked ? 1 : -1

  try {
    if (post.value.liked) {
      await api.post(`/api/posts/${postId.value}/like`)
    } else {
      await api.delete(`/api/posts/${postId.value}/like`)
    }
  } catch (error) {
    post.value.liked = originalLiked
    post.value.likesCount = originalCount
    console.error('Failed to toggle like:', error)
  }
}

const deletePost = async () => {
  if (!confirm('Are you sure you want to delete this post?')) return
  deleting.value = true
  try {
    await api.delete(`/api/posts/${postId.value}`)
    router.push('/posts')
  } catch (error) {
    console.error('Failed to delete post:', error)
  } finally {
    deleting.value = false
  }
}

const submitComment = async () => {
  if (!newComment.value.trim()) return
  submittingComment.value = true
  try {
    const response = await api.post(`/api/posts/${postId.value}/comments`, {
      content: newComment.value.trim()
    })
    comments.value.unshift(response.data)
    newComment.value = ''
  } catch (error) {
    console.error('Failed to submit comment:', error)
  } finally {
    submittingComment.value = false
  }
}

const toggleReply = (commentId: number) => {
  replyTo.value = replyTo.value === commentId ? null : commentId
}

const submitReply = async (commentId: number) => {
  const content = replies.value[commentId]?.trim()
  if (!content) return
  try {
    const response = await api.post(`/api/posts/${postId.value}/comments/${commentId}/replies`, {
      content
    })
    if (!comments.value.find(c => c.id === commentId).replies) {
      comments.value.find(c => c.id === commentId).replies = []
    }
    comments.value.find(c => c.id === commentId).replies.push(response.data)
    replies.value[commentId] = ''
    replyTo.value = null
  } catch (error) {
    console.error('Failed to submit reply:', error)
  }
}

const deleteComment = async (commentId: number) => {
  if (!confirm('Are you sure you want to delete this comment?')) return
  try {
    await api.delete(`/api/posts/${postId.value}/comments/${commentId}`)
    comments.value = comments.value.filter(c => c.id !== commentId)
  } catch (error) {
    console.error('Failed to delete comment:', error)
  }
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

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadPost()
})
</script>

<style scoped>
</style>
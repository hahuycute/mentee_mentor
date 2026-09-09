<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="isEdit ? 'Edit Post' : 'Create Post'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6 max-w-2xl mx-auto">
          <form @submit.prevent="handleSubmit" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-6">
            <!-- Content -->
            <div>
              <label for="content" class="block text-sm font-medium text-gray-700 mb-2">
                Content <span class="text-red-500">*</span>
              </label>
              <textarea
                id="content"
                v-model="form.content"
                rows="8"
                maxlength="5000"
                placeholder="Share your thoughts, ask a question, or start a discussion..."
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-y"
                required
              ></textarea>
              <div class="flex justify-end mt-1">
                <span class="text-xs text-gray-400">{{ form.content.length }}/5000</span>
              </div>
              <p v-if="errors.content" class="mt-1 text-sm text-red-600">{{ errors.content }}</p>
            </div>

            <!-- Images (optional) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Images (optional)</label>
              <div class="flex items-center space-x-4">
                <label class="flex-1">
                  <input
                    type="file"
                    @change="handleImageSelect"
                    accept="image/*"
                    multiple
                    class="hidden"
                    ref="fileInput"
                  />
                  <button
                    type="button"
                    @click="triggerFileInput"
                    :disabled="uploadingImages || form.images.length >= 5"
                    class="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-primary-400 hover:text-primary-600 transition-colors"
                  >
                    <ArrowUpTrayIcon class="h-6 w-6 mx-auto mb-2" />
                    <p>Click to upload images (max 5)</p>
                  </button>
                </label>
              </div>

              <!-- Image Previews -->
              <div v-if="form.images.length > 0" class="flex flex-wrap gap-3 mt-3">
                <div
                  v-for="(image, index) in form.images"
                  :key="index"
                  class="relative w-20 h-20"
                >
                  <img :src="image.preview" class="w-full h-full object-cover rounded-lg" />
                  <button
                    type="button"
                    @click="removeImage(index)"
                    class="absolute -top-2 -right-2 h-6 w-6 bg-red-500 text-white rounded-full flex items-center justify-center"
                  >
                    <XMarkIcon class="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex justify-end space-x-3 border-t border-gray-200 pt-6">
              <router-link
                to="/posts"
                class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                Cancel
              </router-link>
              <button
                type="submit"
                :disabled="submitting || uploadingImages"
                class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="submitting" class="flex items-center space-x-2">
                  <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  <span>Publishing...</span>
                </span>
                <span v-else>{{ isEdit ? 'Update' : 'Publish' }}</span>
              </button>
            </div>
          </form>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ArrowUpTrayIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

const router = useRouter()
const route = useRoute()

const isEdit = computed(() => route.params.id !== undefined)
const postId = computed(() => route.params.id as string)

const form = ref({
  content: '',
  images: [] as Array<{ file: File; preview: string }>,
})

const errors = ref<Record<string, string>>({})
const submitting = ref(false)
const uploadingImages = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)

const loadPost = async () => {
  if (!isEdit.value) return
  try {
    const response = await api.get(`/api/posts/${postId.value}`)
    const post = response.data
    form.value.content = post.content
  } catch (error) {
    console.error('Failed to load post:', error)
    router.push('/posts')
  }
}

const handleImageSelect = (event: Event) => {
  const input = event.target as HTMLInputElement
  if (!input.files) return

  const files = Array.from(input.files)
  const remaining = 5 - form.value.images.length
  const toAdd = files.slice(0, remaining)

  uploadingImages.value = true
  toAdd.forEach(file => {
    const reader = new FileReader()
    reader.onload = (e) => {
      form.value.images.push({ file, preview: e.target?.result as string })
      if (form.value.images.length === toAdd.length) {
        uploadingImages.value = false
      }
    }
    reader.readAsDataURL(file)
  })

  // Clear input
  input.value = ''
}

const removeImage = (index: number) => {
  form.value.images.splice(index, 1)
}

const triggerFileInput = () => {
  fileInput.value?.click()
}

const validateForm = () => {
  errors.value = {}

  if (!form.value.content.trim()) {
    errors.value.content = 'Content is required'
  } else if (form.value.content.trim().length < 10) {
    errors.value.content = 'Content must be at least 10 characters'
  }

  return Object.keys(errors.value).length === 0
}

const handleSubmit = async () => {
  if (!validateForm()) return

  submitting.value = true
  try {
    const formData = new FormData()
    formData.append('content', form.value.content.trim())
    form.value.images.forEach((img, index) => {
      formData.append(`images[${index}]`, img.file)
    })

    if (isEdit.value) {
      await api.put(`/api/posts/${postId.value}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
    } else {
      await api.post('/api/posts', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
    }
    router.push('/posts')
  } catch (error: any) {
    if (error.response?.data?.errors) {
      errors.value = error.response.data.errors
    } else {
      console.error('Failed to save post:', error)
    }
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadPost()
})
</script>

<style scoped>
</style>
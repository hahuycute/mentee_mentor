<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Leave Feedback'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <form @submit.prevent="handleSubmit" class="max-w-2xl mx-auto">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-6">
              <!-- Session info -->
              <div v-if="booking" class="flex items-center space-x-4 bg-gray-50 rounded-xl p-4">
                <img
                  :src="booking.mentor?.avatar || defaultAvatar(booking.mentor?.fullName || 'Mentor')"
                  class="h-12 w-12 rounded-full"
                  alt="Mentor"
                />
                <div>
                  <p class="text-sm text-gray-500">Session with</p>
                  <p class="font-semibold text-gray-900">{{ booking.mentor?.fullName || 'Mentor' }}</p>
                </div>
              </div>

              <!-- Rating -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Your Rating</label>
                <div class="flex items-center space-x-1">
                  <button
                    v-for="i in 5"
                    :key="i"
                    type="button"
                    @click="form.rating = i"
                    class="focus:outline-none transition-transform hover:scale-110"
                    :aria-label="`Rate ${i} stars`"
                  >
                    <StarIcon
                      class="h-10 w-10"
                      :class="i <= (hoverRating || form.rating) ? 'text-yellow-400' : 'text-gray-300'"
                      fill="currentColor"
                      @mouseenter="hoverRating = i"
                      @mouseleave="hoverRating = 0"
                    />
                  </button>
                  <span class="ml-3 text-sm text-gray-500">{{ ratingLabel }}</span>
                </div>
                <p v-if="errors.rating" class="mt-1 text-sm text-red-600">{{ errors.rating }}</p>
              </div>

              <!-- Comment -->
              <div>
                <label for="comment" class="block text-sm font-medium text-gray-700 mb-2">
                  Your Feedback <span class="text-red-500">*</span>
                </label>
                <textarea
                  id="comment"
                  v-model="form.comment"
                  rows="5"
                  maxlength="1000"
                  placeholder="Share your experience about the session..."
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
                  required
                ></textarea>
                <div class="flex justify-between mt-1">
                  <p v-if="errors.comment" class="text-sm text-red-600">{{ errors.comment }}</p>
                  <span class="text-xs text-gray-400 ml-auto">{{ form.comment.length }}/1000</span>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex justify-end space-x-3 border-t border-gray-200 pt-6">
                <router-link
                  to="/bookings"
                  class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
                >
                  Cancel
                </router-link>
                <button
                  type="submit"
                  :disabled="submitting || !form.rating"
                  class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span v-if="submitting" class="flex items-center space-x-2">
                    <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                    </svg>
                    <span>Submitting...</span>
                  </span>
                  <span v-else>Submit Feedback</span>
                </button>
              </div>
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
import { StarIcon } from '@heroicons/vue/24/solid'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

const router = useRouter()
const route = useRoute()

const bookingId = computed(() => route.params.bookingId as string)

const booking = ref<any>(null)
const hoverRating = ref(0)
const submitting = ref(false)

const form = ref({
  rating: 0,
  comment: '',
})

const errors = ref<Record<string, string>>({})

const ratingLabel = computed(() => {
  switch (hoverRating.value || form.value.rating) {
    case 1: return 'Poor'
    case 2: return 'Fair'
    case 3: return 'Good'
    case 4: return 'Very good'
    case 5: return 'Excellent'
    default: return ''
  }
})

const loadBooking = async () => {
  if (!bookingId.value) return
  try {
    const response = await api.get(`/api/bookings/${bookingId.value}`)
    booking.value = response.data
  } catch (error) {
    console.error('Failed to load booking:', error)
  }
}

const validateForm = () => {
  errors.value = {}

  if (!form.value.rating) {
    errors.value.rating = 'Please select a rating'
  }

  if (!form.value.comment.trim()) {
    errors.value.comment = 'Please write your feedback'
  } else if (form.value.comment.trim().length < 10) {
    errors.value.comment = 'Feedback must be at least 10 characters'
  }

  return Object.keys(errors.value).length === 0
}

const handleSubmit = async () => {
  if (!validateForm()) return

  submitting.value = true
  try {
    await api.post('/api/feedbacks', {
      bookingId: bookingId.value ? Number(bookingId.value) : undefined,
      rating: form.value.rating,
      comment: form.value.comment.trim(),
    })
    router.push('/feedbacks')
  } catch (error: any) {
    if (error.response?.data?.errors) {
      errors.value = error.response.data.errors
    } else {
      console.error('Failed to submit feedback:', error)
    }
  } finally {
    submitting.value = false
  }
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadBooking()
})
</script>

<style scoped>
</style>
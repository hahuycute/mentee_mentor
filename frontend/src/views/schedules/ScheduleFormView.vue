<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="isEdit ? 'Edit Schedule' : 'Create Schedule'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <form @submit.prevent="handleSubmit" class="max-w-2xl mx-auto">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-6">
              <div>
                <h2 class="text-lg font-semibold text-gray-900 mb-4">Schedule Details</h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <!-- Day of Week -->
                  <div>
                    <label for="dayOfWeek" class="block text-sm font-medium text-gray-700 mb-2">
                      Day of Week <span class="text-red-500">*</span>
                    </label>
                    <select
                      id="dayOfWeek"
                      v-model="form.dayOfWeek"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      required
                    >
                      <option value="">Select a day</option>
                      <option value="MONDAY">Monday</option>
                      <option value="TUESDAY">Tuesday</option>
                      <option value="WEDNESDAY">Wednesday</option>
                      <option value="THURSDAY">Thursday</option>
                      <option value="FRIDAY">Friday</option>
                      <option value="SATURDAY">Saturday</option>
                      <option value="SUNDAY">Sunday</option>
                    </select>
                    <p v-if="errors.dayOfWeek" class="mt-1 text-sm text-red-600">{{ errors.dayOfWeek }}</p>
                  </div>

                  <!-- Max Bookings -->
                  <div>
                    <label for="maxBookings" class="block text-sm font-medium text-gray-700 mb-2">
                      Max Bookings <span class="text-red-500">*</span>
                    </label>
                    <input
                      id="maxBookings"
                      type="number"
                      v-model.number="form.maxBookings"
                      min="1"
                      max="10"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      required
                    />
                    <p v-if="errors.maxBookings" class="mt-1 text-sm text-red-600">{{ errors.maxBookings }}</p>
                  </div>
                </div>

                <!-- Time Range -->
                <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label for="startTime" class="block text-sm font-medium text-gray-700 mb-2">
                      Start Time <span class="text-red-500">*</span>
                    </label>
                    <input
                      id="startTime"
                      type="time"
                      v-model="form.startTime"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      required
                    />
                    <p v-if="errors.startTime" class="mt-1 text-sm text-red-600">{{ errors.startTime }}</p>
                  </div>

                  <div>
                    <label for="endTime" class="block text-sm font-medium text-gray-700 mb-2">
                      End Time <span class="text-red-500">*</span>
                    </label>
                    <input
                      id="endTime"
                      type="time"
                      v-model="form.endTime"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      required
                    />
                    <p v-if="errors.endTime" class="mt-1 text-sm text-red-600">{{ errors.endTime }}</p>
                  </div>
                </div>
              </div>

              <div class="border-t border-gray-200 pt-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">Status</h2>
                <div class="flex items-center space-x-6">
                  <label class="flex items-center">
                    <input
                      type="radio"
                      value="AVAILABLE"
                      v-model="form.status"
                      class="h-4 w-4 text-primary-600 border-gray-300 focus:ring-primary-500"
                    />
                    <span class="ml-2 text-sm text-gray-700">Available for booking</span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      value="UNAVAILABLE"
                      v-model="form.status"
                      class="h-4 w-4 text-primary-600 border-gray-300 focus:ring-primary-500"
                    />
                    <span class="ml-2 text-sm text-gray-700">Not available</span>
                  </label>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex justify-end space-x-3 border-t border-gray-200 pt-6">
                <router-link
                  to="/schedules"
                  class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
                >
                  Cancel
                </router-link>
                <button
                  type="submit"
                  :disabled="submitting"
                  class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span v-if="submitting" class="flex items-center space-x-2">
                    <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                    </svg>
                    <span>Saving...</span>
                  </span>
                  <span v-else>{{ isEdit ? 'Update' : 'Create' }}</span>
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
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

const router = useRouter()
const route = useRoute()

const isEdit = computed(() => route.params.id !== undefined)
const scheduleId = computed(() => route.params.id as string)

const form = ref({
  dayOfWeek: '',
  startTime: '',
  endTime: '',
  maxBookings: 1,
  status: 'AVAILABLE' as 'AVAILABLE' | 'UNAVAILABLE',
})

const errors = ref<Record<string, string>>({})
const submitting = ref(false)

const loadSchedule = async () => {
  if (!isEdit.value) return

  try {
    const response = await api.get(`/api/schedules/${scheduleId.value}`)
    const schedule = response.data
    form.value = {
      dayOfWeek: schedule.dayOfWeek,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      maxBookings: schedule.maxBookings,
      status: schedule.status,
    }
  } catch (error) {
    console.error('Failed to load schedule:', error)
    router.push('/schedules')
  }
}

const validateForm = () => {
  errors.value = {}

  if (!form.value.dayOfWeek) {
    errors.value.dayOfWeek = 'Please select a day of the week'
  }

  if (!form.value.startTime) {
    errors.value.startTime = 'Please select a start time'
  }

  if (!form.value.endTime) {
    errors.value.endTime = 'Please select an end time'
  }

  if (form.value.startTime && form.value.endTime && form.value.startTime >= form.value.endTime) {
    errors.value.endTime = 'End time must be after start time'
  }

  if (!form.value.maxBookings || form.value.maxBookings < 1) {
    errors.value.maxBookings = 'Max bookings must be at least 1'
  }

  return Object.keys(errors.value).length === 0
}

const handleSubmit = async () => {
  if (!validateForm()) return

  submitting.value = true
  try {
    if (isEdit.value) {
      await api.put(`/api/schedules/${scheduleId.value}`, form.value)
    } else {
      await api.post('/api/schedules', form.value)
    }
    router.push('/schedules')
  } catch (error: any) {
    if (error.response?.data?.errors) {
      errors.value = error.response.data.errors
    } else {
      console.error('Failed to save schedule:', error)
    }
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadSchedule()
})
</script>

<style scoped>
</style>
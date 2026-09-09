<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <div class="mx-auto h-12 w-12 bg-primary-600 rounded-xl flex items-center justify-center">
          <svg class="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
          </svg>
        </div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">Forgot password?</h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Enter your email and we'll send you a reset code
        </p>
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div>
          <label for="email" class="sr-only">Email address</label>
          <input
            id="email"
            name="email"
            type="email"
            autocomplete="email"
            required
            v-model="form.email"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
            placeholder="Email address"
          />
          <p v-if="errors.email" class="mt-1 text-sm text-red-600">{{ errors.email }}</p>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="btn-loading absolute"></span>
            <span v-else>Send reset code</span>
          </button>
        </div>
      </form>

      <div v-if="error" class="text-center text-sm text-red-600 bg-red-50 p-3 rounded-md">
        {{ error }}
      </div>

      <div v-if="success" class="text-center text-sm text-green-600 bg-green-50 p-3 rounded-md">
        {{ success }}
        <router-link to="/reset-password" class="font-medium text-green-600 hover:text-green-500 ml-2">Reset password</router-link>
      </div>

      <div class="text-center">
        <router-link to="/login" class="text-sm font-medium text-primary-600 hover:text-primary-500">
          Back to login
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toastification'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const error = ref<string | null>(null)
const success = ref<string | null>(null)
const errors = reactive<Record<string, string>>({})

const form = reactive({
  email: '',
})

const handleSubmit = async () => {
  error.value = null
  success.value = null
  Object.keys(errors).forEach(key => delete errors[key])

  if (!form.email) {
    errors.email = 'Email is required'
    return
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Please enter a valid email'
    return
  }

  loading.value = true
  try {
    await authStore.forgotPassword(form.email)
    success.value = 'Reset code sent to your email!'
    toast.success('Check your email for the reset code')
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to send reset code'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
</style>
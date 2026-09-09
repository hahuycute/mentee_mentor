<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <div class="mx-auto h-12 w-12 bg-primary-600 rounded-xl flex items-center justify-center">
          <svg class="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
          </svg>
        </div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">Reset your password</h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Enter the 6-digit code sent to your email
        </p>
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div>
          <label class="sr-only">Verification code</label>
          <div class="flex gap-3 justify-center">
            <input
              v-for="(_, index) in 6"
              :key="index"
              type="text"
              maxlength="1"
              v-model="otp[index]"
              @input="handleOtpInput(index)"
              @keydown.backspace="handleBackspace(index)"
              class="w-12 h-12 text-center text-2xl font-bold border-2 border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              :disabled="loading"
              autocomplete="one-time-code"
            />
          </div>
          <p v-if="errors.otp" class="mt-2 text-center text-sm text-red-600">{{ errors.otp }}</p>
        </div>

        <div>
          <label for="newPassword" class="sr-only">New password</label>
          <input
            id="newPassword"
            name="newPassword"
            type="password"
            autocomplete="new-password"
            required
            v-model="form.newPassword"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
            placeholder="New password (min 8 characters)"
          />
          <p v-if="errors.newPassword" class="mt-1 text-sm text-red-600">{{ errors.newPassword }}</p>
        </div>

        <div>
          <label for="confirmPassword" class="sr-only">Confirm new password</label>
          <input
            id="confirmPassword"
            name="confirmPassword"
            type="password"
            autocomplete="new-password"
            required
            v-model="form.confirmPassword"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
            placeholder="Confirm new password"
          />
          <p v-if="errors.confirmPassword" class="mt-1 text-sm text-red-600">{{ errors.confirmPassword }}</p>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading || otp.join('').length !== 6"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="btn-loading absolute"></span>
            <span v-else>Reset password</span>
          </button>
        </div>
      </form>

      <div v-if="error" class="text-center text-sm text-red-600 bg-red-50 p-3 rounded-md">
        {{ error }}
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
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toastification'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const error = ref<string | null>(null)
const errors = reactive<Record<string, string>>({})

const otp = reactive<string[]>(['', '', '', '', '', ''])

const form = reactive({
  newPassword: '',
  confirmPassword: '',
})

const handleOtpInput = (index: number) => {
  if (otp[index].length === 1 && index < 5) {
    const nextInput = document.querySelectorAll('input[type="text"]')[index + 1] as HTMLInputElement
    nextInput?.focus()
  }
  errors.otp = ''
}

const handleBackspace = (index: number) => {
  if (!otp[index] && index > 0) {
    const prevInput = document.querySelectorAll('input[type="text"]')[index - 1] as HTMLInputElement
    prevInput?.focus()
  }
}

const handleSubmit = async () => {
  if (otp.join('').length !== 6) {
    errors.otp = 'Please enter the 6-digit code'
    return
  }
  if (!form.newPassword) {
    errors.newPassword = 'New password is required'
    return
  }
  if (form.newPassword.length < 8) {
    errors.newPassword = 'Password must be at least 8 characters'
    return
  }
  if (form.newPassword !== form.confirmPassword) {
    errors.confirmPassword = 'Passwords do not match'
    return
  }

  error.value = null
  loading.value = true

  try {
    await authStore.resetPassword(otp.join(''), form.newPassword, form.confirmPassword)
    toast.success('Password reset successfully!')
    router.push({ name: 'Login' })
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to reset password'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
</style>
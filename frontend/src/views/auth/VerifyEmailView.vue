<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <div class="mx-auto h-12 w-12 bg-primary-600 rounded-xl flex items-center justify-center">
          <svg class="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
        </div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">Verify your email</h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          We've sent a 6-digit code to <strong>{{ email }}</strong>
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
          <p v-if="error" class="mt-2 text-center text-sm text-red-600">{{ error }}</p>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading || otp.join('').length !== 6"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="btn-loading absolute"></span>
            <span v-else>Verify</span>
          </button>
        </div>

        <div class="text-center">
          <p class="text-sm text-gray-600">
            Didn't receive the code?
            <button
              @click="resendOtp"
              :disabled="resendLoading"
              class="font-medium text-primary-600 hover:text-primary-500 disabled:opacity-50 ml-1"
            >
              {{ resendLoading ? 'Sending...' : 'Resend code' }}
            </button>
          </p>
        </div>
      </form>

      <div class="text-center">
        <router-link to="/login" class="text-sm font-medium text-primary-600 hover:text-primary-500">
          Back to login
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toastification'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const toast = useToast()

const email = computed(() => route.query.email as string || '')
const loading = ref(false)
const resendLoading = ref(false)
const error = ref<string | null>(null)

const otp = reactive<string[]>(['', '', '', '', '', ''])

const handleOtpInput = (index: number) => {
  if (otp[index].length === 1 && index < 5) {
    // Focus next input
    const nextInput = document.querySelectorAll('input[type="text"]')[index + 1] as HTMLInputElement
    nextInput?.focus()
  }
  error.value = null
}

const handleBackspace = (index: number) => {
  if (!otp[index] && index > 0) {
    const prevInput = document.querySelectorAll('input[type="text"]')[index - 1] as HTMLInputElement
    prevInput?.focus()
  }
}

const handleSubmit = async () => {
  if (otp.join('').length !== 6) return

  loading.value = true
  try {
    await authStore.verifyOtp(email.value, otp.join(''))
    toast.success('Email verified successfully!')
    router.push({ name: 'Login' })
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Invalid or expired code'
  } finally {
    loading.value = false
  }
}

const resendOtp = async () => {
  resendLoading.value = true
  try {
    await authStore.resendOtp(email.value)
    toast.success('Verification code resent')
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to resend code'
  } finally {
    resendLoading.value = false
  }
}
</script>

<style scoped>
</style>
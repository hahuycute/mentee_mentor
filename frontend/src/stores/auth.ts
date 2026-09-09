import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'
import type { User } from '@/types/user'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('accessToken'))
  const refreshToken = ref<string | null>(localStorage.getItem('refreshToken'))
  const user = ref<User | null>(null)
  const initialized = ref(false)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const userRole = computed(() => user.value?.role || null)
  const userPermissions = computed(() => user.value?.permissions || [])

  function setTokens(accessToken: string, refreshTokenValue: string) {
    token.value = accessToken
    refreshToken.value = refreshTokenValue
    localStorage.setItem('accessToken', accessToken)
    localStorage.setItem('refreshToken', refreshTokenValue)
    api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`
  }

  function clearTokens() {
    token.value = null
    refreshToken.value = null
    user.value = null
    localStorage.removeItem('accessToken')
    localStorage.removeItem('refreshToken')
    delete api.defaults.headers.common['Authorization']
  }

  async function initialize() {
    if (initialized.value) return

    const storedToken = localStorage.getItem('accessToken')
    const storedRefreshToken = localStorage.getItem('refreshToken')

    if (storedToken && storedRefreshToken) {
      token.value = storedToken
      refreshToken.value = storedRefreshToken
      api.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`

      try {
        await fetchCurrentUser()
      } catch (error) {
        // Token might be expired, try to refresh
        try {
          await refreshAccessToken()
          await fetchCurrentUser()
        } catch (refreshError) {
          clearTokens()
        }
      }
    }

    initialized.value = true
  }

  async function fetchCurrentUser() {
    const response = await api.get('/api/auth/me')
    user.value = response.data.user
  }

  async function login(email: string, password: string) {
    loading.value = true
    try {
      const response = await api.post('/api/auth/login', { email, password })
      const { accessToken, refreshToken: newRefreshToken, user: userData } = response.data

      setTokens(accessToken, newRefreshToken)
      user.value = userData

      return userData
    } finally {
      loading.value = false
    }
  }

  async function register(data: { email: string; password: string; fullName: string; phone: string; role?: string }) {
    loading.value = true
    try {
      const response = await api.post('/api/auth/register', data)
      const { accessToken, refreshToken: newRefreshToken, user: userData } = response.data

      setTokens(accessToken, newRefreshToken)
      user.value = userData

      return userData
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    clearTokens()
  }

  async function refreshAccessToken() {
    if (!refreshToken.value) throw new Error('No refresh token')

    const response = await api.post('/api/auth/refresh-token', null, {
      params: { refreshToken: refreshToken.value },
    })

    const { accessToken, refreshToken: newRefreshToken } = response.data
    setTokens(accessToken, newRefreshToken)
  }

  async function changePassword(currentPassword: string, newPassword: string, confirmPassword: string) {
    loading.value = true
    try {
      await api.post('/api/auth/change-password', {
        currentPassword,
        newPassword,
        confirmPassword,
      })
    } finally {
      loading.value = false
    }
  }

  async function verifyOtp(email: string, otp: string) {
    loading.value = true
    try {
      const response = await api.post('/api/auth/verify-otp', { email, otp })
      const { accessToken, refreshToken: newRefreshToken, user: userData } = response.data
      setTokens(accessToken, newRefreshToken)
      user.value = userData
      return userData
    } finally {
      loading.value = false
    }
  }

  async function resendOtp(email: string) {
    loading.value = true
    try {
      await api.post('/api/auth/resend-otp', { email })
    } finally {
      loading.value = false
    }
  }

  async function forgotPassword(email: string) {
    loading.value = true
    try {
      await api.post('/api/auth/forgot-password', { email })
    } finally {
      loading.value = false
    }
  }

  async function resetPassword(token: string, newPassword: string, confirmPassword: string) {
    loading.value = true
    try {
      await api.post('/api/auth/reset-password', { token, newPassword, confirmPassword })
    } finally {
      loading.value = false
    }
  }

  function updateUser(updates: Partial<User>) {
    if (user.value) {
      user.value = { ...user.value, ...updates }
    }
  }

  function hasPermission(permission: string): boolean {
    return userPermissions.value.includes(permission)
  }

  function hasRole(role: string | string[]): boolean {
    if (!userRole.value) return false
    const roles = Array.isArray(role) ? role : [role]
    return roles.includes(userRole.value)
  }

  return {
    token,
    refreshToken,
    user,
    initialized,
    loading,
    isAuthenticated,
    userRole,
    userPermissions,
    setTokens,
    clearTokens,
    initialize,
    fetchCurrentUser,
    login,
    register,
    logout,
    refreshAccessToken,
    changePassword,
    updateUser,
    hasPermission,
    hasRole,
    verifyOtp,
    resendOtp,
    forgotPassword,
    resetPassword,
  }
})
import axios, { type AxiosError, type AxiosInstance, type InternalAxiosRequestConfig } from 'axios'
import { useAuthStore } from '@/stores/auth'

const api: AxiosInstance = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
})

let isRefreshing = false
let failedQueue: Array<{
  resolve: (token: string) => void
  reject: (error: Error) => void
}> = []

const processQueue = (error: Error | null, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error)
    } else {
      prom.resolve(token!)
    }
  })
  failedQueue = []
}

api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const authStore = useAuthStore()
    if (authStore.token && !config.url?.includes('/auth/')) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  (error: AxiosError) => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean }

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject })
        })
          .then((token) => {
            originalRequest.headers.Authorization = `Bearer ${token}`
            return api(originalRequest)
          })
          .catch((err) => Promise.reject(err))
      }

      originalRequest._retry = true
      isRefreshing = true

      const authStore = useAuthStore()

      try {
        await authStore.refreshAccessToken()
        const newToken = authStore.token
        processQueue(null, newToken)
        originalRequest.headers.Authorization = `Bearer ${newToken}`
        return api(originalRequest)
      } catch (refreshError) {
        processQueue(refreshError as Error, null)
        authStore.logout()
        window.location.href = '/login'
        return Promise.reject(refreshError)
      } finally {
        isRefreshing = false
      }
    }

    return Promise.reject(error)
  }
)

export default api
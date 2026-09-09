<template>
  <div
    class="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
    :class="{ 'bg-blue-50 border-l-4 border-blue-500': !notification.readAt }"
  >
    <div
      class="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center"
      :class="iconBgClass"
    >
      <component :is="iconComponent" class="h-4 w-4 text-white" />
    </div>
    <div class="flex-1 min-w-0">
      <p class="text-sm text-gray-900" v-html="highlightMessage"></p>
      <p class="text-xs text-gray-500 mt-1">{{ formatDate(notification.createdAt) }}</p>
    </div>
    <button
      v-if="!notification.readAt"
      @click="markAsRead"
      class="text-gray-400 hover:text-gray-600 p-1"
      aria-label="Mark as read"
    >
      <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
        <path d="M10 15a5 5 0 01-5-5H5a7 7 0 1110 0h-2a5 5 0 01-5 5z" />
      </svg>
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  BellIcon,
  CalendarIcon,
  CheckCircleIcon,
  ChatBubbleLeftIcon,
  UserPlusIcon,
  ExclamationCircleIcon,
} from '@heroicons/vue/24/outline'

interface Props {
  notification: {
    id: number
    type: string
    message: string
    readAt?: string | null
    createdAt: string
  }
}

const props = defineProps<Props>()

const iconMap = {
  BOOKING_CREATED: CalendarIcon,
  BOOKING_CONFIRMED: CheckCircleIcon,
  BOOKING_CANCELLED: ExclamationCircleIcon,
  SESSION_STARTED: CalendarIcon,
  SESSION_COMPLETED: CheckCircleIcon,
  FEEDBACK_RECEIVED: ChatBubbleLeftIcon,
  NEW_FOLLOWER: UserPlusIcon,
  POST_LIKED: ChatBubbleLeftIcon,
  POST_COMMENTED: ChatBubbleLeftIcon,
  SYSTEM: BellIcon,
} as const

const iconComponent = computed(() => iconMap[props.notification.type as keyof typeof iconMap] || BellIcon)

const colorClasses = {
  BOOKING_CREATED: 'bg-blue-500',
  BOOKING_CONFIRMED: 'bg-green-500',
  BOOKING_CANCELLED: 'bg-red-500',
  SESSION_STARTED: 'bg-yellow-500',
  SESSION_COMPLETED: 'bg-green-500',
  FEEDBACK_RECEIVED: 'bg-purple-500',
  NEW_FOLLOWER: 'bg-pink-500',
  POST_LIKED: 'bg-red-500',
  POST_COMMENTED: 'bg-blue-500',
  SYSTEM: 'bg-gray-500',
} as const

const iconBgClass = computed(() => colorClasses[props.notification.type as keyof typeof colorClasses] || 'bg-gray-500')

const highlightMessage = computed(() => {
  // Simple highlight for bold parts in message
  return props.notification.message
})

const formatDate = (dateString: string) => {
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
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

const markAsRead = () => {
  emit('mark-read', props.notification.id)
}

const emit = defineEmits(['mark-read'])
</script>

<style scoped>
</style>
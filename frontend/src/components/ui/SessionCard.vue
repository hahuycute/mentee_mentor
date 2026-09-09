<template>
  <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
    <div class="flex items-center space-x-3 min-w-0">
      <div class="flex-shrink-0 w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
        <svg class="h-5 w-5 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <div class="min-w-0">
        <p class="text-sm font-medium text-gray-900 truncate">{{ session.topic?.name || 'Session' }}</p>
        <p class="text-sm text-gray-500 truncate">
          with {{ session.mentor?.fullName || session.mentee?.fullName }}
        </p>
      </div>
    </div>
    <div class="flex items-center space-x-3 ml-4">
      <span
        class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
        :class="getStatusClass(session.status)"
      >
        {{ formatStatus(session.status) }}
      </span>
      <time class="text-sm text-gray-500 whitespace-nowrap">
        {{ formatDateTime(session.scheduledAt) }}
      </time>
      <router-link
        :to="`/sessions/${session.id}`"
        class="text-sm text-primary-600 hover:text-primary-500 font-medium"
      >
        View
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  session: {
    id: number
    topic?: { name: string }
    mentor?: { fullName: string }
    mentee?: { fullName: string }
    status: string
    scheduledAt: string
  }
}

defineProps<Props>()

const getStatusClass = (status: string) => {
  switch (status) {
    case 'SCHEDULED': return 'bg-blue-100 text-blue-800'
    case 'CONFIRMED': return 'bg-green-100 text-green-800'
    case 'IN_PROGRESS': return 'bg-yellow-100 text-yellow-800'
    case 'COMPLETED': return 'bg-gray-100 text-gray-800'
    case 'CANCELLED': return 'bg-red-100 text-red-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatStatus = (status: string) => {
  return status.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, l => l.toUpperCase())
}

const formatDateTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<style scoped>
</style>
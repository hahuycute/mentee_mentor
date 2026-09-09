<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <div
          class="flex-shrink-0 w-12 h-12 rounded-lg flex items-center justify-center"
          :class="iconBgClass"
        >
          <component :is="iconComponent" class="h-6 w-6 text-white" />
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-500">{{ title }}</p>
          <p class="text-2xl font-bold text-gray-900 mt-1">
            {{ typeof value === 'string' ? value : (decimal ? value.toFixed(1) : value) }}
          </p>
        </div>
      </div>
      <div v-if="trend" class="flex items-center text-sm font-medium" :class="trendClass">
        <span class="mr-1">{{ trend }}</span>
        <span class="text-gray-500">{{ trendLabel }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  CalendarIcon,
  ClockIcon,
  CheckCircleIcon,
  StarIcon,
  UsersIcon,
  CurrencyDollarIcon,
} from '@heroicons/vue/24/outline'

interface Props {
  title: string
  value: number | string
  icon: string
  color: string
  decimal?: boolean
  trend?: string
  trendLabel?: string
}

const props = withDefaults(defineProps<Props>(), {
  decimal: false,
})

const iconMap = {
  calendar: CalendarIcon,
  clock: ClockIcon,
  'check-circle': CheckCircleIcon,
  star: StarIcon,
  users: UsersIcon,
  currency: CurrencyDollarIcon,
} as const

const iconComponent = computed(() => iconMap[props.icon as keyof typeof iconMap] || CalendarIcon)

const colorClasses = {
  blue: 'bg-blue-500',
  yellow: 'bg-yellow-500',
  green: 'bg-green-500',
  purple: 'bg-purple-500',
  red: 'bg-red-500',
  orange: 'bg-orange-500',
} as const

const iconBgClass = computed(() => colorClasses[props.color as keyof typeof colorClasses] || 'bg-blue-500')

const trendClass = computed(() => {
  if (!props.trend) return ''
  return props.trend.startsWith('+') ? 'text-green-600' : 'text-red-600'
})
</script>

<style scoped>
</style>
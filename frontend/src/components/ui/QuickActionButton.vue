<template>
  <button
    @click="$emit('click')"
    type="button"
    class="flex flex-col items-center justify-center p-4 rounded-xl border-2 transition-all hover:shadow-md"
    :class="colorClasses"
  >
    <component :is="iconComponent" class="h-8 w-8 mb-2" />
    <span class="text-sm font-medium text-center">{{ label }}</span>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  PlusCircleIcon,
  UserPlusIcon,
  PencilIcon,
  BellIcon,
} from '@heroicons/vue/24/outline'

interface Props {
  icon: string
  label: string
  color: string
}

const props = defineProps<Props>()

const iconMap = {
  'plus-circle': PlusCircleIcon,
  'user-plus': UserPlusIcon,
  'pencil-alt': PencilIcon,
  bell: BellIcon,
} as const

const iconComponent = computed(() => iconMap[props.icon as keyof typeof iconMap] || PlusCircleIcon)

const colorClasses = computed(() => {
  const base = 'border-transparent'
  const colors = {
    blue: 'bg-blue-50 text-blue-700 hover:bg-blue-100 hover:border-blue-200',
    green: 'bg-green-50 text-green-700 hover:bg-green-100 hover:border-green-200',
    purple: 'bg-purple-50 text-purple-700 hover:bg-purple-100 hover:border-purple-200',
    orange: 'bg-orange-50 text-orange-700 hover:bg-orange-100 hover:border-orange-200',
    red: 'bg-red-50 text-red-700 hover:bg-red-100 hover:border-red-200',
    yellow: 'bg-yellow-50 text-yellow-700 hover:bg-yellow-100 hover:border-yellow-200',
  }
  return `${base} ${colors[props.color as keyof typeof colors] || colors.blue}`
})

defineEmits(['click'])
</script>

<style scoped>
</style>
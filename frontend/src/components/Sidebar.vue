<template>
  <div class="flex flex-col h-full">
    <!-- Logo -->
    <div class="flex items-center h-16 px-4 border-b border-gray-200">
      <router-link to="/dashboard" class="flex items-center">
        <span class="text-xl font-bold text-primary-600">MenteeMentor</span>
      </router-link>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
      <!-- Dashboard -->
      <router-link
        to="/dashboard"
        class="nav-item"
        :class="{ 'active': $route.name === 'Dashboard' }"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
        </svg>
        <span>Dashboard</span>
      </router-link>

      <!-- Profile -->
      <router-link
        to="/profile"
        class="nav-item"
        :class="{ 'active': $route.name === 'Profile' }"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        <span>Profile</span>
      </router-link>

      <!-- Mentor-specific navigation -->
      <template v-if="authStore.hasRole('MENTOR')">
        <div class="pt-4 pb-2">
          <p class="px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider">Mentor</p>
        </div>
        <router-link
          to="/schedules"
          class="nav-item"
          :class="{ 'active': $route.name === 'Schedules' || $route.name === 'CreateSchedule' || $route.name === 'ScheduleDetail' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <span>My Schedules</span>
        </router-link>
        <router-link
          to="/sessions"
          class="nav-item"
          :class="{ 'active': $route.name === 'Sessions' || $route.name === 'SessionDetail' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Sessions</span>
        </router-link>
        <router-link
          to="/feedbacks"
          class="nav-item"
          :class="{ 'active': $route.name === 'Feedbacks' || $route.name === 'CreateFeedback' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
          </svg>
          <span>Feedbacks</span>
        </router-link>
      </template>

      <!-- Mentee-specific navigation -->
      <template v-if="authStore.hasRole('MENTEE')">
        <div class="pt-4 pb-2">
          <p class="px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider">Mentee</p>
        </div>
        <router-link
          to="/mentors"
          class="nav-item"
          :class="{ 'active': $route.name === 'Mentors' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
          <span>Find Mentors</span>
        </router-link>
        <router-link
          to="/bookings"
          class="nav-item"
          :class="{ 'active': $route.name === 'Bookings' || $route.name === 'BookingDetail' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
          </svg>
          <span>My Bookings</span>
        </router-link>
        <router-link
          to="/sessions"
          class="nav-item"
          :class="{ 'active': $route.name === 'Sessions' || $route.name === 'SessionDetail' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>My Sessions</span>
        </router-link>
      </template>

      <!-- Common navigation -->
      <div class="pt-4 pb-2">
        <p class="px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider">Community</p>
      </div>
      <router-link
        to="/posts"
        class="nav-item"
        :class="{ 'active': $route.name === 'Posts' || $route.name === 'CreatePost' || $route.name === 'PostDetail' }"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
        </svg>
        <span>Posts</span>
      </router-link>
      <router-link
        to="/notifications"
        class="nav-item"
        :class="{ 'active': $route.name === 'Notifications' }"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        <span>Notifications</span>
      </router-link>

      <!-- Admin navigation -->
      <template v-if="authStore.hasRole('ADMIN')">
        <div class="pt-4 pb-2">
          <p class="px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider">Admin</p>
        </div>
        <router-link
          to="/admin"
          class="nav-item"
          :class="{ 'active': $route.name === 'AdminDashboard' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <span>Dashboard</span>
        </router-link>
        <router-link
          to="/admin/users"
          class="nav-item"
          :class="{ 'active': $route.name === 'AdminUsers' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
          <span>User Management</span>
        </router-link>
        <router-link
          to="/admin/permissions"
          class="nav-item"
          :class="{ 'active': $route.name === 'AdminPermissions' }"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          <span>Permissions</span>
        </router-link>
      </template>
    </nav>

    <!-- Footer -->
    <div class="p-4 border-t border-gray-200">
      <p class="text-xs text-gray-400 text-center">v1.0.0</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const emit = defineEmits(['close'])
</script>

<style scoped>
.nav-item {
  @apply flex items-center px-3 py-2.5 text-sm font-medium text-gray-600 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors;
}

.nav-item.active {
  @apply bg-primary-50 text-primary-700;
}

.nav-item svg {
  @apply mr-3 flex-shrink-0;
}
</style>
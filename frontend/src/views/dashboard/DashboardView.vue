<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Dashboard'" />
      </template>

      <template #content>
        <div class="p-6 space-y-6">
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              title="Upcoming Sessions"
              :value="stats.upcomingSessions"
              icon="calendar"
              color="blue"
            />
            <StatCard
              title="Pending Bookings"
              :value="stats.pendingBookings"
              icon="clock"
              color="yellow"
            />
            <StatCard
              title="Completed Sessions"
              :value="stats.completedSessions"
              icon="check-circle"
              color="green"
            />
            <StatCard
              title="Average Rating"
              :value="stats.averageRating"
              icon="star"
              color="purple"
              :decimal="true"
            />
          </div>

          <!-- Quick Actions -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <QuickActionButton
                icon="plus-circle"
                label="Create Schedule"
                color="blue"
                @click="$router.push({ name: 'CreateSchedule' })"
                v-if="authStore.hasRole('MENTOR')"
              />
              <QuickActionButton
                icon="user-plus"
                label="Find Mentors"
                color="green"
                @click="$router.push({ name: 'Mentors' })"
                v-if="authStore.hasRole('MENTEE')"
              />
              <QuickActionButton
                icon="pencil-alt"
                label="Write Post"
                color="purple"
                @click="$router.push({ name: 'CreatePost' })"
              />
              <QuickActionButton
                icon="bell"
                label="View Notifications"
                color="orange"
                @click="$router.push({ name: 'Notifications' })"
              />
            </div>
          </div>

          <!-- Upcoming Sessions & Recent Activity -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-semibold text-gray-900">Upcoming Sessions</h2>
                <router-link
                  to="/sessions"
                  class="text-sm text-primary-600 hover:text-primary-500 font-medium"
                >
                  View all
                </router-link>
              </div>
              <div v-if="upcomingSessions.length === 0" class="text-center py-8 text-gray-500">
                No upcoming sessions
              </div>
              <div v-else class="space-y-3">
                <SessionCard
                  v-for="session in upcomingSessions"
                  :key="session.id"
                  :session="session"
                />
              </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-semibold text-gray-900">Recent Activity</h2>
                <router-link
                  to="/notifications"
                  class="text-sm text-primary-600 hover:text-primary-500 font-medium"
                >
                  View all
                </router-link>
              </div>
              <div v-if="notifications.length === 0" class="text-center py-8 text-gray-500">
                No recent activity
              </div>
              <div v-else class="space-y-3">
                <NotificationItem
                  v-for="notification in notifications"
                  :key="notification.id"
                  :notification="notification"
                />
              </div>
            </div>
          </div>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import StatCard from '@/components/ui/StatCard.vue'
import QuickActionButton from '@/components/ui/QuickActionButton.vue'
import SessionCard from '@/components/ui/SessionCard.vue'
import NotificationItem from '@/components/ui/NotificationItem.vue'

const authStore = useAuthStore()

const stats = ref({
  upcomingSessions: 0,
  pendingBookings: 0,
  completedSessions: 0,
  averageRating: 0,
})

const upcomingSessions = ref<any[]>([])
const notifications = ref<any[]>([])

const loadDashboardData = async () => {
  try {
    let statsRes
    if (authStore.hasRole('ADMIN')) {
      statsRes = await api.get('/api/dashboard/admin')
    } else if (authStore.hasRole('MENTOR')) {
      statsRes = await api.get('/api/dashboard/mentor/me')
    } else {
      statsRes = await api.get('/api/dashboard/mentee/me')
    }

    const [sessionsRes, notifRes] = await Promise.all([
      api.get('/api/sessions/my', { params: { status: 'UPCOMING', limit: 5 } }),
      api.get('/api/notifications', { params: { limit: 5 } }),
    ])

    stats.value = statsRes.data
    upcomingSessions.value = sessionsRes.data.content || sessionsRes.data || []
    notifications.value = notifRes.data.content || notifRes.data || []
  } catch (error) {
    console.error('Failed to load dashboard data:', error)
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
</style>
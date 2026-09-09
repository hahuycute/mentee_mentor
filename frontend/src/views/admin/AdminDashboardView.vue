<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Admin Dashboard'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Stats Grid -->
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <StatCard
              title="Total Users"
              :value="stats.totalUsers"
              icon="users"
              color="blue"
              trend="+12%"
              trendLabel="from last month"
            />
            <StatCard
              title="Active Mentors"
              :value="stats.activeMentors"
              icon="users"
              color="green"
              trend="+8%"
              trendLabel="from last month"
            />
            <StatCard
              title="Total Sessions"
              :value="stats.totalSessions"
              icon="calendar"
              color="purple"
              trend="+23%"
              trendLabel="from last month"
            />
            <StatCard
              title="Revenue"
              :value="formatCurrency(stats.totalRevenue)"
              icon="currency"
              color="orange"
              trend="+15%"
              trendLabel="from last month"
            />
          </div>

          <!-- Charts / Quick Stats -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <!-- User Growth -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">User Registrations (Last 30 Days)</h3>
              <div class="h-64">
                <canvas ref="userChart" />
              </div>
            </div>

            <!-- Session Stats -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Session Status Distribution</h3>
              <div class="h-64 flex items-center justify-center">
                <canvas ref="sessionChart" />
              </div>
            </div>
          </div>

          <!-- Recent Activity -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Recent Users -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-lg font-semibold text-gray-900">Recent Users</h3>
                <router-link to="/admin/users" class="text-sm text-primary-600 hover:text-primary-500">View all</router-link>
              </div>
              <div class="divide-y divide-gray-100">
                <div v-for="user in recentUsers" :key="user.id" class="px-6 py-4 flex items-center space-x-4">
                  <img :src="user.avatar || defaultAvatar(user.fullName)" :alt="user.fullName" class="h-10 w-10 rounded-full" />
                  <div class="flex-1 min-w-0">
                    <p class="font-medium text-gray-900 truncate">{{ user.fullName }}</p>
                    <p class="text-sm text-gray-500">{{ user.email }}</p>
                  </div>
                  <span class="px-2 py-1 text-xs font-medium rounded-full" :class="getRoleClass(user.role)">
                    {{ formatRole(user.role) }}
                  </span>
                  <span class="px-2 py-1 text-xs font-medium rounded-full" :class="user.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
                    {{ user.isActive ? 'Active' : 'Inactive' }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Recent Bookings -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-lg font-semibold text-gray-900">Recent Bookings</h3>
                <router-link to="/admin/bookings" class="text-sm text-primary-600 hover:text-primary-500">View all</router-link>
              </div>
              <div class="divide-y divide-gray-100">
                <div v-for="booking in recentBookings" :key="booking.id" class="px-6 py-4 flex items-center space-x-4">
                  <div class="flex-1 min-w-0">
                    <p class="font-medium text-gray-900">{{ booking.mentee?.fullName }} → {{ booking.mentor?.fullName }}</p>
                    <p class="text-sm text-gray-500">{{ formatDateTime(booking.createdAt) }}</p>
                  </div>
                  <span class="px-2 py-1 text-xs font-medium rounded-full" :class="getBookingStatusClass(booking.status)">
                    {{ formatStatus(booking.status) }}
                  </span>
                </div>
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
import { Chart, registerables } from 'chart.js'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import StatCard from '@/components/ui/StatCard.vue'
import api from '@/services/api'

Chart.register(...registerables)

interface Stats {
  totalUsers: number
  activeMentors: number
  totalSessions: number
  totalRevenue: number
}

const stats = ref<Stats>({
  totalUsers: 0,
  activeMentors: 0,
  totalSessions: 0,
  totalRevenue: 0,
})

const recentUsers = ref<any[]>([])
const recentBookings = ref<any[]>([])
const userChart = ref<HTMLCanvasElement | null>(null)
const sessionChart = ref<HTMLCanvasElement | null>(null)

const loadStats = async () => {
  try {
    const [statsRes, usersRes, bookingsRes] = await Promise.all([
      api.get('/api/admin/stats'),
      api.get('/api/admin/users', { params: { page: 0, size: 5, sort: 'createdAt,desc' } }),
      api.get('/api/admin/bookings', { params: { page: 0, size: 5, sort: 'createdAt,desc' } }),
    ])

    stats.value = statsRes.data
    recentUsers.value = usersRes.data.content || usersRes.data
    recentBookings.value = bookingsRes.data.content || bookingsRes.data

    // Render charts after data loads
    renderCharts()
  } catch (error) {
    console.error('Failed to load admin stats:', error)
  }
}

const renderCharts = () => {
  // User Growth Chart (mock data for now)
  if (userChart.value) {
    new Chart(userChart.value, {
      type: 'line',
      data: {
        labels: Array.from({ length: 30 }, (_, i) => `Day ${30 - i}`).reverse(),
        datasets: [{
          label: 'New Users',
          data: Array.from({ length: 30 }, () => Math.floor(Math.random() * 10)),
          borderColor: '#0ea5e9',
          backgroundColor: 'rgba(14, 165, 233, 0.1)',
          fill: true,
          tension: 0.4,
        }],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true } },
      },
    })
  }

  // Session Status Chart (mock data)
  if (sessionChart.value) {
    new Chart(sessionChart.value, {
      type: 'doughnut',
      data: {
        labels: ['Completed', 'Confirmed', 'Pending', 'Cancelled'],
        datasets: [{
          data: [45, 30, 15, 10],
          backgroundColor: ['#22c55e', '#0ea5e9', '#eab308', '#ef4444'],
          borderWidth: 0,
        }],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: 'bottom' } },
      },
    })
  }
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDateTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const getRoleClass = (role: string) => {
  switch (role) {
    case 'ADMIN': return 'bg-purple-100 text-purple-800'
    case 'MENTOR': return 'bg-blue-100 text-blue-800'
    case 'MENTEE': return 'bg-green-100 text-green-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatRole = (role: string) => {
  return role.charAt(0) + role.slice(1).toLowerCase()
}

const getBookingStatusClass = (status: string) => {
  switch (status) {
    case 'CONFIRMED': return 'bg-green-100 text-green-800'
    case 'PENDING': return 'bg-yellow-100 text-yellow-800'
    case 'CANCELLED': return 'bg-red-100 text-red-800'
    case 'COMPLETED': return 'bg-gray-100 text-gray-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const formatStatus = (status: string) => {
  return status.charAt(0) + status.slice(1).toLowerCase()
}

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadStats()
})
</script>

<style scoped>
</style>
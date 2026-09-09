<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'User Management'" :showSearch="true" :searchPlaceholder="'Search users...'" :searchQuery="searchQuery" @search="handleSearch" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Filters -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
            <div class="flex flex-wrap items-center gap-4">
              <div class="flex-1 min-w-[180px]">
                <label for="roleFilter" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                <select
                  id="roleFilter"
                  v-model="roleFilter"
                  @change="applyFilters"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">All Roles</option>
                  <option value="ADMIN">Admin</option>
                  <option value="MENTOR">Mentor</option>
                  <option value="MENTEE">Mentee</option>
                </select>
              </div>
              <div class="flex-1 min-w-[180px]">
                <label for="statusFilter" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                <select
                  id="statusFilter"
                  v-model="statusFilter"
                  @change="applyFilters"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">All Status</option>
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>
              <div class="flex-1 min-w-[180px]">
                <label for="verifiedFilter" class="block text-sm font-medium text-gray-700 mb-1">Email Verified</label>
                <select
                  id="verifiedFilter"
                  v-model="verifiedFilter"
                  @change="applyFilters"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">All</option>
                  <option value="true">Verified</option>
                  <option value="false">Not Verified</option>
                </select>
              </div>
              <button @click="clearFilters" class="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm font-medium">
                Clear Filters
              </button>
            </div>
          </div>

          <!-- Users Table -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <!-- Loading -->
            <div v-if="loading" class="p-6 text-center">
              <svg class="animate-spin h-8 w-8 text-primary-600 mx-auto" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
            </div>

            <!-- Table -->
            <div v-else class="overflow-x-auto">
              <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email Verified</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                  <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
                    <td class="px-6 py-4">
                      <div class="flex items-center space-x-3">
                        <img :src="user.avatar || defaultAvatar(user.fullName)" :alt="user.fullName" class="h-10 w-10 rounded-full" />
                        <div>
                          <router-link :to="`/profile/${user.id}`" class="font-medium text-gray-900 hover:text-primary-600">
                            {{ user.fullName }}
                          </router-link>
                          <p class="text-sm text-gray-500">{{ user.email }}</p>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4">
                      <span class="px-2 py-1 text-xs font-medium rounded-full" :class="getRoleClass(user.role)">
                        {{ formatRole(user.role) }}
                      </span>
                    </td>
                    <td class="px-6 py-4">
                      <div class="flex items-center space-x-2">
                        <span class="h-2.5 w-2.5 rounded-full" :class="user.isEmailVerified ? 'bg-green-500' : 'bg-gray-300'"></span>
                        <span class="text-sm text-gray-700">{{ user.isEmailVerified ? 'Verified' : 'Not Verified' }}</span>
                      </div>
                    </td>
                    <td class="px-6 py-4">
                      <span class="px-2 py-1 text-xs font-medium rounded-full" :class="user.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
                        {{ user.isActive ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">
                      {{ formatDate(user.createdAt) }}
                    </td>
                    <td class="px-6 py-4 text-right">
                      <div class="flex items-center justify-end space-x-2">
                        <button
                          @click="toggleUserStatus(user)"
                          :disabled="togglingStatus === user.id"
                          class="px-3 py-1.5 text-xs font-medium rounded-lg transition-colors"
                          :class="user.isActive ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-green-50 text-green-600 hover:bg-green-100'"
                        >
                          <span v-if="togglingStatus === user.id">...</span>
                          <span v-else>{{ user.isActive ? 'Deactivate' : 'Activate' }}</span>
                        </button>
                        <button
                          @click="openRoleModal(user)"
                          class="px-3 py-1.5 text-xs font-medium text-primary-600 hover:text-primary-500"
                        >
                          Change Role
                        </button>
                        <router-link
                          :to="`/profile/${user.id}`"
                          class="px-3 py-1.5 text-xs font-medium text-gray-500 hover:text-gray-700"
                        >
                          View
                        </router-link>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Empty State -->
            <div v-if="users.length === 0 && !loading" class="p-12 text-center">
              <UserCircleIcon class="h-12 w-12 text-gray-300 mx-auto mb-3" />
              <h3 class="text-lg font-medium text-gray-900 mb-1">No users found</h3>
              <p class="text-gray-500">Try adjusting your filters.</p>
            </div>

            <!-- Pagination -->
            <div v-if="totalPages > 1" class="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
              <div class="text-sm text-gray-500">
                Showing {{ (currentPage - 1) * pageSize + 1 }} to {{ Math.min(currentPage * pageSize, totalItems) }} of {{ totalItems }} users
              </div>
              <div class="flex items-center space-x-2">
                <button
                  @click="changePage(currentPage - 1)"
                  :disabled="currentPage === 1"
                  class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <span class="px-3 py-2 text-sm text-gray-700">
                  Page {{ currentPage }} of {{ totalPages }}
                </span>
                <button
                  @click="changePage(currentPage + 1)"
                  :disabled="currentPage === totalPages"
                  class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          </div>

          <!-- Role Change Modal -->
          <Transition name="fade">
            <div v-if="roleModalOpen" class="fixed inset-0 z-50 overflow-y-auto">
              <div class="flex min-h-full items-center justify-center p-4">
                <div class="fixed inset-0 bg-black/50" @click="closeRoleModal" />
                <div class="relative bg-white rounded-xl shadow-xl max-w-md w-full">
                  <div class="px-6 py-4 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900">Change Role for {{ selectedUser?.fullName }}</h3>
                  </div>
                  <div class="p-6 space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">New Role</label>
                      <select
                        v-model="newRole"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      >
                        <option value="ADMIN">Admin</option>
                        <option value="MENTOR">Mentor</option>
                        <option value="MENTEE">Mentee</option>
                      </select>
                    </div>
                    <div class="flex justify-end space-x-3">
                      <button @click="closeRoleModal" class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium">
                        Cancel
                      </button>
                      <button
                        @click="saveRole"
                        :disabled="savingRole"
                        class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium disabled:opacity-50"
                      >
                        <span v-if="savingRole" class="flex items-center space-x-2">
                          <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                          <span>Saving...</span>
                        </span>
                        <span v-else>Save</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </Transition>
        </div>
      </template>
    </Layout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { UserCircleIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

interface User {
  id: number
  fullName: string
  email: string
  role: string
  avatar?: string
  isEmailVerified: boolean
  isActive: boolean
  createdAt: string
}

const users = ref<User[]>([])
const loading = ref(false)
const searchQuery = ref('')
const roleFilter = ref('')
const statusFilter = ref('')
const verifiedFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const totalPages = ref(1)
const totalItems = ref(0)
const debounceTimer = ref<number | null>(null)

const roleModalOpen = ref(false)
const selectedUser = ref<User | null>(null)
const newRole = ref('MENTEE')
const savingRole = ref(false)
const togglingStatus = ref<number | null>(null)

const loadUsers = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      page: currentPage.value - 1,
      size: pageSize.value,
      sort: 'createdAt,desc',
    }
    if (searchQuery.value) params.search = searchQuery.value
    if (roleFilter.value) params.role = roleFilter.value
    if (statusFilter.value) params.isActive = statusFilter.value === 'active'
    if (verifiedFilter.value) params.isEmailVerified = verifiedFilter.value === 'true'

    const response = await api.get('/api/admin/users', { params })
    users.value = response.data.content || response.data
    totalPages.value = response.data.totalPages || 1
    totalItems.value = response.data.totalElements || users.value.length
  } catch (error) {
    console.error('Failed to load users:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = (query: string) => {
  searchQuery.value = query
  if (debounceTimer.value) clearTimeout(debounceTimer.value)
  debounceTimer.value = window.setTimeout(() => {
    currentPage.value = 1
    loadUsers()
  }, 300)
}

const applyFilters = () => {
  currentPage.value = 1
  loadUsers()
}

const clearFilters = () => {
  searchQuery.value = ''
  roleFilter.value = ''
  statusFilter.value = ''
  verifiedFilter.value = ''
  currentPage.value = 1
  loadUsers()
}

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadUsers()
  }
}

const toggleUserStatus = async (user: User) => {
  togglingStatus.value = user.id
  try {
    await api.patch(`/api/admin/users/${user.id}/status`, { isActive: !user.isActive })
    user.isActive = !user.isActive
  } catch (error) {
    console.error('Failed to toggle user status:', error)
  } finally {
    togglingStatus.value = null
  }
}

const openRoleModal = (user: User) => {
  selectedUser.value = user
  newRole.value = user.role
  roleModalOpen.value = true
}

const closeRoleModal = () => {
  roleModalOpen.value = false
  selectedUser.value = null
}

const saveRole = async () => {
  if (!selectedUser.value) return
  savingRole.value = true
  try {
    await api.patch(`/api/admin/users/${selectedUser.value.id}/role`, { role: newRole.value })
    selectedUser.value.role = newRole.value
    closeRoleModal()
  } catch (error) {
    console.error('Failed to change user role:', error)
  } finally {
    savingRole.value = false
  }
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
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

const defaultAvatar = (name: string) => {
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0ea5e9&color=fff&size=64`
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
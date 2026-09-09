<template>
  <div class="min-h-screen bg-gray-50">
    <Layout>
      <template #header>
        <Header :title="'Permission Management'" :showSearch="false" />
      </template>

      <template #content>
        <div class="p-6">
          <!-- Tabs -->
          <div class="mb-6 border-b border-gray-200">
            <nav class="flex space-x-8" aria-label="Tabs">
              <button
                v-for="tab in tabs"
                :key="tab.value"
                @click="activeTab = tab.value"
                class="py-4 px-1 border-b-2 font-medium text-sm transition-colors"
                :class="activeTab === tab.value ? 'border-primary-600 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
              >
                {{ tab.label }}
              </button>
            </nav>
          </div>

          <!-- Roles Tab -->
          <div v-if="activeTab === 'roles'">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="p-6 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-lg font-semibold text-gray-900">Roles</h3>
                <router-link to="/admin/roles/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium text-sm">
                  Create Role
                </router-link>
              </div>
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Permissions</th>
                      <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-100">
                    <tr v-for="role in roles" :key="role.id" class="hover:bg-gray-50">
                      <td class="px-6 py-4">
                        <p class="font-medium text-gray-900">{{ role.name }}</p>
                      </td>
                      <td class="px-6 py-4 text-gray-500">{{ role.description || '—' }}</td>
                      <td class="px-6 py-4">
                        <div class="flex flex-wrap gap-1">
                          <span
                            v-for="perm in role.permissions"
                            :key="perm.id"
                            class="px-2 py-0.5 bg-gray-50 text-gray-600 rounded text-xs"
                          >
                            {{ perm.name }}
                          </span>
                        </div>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div class="flex items-center justify-end space-x-2">
                          <router-link :to="`/admin/roles/${role.id}/edit`" class="px-3 py-1.5 text-xs font-medium text-primary-600 hover:text-primary-500">
                            Edit
                          </router-link>
                          <button
                            v-if="!isSystemRole(role.name)"
                            @click="deleteRole(role.id)"
                            class="px-3 py-1.5 text-xs font-medium text-red-600 hover:text-red-500"
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Permissions Tab -->
          <div v-if="activeTab === 'permissions'">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="p-6 border-b border-gray-200 flex items-center justify-between">
                <h3 class="text-lg font-semibold text-gray-900">Permissions</h3>
                <router-link to="/admin/permissions/create" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-medium text-sm">
                  Create Permission
                </router-link>
              </div>
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Resource</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
                      <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-100">
                    <tr v-for="perm in permissions" :key="perm.id" class="hover:bg-gray-50">
                      <td class="px-6 py-4 font-medium text-gray-900">{{ perm.name }}</td>
                      <td class="px-6 py-4 text-gray-500">{{ perm.description || '—' }}</td>
                      <td class="px-6 py-4">
                        <span class="px-2 py-0.5 bg-blue-50 text-blue-700 rounded text-xs">{{ perm.resource }}</span>
                      </td>
                      <td class="px-6 py-4">
                        <span class="px-2 py-0.5 bg-green-50 text-green-700 rounded text-xs">{{ perm.action }}</span>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div class="flex items-center justify-end space-x-2">
                          <router-link :to="`/admin/permissions/${perm.id}/edit`" class="px-3 py-1.5 text-xs font-medium text-primary-600 hover:text-primary-500">
                            Edit
                          </router-link>
                          <button @click="deletePermission(perm.id)" class="px-3 py-1.5 text-xs font-medium text-red-600 hover:text-red-500">
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- User Permissions Tab -->
          <div v-if="activeTab === 'user-permissions'">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100">
              <div class="p-6 border-b border-gray-200">
                <div class="flex flex-wrap gap-4">
                  <div class="flex-1 min-w-[250px]">
                    <label for="userSearch" class="block text-sm font-medium text-gray-700 mb-1">Search User</label>
                    <input
                      id="userSearch"
                      type="text"
                      v-model="userSearch"
                      @input="debouncedSearchUser"
                      placeholder="Search by name or email..."
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    />
                  </div>
                </div>
              </div>

              <div v-if="selectedUser" class="p-6">
                <div class="flex items-center space-x-4 mb-6">
                  <img :src="selectedUser.avatar || defaultAvatar(selectedUser.fullName)" class="h-12 w-12 rounded-full" />
                  <div>
                    <p class="font-semibold text-gray-900">{{ selectedUser.fullName }}</p>
                    <p class="text-sm text-gray-500">{{ selectedUser.email }}</p>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full" :class="getRoleClass(selectedUser.role)">
                      {{ formatRole(selectedUser.role) }}
                    </span>
                  </div>
                </div>

                <h4 class="text-lg font-semibold text-gray-900 mb-4">Assigned Permissions</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-96 overflow-y-auto">
                  <label v-for="perm in allPermissions" :key="perm.id" class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <input
                      type="checkbox"
                      :checked="hasPermission(perm.id)"
                      @change="toggleUserPermission(perm.id)"
                      class="h-4 w-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                    />
                    <div>
                      <p class="font-medium text-gray-900 text-sm">{{ perm.name }}</p>
                      <p class="text-xs text-gray-500">{{ perm.resource }}:{{ perm.action }}</p>
                    </div>
                  </label>
                </div>
              </div>

              <div v-else class="p-12 text-center">
                <UserCircleIcon class="h-12 w-12 text-gray-300 mx-auto mb-3" />
                <h3 class="text-lg font-medium text-gray-900 mb-1">Select a user</h3>
                <p class="text-gray-500">Search for a user to manage their permissions.</p>
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
import { UserCircleIcon } from '@heroicons/vue/24/outline'
import Layout from '@/components/Layout.vue'
import Header from '@/components/Header.vue'
import api from '@/services/api'

interface Role {
  id: number
  name: string
  description?: string
  permissions: Array<{ id: number; name: string }>
}

interface Permission {
  id: number
  name: string
  description?: string
  resource: string
  action: string
}

interface User {
  id: number
  fullName: string
  email: string
  role: string
  avatar?: string
  permissions: Array<{ id: number }>
}

const activeTab = ref<'roles' | 'permissions' | 'user-permissions'>('roles')
const tabs = [
  { value: 'roles' as const, label: 'Roles' },
  { value: 'permissions' as const, label: 'Permissions' },
  { value: 'user-permissions' as const, label: 'User Permissions' },
]

const roles = ref<Role[]>([])
const permissions = ref<Permission[]>([])
const allPermissions = ref<Permission[]>([])
const selectedUser = ref<User | null>(null)
const userSearch = ref('')
const userSearchResults = ref<User[]>([])
const searchDebounce = ref<number | null>(null)

const loadRoles = async () => {
  try {
    const response = await api.get('/api/admin/roles')
    roles.value = response.data.content || response.data
  } catch (error) {
    console.error('Failed to load roles:', error)
  }
}

const loadPermissions = async () => {
  try {
    const response = await api.get('/api/admin/permissions')
    permissions.value = response.data.content || response.data
    allPermissions.value = permissions.value
  } catch (error) {
    console.error('Failed to load permissions:', error)
  }
}

const searchUser = async (query: string) => {
  if (!query.trim()) {
    userSearchResults.value = []
    return
  }
  try {
    const response = await api.get('/api/admin/users/search', { params: { q: query, size: 10 } })
    userSearchResults.value = response.data.content || response.data
  } catch (error) {
    console.error('Failed to search users:', error)
  }
}

const debouncedSearchUser = () => {
  if (searchDebounce.value) clearTimeout(searchDebounce.value)
  searchDebounce.value = window.setTimeout(() => {
    searchUser(userSearch.value)
  }, 300)
}


const hasPermission = (permId: number) => {
  return selectedUser.value?.permissions.some(p => p.id === permId) || false
}

const toggleUserPermission = async (permId: number) => {
  if (!selectedUser.value) return
  try {
    const hasPerm = hasPermission(permId)
    if (hasPerm) {
      await api.delete(`/api/admin/users/${selectedUser.value.id}/permissions/${permId}`)
    } else {
      await api.post(`/api/admin/users/${selectedUser.value.id}/permissions/${permId}`)
    }
    // Refresh user permissions
    const response = await api.get(`/api/admin/users/${selectedUser.value.id}`)
    selectedUser.value = response.data
  } catch (error) {
    console.error('Failed to toggle user permission:', error)
  }
}

const deleteRole = async (roleId: number) => {
  if (!confirm('Are you sure you want to delete this role?')) return
  try {
    await api.delete(`/api/admin/roles/${roleId}`)
    roles.value = roles.value.filter(r => r.id !== roleId)
  } catch (error) {
    console.error('Failed to delete role:', error)
  }
}

const deletePermission = async (permId: number) => {
  if (!confirm('Are you sure you want to delete this permission?')) return
  try {
    await api.delete(`/api/admin/permissions/${permId}`)
    permissions.value = permissions.value.filter(p => p.id !== permId)
    allPermissions.value = allPermissions.value.filter(p => p.id !== permId)
  } catch (error) {
    console.error('Failed to delete permission:', error)
  }
}

const isSystemRole = (roleName: string) => {
  return ['ADMIN', 'MENTOR', 'MENTEE'].includes(roleName)
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
  loadRoles()
  loadPermissions()
})
</script>

<style scoped>
</style>
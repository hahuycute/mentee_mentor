import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/LoginView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/RegisterView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/verify-email',
    name: 'VerifyEmail',
    component: () => import('@/views/auth/VerifyEmailView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/views/auth/ForgotPasswordView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: () => import('@/views/auth/ResetPasswordView.vue'),
    meta: { guestOnly: true },
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/dashboard/DashboardView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/profile/ProfileView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/profile/:userId',
    name: 'PublicProfile',
    component: () => import('@/views/profile/PublicProfileView.vue'),
  },
  {
    path: '/schedules',
    name: 'Schedules',
    component: () => import('@/views/schedules/ScheduleListView.vue'),
    meta: { requiresAuth: true, roles: ['MENTOR'] },
  },
  {
    path: '/schedules/create',
    name: 'CreateSchedule',
    component: () => import('@/views/schedules/ScheduleFormView.vue'),
    meta: { requiresAuth: true, roles: ['MENTOR'] },
  },
  {
    path: '/schedules/:id',
    name: 'ScheduleDetail',
    component: () => import('@/views/schedules/ScheduleDetailView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/bookings',
    name: 'Bookings',
    component: () => import('@/views/bookings/BookingListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/bookings/:id',
    name: 'BookingDetail',
    component: () => import('@/views/bookings/BookingDetailView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/sessions',
    name: 'Sessions',
    component: () => import('@/views/sessions/SessionListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/sessions/:id',
    name: 'SessionDetail',
    component: () => import('@/views/sessions/SessionDetailView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/feedbacks',
    name: 'Feedbacks',
    component: () => import('@/views/feedbacks/FeedbackListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/feedbacks/create/:bookingId',
    name: 'CreateFeedback',
    component: () => import('@/views/feedbacks/FeedbackFormView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/notifications',
    name: 'Notifications',
    component: () => import('@/views/notifications/NotificationListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/posts',
    name: 'Posts',
    component: () => import('@/views/posts/PostListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/posts/create',
    name: 'CreatePost',
    component: () => import('@/views/posts/PostFormView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/posts/:id',
    name: 'PostDetail',
    component: () => import('@/views/posts/PostDetailView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/topics',
    name: 'Topics',
    component: () => import('@/views/topics/TopicListView.vue'),
    meta: { requiresAuth: true, roles: ['ADMIN'] },
  },
  {
    path: '/mentors',
    name: 'Mentors',
    component: () => import('@/views/mentors/MentorListView.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: () => import('@/views/admin/AdminDashboardView.vue'),
    meta: { requiresAuth: true, roles: ['ADMIN'] },
  },
  {
    path: '/admin/users',
    name: 'AdminUsers',
    component: () => import('@/views/admin/UserManagementView.vue'),
    meta: { requiresAuth: true, roles: ['ADMIN'] },
  },
  {
    path: '/admin/permissions',
    name: 'AdminPermissions',
    component: () => import('@/views/admin/PermissionManagementView.vue'),
    meta: { requiresAuth: true, roles: ['ADMIN'] },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFoundView.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(_to, _from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  },
})

router.beforeEach(async (to, _from, next) => {
  const authStore = useAuthStore()

  // Initialize auth if not already done
  if (!authStore.initialized) {
    await authStore.initialize()
  }

  const isAuthenticated = authStore.isAuthenticated
  const userRole = authStore.user?.role

  // Guest-only routes (login, register, etc.)
  if (to.meta.guestOnly) {
    if (isAuthenticated) {
      return next({ name: 'Dashboard' })
    }
    return next()
  }

  // Protected routes
  if (to.meta.requiresAuth) {
    if (!isAuthenticated) {
      return next({ name: 'Login', query: { redirect: to.fullPath } })
    }

    // Check role permissions
    const allowedRoles = to.meta.roles as string[] | undefined
    if (allowedRoles && userRole && !allowedRoles.includes(userRole)) {
      return next({ name: 'Dashboard' })
    }
  }

  next()
})

export default router
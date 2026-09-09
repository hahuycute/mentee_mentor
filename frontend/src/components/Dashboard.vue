<template>
  <div class="dashboard-container">
    <!-- Header Section -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="header-left">
          <h1>Chào mừng trở lại, <span class="user-name">{{ userDisplayName }}</span></h1>
          <p class="header-subtitle">{{ roleDescription }}</p>
        </div>
        <div class="header-right">
          <div class="user-badge">{{ user.role }}</div>
          <div class="user-status">
            <div class="status-dot"></div>
            <span>Đang hoạt động</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Stats Section -->
    <div class="stats-section">
      <div class="stats-grid">
        <div v-for="stat in stats" :key="stat.label" class="stat-card">
          <div class="stat-header">
            <span class="stat-label">{{ stat.label }}</span>
            <span :class="['stat-change', stat.trend]">{{ stat.change }}</span>
          </div>
          <div class="stat-value">{{ stat.value }}</div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="content-wrapper">
      <!-- Navigation Cards -->
      <div class="navigation-section">
        <h2 class="section-title">Điều hướng</h2>
        <div class="nav-grid">
          <button
            v-for="link in quickLinks"
            :key="link.path"
            class="nav-card"
            @click="navigate(link.path)"
          >
            <h3>{{ link.title }}</h3>
            <p>{{ link.desc }}</p>
          </button>
        </div>
      </div>

      <!-- Info Grid -->
      <div class="info-grid">
        <!-- Account Details -->
        <div class="info-section">
          <h2 class="section-title">Thông tin tài khoản</h2>
          <div class="detail-list">
            <div class="detail-item">
              <span class="detail-label">Mã người dùng</span>
              <span class="detail-value">{{ user.id }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">Email</span>
              <span class="detail-value">{{ user.email }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">Vai trò</span>
              <span class="detail-value detail-role">{{ user.role }}</span>
            </div>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="info-section">
          <h2 class="section-title">Hoạt động gần đây</h2>
          <div class="activity-list">
            <div v-for="(activity, index) in activities" :key="index" class="activity-item">
              <div class="activity-time">{{ activity.time }}</div>
              <div class="activity-text">{{ activity.text }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Mock user data for testing
const user = ref({
  id: 1,
  email: 'test@example.com',
  role: 'MENTOR',
  mentorProfile: {
    fullName: 'Nguyễn Văn A'
  },
  createdAt: new Date().toISOString()
});

const userDisplayName = computed(() => {
  if (user.value.mentorProfile?.fullName) return user.value.mentorProfile.fullName;
  if (user.value.menteeProfile?.fullName) return user.value.menteeProfile.fullName;
  return user.value.email.split('@')[0];
});

const roleDescription = computed(() => {
  switch (user.value.role) {
    case 'MENTOR': return 'Chia sẻ kiến thức và hướng dẫn mentee đạt thành công';
    case 'MENTEE': return 'Học hỏi từ các mentor giàu kinh nghiệm và đạt được mục tiêu';
    default: return 'Chào mừng đến với bảng điều khiển';
  }
});

const quickLinks = [
  { path: '/posts', title: 'Bài viết', desc: 'Đọc và tạo bài viết' },
  { path: '/schedules', title: 'Lịch trình', desc: 'Quản lý thời gian của bạn' },
  { path: '/bookings', title: 'Đặt lịch', desc: 'Xem yêu cầu đặt lịch' },
  { path: '/profile', title: 'Hồ sơ', desc: 'Quản lý hồ sơ của bạn' },
];

const stats = [
  { label: 'Buổi học hoàn thành', value: '12', change: '+2', trend: 'up' },
  { label: 'Đánh giá', value: '4.8', change: '+0.2', trend: 'up' },
  { label: 'Bài viết hoạt động', value: '5', change: '0', trend: 'neutral' },
];

const activities = [
  { time: '2 giờ trước', text: 'Nhận được yêu cầu đặt lịch mới' },
  { time: '5 giờ trước', text: 'Có người đã bình luận bài viết của bạn' },
];

const navigate = (path) => {
  console.log('Navigating to:', path);
  // router.push(path); // Mock navigation
};
</script>

<style scoped>
.dashboard-container {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-name {
  color: #3b82f6;
}

.user-badge {
  background: #3b82f6;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  font-size: 0.875rem;
  font-weight: bold;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
}

.nav-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.nav-card {
  background: white;
  border: 1px solid #e5e7eb;
  padding: 1.5rem;
  border-radius: 8px;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
}

.nav-card:hover {
  border-color: #3b82f6;
  transform: translateY(-2px);
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin-top: 2rem;
}

.info-section {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem 0;
  border-bottom: 1px solid #f3f4f6;
}

.up { color: #10b981; }
.neutral { color: #6b7280; }
</style>

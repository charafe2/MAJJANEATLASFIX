<template>
  <div class="mobile-nav-wrapper">
    <nav class="mobile-nav">

      <!-- Home -->
      <button class="nav-item" :class="{ active: activeTab === 'home' }" @click="go('/client/dashboard', 'home')">
        <div class="nav-icon-wrap" :class="{ 'nav-icon-active': activeTab === 'home' }">
          <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
            <path d="M3 10.5L12 3l9 7.5V20a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-9.5z"
              :stroke="activeTab === 'home' ? '#303030' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M9 21V13h6v8"
              :stroke="activeTab === 'home' ? '#303030' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
      </button>

      <!-- Demandes -->
      <button class="nav-item" :class="{ active: activeTab === 'demandes' }" @click="go('/client/mes-demandes', 'demandes')">
        <div class="nav-icon-wrap" :class="{ 'nav-icon-active': activeTab === 'demandes' }">
          <svg width="24" height="24" fill="none" viewBox="0 0 24 24">
            <rect x="3" y="4" width="18" height="18" rx="2"
              :stroke="activeTab === 'demandes' ? '#FC5A15' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
            <path d="M3 9h18M8 2v4M16 2v4"
              :stroke="activeTab === 'demandes' ? '#FC5A15' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
            <path d="M7 13h2M11 13h2M15 13h2M7 17h2M11 17h2"
              :stroke="activeTab === 'demandes' ? '#FC5A15' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
      </button>

      <!-- Center: New Request with user avatar -->
      <button class="nav-item nav-center-item" @click="go('/client/nouvelle-demande', '')">
        <div class="center-btn">
          <img v-if="userAvatar" :src="userAvatar" alt="" class="center-avatar-img" />
          <span v-else class="center-initials">{{ userInitials }}</span>
          <div class="center-plus-badge">
            <svg width="10" height="10" viewBox="0 0 24 24">
              <path d="M12 5v14M5 12h14" stroke="white" stroke-width="3.5" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
      </button>

      <!-- Messages -->
      <button class="nav-item" :class="{ active: activeTab === 'messages' }" @click="go('/messages', 'messages')">
        <div class="nav-icon-wrap" :class="{ 'nav-icon-active': activeTab === 'messages' }">
          <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
              :stroke="activeTab === 'messages' ? '#303030' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
      </button>

      <!-- Profile -->
      <button class="nav-item" :class="{ active: activeTab === 'profile' }" @click="go('/client/profile', 'profile')">
        <div class="nav-icon-wrap" :class="{ 'nav-icon-active': activeTab === 'profile' }">
          <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
            <circle cx="12" cy="8" r="4"
              :stroke="activeTab === 'profile' ? '#303030' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"
              :stroke="activeTab === 'profile' ? '#303030' : '#ffffff'"
              stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
      </button>

    </nav>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  activeTab: {
    type: String,
    default: '',
  },
})

const router = useRouter()

const user = JSON.parse(localStorage.getItem('user') || 'null')

const userAvatar = computed(() => user?.avatar_url || null)

const userInitials = computed(() => {
  if (!user?.full_name) return '+'
  return user.full_name
    .split(' ')
    .map(w => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

function go(path, tab) {
  router.push(path)
}
</script>

<style scoped>
.mobile-nav-wrapper {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  display: flex;
  justify-content: center;
  padding-bottom: env(safe-area-inset-bottom, 12px);
  padding-bottom: 12px;
  background: linear-gradient(180deg, rgba(255,255,255,0) 0%, #ffffff 60%);
  pointer-events: none;
}

.mobile-nav {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 8px 20px;
  gap: 20px;

  width: 342px;
  height: 60px;

  background: #303030;
  border-radius: 100px;
  pointer-events: all;
}

/* Each nav item */
.nav-item {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  background: none;
  border: none;
  border-radius: 100px;
  cursor: pointer;
  padding: 0;
  transition: background 0.15s;
  flex-shrink: 0;
}

/* Icon wrap - the circle highlight for active */
.nav-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 100px;
  transition: background 0.15s;
}

.nav-icon-active {
  background: #ffffff;
}

/* Center button (new request) */
.nav-center-item {
  flex-shrink: 0;
}

.center-btn {
  position: relative;
  width: 44px;
  height: 44px;
  border-radius: 100px;
  border: 1.5px solid #ffffff;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #4B5563;
}

.center-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 100px;
}

.center-initials {
  font-size: 14px;
  font-weight: 600;
  color: #ffffff;
  font-family: 'Public Sans', sans-serif;
}

.center-plus-badge {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 16px;
  height: 16px;
  background: #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1.5px solid #303030;
}
</style>

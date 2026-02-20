<template>
  <nav class="navbar">
    <div class="wrapper">

      <!-- LEFT — Logo -->
      <div class="logo" @click="$router.push('/Home')">
        Atlas <span>Fix</span>
      </div>

      <!-- CENTER — Nav pill -->
      <ul class="nav-box">
        <li class="nav-item active" @click="$router.push('/Aboutus')">
          À propos
          <div class="nav-glow"></div>
        </li>
        <div class="nav-divider"></div>
        <li class="nav-item" @click="$router.push('/services')">
          Services
          <div class="nav-glow"></div>
        </li>
        <div class="nav-divider"></div>
        <li class="nav-item" @click="$router.push('/contact')">
          Contact
          <div class="nav-glow"></div>
        </li>
        <div class="nav-divider"></div>
        <li class="nav-item" @click="$router.push('/faq')">
          FAQ's
          <div class="nav-glow"></div>
        </li>
      </ul>

      <!-- RIGHT -->
      <div class="right">

        <!-- Bell -->
        <div class="bell">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" fill="#FC5A15"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0" fill="#FC5A15"/>
            <circle cx="18" cy="6" r="3.5" fill="#FC5A15"/>
          </svg>
        </div>

        <!-- Logged OUT -->
        <template v-if="!user">
          <button class="signin"      @click="$router.push('/login')">Log in</button>
          <button class="get-started" @click="$router.push('/register')">Sign Up</button>
        </template>

        <!-- Logged IN -->
        <template v-else>
          <div class="account-menu" ref="menuRef">
            <button class="account-btn" @click="toggleDropdown">
              <div class="avatar">{{ initials }}</div>
              <span class="account-label">Mon compte</span>
              <svg class="chevron" :class="{ open: dropdownOpen }"
                width="12" height="12" viewBox="0 0 12 12" fill="none">
                <path d="M2 4l4 4 4-4" stroke="#314158" stroke-width="1.5"
                  stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>

            <transition name="dropdown">
              <div class="dropdown" v-if="dropdownOpen">
                <ul>
                  <li @click="navigate(user.account_type === 'client' ? '/client/profile' : '/artisan/profile')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
                    Mon profil
                  </li>
                  <li @click="navigate('/payments')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                    Mes paiements
                  </li>
                  <li @click="navigate('/messages')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    Mes messages
                  </li>
                  <li @click="navigate(user.account_type === 'client' ? '/client/mes-demandes' : '/artisan/demandes-clients')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    Toutes les demandes
                  </li>
                  <li @click="navigate(user.account_type === 'client' ? '/client/mes-demandes' : '/artisan/mes-demandes')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                    Mes demandes acceptées
                  </li>
                  <li @click="navigate('/Artisan/agenda')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Agenda
                  </li>
                  <li class="logout-item" @click="logout">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    Se déconnecter
                  </li>
                </ul>
              </div>
            </transition>
          </div>
        </template>

        <!-- Language -->
        <div class="lang">
          <span class="lang-text">FR</span>
          <span class="flag">🇫🇷</span>
          <svg width="7" height="4" viewBox="0 0 7 4" fill="none">
            <path d="M1 1l2.5 2L6 1" stroke="#0047AB" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>

      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router       = useRouter()
const user         = ref(null)
const dropdownOpen = ref(false)
const menuRef      = ref(null)

function loadUser() {
  try {
    const raw = localStorage.getItem('user')
    user.value = raw ? JSON.parse(raw) : null
  } catch {
    user.value = null
  }
}

const initials = computed(() => {
  if (!user.value?.full_name) return '?'
  return user.value.full_name
    .split(' ')
    .slice(0, 2)
    .map(w => w[0].toUpperCase())
    .join('')
})

function toggleDropdown() {
  dropdownOpen.value = !dropdownOpen.value
}

function navigate(path) {
  dropdownOpen.value = false
  router.push(path)
}

function onClickOutside(e) {
  if (menuRef.value && !menuRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
}

function logout() {
  dropdownOpen.value = false
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  user.value = null
  router.push('/login')
}

// Fires when storage changes in another tab
function onStorageChange(e) {
  if (e.key === 'user' || e.key === 'token') loadUser()
}

// Fires when login/register happens in the SAME tab
function onAuthChanged() {
  loadUser()
}

onMounted(() => {
  loadUser()
  window.addEventListener('storage',      onStorageChange)
  window.addEventListener('auth-changed', onAuthChanged)
  document.addEventListener('click',      onClickOutside)
})

onUnmounted(() => {
  window.removeEventListener('storage',      onStorageChange)
  window.removeEventListener('auth-changed', onAuthChanged)
  document.removeEventListener('click',      onClickOutside)
})
</script>

<style scoped>
/* ── NAVBAR ──────────────────────────────────────────────── */
.navbar {
  position: sticky;
  top: 0;
  left: 0;
  width: 100%;
  height: 102px;
background-color: white;
  display: flex;
  align-items: center;

  padding: 25px 97px;
  box-sizing: border-box;

  font-family: 'Poppins', sans-serif;

  z-index: 1000;
  backdrop-filter: blur(1px);
}

.wrapper {
  width: 100%;
  max-width: 1280px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  gap: 160px;
}

/* ── LOGO ─────────────────────────────────────────────────── */
.logo {
  font-weight: 700;
  font-size: 22px;
  cursor: pointer;
  color: #155DFC;
  flex-shrink: 0;
}
.logo span { color: #FC5A15; }

/* ── NAV PILL ─────────────────────────────────────────────── */
.nav-box {
  display: flex;
  align-items: center;
  list-style: none;
  margin: 0;
  padding: 0 6px;
  height: 48px;
  background: rgb(255, 255, 255);
  border: 1px solid #ffffff;
  box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  flex: 1;
  justify-content: center;
  max-width: 560px;
}

.nav-item {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 9px;
  height: 100%;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-size: 16.8px;
  font-weight: 400;
  color: #444444;
  transition: color 0.15s;
  white-space: nowrap;
}

.nav-item.active { color: #000000; }
.nav-item:hover  { color: #FC5A15; }

.nav-glow {
  position: absolute;
  bottom: -14px;
  left: 50%;
  transform: translateX(-50%);
  width: 100px;
  height: 13px;
  opacity: 0;
  filter: blur(7.9px);
  transition: opacity 0.2s;
  pointer-events: none;
}
.nav-item.active .nav-glow,
.nav-item:hover  .nav-glow { opacity: 1; }

.nav-divider {
  width: 1px;
  height: 26px;
  background: #000000;
  opacity: 0.15;
  flex-shrink: 0;
}

/* ── RIGHT ────────────────────────────────────────────────── */
.right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.bell {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
}

.signin {
  background: rgba(255,255,255,0.55);
  border: 1px solid #FC5A15;
  color: #FC5A15;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-size: 14px;
}

.get-started {
  background: #FC5A15;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-size: 14px;
}

/* ── ACCOUNT MENU ─────────────────────────────────────────── */
.account-menu { position: relative; }

.account-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 8px;
  height: 48px;
  background: transparent;
  border: none;
  border-radius: 9999px;
  cursor: pointer;
  font-family: 'Inter', 'Poppins', sans-serif;
  font-size: 16px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.31px;
  transition: background 0.15s;
}
.account-btn:hover { background: rgba(0,0,0,0.04); }

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #FC5A15;
  color: white;
  font-size: 12px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.account-label { white-space: nowrap; }

.chevron {
  transition: transform 0.2s ease;
  flex-shrink: 0;
}
.chevron.open { transform: rotate(180deg); }

/* ── DROPDOWN ─────────────────────────────────────────────── */
.dropdown {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.12), 0 2px 8px rgba(0,0,0,0.06);
  min-width: 220px;
  overflow: hidden;
  z-index: 999;
}

.dropdown ul {
  list-style: none;
  padding: 6px 0;
  margin: 0;
}

.dropdown ul li {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 18px;
  font-family: 'Poppins', sans-serif;
  font-size: 13.5px;
  font-weight: 500;
  color: #393939;
  cursor: pointer;
  transition: background 0.15s;
}
.dropdown ul li:hover     { background: #f7f7f7; }
.dropdown ul li svg       { color: #888; flex-shrink: 0; }
.dropdown ul li:hover svg { color: #FC5A15; }

.logout-item {
  border-top: 1px solid #f0f0f0;
  margin-top: 4px;
  color: #dc2626 !important;
}
.logout-item svg { color: #dc2626 !important; }

/* ── DROPDOWN TRANSITION ──────────────────────────────────── */
.dropdown-enter-active,
.dropdown-leave-active { transition: opacity 0.15s ease, transform 0.15s ease; }
.dropdown-enter-from,
.dropdown-leave-to     { opacity: 0; transform: translateY(-6px); }

/* ── LANGUAGE ─────────────────────────────────────────────── */
.lang {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 4px 11px;
  height: 26px;
  background: rgba(0, 0, 0, 0.03);
  backdrop-filter: blur(25px);
  border-radius: 20px;
  cursor: pointer;
  box-sizing: border-box;
}

.lang-text {
  font-family: 'Cabin', 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 12px;
  color: #444444;
}

.flag { font-size: 14px; line-height: 1; }
</style>
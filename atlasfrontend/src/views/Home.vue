<!-- src/components/HeroSection.vue -->
<template>
  
 <section class="hero">
    <Hero/>
    <services/>
       <published />
       <About/>
       <How/>
       <Temoigne/>
       <Topartisan/>
       <Appdownload/>
       <footer />
  </section>
</template>

<script setup>
import Navbar from '../components/navbar.vue';
import services from "../components/servicesection.vue";
import published from '../components/published.vue';
import About from '../components/About.vue';
import How from '../components/How.vue';
// No logic needed for now — can add later (v-model, search submit, etc.)
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import Howitworks from '../components/Howitworks.vue';
import Temoigne from '../components/temoigne.vue';
import Hero from '../components/Hero.vue';
import Topartisan from '../components/topartisan.vue';
import Appdownload from '../components/Appdownload.vue';
import footer from '../components/footer.vue';
const router = useRouter()
const user   = ref(null)

// ── Read user from localStorage ─────────────────────────────────────────────
function loadUser() {
  try {
    const raw = localStorage.getItem('user')
    user.value = raw ? JSON.parse(raw) : null
  } catch {
    user.value = null
  }
}

// ── First letters of full name for the avatar circle ───────────────────────
const initials = computed(() => {
  if (!user.value?.full_name) return '?'
  return user.value.full_name
    .split(' ')
    .slice(0, 2)
    .map(w => w[0].toUpperCase())
    .join('')
})

// ── Logout ──────────────────────────────────────────────────────────────────
function logout() {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  user.value = null
  router.push('/login')
}

// ── Re-read whenever storage changes (other tab, or after login) ────────────
function onStorageChange(e) {
  if (e.key === 'user' || e.key === 'token') loadUser()
}

onMounted(() => {
  loadUser()
  window.addEventListener('storage', onStorageChange)
})

onUnmounted(() => {
  window.removeEventListener('storage', onStorageChange)
})

</script>

<style scoped>
@import '../assets/css/Home.css';
/* NAVBAR ROOT */
.navbar {
  height: 100px;
  display: flex;
  align-items: center;
  font-family: 'Poppins', sans-serif;
  background-color: #f0eeee;
}

/* MAIN CONTAINER */
.wrapper {
  width: 90%;
  margin: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* LOGO */
.logo {
  font-weight: 700;
  font-size: 22px;
  cursor: pointer;
}
.logo span { color: #FC5A15; }

/* CENTER NAVIGATION */
.nav-box {
  display: flex;
  list-style: none;
  margin-left: 200px;
  padding: 12px 10px;
  background: rgba(255, 255, 255, 0.65);
  border: 1px solid white;
  box-shadow: 0 4px 4px rgba(0,0,0,0.1);
  border-radius: 8px;
}
.nav-box li {
  padding: 0 18px;
  cursor: pointer;
  font-size: 16px;
}
.nav-box li:not(:last-child) {
  border-right: 1px solid #999;
  
}

/* RIGHT */
.right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bell {
  font-size: 20px;
  color: #FC5A15;
}

/* SIGN IN */
.signin {
  background: rgba(255,255,255,0.55);
  border: 1px solid #FC5A15;
  color: #FC5A15;
  padding: 10px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
}

/* GET STARTED */
.get-started {
  background: #FC5A15;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
}

/* ── USER CHIP (avatar + name) ───────────────────────────── */
.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(252, 90, 21, 0.08);
  border: 1px solid rgba(252, 90, 21, 0.2);
  border-radius: 24px;
  padding: 5px 14px 5px 5px;
}

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

.username {
  font-size: 14px;
  font-weight: 600;
  color: #393939;
  white-space: nowrap;
}

/* LOGOUT */
.logout {
  background: transparent;
  border: 1px solid #dc2626;
  color: #dc2626;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  font-family: 'Poppins', sans-serif;
  transition: background 0.15s, color 0.15s;
}
.logout:hover {
  background: #dc2626;
  color: white;
}

/* LANGUAGE */
.lang {
  background: rgba(0,0,0,0.03);
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 14px;
}
</style>
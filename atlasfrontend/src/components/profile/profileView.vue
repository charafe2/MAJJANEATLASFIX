<template>
  <div class="page-wrapper">

    
    <!-- ─── Main ──────────────────────────────────────────────────── -->
    <div class="page-content">
      <div v-if="loading" class="state-box">
        <div class="spinner" /><p>Chargement du profil…</p>
      </div>
      <div v-else-if="error" class="state-box">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
          <circle cx="12" cy="12" r="10" stroke="#EF4444" stroke-width="1.5"/>
          <path d="M12 8v4m0 4h.01" stroke="#EF4444" stroke-width="2" stroke-linecap="round"/>
        </svg>
        <p>{{ error }}</p>
        <button class="btn-retry" @click="fetchProfile">Réessayer</button>
      </div>

      <template v-else>
        <button class="back-btn" @click="goBack">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M12.5 15l-5-5 5-5" stroke="#62748E" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour aux demandes
        </button>
        <!-- Profile Card -->
        <div class="profile-card">
          <div class="profile-top">
            <div class="avatar-ring">
              <img :src="avatarSrc" :alt="client.name" class="avatar-img" />
            </div>
            <div class="profile-info">
              <div class="profile-header-row">
                <div class="name-block">
                  <h1 class="client-name">{{ client.name || '—' }}</h1>
                  <div class="profile-meta">
                    <span class="meta-item">
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                        <path d="M8 1.5A4.5 4.5 0 0 0 3.5 6c0 3.5 4.5 8.5 4.5 8.5S12.5 9.5 12.5 6A4.5 4.5 0 0 0 8 1.5zm0 6a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z" stroke="#FC5A15" stroke-width="1.33" fill="none"/>
                      </svg>
                      {{ client.city || 'Casablanca, Maarif' }}
                    </span>
                    <span class="meta-item">
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                        <rect x="2" y="3" width="12" height="10" rx="1.5" stroke="#FC5A15" stroke-width="1.33"/>
                        <path d="M5 1.5v3M11 1.5v3M2 7h12" stroke="#FC5A15" stroke-width="1.33" stroke-linecap="round"/>
                      </svg>
                      Membre depuis {{ client.memberSince || 'Janvier 2023' }}
                    </span>
                  </div>
                </div>
                <div class="profile-actions">
                  <button class="btn-outline" @click="handleCall">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                      <path d="M3 2h3l1.5 3.5-1.5 1.5s1.5 3 4 4.5l1.5-1.5 3.5 1.5v2.5C14 16 8 17 3.5 12S3 3 3 2z" stroke="#FC5A15" stroke-width="1.33" stroke-linejoin="round" fill="none"/>
                    </svg>
                    Appeler
                  </button>
                  <button class="btn-solid" @click="handleMessage">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                      <rect x="1.33" y="2.67" width="13.33" height="10.67" rx="2" stroke="#fff" stroke-width="1.33"/>
                      <path d="M1.33 5.33L8 9.33l6.67-4" stroke="#fff" stroke-width="1.33" stroke-linecap="round"/>
                    </svg>
                    Message
                  </button>
                  <button class="btn-report" @click="handleReport" title="Signaler">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" fill="rgba(255,255,255,.9)"/>
                      <path d="M12 9v4m0 4h.01" stroke="#FF0000" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                  </button>
                </div>
              </div>
              <div class="stats-row">
                <div class="stat-card stat-blue">
                  <span class="stat-val blue">{{ client.activeRequests ?? 0 }}</span>
                  <span class="stat-lbl">Demandes actives</span>
                </div>
                <div class="stat-card stat-green">
                  <span class="stat-val green">{{ client.completedRequests ?? 0 }}</span>
                  <span class="stat-lbl">Demandes complétées</span>
                </div>
                <div class="stat-card stat-yellow">
                  <div class="stat-val-row">
                    <span class="stat-val yellow">{{ client.avgRating || '—' }}</span>
                    <svg v-if="client.avgRating" width="20" height="20" viewBox="0 0 20 20"><path d="M10 1l2.39 4.83 5.33.78-3.86 3.76.91 5.31L10 13.27l-4.77 2.51.91-5.31L2.28 6.61l5.33-.78L10 1z" fill="#F0B100"/></svg>
                  </div>
                  <span class="stat-lbl">Note moyenne</span>
                </div>
                <div class="stat-card stat-orange">
                  <span class="stat-val orange">{{ client.totalSpent ?? '0 DH' }}</span>
                  <span class="stat-lbl">Total dépensé</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Bottom Grid -->
        <div class="bottom-grid">
          <!-- History -->
          <div class="history-col">
            <h2 class="section-title">Historique des demandes</h2>
            <div v-if="requests.length === 0" class="empty-card">
              <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
                <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2M9 5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2M9 5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2" stroke="#D1D5DC" stroke-width="1.5"/>
              </svg>
              <p>Aucune demande trouvée</p>
            </div>
            <div v-for="req in requests" :key="req.id" class="request-card">
              <div class="req-main">
                <div class="req-left">
                  <div class="req-top-row">
                    <span :class="['badge', badgeClass(req.status)]">
                      <svg v-if="isCompleted(req.status)" width="12" height="12" viewBox="0 0 12 12" fill="none">
                        <path d="M2 6l3 3 5-5" stroke="#00A63E" stroke-width="1.33" stroke-linecap="round"/>
                      </svg>
                      {{ statusLabel(req.status) }}
                    </span>
                    <span class="req-date">{{ formatDate(req.date) }}</span>
                  </div>
                  <h3 class="req-title">{{ req.title }}</h3>
                  <div class="req-cats">
                    <span class="cat-primary">{{ req.category }}</span>
                    <span class="cat-arrow">→</span>
                    <span class="cat-sub">{{ req.subcategory }}</span>
                  </div>
                </div>
                <div v-if="req.rating" class="stars">
                  <span v-for="i in 5" :key="i" :class="['star', i <= req.rating ? 'filled' : 'empty']">★</span>
                </div>
              </div>
              <div class="req-footer">
                <span class="f-label">Artisan:</span>
                <span class="f-name">{{ req.artisan }}</span>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="sidebar">
            <div class="sidebar-card">
              <h3 class="sidebar-title">Coordonnées</h3>
              <div class="contact-list">
                <div class="contact-row">
                  <div class="c-icon c-blue">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                      <path d="M3 2h3l1.5 3.5-1.5 1.5s1.5 3 4 4.5l1.5-1.5 3.5 1.5v2.5C14 16 8 17 3.5 12S3 3 3 2z" stroke="#155DFC" stroke-width="1.67" stroke-linejoin="round" fill="none"/>
                    </svg>
                  </div>
                  <div class="c-text">
                    <span class="c-lbl">Téléphone</span>
                    <span class="c-val">{{ client.phone || '+212 6 12 34 56 78' }}</span>
                  </div>
                </div>
                <div class="contact-row">
                  <div class="c-icon c-purple">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                      <rect x="1.67" y="5" width="16.67" height="11.67" rx="2" stroke="#9810FA" stroke-width="1.67"/>
                      <path d="M1.67 7.5L10 12.5l8.33-5" stroke="#9810FA" stroke-width="1.67" stroke-linecap="round"/>
                    </svg>
                  </div>
                  <div class="c-text">
                    <span class="c-lbl">Email</span>
                    <span class="c-val">{{ client.email || 'client@email.com' }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="reliability-card">
              <div class="rel-header">
                <div class="rel-icon">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M5 12l5 5L20 7" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div>
                  <div class="rel-title">Client fiable</div>
                  <div class="rel-sub">Score de fiabilité</div>
                </div>
              </div>
              <div class="score-row">
                <span class="score-num">{{ client.reliabilityScore ?? 93 }}%</span>
                <span class="score-tag">Excellent</span>
              </div>
              <div class="bar-bg"><div class="bar-fill" :style="{ width: (client.reliabilityScore ?? 93) + '%' }" /></div>
              <ul class="rel-list">
                <li class="rel-item"><svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="#00C950" stroke-width="1.33" stroke-linecap="round"/></svg>Paiements à temps</li>
                <li class="rel-item"><svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="#00C950" stroke-width="1.33" stroke-linecap="round"/></svg>Bonne communication</li>
                <li class="rel-item"><svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="#00C950" stroke-width="1.33" stroke-linecap="round"/></svg>Avis positifs</li>
              </ul>
            </div>
          </div>
        </div>
      </template>
    </div>

    <!-- Toast -->
    <transition name="toast">
      <div v-if="toast.show" :class="['toast', `toast--${toast.type}`]">{{ toast.message }}</div>
    </transition>

   
  </div>
</template>

<script>
/**
 * ClientProfile.vue
 * Backend endpoints consumed:
 *   GET  /clients/:id           → profile
 *   GET  /clients/:id/requests  → history
 *   POST /clients/:id/report    → report
 *
 * Set VITE_API_URL in .env  (defaults to /api)
 * Reads Bearer token from localStorage key "auth_token"
 */
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  withCredentials: true,
})
api.interceptors.request.use(cfg => {
const t = localStorage.getItem('token')
  if (t) cfg.headers.Authorization = `Bearer ${t}`
  return cfg
})
api.interceptors.response.use(
  r => r,
  err => {
    if (err.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

// function normalizeClient(raw) {
//   const u = raw?.user ?? raw?.client ?? raw ?? {}
//   return {
//     id:                u.id,
//     name:              u.name ?? ([u.first_name, u.last_name].filter(Boolean).join(' ') || '—'),
//     email:             u.email,
//     phone:             u.phone ?? u.phone_number,
//     location:          u.city
//       ? `${u.city}${u.neighborhood ? ', ' + u.neighborhood : ''}`
//       : null,
//     memberSince:       u.created_at
//       ? new Date(u.created_at).toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
//       : null,
//     avatar:            u.avatar ?? u.profile_photo_url ?? null,
//     activeRequests:    u.active_requests_count    ?? null,
//     completedRequests: u.completed_requests_count ?? null,
//     avgRating:         u.average_rating            ?? null,
//     totalSpent:        u.total_spent
//       ? `${Number(u.total_spent).toLocaleString('fr-MA')} DH`
//       : null,
//     reliabilityScore:  u.reliability_score ?? null,
//   }
// }

// function normalizeRequests(raw) {
//   const list = Array.isArray(raw) ? raw : raw?.data ?? raw?.requests ?? []
//   return list.map(r => ({
//     id:          r.id,
//     status:      r.status,
//     date:        r.created_at ?? r.date,
//     title:       r.title,
//     category:    r.category?.name ?? r.category,
//     subcategory: r.subcategory?.name ?? r.subcategory ?? r.type,
//     artisan:     r.artisan?.name ?? r.artisan_name ?? '—',
//     rating:      r.rating ?? null,
//   }))
// }

export default {
  name: 'ClientProfile',
  props: { clientId: { type: [String, Number], default: null } },

  setup(props) {
    const route    = useRoute()
    const loading  = ref(true)
    const error    = ref(null)
    const client   = ref({})
    const requests = ref([])
    const toast    = ref({ show: false, message: '', type: 'success' })

    const avatarSrc = computed(() =>
      client.value.avatar ??
      `https://ui-avatars.com/api/?name=${encodeURIComponent(client.value.name || 'U')}&background=FC5A15&color=fff&size=128`
    )

    function notify(message, type = 'success') {
      toast.value = { show: true, message, type }
      setTimeout(() => (toast.value.show = false), 3200)
    }

    async function fetchProfile() {
  loading.value = true
  error.value   = null

  try {
    const clientId = route.params.id

    if (clientId) {
      // ── Artisan viewing a specific client's profile ───────────────────
      const res = await api.get(`/artisan/clients/${clientId}`)
      const d   = res.data.data

      client.value = {
        id:                d.id,
        name:              d.name,
        email:             d.email,
        phone:             d.phone,
        city:              d.city,
        memberSince:       null,
        avatar:            null,
        activeRequests:    d.active_requests    ?? 0,
        completedRequests: d.completed_requests ?? 0,
        avgRating:         '—',
        totalSpent:        d.total_spent
          ? `${Number(d.total_spent).toLocaleString('fr-FR')} DH`
          : '0 DH',
        reliabilityScore: d.reliability_score
          ? Math.round(Number(d.reliability_score))
          : 0,
      }

      requests.value = (d.recent_requests ?? []).map(r => ({
        id:          r.id,
        status:      r.status,
        date:        r.created_at,
        title:       r.title || r.service_type?.name || 'Sans titre',
        category:    r.category?.name    ?? '—',
        subcategory: r.service_type?.name ?? '—',
        artisan:     '—',
        rating:      null,
      }))

    } else {
      // ── Client viewing their own profile ─────────────────────────────
      const [meRes, reqRes] = await Promise.all([
        api.get('/me'),
        api.get('/client/service-requests'),
      ])

      client.value = meRes.data

      const rawReqs = reqRes.data?.data ?? []
      client.value.activeRequests    = rawReqs.filter(r => ['open', 'in_progress'].includes(r.status)).length
      client.value.completedRequests = rawReqs.filter(r => r.status === 'completed').length

      requests.value = rawReqs.map(r => ({
        id:          r.id,
        status:      r.status,
        date:        r.created_at,
        title:       r.title || r.service_type?.name || 'Sans titre',
        category:    r.category?.name    ?? '—',
        subcategory: r.service_type?.name ?? '—',
        artisan:     r.accepted_offer?.artisan?.user?.name ?? '—',
        rating:      null,
      }))
    }

  } catch (e) {
    error.value = e.response?.data?.message ?? e.message ?? 'Une erreur est survenue.'
  } finally {
    loading.value = false
  }
}

function handleCall() {
  client.value.phone
    ? (window.location.href = `tel:${client.value.phone}`)
    : notify('Numéro non disponible.', 'warning')
}

function handleMessage() {
  client.value.email
    ? (window.location.href = `mailto:${client.value.email}`)
    : notify('Email non disponible.', 'warning')
}

async function handleReport() {
  if (!window.confirm('Voulez-vous vraiment signaler ce client ?')) return
  try {
    await api.post(`/users/${client.value.id}/report`, { reason: 'inappropriate_behavior' })
    notify('Signalement envoyé.')
  } catch {
    notify('Erreur lors du signalement.', 'error')
  }
}

function goBack() {
  window.history.length > 1 ? window.history.back() : (window.location.href = '/')
}

function formatDate(d) {
  return d
    ? new Date(d).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
    : '—'
}

function isCompleted(s) {
  return s === 'completed' || s === 'Complétée'
}

function badgeClass(s) {
  if (s === 'active'    || s === 'in_progress' || s === 'En cours') return 'badge-active'
  if (s === 'completed' || s === 'Complétée')                       return 'badge-completed'
  if (s === 'cancelled' || s === 'Annulée')                         return 'badge-cancelled'
  return 'badge-pending'
}

function statusLabel(s) {
  return {
    pending:     'En attente',
    active:      'En cours',
    in_progress: 'En cours',
    completed:   'Complétée',
    cancelled:   'Annulée',
  }[s] ?? s
}

onMounted(fetchProfile)

return {
  loading, error, client, requests, toast, avatarSrc,
  fetchProfile, handleCall, handleMessage, handleReport, goBack,
  formatDate, isCompleted, badgeClass, statusLabel,
}
}};
</script>

<style scoped>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
.page-wrapper { min-height: 100vh; font-family: 'Inter', system-ui, sans-serif; background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 60%); color: #314158; }
.navbar { position: sticky; top: 0; z-index: 50; background: #fff; box-shadow: 0 1px 0 #F3F4F6, 0 2px 8px rgba(0,0,0,.06); height: 72px; padding: 0 80px; }
.navbar-inner { height: 100%; display: flex; align-items: center; gap: 32px; }
.logo { font-size: 22px; font-weight: 700; letter-spacing: -.5px; flex-shrink: 0; }
.logo-blue { color: #155DFC; } .logo-orange { color: #FC5A15; }
.nav-links { flex: 0 1 520px; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,.5); border: 1px solid #fff; box-shadow: 0 4px 4px rgba(0,0,0,.08); border-radius: 8px; height: 44px; margin: 0 auto; }
.nav-item { padding: 0 18px; font-family: 'Poppins', sans-serif; font-size: 15px; color: #444; cursor: pointer; user-select: none; transition: color .15s; }
.nav-item:hover { color: #FC5A15; } .nav-item.active { color: #000; font-weight: 600; }
.nav-divider { width: 1px; height: 20px; background: rgba(0,0,0,.12); }
.nav-actions { display: flex; align-items: center; gap: 12px; margin-left: auto; }
.bell-icon { cursor: pointer; display: flex; align-items: center; padding: 6px; border-radius: 8px; transition: background .15s; }
.bell-icon:hover { background: #f3f4f6; }
.account-btn { display: flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 9999px; cursor: pointer; font-size: 15px; color: #314158; transition: background .15s; }
.account-btn:hover { background: #f3f4f6; }
.account-avatar { width: 32px; height: 32px; background: #FC5A15; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.lang-switch { display: flex; align-items: center; gap: 5px; background: rgba(0,0,0,.04); border-radius: 20px; padding: 5px 12px; font-size: 12px; font-weight: 500; color: #444; cursor: pointer; }
.page-content { max-width: 1248px; margin: 0 auto; padding: 32px 24px 64px; }
.state-box { min-height: 380px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 16px; color: #62748E; font-size: 16px; }
.spinner { width: 44px; height: 44px; border: 3px solid #f3f4f6; border-top-color: #FC5A15; border-radius: 50%; animation: spin .75s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.btn-retry { padding: 9px 28px; background: #FC5A15; color: #fff; border: none; border-radius: 10px; font-size: 14px; cursor: pointer; font-family: inherit; transition: opacity .2s; }
.btn-retry:hover { opacity: .85; }
.back-btn { display: inline-flex; align-items: center; gap: 8px; background: none; border: none; color: #62748E; font-size: 15px; cursor: pointer; margin-bottom: 20px; padding: 4px 8px; border-radius: 8px; font-family: inherit; transition: color .15s, background .15s; }
.back-btn:hover { color: #FC5A15; background: rgba(252,90,21,.06); }
.profile-card { background: #fff; border: 1px solid #F3F4F6; box-shadow: 0 4px 12px rgba(0,0,0,.09); border-radius: 16px; padding: 33px; margin-bottom: 24px; }
.profile-top { display: flex; gap: 24px; align-items: flex-start; }
.avatar-ring { flex-shrink: 0; width: 128px; height: 128px; border-radius: 50%; border: 3px solid #FC5A15; overflow: hidden; background: #f3f4f6; }
.avatar-img { width: 100%; height: 100%; object-fit: cover; display: block; }
.profile-info { flex: 1; display: flex; flex-direction: column; gap: 20px; }
.profile-header-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; }
.name-block { display: flex; flex-direction: column; gap: 8px; }
.client-name { font-size: 30px; font-weight: 400; line-height: 1.2; color: #314158; }
.profile-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
.meta-item { display: flex; align-items: center; gap: 6px; font-size: 15px; color: #62748E; }
.profile-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.btn-outline { display: flex; align-items: center; gap: 8px; padding: 0 16px; height: 40px; background: #fff; border: 2px solid #FC5A15; border-radius: 14px; color: #FC5A15; font-size: 14px; font-family: inherit; cursor: pointer; transition: background .15s; }
.btn-outline:hover { background: #fff7ed; }
.btn-solid { display: flex; align-items: center; gap: 8px; padding: 0 16px; height: 40px; background: #FC5A15; border: none; border-radius: 14px; color: #fff; font-size: 14px; font-family: inherit; cursor: pointer; transition: opacity .15s; }
.btn-solid:hover { opacity: .88; }
.btn-report { width: 40px; height: 40px; background: #FF0000; border: none; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: opacity .15s; }
.btn-report:hover { opacity: .82; }
.stats-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; }
.stat-card { border-radius: 14px; padding: 16px 17px 12px; display: flex; flex-direction: column; gap: 4px; }
.stat-blue { background: #EFF6FF; border: 1px solid #DBEAFE; } .stat-green { background: #F0FDF4; border: 1px solid #DCFCE7; }
.stat-yellow { background: #FEFCE8; border: 1px solid #FEF9C2; } .stat-orange { background: #FFF7ED; border: 1px solid #FFEDD4; }
.stat-val { font-size: 24px; line-height: 32px; } .stat-val-row { display: flex; align-items: center; gap: 4px; }
.blue { color: #155DFC; } .green { color: #00A63E; } .yellow { color: #D08700; } .orange { color: #FC5A15; }
.stat-lbl { font-size: 12px; color: #62748E; }
.bottom-grid { display: grid; grid-template-columns: 1fr 400px; gap: 24px; align-items: start; }
.history-col { display: flex; flex-direction: column; gap: 16px; }
.section-title { font-size: 24px; font-weight: 400; color: #314158; }
.empty-card { background: #fff; border: 1px solid #E5E7EB; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; padding: 48px; color: #62748E; font-size: 15px; }
.request-card { background: #fff; border: 1px solid #E5E7EB; border-radius: 14px; padding: 21px 21px 0; display: flex; flex-direction: column; gap: 12px; transition: box-shadow .2s, transform .15s; }
.request-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,.09); transform: translateY(-1px); }
.req-main { display: flex; justify-content: space-between; align-items: flex-start; }
.req-left { display: flex; flex-direction: column; gap: 8px; flex: 1; }
.req-top-row { display: flex; align-items: center; gap: 8px; }
.badge { display: inline-flex; align-items: center; gap: 5px; height: 24px; padding: 0 10px; border-radius: 9999px; font-size: 12px; font-weight: 500; }
.badge-active { background: #DBEAFE; color: #155DFC; } .badge-completed { background: #DCFCE7; color: #00A63E; }
.badge-pending { background: #FEF9C2; color: #A16207; } .badge-cancelled { background: #FEE2E2; color: #DC2626; }
.req-date { font-size: 14px; color: #62748E; } .req-title { font-size: 16px; color: #314158; }
.req-cats { display: flex; align-items: center; gap: 8px; font-size: 14px; }
.cat-primary { color: #FC5A15; } .cat-arrow { color: #D1D5DC; } .cat-sub { color: #62748E; }
.stars { display: flex; gap: 2px; } .star { font-size: 18px; }
.star.filled { color: #F0B100; } .star.empty { color: #D1D5DC; }
.req-footer { border-top: 1px solid #F3F4F6; padding: 8px 0 12px; display: flex; align-items: center; gap: 8px; font-size: 14px; }
.f-label { color: #62748E; } .f-name { color: #314158; font-weight: 500; }
.sidebar { display: flex; flex-direction: column; gap: 24px; }
.sidebar-card { background: #fff; border: 1px solid #F3F4F6; border-radius: 14px; padding: 25px; display: flex; flex-direction: column; gap: 16px; }
.sidebar-title { font-size: 20px; font-weight: 400; color: #314158; }
.contact-list { display: flex; flex-direction: column; gap: 16px; }
.contact-row { display: flex; align-items: center; gap: 12px; }
.c-icon { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.c-blue { background: #DBEAFE; } .c-purple { background: #F3E8FF; }
.c-text { display: flex; flex-direction: column; } .c-lbl { font-size: 12px; color: #62748E; } .c-val { font-size: 16px; color: #314158; }
.reliability-card { background: linear-gradient(135deg, #F0FDF4 0%, #ECFDF5 100%); border: 1px solid #B9F8CF; border-radius: 14px; padding: 25px; display: flex; flex-direction: column; gap: 14px; }
.rel-header { display: flex; align-items: center; gap: 12px; }
.rel-icon { width: 48px; height: 48px; background: #00C950; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.rel-title { font-size: 16px; color: #314158; font-weight: 500; } .rel-sub { font-size: 14px; color: #62748E; }
.score-row { display: flex; align-items: baseline; gap: 10px; }
.score-num { font-size: 30px; color: #00A63E; font-weight: 400; } .score-tag { font-size: 14px; color: #62748E; }
.bar-bg { height: 8px; background: #B9F8CF; border-radius: 9999px; overflow: hidden; }
.bar-fill { height: 100%; background: #00C950; border-radius: 9999px; transition: width .7s ease; }
.rel-list { list-style: none; display: flex; flex-direction: column; gap: 8px; }
.rel-item { display: flex; align-items: center; gap: 8px; font-size: 14px; color: #62748E; }
.toast { position: fixed; bottom: 28px; right: 28px; padding: 14px 22px; border-radius: 12px; font-size: 14px; color: #fff; z-index: 9999; box-shadow: 0 4px 24px rgba(0,0,0,.16); pointer-events: none; }
.toast--success { background: #00A63E; } .toast--error { background: #EF4444; } .toast--warning { background: #F59E0B; }
.toast-enter-active, .toast-leave-active { transition: all .3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(10px); }
.footer { background: rgba(0,0,0,.84); color: #fff; padding: 45px 98px 0; }
.footer-inner { display: flex; gap: 64px; padding-bottom: 32px; }
.footer-brand { max-width: 326px; } .f-logo { font-size: 22px; font-weight: 700; margin-bottom: 16px; }
.f-desc { font-size: 15px; color: #99A1AF; line-height: 1.6; }
.footer-cols { display: flex; gap: 44px; flex: 1; justify-content: flex-end; }
.f-col { display: flex; flex-direction: column; gap: 14px; }
.f-col a { color: #99A1AF; font-size: 15px; text-decoration: none; transition: color .15s; white-space: nowrap; }
.f-col a:first-child { color: #fff; font-weight: 500; } .f-col a:hover { color: #FC5A15; }
.footer-bottom { border-top: 1px solid rgba(255,255,255,.18); display: flex; justify-content: space-between; padding: 16px 0; font-size: 15px; }
@media (max-width: 1100px) { .bottom-grid { grid-template-columns: 1fr; } .stats-row { grid-template-columns: repeat(2,1fr); } }
@media (max-width: 768px) { .navbar { padding: 0 16px; } .nav-links, .lang-switch { display: none; } .page-content { padding: 20px 16px 40px; } .profile-top { flex-direction: column; } .profile-header-row { flex-direction: column; } .footer { padding: 32px 24px 0; } .footer-inner { flex-direction: column; gap: 32px; } .footer-cols { flex-direction: column; } }</style>
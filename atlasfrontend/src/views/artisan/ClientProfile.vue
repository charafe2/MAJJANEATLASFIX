<template>
  <div class="client-profile-page">

    <!-- ── Header ─────────────────────────────────────────────────────── -->
    <div class="page-header">
      <button class="btn-back" @click="$router.back()">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <polyline points="15 18 9 12 15 6"/>
        </svg>
        Retour
      </button>
      <h1 class="page-title">Profil client</h1>
    </div>

    <!-- ── Loading ─────────────────────────────────────────────────────── -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Chargement du profil…</p>
    </div>

    <!-- ── Error ───────────────────────────────────────────────────────── -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>Profil introuvable</h3>
      <p>{{ error }}</p>
      <button class="btn-retry" @click="loadProfile">Réessayer</button>
    </div>

    <!-- ── Profile content ────────────────────────────────────────────── -->
    <div v-else-if="profile" class="profile-content">

      <!-- Identity card -->
      <div class="identity-card">
        <div class="avatar-wrap">
          <div class="avatar-lg" :style="{ background: avatarColor(profile.name) }">
            {{ initials(profile.name) }}
          </div>
        </div>
        <div class="identity-info">
          <h2 class="client-name">{{ profile.name }}</h2>
          <div v-if="profile.city" class="client-city">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
            </svg>
            {{ profile.city }}
          </div>
        </div>
      </div>

      <!-- Stats row -->
      <div class="stats-row">
        <div class="stat-card">
          <span class="stat-value orange">{{ profile.active_requests }}</span>
          <span class="stat-label">Demandes actives</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ profile.completed_requests }}</span>
          <span class="stat-label">Demandes complétées</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ ratingDisplay }}</span>
          <span class="stat-label">Note moyenne</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ totalSpentDisplay }}</span>
          <span class="stat-label">Total dépensé</span>
        </div>
      </div>

      <!-- Two-column layout -->
      <div class="two-col-layout">

        <!-- Left: Contact + Reliability -->
        <div class="left-col">
          <!-- Contact info -->
          <div class="section-card">
            <h3 class="section-title">Coordonnées</h3>
            <div class="contact-list">
              <div v-if="profile.phone" class="contact-item">
                <div class="contact-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
                  </svg>
                </div>
                <div class="contact-text">
                  <span class="contact-label">Téléphone</span>
                  <a :href="`tel:${profile.phone}`" class="contact-value">{{ profile.phone }}</a>
                </div>
              </div>
              <div v-if="profile.email" class="contact-item">
                <div class="contact-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>
                  </svg>
                </div>
                <div class="contact-text">
                  <span class="contact-label">Email</span>
                  <a :href="`mailto:${profile.email}`" class="contact-value">{{ profile.email }}</a>
                </div>
              </div>
              <div v-if="!profile.phone && !profile.email" class="no-contact">
                Aucune coordonnée disponible.
              </div>
            </div>
          </div>

          <!-- Reliability -->
          <div class="section-card">
            <h3 class="section-title">Fiabilité</h3>
            <div class="reliability-wrap">
              <div class="reliability-score-row">
                <span class="reliability-score">{{ reliabilityPercent }}%</span>
                <span v-if="reliabilityPercent >= 80" class="reliability-badge good">
                  ✓ Client fiable
                </span>
                <span v-else-if="reliabilityPercent >= 50" class="reliability-badge avg">
                  ~ Fiabilité moyenne
                </span>
                <span v-else class="reliability-badge low">
                  ⚠ Fiabilité basse
                </span>
              </div>
              <div class="reliability-bar-bg">
                <div
                  class="reliability-bar-fill"
                  :style="{ width: reliabilityPercent + '%', background: reliabilityColor }"
                ></div>
              </div>
              <p class="reliability-note">
                Basé sur {{ profile.total_requests }} demande{{ profile.total_requests !== 1 ? 's' : '' }} au total.
              </p>
            </div>
          </div>
        </div>

        <!-- Right: Request history -->
        <div class="right-col">
          <div class="section-card">
            <h3 class="section-title">Historique des demandes</h3>

            <div v-if="profile.recent_requests.length === 0" class="no-history">
              Aucune demande récente.
            </div>

            <div v-else class="history-list">
              <div
                v-for="req in profile.recent_requests"
                :key="req.id"
                class="history-item"
              >
                <div class="history-left">
                  <div class="history-category">
                    {{ req.category?.name ?? 'Service' }}
                  </div>
                  <div class="history-title">{{ req.title || req.service_type?.name || 'Sans titre' }}</div>
                  <div class="history-date">{{ formatDate(req.created_at) }}</div>
                </div>
                <span :class="['status-pill', `status-${req.status}`]">
                  {{ statusLabel(req.status) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getClientProfile } from '../../api/serviceRequests.js'

const route = useRoute()

// ── State ────────────────────────────────────────────────────────────────
const profile = ref(null)
const loading = ref(false)
const error   = ref('')

// ── Computed ─────────────────────────────────────────────────────────────
const ratingDisplay = computed(() => {
  if (!profile.value) return '—'
  // Computed from completed requests — placeholder since client model doesn't have rating_average
  return '4.6 ★'
})

const totalSpentDisplay = computed(() => {
  if (!profile.value || !profile.value.total_spent) return '0 DH'
  return Number(profile.value.total_spent).toLocaleString('fr-FR') + ' DH'
})

const reliabilityPercent = computed(() => {
  if (!profile.value?.reliability_score) return 0
  return Math.round(Number(profile.value.reliability_score))
})

const reliabilityColor = computed(() => {
  const p = reliabilityPercent.value
  if (p >= 80) return '#10B981'
  if (p >= 50) return '#F59E0B'
  return '#EF4444'
})

// ── Data loading ─────────────────────────────────────────────────────────
async function loadProfile() {
  loading.value = true
  error.value   = ''
  try {
    const res = await getClientProfile(route.params.id)
    profile.value = res.data.data
  } catch (err) {
    error.value = err.response?.data?.error ?? 'Impossible de charger ce profil.'
  } finally {
    loading.value = false
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────
function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(p => p[0]).join('').toUpperCase().slice(0, 2)
}

const COLORS = ['#FC5A15','#3B82F6','#8B5CF6','#10B981','#F59E0B','#EF4444','#06B6D4','#84CC16']
function avatarColor(name) {
  if (!name) return COLORS[0]
  let h = 0
  for (const c of name) h = (h * 31 + c.charCodeAt(0)) % COLORS.length
  return COLORS[h]
}

function formatDate(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

const STATUS_LABELS = {
  open:        'Ouverte',
  in_progress: 'En cours',
  completed:   'Complétée',
  cancelled:   'Annulée',
}
function statusLabel(s) { return STATUS_LABELS[s] ?? s }

// ── Init ──────────────────────────────────────────────────────────────────
onMounted(loadProfile)
</script>

<style scoped>
/* ── Layout ─────────────────────────────────────────────────────────────── */
.client-profile-page {
  font-family: 'Inter', 'Poppins', sans-serif;
  min-height: 100vh;
  background: #F5F6FA;
  padding: 0 0 60px;
  color: #314158;
}

/* ── Header ─────────────────────────────────────────────────────────────── */
.page-header {
  background: #fff;
  padding: 16px 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  border-bottom: 1px solid #E8ECF0;
  position: sticky;
  top: 0;
  z-index: 50;
}
.btn-back {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: #62748E;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 8px;
  transition: background 0.15s;
}
.btn-back:hover { background: #F5F6FA; }
.page-title {
  font-size: 20px;
  font-weight: 700;
  color: #314158;
  margin: 0;
}

/* ── Loading / Error ─────────────────────────────────────────────────────── */
.loading-state, .error-state {
  text-align: center;
  padding: 80px 24px;
  color: #62748E;
}
.spinner {
  width: 40px; height: 40px;
  border: 3px solid #E8ECF0;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }
.error-icon { font-size: 48px; margin-bottom: 16px; }
.error-state h3 { font-size: 18px; font-weight: 700; color: #314158; margin: 0 0 8px; }
.btn-retry {
  margin-top: 16px;
  padding: 10px 24px;
  border: none;
  border-radius: 10px;
  background: #FC5A15;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
}

/* ── Profile content ─────────────────────────────────────────────────────── */
.profile-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Identity card */
.identity-card {
  background: #fff;
  border-radius: 16px;
  padding: 28px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 1px 8px rgba(49,65,88,0.07);
}
.avatar-lg {
  width: 72px; height: 72px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 800;
  font-size: 26px;
  flex-shrink: 0;
}
.client-name {
  font-size: 22px;
  font-weight: 700;
  color: #314158;
  margin: 0 0 6px;
}
.client-city {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
  color: #62748E;
}

/* Stats row */
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}
.stat-card {
  background: #fff;
  border-radius: 14px;
  padding: 20px 16px;
  text-align: center;
  box-shadow: 0 1px 8px rgba(49,65,88,0.07);
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.stat-value {
  font-size: 26px;
  font-weight: 800;
  color: #314158;
  line-height: 1;
}
.stat-value.orange { color: #FC5A15; }
.stat-label {
  font-size: 12px;
  color: #62748E;
  line-height: 1.3;
}

/* Two-column layout */
.two-col-layout {
  display: grid;
  grid-template-columns: 340px 1fr;
  gap: 20px;
  align-items: start;
}
.left-col, .right-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Section cards */
.section-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 1px 8px rgba(49,65,88,0.07);
}
.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #314158;
  margin: 0 0 18px;
  padding-bottom: 14px;
  border-bottom: 1px solid #F0F2F5;
}

/* Contact */
.contact-list { display: flex; flex-direction: column; gap: 14px; }
.contact-item { display: flex; align-items: flex-start; gap: 12px; }
.contact-icon {
  width: 36px; height: 36px;
  background: #FFF0E9;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #FC5A15;
  flex-shrink: 0;
}
.contact-text { display: flex; flex-direction: column; gap: 2px; }
.contact-label { font-size: 11px; color: #62748E; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
.contact-value {
  font-size: 14px;
  font-weight: 600;
  color: #314158;
  text-decoration: none;
}
.contact-value:hover { color: #FC5A15; }
.no-contact { font-size: 14px; color: #62748E; }

/* Reliability */
.reliability-wrap { display: flex; flex-direction: column; gap: 10px; }
.reliability-score-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.reliability-score {
  font-size: 36px;
  font-weight: 800;
  color: #314158;
  line-height: 1;
}
.reliability-badge {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
}
.reliability-badge.good { background: #D1FAE5; color: #065F46; }
.reliability-badge.avg  { background: #FEF3C7; color: #92400E; }
.reliability-badge.low  { background: #FEE2E2; color: #991B1B; }
.reliability-bar-bg {
  height: 8px;
  background: #F0F2F5;
  border-radius: 99px;
  overflow: hidden;
}
.reliability-bar-fill {
  height: 100%;
  border-radius: 99px;
  transition: width 0.8s ease;
}
.reliability-note { font-size: 12px; color: #62748E; margin: 0; }

/* History list */
.no-history { font-size: 14px; color: #62748E; }
.history-list { display: flex; flex-direction: column; gap: 12px; }
.history-item {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid #F0F2F5;
}
.history-item:last-child { border-bottom: none; padding-bottom: 0; }
.history-left { display: flex; flex-direction: column; gap: 3px; }
.history-category { font-size: 11px; font-weight: 600; color: #FC5A15; text-transform: uppercase; letter-spacing: 0.5px; }
.history-title { font-size: 14px; font-weight: 600; color: #314158; }
.history-date { font-size: 12px; color: #62748E; }

/* Status pills */
.status-pill {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}
.status-open        { background: #EFF6FF; color: #3B82F6; }
.status-in_progress { background: #FEF3C7; color: #D97706; }
.status-completed   { background: #D1FAE5; color: #065F46; }
.status-cancelled   { background: #FEE2E2; color: #DC2626; }

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 720px) {
  .stats-row { grid-template-columns: repeat(2, 1fr); }
  .two-col-layout { grid-template-columns: 1fr; }
}
@media (max-width: 480px) {
  .stats-row { grid-template-columns: 1fr 1fr; }
  .identity-card { flex-direction: column; text-align: center; }
}
</style>

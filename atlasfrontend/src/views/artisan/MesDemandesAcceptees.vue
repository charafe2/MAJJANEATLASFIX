<template>
  <div class="mes-demandes-page">

    <!-- ── Header ─────────────────────────────────────────────────────── -->
    <div class="page-header">
      <div class="header-top">
        <button class="btn-back" @click="$router.back()">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
          Retour
        </button>
      </div>
      <div class="header-body">
        <div>
          <h1 class="page-title">Mes demandes acceptées</h1>
          <p class="page-subtitle">Gérez les demandes que vous avez acceptées</p>
        </div>
      </div>

      <!-- Tabs -->
      <div class="tabs-row">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          :class="['tab-btn', activeTab === tab.key && 'active']"
          @click="switchTab(tab.key)"
        >
          {{ tab.label }} ({{ tab.count }})
        </button>
      </div>
    </div>

    <!-- ── Loading ─────────────────────────────────────────────────────── -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Chargement de vos demandes…</p>
    </div>

    <!-- ── Empty state ─────────────────────────────────────────────────── -->
    <div v-else-if="filtered.length === 0" class="empty-state">
      <div class="empty-icon">📋</div>
      <h3>Aucune demande</h3>
      <p>Vous n'avez pas encore de demandes dans cette catégorie.</p>
    </div>

    <!-- ── Offer cards ────────────────────────────────────────────────── -->
    <div v-else class="cards-list">
      <div v-for="offer in filtered" :key="offer.id" class="offer-card">

        <!-- Card top: avatar + meta + status badge -->
        <div class="card-top">
          <div class="client-avatar" :style="{ background: avatarColor(offer.service_request?.client?.user?.name) }">
            {{ initials(offer.service_request?.client?.user?.name) }}
          </div>
          <div class="client-meta">
            <span class="client-name">{{ offer.service_request?.client?.user?.name ?? 'Client' }}</span>
            <span class="meta-sep">·</span>
            <span class="time-ago">{{ offerTimeLabel(offer) }}</span>
          </div>
          <span :class="['status-badge', offerStatusKey(offer)]">
            <svg v-if="offerStatusKey(offer) === 'confirmed'" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
            <svg v-else-if="offerStatusKey(offer) === 'pending'" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
            </svg>
            <svg v-else-if="offerStatusKey(offer) === 'completed'" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
            {{ offerStatusLabel(offer) }}
          </span>
        </div>

        <!-- Category strip -->
        <div class="category-strip">
          <span class="cat-name">{{ offer.service_request?.category?.name }}</span>
          <span class="cat-sep">•</span>
          <span class="cat-service">{{ offer.service_request?.service_type?.name }}</span>
        </div>

        <!-- Request title -->
        <h3 class="req-title">
          {{ offer.service_request?.title || offer.service_request?.service_type?.name || 'Sans titre' }}
        </h3>

        <!-- Info row: location · date · duration -->
        <div class="info-row">
          <div class="info-item">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
              <circle cx="12" cy="10" r="3"/>
            </svg>
            {{ offer.service_request?.city ?? '—' }}
          </div>
          <div class="info-item">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
              <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
              <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            {{ formatDate(offer.service_request?.created_at) }}
          </div>
          <div class="info-item">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
            </svg>
            Durée : {{ formatDuration(offer.estimated_duration) }}
          </div>
        </div>

        <!-- "Votre proposition" green box -->
        <div class="proposition-box">
          <p class="prop-label">Votre proposition</p>
          <div class="prop-values">
            <div class="prop-price">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="1" x2="12" y2="23"/>
                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
              </svg>
              <span>{{ Number(offer.proposed_price).toLocaleString('fr-FR') }} DH</span>
            </div>
            <div class="prop-duration">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
              </svg>
              <span>{{ formatDuration(offer.estimated_duration) }}</span>
            </div>
          </div>
        </div>

        <!-- Action buttons -->
        <div class="card-actions">
          <button class="btn-contact" @click="contactClient(offer)">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
            </svg>
            Contacter le client
          </button>
          <button
            v-if="offerStatusKey(offer) !== 'pending'"
            class="btn-profile"
            @click="router.push(`/artisan/demandes/${offer.service_request?.id}`)"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
            </svg>
            Voir les détails
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMyOffers } from '../../api/serviceRequests.js'
import { getOrCreateConversation } from '../../api/messages.js'

const router = useRouter()

// ── State ────────────────────────────────────────────────────────────────
const allOffers  = ref([])
const loading    = ref(false)
const activeTab  = ref('all')

// ── Computed helpers ─────────────────────────────────────────────────────
function offerStatusKey(offer) {
  if (offer.status === 'accepted') {
    return offer.service_request?.status === 'completed' ? 'completed' : 'confirmed'
  }
  return 'pending'
}

const filtered = computed(() => {
  switch (activeTab.value) {
    case 'pending':   return allOffers.value.filter(o => offerStatusKey(o) === 'pending')
    case 'confirmed': return allOffers.value.filter(o => offerStatusKey(o) === 'confirmed')
    case 'completed': return allOffers.value.filter(o => offerStatusKey(o) === 'completed')
    default:          return allOffers.value
  }
})

const tabs = computed(() => [
  { key: 'all',       label: 'Tous',      count: allOffers.value.length },
  { key: 'pending',   label: 'En attente', count: allOffers.value.filter(o => offerStatusKey(o) === 'pending').length },
  { key: 'confirmed', label: 'Confirmés',  count: allOffers.value.filter(o => offerStatusKey(o) === 'confirmed').length },
  { key: 'completed', label: 'Terminés',   count: allOffers.value.filter(o => offerStatusKey(o) === 'completed').length },
])

// ── Actions ──────────────────────────────────────────────────────────────
function switchTab(key) {
  activeTab.value = key
}

async function loadOffers() {
  loading.value = true
  try {
    const res = await getMyOffers()
    allOffers.value = res.data.data
  } catch {
    allOffers.value = []
  } finally {
    loading.value = false
  }
}

function viewClientProfile(client) {
  if (client?.id) router.push(`/artisan/clients/${client.id}`)
}

async function contactClient(offer) {
  const clientId         = offer.service_request?.client?.id
  const serviceRequestId = offer.service_request?.id
  if (!clientId) return
  try {
    const { data } = await getOrCreateConversation({
      client_id:          clientId,
      service_request_id: serviceRequestId ?? null,
    })
    router.push(`/messages/${data.data.id}`)
  } catch {
    alert('Impossible d\'ouvrir la conversation. Veuillez réessayer.')
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

function timeAgo(iso) {
  if (!iso) return ''
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1)  return 'à l\'instant'
  if (m < 60) return `il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `il y a ${h}h`
  const d = Math.floor(h / 24)
  return `il y a ${d} jour${d > 1 ? 's' : ''}`
}

function offerTimeLabel(offer) {
  const sk = offerStatusKey(offer)
  if (sk === 'completed') {
    const sr = offer.service_request
    const d = sr?.updated_at ? new Date(sr.updated_at) : null
    return d ? `Complété le ${d.toLocaleDateString('fr-FR')}` : 'Complété'
  }
  return `Accepté ${timeAgo(offer.created_at)}`
}

function offerStatusLabel(offer) {
  const sk = offerStatusKey(offer)
  if (sk === 'confirmed') return 'Confirmé'
  if (sk === 'completed') return 'Terminé'
  return 'En attente de confirmation'
}

function formatDate(iso) {
  if (!iso) return '—'
  const d = new Date(iso)
  return d.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' }) +
    ' à ' + d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

function formatDuration(minutes) {
  if (!minutes) return '—'
  const h = Math.floor(minutes / 60)
  const m = minutes % 60
  if (h === 0) return `${m} min`
  if (m === 0) return `${h} heure${h > 1 ? 's' : ''}`
  return `${h}h${String(m).padStart(2, '0')}`
}

// ── Init ──────────────────────────────────────────────────────────────────
onMounted(loadOffers)
</script>

<style scoped>
/* ── Layout ─────────────────────────────────────────────────────────────── */
.mes-demandes-page {
  font-family: 'Inter', 'Poppins', sans-serif;
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  color: #314158;
}

/* ── Header ─────────────────────────────────────────────────────────────── */
.page-header {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
  padding: 0 96px;
}
.header-top {
  padding: 20px 0 0;
}
.btn-back {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: #62748E;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  letter-spacing: -0.3125px;
  cursor: pointer;
  padding: 0;
}
.btn-back:hover { color: #314158; }
.header-body {
  padding: 20px 0 0;
}
.page-title {
  font-size: 30px;
  font-weight: 400;
  color: #314158;
  letter-spacing: 0.395508px;
  margin: 0 0 8px;
  line-height: 36px;
}
.page-subtitle {
  font-size: 16px;
  color: #62748E;
  letter-spacing: -0.3125px;
  margin: 0;
  line-height: 24px;
}

/* Tabs */
.tabs-row {
  display: flex;
  gap: 8px;
  padding: 20px 0 0;
  flex-wrap: wrap;
  margin-bottom: 8px;
}
.tab-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 10px;
  background: #F3F4F6;
  color: #62748E;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  transition: all 0.15s;
  height: 40px;
}
.tab-btn:hover { background: #E5E7EB; color: #314158; }
.tab-btn.active {
  background: #FC5A15;
  color: #fff;
}

/* ── Loading / Empty ─────────────────────────────────────────────────────── */
.loading-state, .empty-state {
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
.empty-icon { font-size: 48px; margin-bottom: 16px; }
.empty-state h3 { font-size: 18px; font-weight: 700; color: #314158; margin: 0 0 8px; }

/* ── Cards list ─────────────────────────────────────────────────────────── */
.cards-list {
  padding: 24px 96px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-width: 1440px;
  margin: 0 auto;
  box-sizing: border-box;
}
.offer-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px;
  box-shadow: 0 4px 4px rgba(0,0,0,0.11);
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* Card top */
.card-top {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}
.client-avatar {
  width: 48px; height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 16px;
  font-weight: 400;
  letter-spacing: -0.3125px;
  flex-shrink: 0;
}
.client-meta {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}
.client-name {
  font-size: 18px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.439453px;
}
.meta-sep { color: #C5CDD8; font-size: 14px; }
.time-ago {
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.150391px;
}

/* Status badges */
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 400;
  line-height: 16px;
  border: 1px solid;
  white-space: nowrap;
}
.status-badge.confirmed {
  background: #DCFCE7;
  border-color: #B9F8CF;
  color: #008236;
}
.status-badge.pending {
  background: #FEF9C2;
  border-color: #FFF085;
  color: #A65F00;
}
.status-badge.completed {
  background: #F3F4F6;
  border-color: #E5E7EB;
  color: #364153;
}

/* Category strip */
.category-strip {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 247, 237, 0.22);
  border-radius: 10px;
  padding: 12px;
  margin-bottom: 12px;
}
.cat-name {
  font-size: 14px;
  color: #FC5A15;
  letter-spacing: -0.150391px;
}
.cat-sep {
  font-size: 14px;
  color: #62748E;
}
.cat-service {
  font-size: 14px;
  color: #314158;
  letter-spacing: -0.150391px;
}

/* Request title */
.req-title {
  font-size: 16px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.3125px;
  margin: 0 0 12px;
  line-height: 24px;
}

/* Info row */
.info-row {
  display: flex;
  align-items: center;
  gap: 32px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}
.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.150391px;
}
.info-item svg { flex-shrink: 0; }

/* Proposition box */
.proposition-box {
  background: #F0FDF4;
  border: 1px solid #B9F8CF;
  border-radius: 10px;
  padding: 17px;
  margin-bottom: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.prop-label {
  font-size: 14px;
  color: #0D542B;
  letter-spacing: -0.150391px;
  margin: 0;
  line-height: 20px;
}
.prop-values {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}
.prop-price, .prop-duration {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #008236;
}
.prop-price span {
  font-size: 18px;
  letter-spacing: -0.439453px;
  line-height: 28px;
}
.prop-duration span {
  font-size: 16px;
  letter-spacing: -0.3125px;
  line-height: 24px;
}
.prop-price svg, .prop-duration svg { color: #008236; }

/* Action buttons */
.card-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid #F3F4F6;
  margin-top: 16px;
  flex-wrap: wrap;
}
.btn-contact {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 20px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  color: #fff;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  height: 40px;
  transition: all 0.15s;
}
.btn-contact:hover { background: #e04e0f; }
.btn-profile {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 20px;
  background: #fff;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  color: #62748E;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  height: 42px;
  transition: all 0.15s;
}
.btn-profile:hover { border-color: #FC5A15; color: #FC5A15; }

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 960px) {
  .page-header { padding: 0 24px; }
  .cards-list   { padding: 20px 24px; }
}
@media (max-width: 600px) {
  .page-header { padding: 0 16px; }
  .cards-list   { padding: 16px; }
  .page-title   { font-size: 22px; }
  .info-row     { flex-direction: column; align-items: flex-start; gap: 8px; }
  .card-actions { flex-direction: column; align-items: stretch; }
  .btn-contact, .btn-profile { justify-content: center; }
}
</style>

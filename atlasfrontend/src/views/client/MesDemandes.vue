<template>
  <div class="md-page">

    <!-- ── Top header bar ─────────────────────────────────────────── -->
    <div class="md-topbar">
      <div class="md-topbar-inner">

        <!-- Back -->
        <button class="back-btn" @click="$router.push('/Home')">
          <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
            <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour
        </button>

        <!-- Title row -->
        <div class="header-row">
          <div>
            <h1 class="page-title">Mes demandes</h1>
            <p class="page-sub">Gérez vos demandes de service et consultez les réponses des artisans</p>
          </div>
          <button class="btn-orange" @click="$router.push('/client/nouvelle-demande')">
            + Nouvelle demande
          </button>
        </div>

        <!-- Filter tabs -->
        <div class="filter-bar">
          <div class="filter-label">
            <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
              <path d="M3 6h18M6 12h12M9 18h6" stroke-linecap="round"/>
            </svg>
            Filtrer par statut :
          </div>
          <div class="filter-tabs">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              class="filter-tab"
              :class="[{ active: activeFilter === tab.key }, `tab-${tab.key}`]"
              @click="activeFilter = tab.key"
            >
              <component :is="tab.icon" v-if="tab.icon" class="tab-icon" />
              {{ tab.label }} ({{ tab.count }})
            </button>
          </div>
        </div>

      </div>
    </div>

    <!-- ── Content ────────────────────────────────────────────────── -->
    <div class="md-content">
      <div v-if="loading" class="state-msg">Chargement de vos demandes…</div>
      <div v-else-if="error"  class="state-msg error-msg">{{ error }}</div>
      <div v-else-if="!filteredRequests.length" class="empty-state">
        <svg width="48" height="48" fill="none" stroke="#D1D5DB" stroke-width="1.5" viewBox="0 0 24 24">
          <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"/>
          <rect x="9" y="3" width="6" height="4" rx="1"/>
        </svg>
        <p>Aucune demande pour le moment.</p>
        <button class="btn-orange" @click="$router.push('/client/nouvelle-demande')">
          Créer une demande
        </button>
      </div>

      <!-- Request cards -->
      <div v-else class="requests-list">
        <div
          v-for="req in filteredRequests"
          :key="req.id"
          class="req-card"
        >
          <!-- Card header -->
          <div class="card-header">
            <div class="card-header-left">
              <h3 class="card-title">{{ req.category?.name || req.service_type?.name || 'Demande' }}</h3>
              <span v-if="req.offers?.length" class="badge-responses">
                {{ req.offers.length }} réponse{{ req.offers.length > 1 ? 's' : '' }}
              </span>
              <span class="status-pill" :class="`pill-${req.status}`">{{ statusLabel(req.status) }}</span>
            </div>
            <div class="card-actions">
              <button class="action-btn" title="Voir" @click="viewRequest(req)">
                <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                  <circle cx="12" cy="12" r="3"/>
                </svg>
              </button>
              <button
                v-if="req.status === 'open'"
                class="action-btn action-delete"
                title="Annuler"
                @click="cancelReq(req)"
              >
                <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
                  <polyline points="3 6 5 6 21 6"/>
                  <path d="M19 6l-1 14H6L5 6M10 11v6M14 11v6M9 6V4h6v2"/>
                </svg>
              </button>
              <button
                class="action-btn chevron-btn"
                :class="{ rotated: req._expanded }"
                @click="req._expanded = !req._expanded"
              >
                <svg width="20" height="20" fill="none" stroke="#FC5A15" stroke-width="1.67" viewBox="0 0 24 24">
                  <path d="M6 9l6 6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- Expanded body -->
          <transition name="expand">
            <div v-if="req._expanded" class="card-body">

              <!-- Request summary -->
              <div class="req-summary">
                <div class="summary-label">Description de la demande</div>
                <div class="summary-text">
                  {{ req.description || req.service_type?.name || '—' }}
                </div>
                <div class="summary-meta">
                  <span class="meta-item">
                    <svg width="16" height="16" fill="none" stroke="#62748E" stroke-width="1.33" viewBox="0 0 24 24">
                      <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                      <circle cx="12" cy="9" r="2.5"/>
                    </svg>
                    {{ req.city }}
                  </span>
                  <span class="meta-item">
                    <svg width="16" height="16" fill="none" stroke="#62748E" stroke-width="1.33" viewBox="0 0 24 24">
                      <rect x="3" y="4" width="18" height="18" rx="2"/>
                      <path d="M16 2v4M8 2v4M3 10h18"/>
                    </svg>
                    {{ formatDate(req.created_at) }}
                  </span>
                </div>
              </div>

              <!-- Artisan offers -->
              <div v-if="req.offers?.length" class="offers-section">
                <h4 class="offers-heading">Artisans ayant répondu ({{ req.offers.length }})</h4>
                <div class="offers-row">
                  <div
                    v-for="offer in req.offers"
                    :key="offer.id"
                    class="offer-card"
                    :class="{
                      'offer-accepted': offer.status === 'accepted',
                      'offer-rejected': offer.status === 'rejected',
                    }"
                  >
                    <!-- Artisan profile row -->
                    <div class="artisan-row">
                      <div class="avatar-wrap" style="cursor:pointer" @click="viewArtisanProfile(offer.artisan?.id)">
                        <div class="avatar" :style="{ background: avatarColor(offer.artisan?.user?.full_name) }">
                          <img
                            v-if="offer.artisan?.user?.avatar_url"
                            :src="offer.artisan.user.avatar_url"
                            :alt="offer.artisan.user.full_name"
                            class="avatar-img"
                          />
                          <span v-else>{{ initials(offer.artisan?.user?.full_name) }}</span>
                        </div>
                        <span class="online-dot"></span>
                      </div>
                      <div class="artisan-info">
                        <div class="artisan-name artisan-name-link" @click="viewArtisanProfile(offer.artisan?.id)">{{ offer.artisan?.user?.full_name || 'Artisan' }}</div>
                        <div class="artisan-specialty">{{ offer.artisan?.business_name || 'Artisan indépendant' }}</div>
                        <div class="artisan-rating">
                          <span class="rating-badge">
                            <svg width="12" height="12" fill="#FDC700" viewBox="0 0 24 24">
                              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"/>
                            </svg>
                            {{ Number(offer.artisan?.rating_average || 0).toFixed(1) }}
                          </span>
                          <span class="review-count">({{ offer.artisan?.total_reviews || 0 }} avis)</span>
                        </div>
                      </div>
                    </div>

                    <!-- Price box -->
                    <div class="price-box">
                      <div class="price-col">
                        <div class="price-label">Prix proposé</div>
                        <div class="price-amount">{{ offer.proposed_price }}<span class="currency">DH</span></div>
                      </div>
                      <div class="price-col text-right">
                        <div class="price-label">Durée estimée</div>
                        <div class="duration-value">{{ formatDuration(offer.estimated_duration) }}</div>
                      </div>
                    </div>

                    <!-- Response time -->
                    <div class="response-time">
                      <svg width="12" height="12" fill="none" stroke="#62748E" stroke-width="1.33" viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="10"/>
                        <path d="M12 6v6l4 2" stroke-linecap="round"/>
                      </svg>
                      Répondu {{ timeAgo(offer.created_at) }}
                    </div>

                    <!-- Status badge if not pending -->
                    <div v-if="offer.status !== 'pending'" class="offer-status-badge" :class="`offer-status-${offer.status}`">
                      {{ offer.status === 'accepted' ? '✓ Offre acceptée' : '✗ Offre refusée' }}
                    </div>

                    <!-- Primary CTA buttons -->
                    <div v-if="offer.status === 'pending'" class="offer-cta">
                      <button
                        class="btn-reject"
                        @click="handleRejectOffer(req, offer)"
                        :disabled="offer._loading"
                      >Refuser l'offre</button>
                      <button
                        class="btn-accept"
                        @click="handleAcceptOffer(req, offer)"
                        :disabled="offer._loading"
                      >Accepter l'offre</button>
                    </div>

                    <!-- Secondary actions -->
                    <div class="offer-secondary">
                      <button class="btn-secondary" @click="messageArtisan(req, offer)">
                        <svg width="15" height="15" fill="none" stroke="#62748E" stroke-width="1.25" viewBox="0 0 24 24">
                          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                        </svg>
                        Message
                      </button>
                      <button class="btn-secondary">
                        <svg width="15" height="15" fill="none" stroke="#62748E" stroke-width="1.25" viewBox="0 0 24 24">
                          <path d="M22 16.92v3a2 2 0 0 1-2.18 2A19.79 19.79 0 0 1 3.08 5.18 2 2 0 0 1 5.1 3h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L9.09 10.91a16 16 0 0 0 5 5l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
                        </svg>
                        Appel
                      </button>
                      <button class="btn-secondary" @click="viewArtisanProfile(offer.artisan?.id)">
                        <svg width="15" height="15" fill="none" stroke="#62748E" stroke-width="1.25" viewBox="0 0 24 24">
                          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                          <circle cx="12" cy="7" r="4"/>
                        </svg>
                        Profil
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div v-else class="no-offers">
                <svg width="32" height="32" fill="none" stroke="#D1D5DB" stroke-width="1.5" viewBox="0 0 24 24">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                </svg>
                <p>Aucune réponse d'artisan pour le moment.</p>
              </div>

            </div>
          </transition>
        </div>
      </div>
    </div>

    <!-- ── Toast notification ────────────────────────────────────── -->
    <transition name="toast">
      <div v-if="toast.show" class="toast" :class="`toast-${toast.type}`">
        {{ toast.message }}
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  getServiceRequests,
  cancelServiceRequest,
  acceptOffer,
  rejectOffer,
} from '../../api/serviceRequests'
import { getOrCreateConversation } from '../../api/messages'

const router = useRouter()

// ── State ────────────────────────────────────────────────────────────────────
const requests     = ref([])
const loading      = ref(false)
const error        = ref('')
const activeFilter = ref('all')
const toast        = ref({ show: false, message: '', type: 'success' })

// ── Fetch ─────────────────────────────────────────────────────────────────────
onMounted(fetchRequests)

async function fetchRequests() {
  loading.value = true
  error.value   = ''
  try {
    const { data } = await getServiceRequests()
    // Flatten paginated response; add reactive _expanded flag
    const rows = data.data ?? data
    requests.value = rows.map(r => ({ ...r, _expanded: true }))
  } catch (e) {
    error.value = e.response?.data?.error || 'Impossible de charger vos demandes.'
  } finally {
    loading.value = false
  }
}

// ── Filter tabs ───────────────────────────────────────────────────────────────
const tabs = computed(() => {
  const counts = { all: requests.value.length }
  for (const r of requests.value) {
    counts[r.status] = (counts[r.status] || 0) + 1
  }
  return [
    { key: 'all',         label: 'Tous',      count: counts.all        || 0 },
    { key: 'open',        label: 'En attente', count: counts.open       || 0 },
    { key: 'in_progress', label: 'Accepté',    count: counts.in_progress|| 0 },
    { key: 'cancelled',   label: 'Annulé',     count: counts.cancelled  || 0 },
    { key: 'completed',   label: 'Terminé',    count: counts.completed  || 0 },
  ].filter(t => t.key === 'all' || t.count > 0)
})

const filteredRequests = computed(() => {
  if (activeFilter.value === 'all') return requests.value
  return requests.value.filter(r => r.status === activeFilter.value)
})

// ── Actions ───────────────────────────────────────────────────────────────────
function viewRequest(req) {
  router.push(`/client/demandes/${req.id}`)
}

function viewArtisanProfile(artisanId) {
  if (!artisanId) return
  router.push(`/artisans/profile/${artisanId}`)
}

async function cancelReq(req) {
  if (!confirm('Annuler cette demande ?')) return
  try {
    await cancelServiceRequest(req.id)
    req.status = 'cancelled'
    showToast('Demande annulée.')
  } catch {
    showToast('Impossible d\'annuler la demande.', 'error')
  }
}

async function handleAcceptOffer(req, offer) {
  offer._loading = true
  try {
    const { data } = await acceptOffer(req.id, offer.id)
    // Update offers list in place
    const updatedReq = data.data
    Object.assign(req, { ...updatedReq, _expanded: true })
    showToast('Offre acceptée ! L\'artisan sera notifié.')
  } catch (e) {
    showToast(e.response?.data?.error || 'Impossible d\'accepter l\'offre.', 'error')
  } finally {
    offer._loading = false
  }
}

async function messageArtisan(req, offer) {
  const artisanId = offer.artisan?.id
  if (!artisanId) return
  try {
    const { data } = await getOrCreateConversation({
      artisan_id:         artisanId,
      service_request_id: req.id ?? null,
    })
    router.push(`/messages/${data.data.id}`)
  } catch {
    showToast('Impossible d\'ouvrir la conversation.', 'error')
  }
}

async function handleRejectOffer(req, offer) {
  offer._loading = true
  try {
    await rejectOffer(req.id, offer.id)
    offer.status = 'rejected'
    showToast('Offre refusée.')
  } catch (e) {
    showToast(e.response?.data?.error || 'Impossible de refuser l\'offre.', 'error')
  } finally {
    offer._loading = false
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function statusLabel(s) {
  const map = { open: 'En attente', in_progress: 'En cours', completed: 'Terminé', cancelled: 'Annulé' }
  return map[s] || s
}

function formatDate(iso) {
  if (!iso) return '—'
  return new Date(iso).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
}

function formatDuration(minutes) {
  if (!minutes) return '—'
  if (minutes < 60)  return `${minutes} min`
  const h = Math.floor(minutes / 60)
  const m = minutes % 60
  return m ? `${h}h${String(m).padStart(2, '0')}` : `${h} heure${h > 1 ? 's' : ''}`
}

function timeAgo(iso) {
  if (!iso) return ''
  const diff = Date.now() - new Date(iso).getTime()
  const minutes = Math.floor(diff / 60000)
  if (minutes < 1)   return 'à l\'instant'
  if (minutes < 60)  return `il y a ${minutes} min`
  const hours = Math.floor(minutes / 60)
  if (hours < 24)    return `il y a ${hours} heure${hours > 1 ? 's' : ''}`
  const days = Math.floor(hours / 24)
  return `il y a ${days} jour${days > 1 ? 's' : ''}`
}

function initials(name) {
  if (!name) return 'A'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}

const _avatarPalette = ['#3B82F6','#8B5CF6','#10B981','#F59E0B','#EF4444','#06B6D4','#EC4899','#6366F1']
function avatarColor(name) {
  if (!name) return '#6B7280'
  const i = name.charCodeAt(0) % _avatarPalette.length
  return _avatarPalette[i]
}

let _toastTimer = null
function showToast(message, type = 'success') {
  clearTimeout(_toastTimer)
  toast.value = { show: true, message, type }
  _toastTimer = setTimeout(() => { toast.value.show = false }, 3500)
}
</script>

<style scoped>
/* ── Page ─────────────────────────────────────────────────────────────────── */
.md-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Inter', sans-serif;
}

/* ── Top bar ──────────────────────────────────────────────────────────────── */
.md-topbar {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
}
.md-topbar-inner {
  max-width: 1440px;
  margin: 0 auto;
  padding: 32px 96px 0;
  display: flex;
  flex-direction: column;
  gap: 15px;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  cursor: pointer;
  color: #62748E;
  font-size: 16px;
  padding: 0;
  width: fit-content;
}
.header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.page-title { font-size: 30px; font-weight: 400; color: #314158; margin: 0 0 2px; }
.page-sub   { font-size: 16px; color: #62748E; margin: 0; }

/* ── Filter bar ───────────────────────────────────────────────────────────── */
.filter-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-bottom: 20px;
  flex-wrap: wrap;
}
.filter-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  color: #62748E;
  white-space: nowrap;
}
.filter-tabs { display: flex; gap: 8px; flex-wrap: wrap; }
.filter-tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  cursor: pointer;
  transition: background .15s, color .15s;
  font-family: 'Inter', sans-serif;
}
.filter-tab.active {
  background: #FC5A15;
  color: #fff;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,.1);
}
.filter-tab:not(.active) { background: #F3F4F6; color: #62748E; }
.filter-tab:not(.active):hover { background: #E5E7EB; }

/* ── Content ──────────────────────────────────────────────────────────────── */
.md-content {
  max-width: 1244px;
  margin: 0 auto;
  padding: 32px 24px 64px;
}

/* ── States ───────────────────────────────────────────────────────────────── */
.state-msg { text-align: center; padding: 60px; color: #62748E; font-size: 16px; }
.error-msg { color: #EF4444; }
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 80px 24px;
  color: #9CA3AF;
  font-size: 16px;
}

/* ── Request card ─────────────────────────────────────────────────────────── */
.req-card {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 14px;
  margin-bottom: 20px;
  overflow: hidden;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
}
.card-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.card-title {
  font-family: 'Poppins', sans-serif;
  font-size: 20px;
  font-weight: 500;
  color: #314158;
  margin: 0;
}
.badge-responses {
  background: #FFEDD4;
  color: #FC5A15;
  font-size: 13px;
  padding: 4px 12px;
  border-radius: 999px;
}
.status-pill {
  font-size: 13px;
  padding: 3px 10px;
  border-radius: 999px;
  font-weight: 500;
}
.pill-open        { background: #FEFCE8; color: #A65F00; }
.pill-in_progress { background: #F0FDF4; color: #008236; }
.pill-completed   { background: #EFF6FF; color: #1D4ED8; }
.pill-cancelled   { background: #FEF2F2; color: #C10007; }

.card-actions { display: flex; align-items: center; gap: 4px; }
.action-btn {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  background: none;
  border-radius: 8px;
  cursor: pointer;
  transition: background .15s;
}
.action-btn:hover { background: #F3F4F6; }
.action-delete:hover svg { stroke: #EF4444; }
.chevron-btn svg { transition: transform .25s; }
.chevron-btn.rotated svg { transform: rotate(180deg); }

/* ── Card body ────────────────────────────────────────────────────────────── */
.card-body {
  border-top: 1px solid #E5E7EB;
  padding: 20px 24px;
}

.req-summary {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 14px;
  padding: 20px 24px;
  margin-bottom: 24px;
}
.summary-label { font-family: 'Poppins', sans-serif; font-size: 14px; color: #62748E; margin-bottom: 6px; }
.summary-text  { font-family: 'Poppins', sans-serif; font-size: 16px; color: #314158; margin-bottom: 10px; }
.summary-meta  { display: flex; gap: 16px; flex-wrap: wrap; }
.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #62748E;
}

/* ── Offers ───────────────────────────────────────────────────────────────── */
.offers-heading {
  font-family: 'Poppins', sans-serif;
  font-size: 18px;
  font-weight: 500;
  color: #314158;
  margin: 0 0 16px;
}
.offers-row {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 16px;
}

.offer-card {
  background: #fff;
  border: 0.75px solid #F3F4F6;
  border-radius: 12px;
  padding: 18px;
  box-shadow: 0 1px 2px rgba(0,0,0,.1);
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: box-shadow .15s;
}
.offer-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,.1); }
.offer-accepted { border-color: #86EFAC; background: #F0FDF4; }
.offer-rejected { opacity: .55; }

/* Artisan row */
.artisan-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}
.avatar-wrap { position: relative; flex-shrink: 0; }
.avatar {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  overflow: hidden;
  box-shadow: 0 0 0 1.5px #F3F4F6;
}
.avatar-img { width: 100%; height: 100%; object-fit: cover; }
.online-dot {
  position: absolute;
  bottom: -2px;
  right: -2px;
  width: 14px;
  height: 14px;
  background: #00C950;
  border: 1.5px solid #fff;
  border-radius: 50%;
}
.artisan-info { display: flex; flex-direction: column; gap: 2px; }
.artisan-name      { font-size: 13.5px; color: #314158; font-weight: 500; }
.artisan-name-link { cursor: pointer; transition: color 0.15s; }
.artisan-name-link:hover { color: #FC5A15; }
.artisan-specialty { font-size: 10.5px; color: #62748E; }
.artisan-rating    { display: flex; align-items: center; gap: 6px; }
.rating-badge {
  display: flex;
  align-items: center;
  gap: 3px;
  background: #FEFCE8;
  padding: 2px 8px;
  border-radius: 8px;
  font-size: 10.5px;
  color: #314158;
}
.review-count { font-size: 9px; color: #62748E; }

/* Price box */
.price-box {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  background: linear-gradient(90deg, rgba(252,90,21,.07) 0%, rgba(252,90,21,.07) 100%);
  border-radius: 10px;
  padding: 12px;
}
.price-col     { display: flex; flex-direction: column; gap: 2px; }
.text-right    { text-align: right; }
.price-label   { font-size: 9px; color: #62748E; }
.price-amount  { font-size: 22px; color: #FC5A15; line-height: 1.2; font-weight: 400; }
.currency      { font-size: 16px; }
.duration-value{ font-size: 13.5px; color: #314158; }

/* Response time */
.response-time {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 10.5px;
  color: #62748E;
}

/* Status badge */
.offer-status-badge {
  text-align: center;
  font-size: 13px;
  font-weight: 600;
  padding: 6px;
  border-radius: 8px;
}
.offer-status-accepted { background: #DCFCE7; color: #16A34A; }
.offer-status-rejected { background: #FEF2F2; color: #C10007; }

/* CTA buttons */
.offer-cta {
  display: flex;
  gap: 8px;
}
.btn-reject {
  flex: 1;
  padding: 8px;
  border: 0.5px solid #FC5A15;
  border-radius: 10px;
  background: none;
  color: #FC5A15;
  font-size: 12px;
  cursor: pointer;
  transition: background .15s;
}
.btn-reject:hover    { background: #FFF7ED; }
.btn-reject:disabled { opacity: .5; cursor: not-allowed; }
.btn-accept {
  flex: 1;
  padding: 8px;
  border: none;
  border-radius: 10px;
  background: #FC5A15;
  color: #fff;
  font-size: 12px;
  cursor: pointer;
  transition: background .15s;
}
.btn-accept:hover    { background: #e04e0d; }
.btn-accept:disabled { opacity: .5; cursor: not-allowed; }

/* Secondary action row */
.offer-secondary {
  display: flex;
  gap: 8px;
}
.btn-secondary {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 7px 4px;
  background: #F9FAFB;
  border: 0.75px solid #E5E7EB;
  border-radius: 10px;
  font-size: 10.5px;
  color: #62748E;
  cursor: pointer;
  font-family: 'Inter', sans-serif;
  transition: background .15s;
}
.btn-secondary:hover { background: #F3F4F6; }

/* No offers placeholder */
.no-offers {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 40px;
  color: #9CA3AF;
  font-size: 14px;
  text-align: center;
}

/* ── Shared orange button ─────────────────────────────────────────────────── */
.btn-orange {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  transition: background .15s;
  white-space: nowrap;
}
.btn-orange:hover { background: #e04e0d; }

/* ── Expand transition ────────────────────────────────────────────────────── */
.expand-enter-active, .expand-leave-active {
  transition: max-height .3s ease, opacity .3s ease;
  max-height: 2000px;
  overflow: hidden;
}
.expand-enter-from, .expand-leave-to {
  max-height: 0;
  opacity: 0;
}

/* ── Toast ────────────────────────────────────────────────────────────────── */
.toast {
  position: fixed;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  padding: 14px 28px;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 500;
  z-index: 9999;
  box-shadow: 0 8px 24px rgba(0,0,0,.15);
}
.toast-success { background: #16A34A; color: #fff; }
.toast-error   { background: #EF4444; color: #fff; }
.toast-enter-active, .toast-leave-active { transition: opacity .3s, transform .3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }

/* ── Responsive ───────────────────────────────────────────────────────────── */
@media (max-width: 768px) {
  .md-topbar-inner { padding: 20px 16px 0; }
  .md-content      { padding: 20px 16px 40px; }
  .header-row      { flex-direction: column; align-items: flex-start; gap: 12px; }
  .offers-row      { grid-template-columns: 1fr; }
  .offer-cta       { flex-direction: column; }
}
</style>

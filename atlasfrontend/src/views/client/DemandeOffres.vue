<template>
  <div class="page">

    <!-- ── Orange top section ─────────────────────────────────────── -->
    <div class="top-section">

      <!-- Topbar row: back + logo + bell -->
      <div class="topbar">
        <button class="back-btn" @click="$router.push('/client/mes-demandes')">
          <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
            <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
        <div class="logo-wrap">
          <img src="../../assets/images/Exclude.svg" alt="Atlas Fix" class="logo-img" />
          <span class="logo-text">Atlas <strong>Fix</strong></span>
        </div>
        <button class="icon-btn" @click="$router.push('/messages')">
          <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="#303030" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="#303030" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
      </div>

      <!-- Search row: demand search + city filter -->
      <div class="search-row">
        <div class="search-bar flex-1">
          <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
            <circle cx="11" cy="11" r="7" stroke="#494949" stroke-width="1.5"/>
            <path d="M21 21l-4.35-4.35" stroke="#494949" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            :placeholder="catName || 'Quelle demande rechercher ?'"
            class="search-input"
          />
          <button class="search-action-btn">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
              <path d="M12 2a3 3 0 0 1 3 3v6a3 3 0 0 1-6 0V5a3 3 0 0 1 3-3z" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round"/>
              <path d="M19 10a7 7 0 0 1-14 0M12 19v3M8 22h8" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </button>
        </div>
        <div class="city-bar">
          <input
            v-model="cityFilter"
            type="text"
            placeholder="Ville…"
            class="city-input"
          />
          <button class="city-chevron">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
              <path d="M6 9l6 6 6-6" stroke="#ffffff" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>
      </div>

    </div>

    <!-- ── Filter bar ──────────────────────────────────────────────── -->
    <div class="filter-bar">
      <button class="filter-icon-btn">
        <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
          <path d="M4 6h16M7 12h10M10 18h4" stroke="#FC5A15" stroke-width="2" stroke-linecap="round"/>
        </svg>
      </button>
      <button class="filter-pill-btn">Filtrer</button>
    </div>

    <!-- ── Content ─────────────────────────────────────────────────── -->
    <div class="content">

      <div v-if="loading" class="state-msg">
        <div class="spinner"></div>
        Chargement des offres…
      </div>
      <div v-else-if="error" class="state-msg state-error">{{ error }}</div>
      <div v-else-if="!filteredOffers.length" class="empty-state">
        <svg width="48" height="48" fill="none" stroke="#D1D5DB" stroke-width="1.5" viewBox="0 0 24 24">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
        <p>Aucune offre pour le moment.</p>
      </div>

      <!-- Offer cards -->
      <div v-else class="offers-list">
        <div
          v-for="item in filteredOffers"
          :key="item.offer.id"
          class="offer-card"
          :class="{
            'offer-accepted': item.offer.status === 'accepted',
            'offer-rejected': item.offer.status === 'rejected',
            'offer-boosted': item.offer.has_active_boost,
          }"
        >
          <!-- Boost badge -->
          <div v-if="item.offer.has_active_boost" class="boost-badge">
            <svg width="12" height="12" viewBox="0 0 16 16" fill="none">
              <path d="M8 1l1.5 3.5H14l-3 2.5 1.2 3.5L8 8.2 3.8 10.5 5 7 2 4.5h4.5z" fill="#FC5A15"/>
            </svg>
            Mis en avant
          </div>

          <!-- Artisan row -->
          <div class="artisan-row">
            <!-- Avatar -->
            <div class="avatar-wrap" @click="viewArtisan(item.offer.artisan?.id)">
              <div
                class="avatar"
                :style="{ background: avatarColor(item.offer.artisan?.user?.full_name) }"
              >
                <img
                  v-if="item.offer.artisan?.user?.avatar_url"
                  :src="item.offer.artisan.user.avatar_url"
                  :alt="item.offer.artisan.user.full_name"
                  class="avatar-img"
                />
                <span v-else>{{ initials(item.offer.artisan?.user?.full_name) }}</span>
              </div>
              <div class="online-dot"></div>
            </div>

            <!-- Info -->
            <div class="artisan-info">
              <div class="artisan-name" @click="viewArtisan(item.offer.artisan?.id)">
                {{ item.offer.artisan?.user?.full_name || 'Artisan' }}
              </div>
              <div class="artisan-specialty">
                {{ item.req.category?.name || item.req.service_type?.name || 'Service' }}
              </div>
              <div class="rating-row">
                <div class="rating-badge">
                  <svg width="10" height="10" fill="#FDC700" viewBox="0 0 24 24">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"/>
                  </svg>
                  {{ Number(item.offer.artisan?.rating_average || 0).toFixed(1) }}
                </div>
                <span class="review-count">({{ item.offer.artisan?.total_reviews || 0 }} avis)</span>
              </div>
            </div>

            <!-- Profil badge + response time -->
            <div class="artisan-right">
              <button class="profil-badge" @click="viewArtisan(item.offer.artisan?.id)">
                <svg width="12" height="12" fill="none" viewBox="0 0 24 24">
                  <circle cx="12" cy="8" r="4" stroke="#ffffff" stroke-width="2"/>
                  <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="#ffffff" stroke-width="2" stroke-linecap="round"/>
                </svg>
                Profil
              </button>
              <span class="response-time">{{ timeAgo(item.offer.created_at) }}</span>
            </div>
          </div>

          <!-- Price & duration box -->
          <div class="price-box">
            <div class="price-col">
              <span class="price-label">Prix proposé</span>
              <span class="price-amount">{{ item.offer.proposed_price }}<span class="currency">€</span></span>
            </div>
            <div class="price-col text-right">
              <span class="price-label">Durée estimée</span>
              <span class="duration-value">{{ formatDuration(item.offer.estimated_duration) }}</span>
            </div>
          </div>

          <!-- Status badge (if not pending) -->
          <div
            v-if="item.offer.status !== 'pending'"
            class="status-badge"
            :class="`status-${item.offer.status}`"
          >
            {{ item.offer.status === 'accepted' ? '✓ Offre acceptée' : '✗ Offre refusée' }}
          </div>

          <!-- CTA buttons -->
          <div v-if="item.offer.status === 'pending'" class="cta-row">
            <button
              class="btn-reject"
              :disabled="item.offer._loading"
              @click="rejectOfferAction(item)"
            >
              Refuser l'offre
            </button>
            <button
              class="btn-accept"
              :disabled="item.offer._loading"
              @click="acceptOfferAction(item)"
            >
              Accepter l'offre
            </button>
          </div>

        </div>
      </div>

    </div>

    <!-- ── Bottom spacer ────────────────────────────────────────────── -->
    <div style="height: 100px;"></div>

    <!-- ── Bottom navigation ─────────────────────────────────────────  -->
    <MobileBottomNav active-tab="demandes" />

    <!-- ── Toast ────────────────────────────────────────────────────── -->
    <transition name="toast">
      <div v-if="toast.show" class="toast" :class="`toast-${toast.type}`">
        {{ toast.message }}
      </div>
    </transition>

    <!-- ── Address confirmation modal ─────────────────────────────── -->
    <Teleport to="body">
      <div v-if="addrModal.show" class="addr-overlay" @click.self="closeAddrModal">
        <div class="addr-modal">
          <div class="addr-header">
            <div class="addr-header-left">
              <div class="addr-icon-wrap">
                <svg width="20" height="20" fill="none" stroke="#FC5A15" stroke-width="1.8" viewBox="0 0 24 24">
                  <path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9.5z" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M9 21V12h6v9" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <div>
                <div class="addr-title">Confirmation de l'adresse</div>
                <div class="addr-sub">Service à domicile</div>
              </div>
            </div>
            <button class="addr-close-btn" @click="closeAddrModal">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M18 6L6 18M6 6l12 12" stroke-linecap="round"/>
              </svg>
            </button>
          </div>

          <div class="addr-body">
            <div class="addr-notice">
              <svg width="16" height="16" fill="none" stroke="#92400E" stroke-width="1.5" viewBox="0 0 24 24" style="flex-shrink:0;margin-top:1px">
                <rect x="3" y="11" width="18" height="11" rx="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke-linecap="round"/>
              </svg>
              Veuillez confirmer l'adresse où l'artisan doit se rendre.
            </div>
            <div class="addr-field">
              <label class="addr-label">Adresse complète</label>
              <div class="addr-input-row">
                <input
                  v-model="addrInput"
                  type="text"
                  class="addr-input"
                  placeholder="Ex: 12 rue Mohammed V, Casablanca"
                />
              </div>
            </div>
          </div>

          <div class="addr-footer">
            <button class="addr-btn-cancel" @click="closeAddrModal">Annuler</button>
            <button class="addr-btn-confirm" :disabled="addrLoading" @click="confirmAccept">
              <svg v-if="!addrLoading" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24">
                <path d="M20 6L9 17l-5-5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <div v-else class="spinner small"></div>
              {{ addrLoading ? 'Traitement…' : 'Confirmer' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getServiceRequests, acceptOffer, rejectOffer } from '../../api/serviceRequests'
import MobileBottomNav from '../../components/MobileBottomNav.vue'

const router = useRouter()
const route  = useRoute()

// ── Route query params ────────────────────────────────────────────────────────
const catKey  = route.query.cat     || null
const catName = route.query.catName || 'Toutes les offres'

// ── State ─────────────────────────────────────────────────────────────────────
const requests    = ref([])
const loading     = ref(false)
const error       = ref('')
const searchQuery = ref('')
const cityFilter  = ref('')
const toast       = ref({ show: false, message: '', type: 'success' })

// Address modal state
const addrModal  = ref({ show: false, item: null })
const addrInput  = ref('')
const addrLoading = ref(false)

// ── Fetch ─────────────────────────────────────────────────────────────────────
onMounted(async () => {
  loading.value = true
  error.value   = ''
  try {
    const { data } = await getServiceRequests()
    const rows = data.data ?? data
    requests.value = rows
  } catch (e) {
    error.value = e.response?.data?.error || 'Impossible de charger les offres.'
  } finally {
    loading.value = false
  }
})

// ── Flatten offers ────────────────────────────────────────────────────────────
const allOfferItems = computed(() => {
  const items = []
  for (const req of requests.value) {
    const reqCatKey = String(req.category?.id || req.category?.name || req.service_type?.name || 'Autre')
    // Filter by category if provided
    if (catKey && reqCatKey !== catKey) continue
    if (req.offers?.length) {
      for (const offer of req.offers) {
        items.push({ req, offer })
      }
    }
  }
  return items
})

const filteredOffers = computed(() => {
  let items = allOfferItems.value
  const q = searchQuery.value.trim().toLowerCase()
  const c = cityFilter.value.trim().toLowerCase()
  if (q) {
    items = items.filter(i =>
      (i.offer.artisan?.user?.full_name || '').toLowerCase().includes(q) ||
      (i.req.category?.name || '').toLowerCase().includes(q) ||
      (i.req.service_type?.name || '').toLowerCase().includes(q)
    )
  }
  if (c) {
    items = items.filter(i => (i.req.city || '').toLowerCase().includes(c))
  }
  // Boosted offers appear first
  items = [...items].sort((a, b) => {
    const aBoosted = a.offer.has_active_boost ? 1 : 0
    const bBoosted = b.offer.has_active_boost ? 1 : 0
    return bBoosted - aBoosted
  })
  return items
})

// ── Actions ───────────────────────────────────────────────────────────────────
function viewArtisan(id) {
  if (id) router.push(`/artisans/profile/${id}`)
}

function acceptOfferAction(item) {
  addrModal.value = { show: true, item }
  addrInput.value = item.req.city || ''
}

function closeAddrModal() {
  addrModal.value = { show: false, item: null }
  addrLoading.value = false
}

async function confirmAccept() {
  const item = addrModal.value.item
  if (!item) return
  addrLoading.value = true
  try {
    const body = addrInput.value.trim() ? { address: addrInput.value.trim() } : {}
    const { data } = await acceptOffer(item.req.id, item.offer.id, body)
    // Update the request in our list
    const idx = requests.value.findIndex(r => r.id === item.req.id)
    if (idx !== -1) {
      requests.value[idx] = { ...data.data }
    }
    showToast('Offre acceptée ! L\'artisan sera notifié.')
    closeAddrModal()
  } catch (e) {
    showToast(e.response?.data?.error || 'Impossible d\'accepter l\'offre.', 'error')
    addrLoading.value = false
  }
}

async function rejectOfferAction(item) {
  item.offer._loading = true
  try {
    await rejectOffer(item.req.id, item.offer.id)
    item.offer.status = 'rejected'
    showToast('Offre refusée.')
  } catch (e) {
    showToast(e.response?.data?.error || 'Impossible de refuser l\'offre.', 'error')
  } finally {
    item.offer._loading = false
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
const _palette = ['#3B82F6','#8B5CF6','#10B981','#F59E0B','#EF4444','#06B6D4','#EC4899']
function avatarColor(name) {
  if (!name) return '#6B7280'
  return _palette[name.charCodeAt(0) % _palette.length]
}
function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}

function formatDuration(minutes) {
  if (!minutes) return '—'
  if (minutes < 60) return `${minutes} min`
  const h = Math.floor(minutes / 60)
  const m = minutes % 60
  return m ? `${h}h${String(m).padStart(2, '0')}` : `${h}h`
}

function timeAgo(iso) {
  if (!iso) return ''
  const diff = Date.now() - new Date(iso).getTime()
  const minutes = Math.floor(diff / 60000)
  if (minutes < 1)   return 'à l\'instant'
  if (minutes < 60)  return `il y a ${minutes} min`
  const hours = Math.floor(minutes / 60)
  if (hours < 24)    return `il y a ${hours}h`
  const days = Math.floor(hours / 24)
  return `il y a ${days}j`
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
.page {
  min-height: 100vh;
  background: linear-gradient(0deg, rgba(255, 140, 91, 0) 62%, rgba(255, 140, 91, 0.3) 100%), #ffffff;
  font-family: 'Public Sans', 'Inter', sans-serif;
  max-width: 480px;
  margin: 0 auto;
  position: relative;
}

/* ── Orange top section ───────────────────────────────────────────────────── */
.top-section {
  background: #FC5A15;
  border-radius: 0 0 20px 20px;
  padding: 52px 29px 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Topbar */
.topbar {
  display: flex;
  align-items: center;
  gap: 12px;
}

.back-btn {
  width: 36px;
  height: 36px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 100px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: background 0.15s;
}
.back-btn:hover { background: rgba(255, 255, 255, 0.35); }

.logo-wrap {
  display: flex;
  align-items: center;
  gap: 6px;
  flex: 1;
}

.logo-img {
  height: 28px;
  filter: brightness(10);
}

.logo-text {
  font-family: 'Public Sans', sans-serif;
  font-size: 18px;
  color: #ffffff;
  letter-spacing: -0.5px;
}
.logo-text strong { font-weight: 700; }

.icon-btn {
  width: 40px;
  height: 40px;
  border-radius: 100px;
  background: #ffffff;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.15s;
  flex-shrink: 0;
}
.icon-btn:hover { background: #f3f4f6; }

/* Search row */
.search-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.flex-1 { flex: 1; }

.search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.85);
  border-radius: 100px;
  padding: 10px 8px 10px 14px;
  height: 48px;
}

.search-input {
  flex: 1;
  background: none;
  border: none;
  outline: none;
  font-family: 'Public Sans', sans-serif;
  font-size: 13px;
  color: #314158;
  letter-spacing: -0.01em;
  min-width: 0;
}
.search-input::placeholder { color: #494949; font-size: 12px; }

.search-action-btn {
  width: 36px;
  height: 36px;
  background: #393C40;
  border: none;
  border-radius: 100px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.city-bar {
  display: flex;
  align-items: center;
  gap: 4px;
  background: #ffffff;
  border-radius: 100px;
  padding: 10px 8px 10px 14px;
  height: 48px;
  min-width: 100px;
}

.city-input {
  width: 50px;
  background: none;
  border: none;
  outline: none;
  font-family: 'Public Sans', sans-serif;
  font-size: 13px;
  color: #494949;
}
.city-input::placeholder { color: #494949; }

.city-chevron {
  width: 36px;
  height: 36px;
  background: #393C40;
  border: none;
  border-radius: 100px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

/* ── Filter bar ───────────────────────────────────────────────────────────── */
.filter-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 29px;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1);
  border-radius: 100px;
  margin: 16px 14px 0;
}

.filter-icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0;
  flex-shrink: 0;
}

.filter-pill-btn {
  flex: 1;
  background: #FC5A15;
  border: none;
  border-radius: 100px;
  padding: 8px 24px;
  color: #ffffff;
  font-family: 'Public Sans', sans-serif;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.15s;
  text-align: center;
}
.filter-pill-btn:hover { background: #e04e0d; }

/* ── Content ──────────────────────────────────────────────────────────────── */
.content {
  padding: 16px 14px 0;
}

/* States */
.state-msg {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 60px 24px;
  color: #62748E;
  font-size: 15px;
  text-align: center;
}
.state-error { color: #EF4444; }

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14px;
  padding: 60px 24px;
  color: #9CA3AF;
  font-size: 14px;
  text-align: center;
}

/* ── Offer cards ──────────────────────────────────────────────────────────── */
.offers-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.offer-card {
  background: #ffffff;
  border: 0.61px solid #FC5A15;
  box-shadow: 0px 0.61px 1.84px rgba(0,0,0,0.1), 0px 0.61px 1.23px -0.61px rgba(0,0,0,0.1);
  border-radius: 9.8px;
  padding: 12px 15px 0.61px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: box-shadow 0.15s;
}

.offer-card:hover {
  box-shadow: 0px 4px 16px rgba(252,90,21,0.15);
}

.offer-boosted {
  border-color: #FC5A15;
  border-width: 1.5px;
  background: linear-gradient(180deg, #FFF8F5 0%, #FFFFFF 30%);
}

.boost-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  background: #FFF5F0;
  color: #FC5A15;
  font-family: 'Public Sans', sans-serif;
  font-weight: 600;
  font-size: 9px;
  padding: 3px 10px;
  border-radius: 20px;
  width: fit-content;
}

.offer-accepted {
  border-color: #86EFAC;
  background: #F0FDF4;
}

.offer-rejected {
  opacity: 0.55;
}

/* Artisan row */
.artisan-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.avatar-wrap {
  position: relative;
  flex-shrink: 0;
  cursor: pointer;
}

.avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: 1.9px solid #ffffff;
  box-shadow: 0px 4.77px 7.15px -1.43px rgba(0,0,0,0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  color: #ffffff;
  overflow: hidden;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 14px;
  height: 14px;
  background: #00C950;
  border: 0.66px solid #ffffff;
  border-radius: 50%;
}

.artisan-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
}

.artisan-name {
  font-family: 'Public Sans', sans-serif;
  font-size: 11px;
  color: #314158;
  font-weight: 400;
  cursor: pointer;
  transition: color 0.15s;
}
.artisan-name:hover { color: #FC5A15; }

.artisan-specialty {
  font-size: 8.5px;
  color: #62748E;
  letter-spacing: -0.09px;
}

.rating-row {
  display: flex;
  align-items: center;
  gap: 5px;
}

.rating-badge {
  display: flex;
  align-items: center;
  gap: 2.5px;
  background: #FEFCE8;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 8.5px;
  color: #314158;
}

.review-count {
  font-size: 7.5px;
  color: #62748E;
}

/* Artisan right: badge + time */
.artisan-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 6px;
  flex-shrink: 0;
}

.profil-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  background: #393C40;
  border: none;
  border-radius: 20px;
  padding: 4px 10px;
  color: #ffffff;
  font-size: 8.5px;
  font-family: 'Public Sans', sans-serif;
  cursor: pointer;
  transition: background 0.15s;
}
.profil-badge:hover { background: #1a1d20; }

.response-time {
  font-size: 8px;
  color: #62748E;
  letter-spacing: -0.09px;
  white-space: nowrap;
}

/* Price box */
.price-box {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  background: #FFEFE8;
  border-radius: 8.5px;
  padding: 10px 12px;
}

.price-col {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.text-right { text-align: right; }

.price-label {
  font-size: 7.5px;
  color: #62748E;
}

.price-amount {
  font-size: 18px;
  color: #FC5A15;
  font-weight: 400;
  line-height: 1.2;
  letter-spacing: 0.24px;
}

.currency { font-size: 14px; }

.duration-value {
  font-size: 11px;
  color: #314158;
  letter-spacing: -0.27px;
}

/* Status badge */
.status-badge {
  text-align: center;
  font-size: 12px;
  font-weight: 600;
  padding: 6px;
  border-radius: 8px;
}
.status-accepted { background: #DCFCE7; color: #16A34A; }
.status-rejected  { background: #FEF2F2; color: #C10007; }

/* CTA buttons */
.cta-row {
  display: flex;
  gap: 21px;
  padding-bottom: 10px;
}

.btn-reject {
  flex: 1;
  height: 35px;
  border: 0.41px solid #FC5A15;
  background: none;
  border-radius: 20px;
  color: #FC5A15;
  font-size: 10px;
  font-family: 'Public Sans', sans-serif;
  cursor: pointer;
  transition: background 0.15s;
  letter-spacing: -0.19px;
}
.btn-reject:hover { background: #FFF7ED; }
.btn-reject:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-accept {
  flex: 1;
  height: 35px;
  border: none;
  background: #FC5A15;
  border-radius: 20px;
  color: #ffffff;
  font-size: 10px;
  font-family: 'Public Sans', sans-serif;
  cursor: pointer;
  transition: background 0.15s;
  letter-spacing: -0.19px;
}
.btn-accept:hover { background: #e04e0d; }
.btn-accept:disabled { opacity: 0.5; cursor: not-allowed; }

/* ── Address modal ────────────────────────────────────────────────────────── */
.addr-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 16px;
}

.addr-modal {
  background: #fff;
  border-radius: 16px;
  width: 100%;
  max-width: 420px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,.25);
  display: flex;
  flex-direction: column;
}

.addr-header {
  background: #FC5A15;
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.addr-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.addr-icon-wrap {
  width: 40px;
  height: 40px;
  background: #fff;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.addr-title {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
}

.addr-sub {
  color: rgba(255,255,255,.78);
  font-size: 12px;
  margin-top: 1px;
}

.addr-close-btn {
  background: rgba(255,255,255,.2);
  border: none;
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #fff;
  transition: background .15s;
  flex-shrink: 0;
}
.addr-close-btn:hover { background: rgba(255,255,255,.35); }

.addr-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.addr-notice {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  background: #FFFBEB;
  border: 1px solid #FDE68A;
  border-radius: 10px;
  padding: 12px 14px;
  font-size: 13px;
  color: #92400E;
  line-height: 1.5;
}

.addr-field { display: flex; flex-direction: column; gap: 6px; }

.addr-label {
  font-size: 13px;
  color: #314158;
  font-weight: 500;
}

.addr-input-row { display: flex; gap: 8px; align-items: center; }

.addr-input {
  flex: 1;
  padding: 10px 14px;
  border: 1px solid #E5E7EB;
  border-radius: 10px;
  font-size: 14px;
  color: #314158;
  font-family: 'Public Sans', sans-serif;
  outline: none;
  transition: border-color .15s;
}
.addr-input:focus { border-color: #FC5A15; }

.addr-footer {
  padding: 16px 20px;
  display: flex;
  gap: 10px;
  border-top: 1px solid #F3F4F6;
}

.addr-btn-cancel {
  flex: 1;
  padding: 11px;
  border: 1px solid #E5E7EB;
  background: none;
  border-radius: 10px;
  font-size: 14px;
  font-family: 'Public Sans', sans-serif;
  color: #62748E;
  cursor: pointer;
  transition: background .15s;
}
.addr-btn-cancel:hover { background: #F9FAFB; }

.addr-btn-confirm {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 11px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-family: 'Public Sans', sans-serif;
  cursor: pointer;
  transition: background .15s;
}
.addr-btn-confirm:hover { background: #e04e0d; }
.addr-btn-confirm:disabled { opacity: 0.6; cursor: not-allowed; }

/* ── Spinner ──────────────────────────────────────────────────────────────── */
.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid rgba(252, 90, 21, 0.2);
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
.spinner.small { width: 16px; height: 16px; border-width: 2px; }

@keyframes spin { to { transform: rotate(360deg); } }

/* ── Toast ────────────────────────────────────────────────────────────────── */
.toast {
  position: fixed;
  bottom: 90px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 500;
  z-index: 9999;
  box-shadow: 0 8px 24px rgba(0,0,0,.15);
  white-space: nowrap;
}

.toast-success { background: #16A34A; color: #fff; }
.toast-error   { background: #EF4444; color: #fff; }

.toast-enter-active, .toast-leave-active { transition: opacity 0.3s, transform 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(16px); }

/* ── Responsive: Tablet (768px+) ─────────────────────────────────────────── */
@media (min-width: 768px) {
  .page {
    max-width: 720px;
  }

  .top-section {
    padding: 56px 40px 24px;
    gap: 20px;
    border-radius: 0 0 28px 28px;
  }

  .topbar {
    gap: 16px;
  }

  .logo-text {
    font-size: 22px;
  }

  .logo-img {
    height: 34px;
  }

  .back-btn {
    width: 42px;
    height: 42px;
  }

  .icon-btn {
    width: 46px;
    height: 46px;
  }

  .search-bar {
    padding: 12px 12px 12px 18px;
    height: 52px;
    gap: 10px;
  }

  .search-input {
    font-size: 15px;
  }
  .search-input::placeholder {
    font-size: 14px;
  }

  .city-bar {
    min-width: 140px;
    height: 52px;
    padding: 12px 10px 12px 18px;
  }

  .city-input {
    width: 80px;
    font-size: 15px;
  }

  .filter-bar {
    padding: 16px 40px;
    margin: 20px 20px 0;
  }

  .filter-pill-btn {
    font-size: 15px;
    padding: 10px 28px;
  }

  .content {
    padding: 20px 20px 0;
  }

  .offers-list {
    gap: 18px;
  }

  .offer-card {
    padding: 16px 20px 4px;
    border-radius: 12px;
    gap: 14px;
  }

  .artisan-row {
    gap: 14px;
  }

  .avatar {
    width: 68px;
    height: 68px;
    font-size: 18px;
  }

  .artisan-name {
    font-size: 14px;
  }

  .artisan-specialty {
    font-size: 11px;
  }

  .rating-badge {
    font-size: 11px;
    padding: 3px 8px;
  }

  .review-count {
    font-size: 10px;
  }

  .profil-badge {
    font-size: 11px;
    padding: 6px 14px;
  }

  .response-time {
    font-size: 10px;
  }

  .price-box {
    padding: 14px 18px;
    border-radius: 10px;
  }

  .price-label {
    font-size: 10px;
  }

  .price-amount {
    font-size: 22px;
  }

  .currency {
    font-size: 16px;
  }

  .duration-value {
    font-size: 14px;
  }

  .status-badge {
    font-size: 14px;
    padding: 8px;
  }

  .cta-row {
    gap: 24px;
    padding-bottom: 14px;
  }

  .btn-reject,
  .btn-accept {
    height: 40px;
    font-size: 13px;
  }

  .state-msg {
    font-size: 17px;
    padding: 80px 32px;
  }

  .empty-state {
    font-size: 16px;
    padding: 80px 32px;
  }

  /* Modal */
  .addr-modal {
    max-width: 480px;
  }

  .addr-header {
    padding: 22px 24px;
  }

  .addr-title {
    font-size: 18px;
  }

  .addr-sub {
    font-size: 13px;
  }

  .addr-body {
    padding: 24px;
    gap: 16px;
  }

  .addr-notice {
    font-size: 14px;
    padding: 14px 16px;
  }

  .addr-input {
    padding: 12px 16px;
    font-size: 15px;
  }

  .addr-footer {
    padding: 18px 24px;
    gap: 12px;
  }

  .addr-btn-cancel,
  .addr-btn-confirm {
    font-size: 15px;
    padding: 12px;
  }

  .toast {
    font-size: 15px;
    padding: 14px 28px;
  }
}

/* ── Responsive: Small mobile (max 640px) ────────────────────────────────── */
@media (max-width: 640px) {
  .page {
    max-width: 100%;
  }

  .top-section {
    padding: 48px 20px 18px;
    gap: 14px;
  }

  .search-row {
    gap: 8px;
  }

  .search-bar {
    padding: 8px 6px 8px 12px;
    height: 44px;
    gap: 6px;
  }

  .search-input {
    font-size: 12px;
  }
  .search-input::placeholder {
    font-size: 11px;
  }

  .search-action-btn {
    width: 32px;
    height: 32px;
  }

  .city-bar {
    min-width: 88px;
    height: 44px;
    padding: 8px 6px 8px 12px;
  }

  .city-input {
    width: 42px;
    font-size: 12px;
  }

  .city-chevron {
    width: 32px;
    height: 32px;
  }

  .filter-bar {
    padding: 12px 20px;
    margin: 14px 10px 0;
  }

  .filter-pill-btn {
    font-size: 13px;
    padding: 7px 20px;
  }

  .content {
    padding: 14px 10px 0;
  }

  .offer-card {
    padding: 10px 12px 0.5px;
    gap: 10px;
  }

  .artisan-row {
    gap: 8px;
  }

  .avatar {
    width: 54px;
    height: 54px;
    font-size: 14px;
  }

  .online-dot {
    width: 12px;
    height: 12px;
  }

  .price-box {
    padding: 8px 10px;
  }

  .price-amount {
    font-size: 16px;
  }

  .currency {
    font-size: 12px;
  }

  .cta-row {
    gap: 14px;
    padding-bottom: 8px;
  }

  .btn-reject,
  .btn-accept {
    height: 33px;
    font-size: 9px;
  }

  /* Modal */
  .addr-overlay {
    padding: 12px;
  }

  .addr-modal {
    max-width: 100%;
  }

  .addr-header {
    padding: 14px 16px;
  }

  .addr-title {
    font-size: 14px;
  }

  .addr-sub {
    font-size: 11px;
  }

  .addr-icon-wrap {
    width: 34px;
    height: 34px;
  }

  .addr-body {
    padding: 16px;
    gap: 12px;
  }

  .addr-notice {
    font-size: 12px;
    padding: 10px 12px;
  }

  .addr-input {
    font-size: 13px;
    padding: 9px 12px;
  }

  .addr-footer {
    padding: 14px 16px;
  }

  .addr-btn-cancel,
  .addr-btn-confirm {
    font-size: 13px;
    padding: 10px;
  }

  .toast {
    font-size: 13px;
    padding: 10px 20px;
    bottom: 80px;
  }
}

/* ── Responsive: Extra small mobile (max 480px) ─────────────────────────── */
@media (max-width: 480px) {
  .top-section {
    padding: 44px 14px 16px;
    gap: 12px;
    border-radius: 0 0 16px 16px;
  }

  .topbar {
    gap: 8px;
  }

  .back-btn {
    width: 32px;
    height: 32px;
  }

  .logo-text {
    font-size: 16px;
  }

  .logo-img {
    height: 24px;
  }

  .icon-btn {
    width: 36px;
    height: 36px;
  }

  .search-row {
    flex-direction: column;
    gap: 8px;
  }

  .search-bar {
    width: 100%;
    height: 42px;
  }

  .city-bar {
    width: 100%;
    min-width: unset;
    height: 42px;
  }

  .city-input {
    width: auto;
    flex: 1;
  }

  .filter-bar {
    padding: 10px 14px;
    margin: 12px 8px 0;
    gap: 8px;
  }

  .filter-pill-btn {
    font-size: 12px;
    padding: 6px 16px;
  }

  .content {
    padding: 12px 8px 0;
  }

  .offers-list {
    gap: 10px;
  }

  .offer-card {
    padding: 8px 10px 0.5px;
    gap: 8px;
    border-radius: 8px;
  }

  .artisan-row {
    flex-wrap: wrap;
    gap: 8px;
  }

  .avatar {
    width: 48px;
    height: 48px;
    font-size: 13px;
  }

  .online-dot {
    width: 10px;
    height: 10px;
  }

  .artisan-name {
    font-size: 10px;
  }

  .artisan-specialty {
    font-size: 8px;
  }

  .rating-badge {
    font-size: 8px;
    padding: 1.5px 5px;
  }

  .review-count {
    font-size: 7px;
  }

  .profil-badge {
    font-size: 7.5px;
    padding: 3px 8px;
  }

  .response-time {
    font-size: 7px;
  }

  .price-box {
    padding: 7px 8px;
    border-radius: 7px;
  }

  .price-label {
    font-size: 7px;
  }

  .price-amount {
    font-size: 15px;
  }

  .currency {
    font-size: 11px;
  }

  .duration-value {
    font-size: 10px;
  }

  .status-badge {
    font-size: 11px;
    padding: 5px;
    border-radius: 6px;
  }

  .cta-row {
    gap: 10px;
    padding-bottom: 7px;
  }

  .btn-reject,
  .btn-accept {
    height: 30px;
    font-size: 9px;
    border-radius: 16px;
  }

  .state-msg {
    padding: 40px 16px;
    font-size: 13px;
  }

  .empty-state {
    padding: 40px 16px;
    font-size: 13px;
  }

  /* Modal */
  .addr-overlay {
    padding: 8px;
    align-items: flex-end;
  }

  .addr-modal {
    border-radius: 16px 16px 0 0;
    max-width: 100%;
  }

  .addr-header {
    padding: 12px 14px;
  }

  .addr-header-left {
    gap: 8px;
  }

  .addr-icon-wrap {
    width: 32px;
    height: 32px;
    border-radius: 8px;
  }

  .addr-title {
    font-size: 13px;
  }

  .addr-sub {
    font-size: 10px;
  }

  .addr-close-btn {
    width: 28px;
    height: 28px;
  }

  .addr-body {
    padding: 14px;
    gap: 10px;
  }

  .addr-notice {
    font-size: 11px;
    padding: 8px 10px;
    border-radius: 8px;
  }

  .addr-label {
    font-size: 12px;
  }

  .addr-input {
    font-size: 13px;
    padding: 8px 10px;
    border-radius: 8px;
  }

  .addr-footer {
    padding: 12px 14px;
    gap: 8px;
  }

  .addr-btn-cancel,
  .addr-btn-confirm {
    font-size: 12px;
    padding: 9px;
    border-radius: 8px;
  }

  .toast {
    font-size: 12px;
    padding: 10px 16px;
    bottom: 75px;
    max-width: calc(100vw - 32px);
    white-space: normal;
    text-align: center;
  }
}
</style>

<template>
  <div class="demandes-page">

    <!-- ── Header ─────────────────────────────────────────────────────── -->
    <div class="page-header">
      <button class="btn-back" @click="$router.back()">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <polyline points="15 18 9 12 15 6"/>
        </svg>
        Retour
      </button>
      <div class="header-center">
        <h1 class="page-title">Demandes des clients</h1>
        <span v-if="!loading" class="badge-count">{{ total }} demande{{ total !== 1 ? 's' : '' }}</span>
      </div>
    </div>

    <!-- ── Filters ─────────────────────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="search-wrap">
        <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          v-model="searchQ"
          type="text"
          placeholder="Rechercher par titre, description ou ville…"
          class="search-input"
          @input="debouncedLoad"
        />
        <button v-if="searchQ" class="clear-search" @click="searchQ = ''; loadRequests()">×</button>
      </div>

      <select v-model="dateFilter" class="filter-select" @change="loadRequests">
        <option value="">Toutes les dates</option>
        <option value="today">Aujourd'hui</option>
        <option value="week">Cette semaine</option>
        <option value="month">Ce mois</option>
      </select>

      <select v-model="categoryFilter" class="filter-select" @change="loadRequests">
        <option value="">Tous les services</option>
        <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
      </select>
    </div>

    <!-- ── Loading ─────────────────────────────────────────────────────── -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Chargement des demandes…</p>
    </div>

    <!-- ── Empty state ─────────────────────────────────────────────────── -->
    <div v-else-if="requests.length === 0" class="empty-state">
      <div class="empty-icon">📋</div>
      <h3>Aucune demande disponible</h3>
      <p>Il n'y a pas de demandes ouvertes pour le moment.<br>Revenez plus tard !</p>
    </div>

    <!-- ── Request cards ──────────────────────────────────────────────── -->
    <div v-else class="cards-list">
      <div
        v-for="req in requests"
        :key="req.id"
        class="request-card"
        :class="{ 'is-refused': refusedIds.has(req.id) }"
      >
        <!-- Card top row: avatar + meta -->
        <div class="card-top">
          <div class="client-avatar" :style="{ background: avatarColor(req.client?.user?.name) }">
            {{ initials(req.client?.user?.name) }}
          </div>
          <div class="client-meta">
            <span class="client-name">{{ req.client?.user?.name ?? 'Client' }}</span>
            <span class="meta-sep">·</span>
            <span class="time-ago">{{ timeAgo(req.created_at) }}</span>
            <span class="meta-sep">·</span>
            <span class="req-date">{{ formatDate(req.created_at) }}</span>
          </div>
          <div class="card-badges">
            <span class="badge-category">{{ req.category?.name }}</span>
            <span class="badge-service">{{ req.service_type?.name }}</span>
          </div>
        </div>

        <!-- Title & description -->
        <h3 class="req-title">{{ req.title || req.service_type?.name || 'Sans titre' }}</h3>
        <p class="req-desc">{{ truncate(req.description, 140) }}</p>

        <!-- Photos (up to 2) -->
        <div v-if="req.photos && req.photos.length" class="photos-row">
          <img
            v-for="(ph, i) in req.photos.slice(0, 2)"
            :key="i"
            :src="ph.photo_url"
            class="req-photo"
            alt="photo"
          />
          <div v-if="req.photos.length > 2" class="photo-more">+{{ req.photos.length - 2 }}</div>
        </div>

        <!-- Footer info -->
        <div class="card-footer">
          <div class="footer-left">
            <div class="location">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                <circle cx="12" cy="10" r="3"/>
              </svg>
              {{ req.city }}
            </div>
            <div v-if="req.budget_min || req.budget_max" class="budget">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
              </svg>
              {{ budgetLabel(req) }}
            </div>
          </div>
          <div class="card-actions">
            <button
              class="btn-refuse"
              :disabled="refusedIds.has(req.id)"
              @click="refuseRequest(req.id)"
            >
              Refuser
            </button>
            <button
              class="btn-accept"
              @click="openOfferModal(req)"
            >
              Accepter &amp; contacter
            </button>
            <button
              class="btn-profile"
              @click="viewClientProfile(req.client)"
              title="Voir le profil du client"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Pagination ──────────────────────────────────────────────────── -->
    <div v-if="lastPage > 1" class="pagination">
      <button :disabled="currentPage <= 1" @click="goPage(currentPage - 1)" class="page-btn">‹</button>
      <span class="page-info">{{ currentPage }} / {{ lastPage }}</span>
      <button :disabled="currentPage >= lastPage" @click="goPage(currentPage + 1)" class="page-btn">›</button>
    </div>

    <!-- ── "Proposer vos services" Modal ──────────────────────────────── -->
    <Teleport to="body">
      <div v-if="modalOpen" class="modal-overlay" @click.self="closeModal">
        <div class="modal">
          <button class="modal-close" @click="closeModal">×</button>

          <h2 class="modal-title">Proposer vos services</h2>

          <!-- Request summary card inside modal -->
          <div v-if="selectedReq" class="modal-summary">
            <div class="summary-icon">{{ categoryEmoji(selectedReq.category?.name) }}</div>
            <div class="summary-info">
              <span class="summary-category">{{ selectedReq.category?.name }}</span>
              <span class="summary-title">{{ selectedReq.title || selectedReq.service_type?.name || 'Sans titre' }}</span>
              <span class="summary-client">Client : <b>{{ selectedReq.client?.user?.name }}</b></span>
              <span v-if="selectedReq.budget_min || selectedReq.budget_max" class="summary-budget">
                Budget : {{ budgetLabel(selectedReq) }}
              </span>
            </div>
          </div>

          <!-- Offer form -->
          <form @submit.prevent="sendOffer" class="offer-form">
            <div class="form-row two-col">
              <div class="form-group">
                <label>Votre prix *</label>
                <div class="input-suffix-wrap">
                  <input
                    v-model.number="offerForm.price"
                    type="number"
                    min="0"
                    step="0.01"
                    placeholder="0"
                    class="form-input"
                    required
                  />
                  <span class="input-suffix">DH</span>
                </div>
              </div>
              <div class="form-group">
                <label>Durée estimée *</label>
                <div class="input-suffix-wrap">
                  <input
                    v-model.number="offerForm.duration"
                    type="number"
                    min="1"
                    placeholder="60"
                    class="form-input"
                    required
                  />
                  <span class="input-suffix">min</span>
                </div>
              </div>
            </div>

            <div class="form-group">
              <label>Message pour le client <span class="optional">(optionnel)</span></label>
              <textarea
                v-model="offerForm.description"
                rows="4"
                maxlength="1000"
                placeholder="Décrivez votre approche, vos qualifications…"
                class="form-textarea"
              ></textarea>
              <span class="char-count">{{ offerForm.description.length }}/1000</span>
            </div>

            <div v-if="offerError" class="form-error">{{ offerError }}</div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="closeModal">Annuler</button>
              <button type="submit" class="btn-send" :disabled="sendingOffer">
                <span v-if="sendingOffer" class="btn-spinner"></span>
                {{ sendingOffer ? 'Envoi…' : 'Envoyer' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- ── Toast ──────────────────────────────────────────────────────── -->
    <div v-if="toast.visible" :class="['toast', toast.type]">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getArtisanServiceRequests, submitOffer, getCategories } from '../../api/serviceRequests.js'

const router = useRouter()

// ── State ────────────────────────────────────────────────────────────────
const requests    = ref([])
const categories  = ref([])
const loading     = ref(false)
const total       = ref(0)
const currentPage = ref(1)
const lastPage    = ref(1)

const searchQ       = ref('')
const dateFilter    = ref('')
const categoryFilter = ref('')

const refusedIds = ref(new Set())

// Modal
const modalOpen     = ref(false)
const selectedReq   = ref(null)
const sendingOffer  = ref(false)
const offerError    = ref('')
const offerForm     = ref({ price: '', duration: '', description: '' })

// Toast
const toast = ref({ visible: false, message: '', type: 'success' })

// ── Debounce helper ──────────────────────────────────────────────────────
let debounceTimer = null
function debouncedLoad() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => loadRequests(), 400)
}

// ── Data loading ─────────────────────────────────────────────────────────
async function loadRequests(page = 1) {
  loading.value = true
  try {
    const params = { page }
    if (searchQ.value)        params.search      = searchQ.value
    if (dateFilter.value)     params.date        = dateFilter.value
    if (categoryFilter.value) params.category_id = categoryFilter.value

    const res = await getArtisanServiceRequests(params)
    const d = res.data
    requests.value  = d.data
    total.value     = d.total
    currentPage.value = d.current_page
    lastPage.value  = d.last_page
  } catch (e) {
    showToast('Erreur lors du chargement des demandes.', 'error')
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  try {
    const res = await getCategories()
    categories.value = res.data.data
  } catch {}
}

function goPage(p) {
  loadRequests(p)
}

// ── Refuse ───────────────────────────────────────────────────────────────
function refuseRequest(id) {
  refusedIds.value = new Set([...refusedIds.value, id])
}

// ── Modal ────────────────────────────────────────────────────────────────
function openOfferModal(req) {
  selectedReq.value = req
  offerForm.value   = { price: '', duration: '', description: '' }
  offerError.value  = ''
  modalOpen.value   = true
}

function closeModal() {
  modalOpen.value  = false
  selectedReq.value = null
}

async function sendOffer() {
  if (!selectedReq.value) return
  sendingOffer.value = true
  offerError.value   = ''
  try {
    await submitOffer(selectedReq.value.id, {
      proposed_price:     offerForm.value.price,
      estimated_duration: offerForm.value.duration,
      description:        offerForm.value.description || null,
    })
    // Remove the request from list (artisan now has a pending offer)
    requests.value = requests.value.filter(r => r.id !== selectedReq.value.id)
    total.value = Math.max(0, total.value - 1)
    closeModal()
    showToast('Votre offre a été envoyée avec succès !', 'success')
  } catch (err) {
    offerError.value = err.response?.data?.error ?? 'Impossible d\'envoyer l\'offre.'
  } finally {
    sendingOffer.value = false
  }
}

// ── Client profile ────────────────────────────────────────────────────────
function viewClientProfile(client) {
  if (client?.id) router.push(`/artisan/clients/${client.id}`)
}

// ── Toast ─────────────────────────────────────────────────────────────────
function showToast(message, type = 'success') {
  toast.value = { visible: true, message, type }
  setTimeout(() => { toast.value.visible = false }, 3500)
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
  if (m < 1)  return 'À l\'instant'
  if (m < 60) return `Il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `Il y a ${h}h`
  const d = Math.floor(h / 24)
  return `Il y a ${d}j`
}

function formatDate(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function truncate(text, len) {
  if (!text) return ''
  return text.length > len ? text.slice(0, len) + '…' : text
}

function budgetLabel(req) {
  const min = req.budget_min ? `${Number(req.budget_min).toLocaleString('fr-FR')} DH` : ''
  const max = req.budget_max ? `${Number(req.budget_max).toLocaleString('fr-FR')} DH` : ''
  if (min && max) return `${min} – ${max}`
  return min || max || ''
}

const CAT_EMOJIS = {
  'Plomberie': '🔧', 'Électricité': '⚡', 'Menuiserie': '🪚', 'Peinture': '🎨',
  'Maçonnerie': '🧱', 'Carrelage': '🏠', 'Climatisation': '❄️', 'Jardinage': '🌿',
  'Nettoyage': '🧹', 'Déménagement': '📦', 'Serrurerie': '🔑', 'Vitrerie': '🪟',
  'Toiture': '🏗️', 'Isolation': '🛡️', 'Domotique': '💡',
}
function categoryEmoji(name) {
  return CAT_EMOJIS[name] ?? '🔨'
}

// ── Init ──────────────────────────────────────────────────────────────────
onMounted(() => {
  loadRequests()
  loadCategories()
})
</script>

<style scoped>
/* ── Layout ─────────────────────────────────────────────────────────────── */
.demandes-page {
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
.header-center {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
}
.page-title {
  font-size: 20px;
  font-weight: 700;
  color: #314158;
  margin: 0;
}
.badge-count {
  background: #FFF0E9;
  color: #FC5A15;
  font-size: 13px;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 20px;
}

/* ── Filters ────────────────────────────────────────────────────────────── */
.filters-bar {
  padding: 16px 24px;
  background: #fff;
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: center;
  border-bottom: 1px solid #E8ECF0;
}
.search-wrap {
  flex: 1;
  min-width: 220px;
  position: relative;
  display: flex;
  align-items: center;
}
.search-icon {
  position: absolute;
  left: 12px;
  color: #62748E;
  pointer-events: none;
}
.search-input {
  width: 100%;
  padding: 10px 36px 10px 38px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  font-size: 14px;
  color: #314158;
  outline: none;
  transition: border-color 0.2s;
  background: #F9FAFB;
}
.search-input:focus { border-color: #FC5A15; background: #fff; }
.clear-search {
  position: absolute;
  right: 10px;
  background: none;
  border: none;
  color: #62748E;
  font-size: 18px;
  cursor: pointer;
  line-height: 1;
}
.filter-select {
  padding: 10px 14px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  font-size: 14px;
  color: #314158;
  background: #F9FAFB;
  outline: none;
  cursor: pointer;
  min-width: 160px;
  transition: border-color 0.2s;
}
.filter-select:focus { border-color: #FC5A15; }

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
.empty-state p { font-size: 14px; line-height: 1.6; }

/* ── Cards list ─────────────────────────────────────────────────────────── */
.cards-list {
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-width: 860px;
  margin: 0 auto;
}
.request-card {
  background: #fff;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 1px 8px rgba(49,65,88,0.07);
  transition: box-shadow 0.2s, opacity 0.2s;
}
.request-card:hover { box-shadow: 0 4px 20px rgba(49,65,88,0.12); }
.request-card.is-refused { opacity: 0.45; pointer-events: none; }

/* Card top row */
.card-top {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}
.client-avatar {
  width: 42px; height: 42px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 700;
  font-size: 15px;
  flex-shrink: 0;
}
.client-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #62748E;
  flex: 1;
  flex-wrap: wrap;
}
.client-name { font-weight: 600; color: #314158; font-size: 14px; }
.meta-sep { color: #C5CDD8; }
.time-ago { color: #62748E; }
.req-date { color: #62748E; }
.card-badges { display: flex; gap: 8px; flex-wrap: wrap; }
.badge-category, .badge-service {
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}
.badge-category { background: #FFF0E9; color: #FC5A15; }
.badge-service  { background: #EFF6FF; color: #3B82F6; }

/* Title & desc */
.req-title {
  font-size: 16px;
  font-weight: 700;
  color: #314158;
  margin: 0 0 6px;
}
.req-desc {
  font-size: 14px;
  color: #62748E;
  line-height: 1.5;
  margin: 0 0 12px;
}

/* Photos */
.photos-row {
  display: flex;
  gap: 8px;
  margin-bottom: 14px;
}
.req-photo {
  width: 90px;
  height: 70px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #E8ECF0;
}
.photo-more {
  width: 90px;
  height: 70px;
  border-radius: 8px;
  background: #F5F6FA;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #62748E;
  border: 1px dashed #C5CDD8;
}

/* Card footer */
.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 14px;
  border-top: 1px solid #F0F2F5;
}
.footer-left {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}
.location, .budget {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: #62748E;
}
.card-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.btn-refuse {
  padding: 9px 18px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  background: #fff;
  color: #62748E;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-refuse:hover:not(:disabled) { border-color: #C5CDD8; background: #F5F6FA; }
.btn-refuse:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-accept {
  padding: 9px 20px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #FC5A15, #FF7A3D);
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  box-shadow: 0 2px 8px rgba(252,90,21,0.25);
}
.btn-accept:hover { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(252,90,21,0.35); }
.btn-profile {
  width: 38px; height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  background: #fff;
  color: #62748E;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-profile:hover { border-color: #FC5A15; color: #FC5A15; background: #FFF0E9; }

/* ── Pagination ─────────────────────────────────────────────────────────── */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 24px;
}
.page-btn {
  width: 40px; height: 40px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  background: #fff;
  font-size: 18px;
  cursor: pointer;
  color: #314158;
  transition: all 0.15s;
}
.page-btn:hover:not(:disabled) { border-color: #FC5A15; color: #FC5A15; }
.page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.page-info { font-size: 14px; color: #62748E; font-weight: 500; }

/* ── Modal ──────────────────────────────────────────────────────────────── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(49,65,88,0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
  padding: 16px;
}
.modal {
  background: #fff;
  border-radius: 20px;
  padding: 32px;
  width: 100%;
  max-width: 480px;
  position: relative;
  box-shadow: 0 24px 60px rgba(0,0,0,0.18);
  animation: slideUp 0.25s ease;
}
@keyframes slideUp { from { transform: translateY(30px); opacity: 0; } to { transform: none; opacity: 1; } }
.modal-close {
  position: absolute;
  top: 16px; right: 20px;
  background: none; border: none;
  font-size: 24px; color: #62748E;
  cursor: pointer; line-height: 1;
}
.modal-close:hover { color: #314158; }
.modal-title {
  font-size: 20px;
  font-weight: 700;
  color: #314158;
  margin: 0 0 20px;
}

/* Request summary inside modal */
.modal-summary {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  background: #F9FAFB;
  border: 1px solid #E8ECF0;
  border-radius: 12px;
  padding: 14px;
  margin-bottom: 24px;
}
.summary-icon { font-size: 32px; line-height: 1; }
.summary-info {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.summary-category { font-size: 12px; font-weight: 600; color: #FC5A15; text-transform: uppercase; letter-spacing: 0.5px; }
.summary-title { font-size: 15px; font-weight: 700; color: #314158; }
.summary-client, .summary-budget { font-size: 13px; color: #62748E; }

/* Offer form */
.offer-form { display: flex; flex-direction: column; gap: 18px; }
.form-row.two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 13px; font-weight: 600; color: #314158; }
.optional { font-weight: 400; color: #62748E; }
.input-suffix-wrap { position: relative; display: flex; align-items: center; }
.form-input {
  width: 100%;
  padding: 11px 44px 11px 14px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  font-size: 15px;
  color: #314158;
  outline: none;
  background: #F9FAFB;
  transition: border-color 0.2s;
  box-sizing: border-box;
}
.form-input:focus { border-color: #FC5A15; background: #fff; }
.input-suffix {
  position: absolute;
  right: 14px;
  font-size: 13px;
  font-weight: 600;
  color: #62748E;
  pointer-events: none;
}
.form-textarea {
  padding: 11px 14px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  font-size: 14px;
  color: #314158;
  resize: vertical;
  outline: none;
  background: #F9FAFB;
  transition: border-color 0.2s;
  font-family: inherit;
}
.form-textarea:focus { border-color: #FC5A15; background: #fff; }
.char-count { font-size: 11px; color: #C5CDD8; text-align: right; }
.form-error {
  background: #FEF2F2;
  border: 1px solid #FCA5A5;
  color: #DC2626;
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 13px;
}
.modal-actions { display: flex; gap: 12px; justify-content: flex-end; }
.btn-cancel {
  padding: 11px 24px;
  border: 1.5px solid #E8ECF0;
  border-radius: 10px;
  background: #fff;
  color: #62748E;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-cancel:hover { border-color: #C5CDD8; background: #F5F6FA; }
.btn-send {
  padding: 11px 28px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #FC5A15, #FF7A3D);
  color: #fff;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 2px 8px rgba(252,90,21,0.25);
}
.btn-send:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(252,90,21,0.35); }
.btn-send:disabled { opacity: 0.7; cursor: not-allowed; transform: none; }
.btn-spinner {
  width: 16px; height: 16px;
  border: 2px solid rgba(255,255,255,0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

/* ── Toast ──────────────────────────────────────────────────────────────── */
.toast {
  position: fixed;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  padding: 14px 24px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  z-index: 9999;
  animation: fadeInUp 0.3s ease;
  white-space: nowrap;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.toast.success { background: #314158; color: #fff; }
.toast.error   { background: #DC2626; color: #fff; }
@keyframes fadeInUp { from { opacity: 0; transform: translateX(-50%) translateY(16px); } to { opacity: 1; transform: translateX(-50%) translateY(0); } }

@media (max-width: 600px) {
  .filters-bar { flex-direction: column; }
  .search-wrap { min-width: 100%; }
  .filter-select { min-width: 100%; }
  .card-top { flex-direction: column; align-items: flex-start; }
  .card-footer { flex-direction: column; align-items: flex-start; }
  .form-row.two-col { grid-template-columns: 1fr; }
}
</style>

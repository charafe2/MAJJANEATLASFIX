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
        <!-- Top row: client info left + category badge right -->
        <div class="card-top">
          <div class="client-info">
            <div class="client-avatar" :style="{ background: avatarColor(req.client?.user?.name) }">
              {{ initials(req.client?.user?.name) }}
            </div>
            <div class="client-meta">
              <span class="client-name">{{ req.client?.user?.name ?? 'Client' }}</span>
              <div class="meta-row">
                <svg class="meta-clock" width="14" height="14" viewBox="0 0 14 14" fill="none">
                  <circle cx="7" cy="7" r="5.5" stroke="#62748E" stroke-width="1.167"/>
                  <path d="M7 4.2V7l1.75 1.05" stroke="#62748E" stroke-width="1.167" stroke-linecap="round"/>
                </svg>
                <span class="meta-time">{{ formatTime(req.created_at) }}</span>
                <span class="meta-dot">•</span>
                <span class="meta-date">{{ formatDate(req.created_at) }}</span>
              </div>
            </div>
          </div>

          <!-- Category + service pill -->
          <div class="card-badge">
            <span class="badge-cat">{{ req.category?.name }}</span>
            <span class="badge-arrow">→</span>
            <span class="badge-svc">{{ req.service_type?.name }}</span>
          </div>
        </div>

        <!-- Title -->
        <h3 class="req-title">{{ req.title || req.service_type?.name || 'Sans titre' }}</h3>

        <!-- Description -->
        <p class="req-desc">
          {{ truncate(req.description, 200) }}<span v-if="(req.description?.length ?? 0) > 200" class="voir-plus">… voir plus</span>
        </p>

        <!-- Photos (up to 2) -->
        <div v-if="req.photos && req.photos.length" class="photos-row">
          <div
            v-for="(ph, i) in req.photos.slice(0, 2)"
            :key="i"
            class="photo-wrap"
          >
            <img :src="ph.photo_url" class="req-photo" alt="photo"/>
          </div>
          <div v-if="req.photos.length > 2" class="photo-more">+{{ req.photos.length - 2 }}</div>
        </div>

        <!-- Footer -->
        <div class="card-footer">
          <div class="footer-left">
            <div class="location">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" stroke="#FC5A15" stroke-width="1.5" stroke-linejoin="round"/>
                <circle cx="12" cy="9" r="2.5" stroke="#FC5A15" stroke-width="1.5"/>
              </svg>
              <span>{{ req.city }}</span>
            </div>
            <div v-if="req.budget_min || req.budget_max" class="budget">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.5">
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
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path d="M18 6L6 18M6 6l12 12" stroke="#62748E" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
              Refuser
            </button>
            <button class="btn-accept" @click="openOfferModal(req)">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path d="M20 6L9 17l-5-5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Accepter &amp; contacter
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

const searchQ        = ref('')
const dateFilter     = ref('')
const categoryFilter = ref('')

const refusedIds = ref(new Set())

// Modal
const modalOpen    = ref(false)
const selectedReq  = ref(null)
const sendingOffer = ref(false)
const offerError   = ref('')
const offerForm    = ref({ price: '', duration: '', description: '' })

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
    requests.value    = d.data
    total.value       = d.total
    currentPage.value = d.current_page
    lastPage.value    = d.last_page
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

function goPage(p) { loadRequests(p) }

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
  modalOpen.value   = false
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

function formatTime(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

function formatDate(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
}

function truncate(text, len) {
  if (!text) return ''
  return text.length > len ? text.slice(0, len) : text
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
function categoryEmoji(name) { return CAT_EMOJIS[name] ?? '🔨' }

// ── Init ──────────────────────────────────────────────────────────────────
onMounted(() => {
  loadRequests()
  loadCategories()
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* ── Page ─────────────────────────────────────────────────────────────── */
.demandes-page {
  font-family: 'Inter', sans-serif;
  min-height: 100vh;
  background: #F5F6FA;
  padding-bottom: 60px;
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
.search-icon { position: absolute; left: 12px; color: #62748E; pointer-events: none; }
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
  font-family: inherit;
}
.search-input:focus { border-color: #FC5A15; background: #fff; }
.clear-search {
  position: absolute; right: 10px;
  background: none; border: none;
  color: #62748E; font-size: 18px;
  cursor: pointer; line-height: 1;
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
  font-family: inherit;
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
.empty-state p  { font-size: 14px; line-height: 1.6; }

/* ── Cards list ─────────────────────────────────────────────────────────── */
.cards-list {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  max-width: 1440px;
  margin: 0 auto;
}

/* ── Request card ───────────────────────────────────────────────────────── */
.request-card {
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.07);
  border-radius: 16px;
  padding: 24px 28px;
  transition: box-shadow 0.2s, opacity 0.2s;
}
.request-card:hover { box-shadow: 0 6px 24px rgba(0,0,0,0.10); }
.request-card.is-refused { opacity: 0.4; pointer-events: none; }

/* Top row */
.card-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.client-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.client-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 700;
  font-size: 18px;
  flex-shrink: 0;
  box-shadow: 0 0 0 2px #FFEDD4;
}

.client-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.client-name {
  font-size: 16px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.3125px;
  line-height: 24px;
}

.meta-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.meta-clock { flex-shrink: 0; }

.meta-time, .meta-date {
  font-size: 14px;
  font-weight: 400;
  color: #62748E;
  letter-spacing: -0.15px;
  line-height: 20px;
}

.meta-dot {
  font-size: 14px;
  color: #D1D5DC;
  line-height: 20px;
}

/* Category badge */
.card-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 16px;
  height: 38px;
  background: rgba(252, 90, 21, 0.02);
  border: 1px solid #FC5A15;
  border-radius: 9999px;
  flex-shrink: 0;
}

.badge-cat {
  font-size: 14px;
  font-weight: 400;
  color: #FC5A15;
  letter-spacing: -0.15px;
  white-space: nowrap;
}

.badge-arrow {
  font-size: 12px;
  color: #FFB86A;
  line-height: 1;
}

.badge-svc {
  font-size: 14px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.15px;
  white-space: nowrap;
}

/* Title */
.req-title {
  font-size: 20px;
  font-weight: 400;
  color: #314158;
  letter-spacing: -0.45px;
  line-height: 28px;
  margin: 0 0 12px;
}

/* Description */
.req-desc {
  font-size: 16px;
  font-weight: 400;
  color: #62748E;
  line-height: 26px;
  letter-spacing: -0.3125px;
  margin: 0 0 16px;
}

.voir-plus {
  color: #FC5A15;
  cursor: pointer;
  font-size: 14px;
}

/* Photos row */
.photos-row {
  display: flex;
  gap: 9px;
  margin-bottom: 0;
}

.photo-wrap {
  flex: 1;
  max-width: calc(50% - 5px);
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 3px 4.5px -0.75px rgba(0,0,0,0.1), 0 1.5px 3px -1.5px rgba(0,0,0,0.1);
}

.req-photo {
  width: 100%;
  height: 220px;
  object-fit: cover;
  display: block;
}

.photo-more {
  flex: 1;
  max-width: calc(50% - 5px);
  height: 220px;
  border-radius: 10px;
  background: #F5F6FA;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 700;
  color: #62748E;
  border: 1px dashed #C5CDD8;
}

/* Footer */
.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 16px;
  margin-top: 16px;
  border-top: 1px solid #F3F4F6;
}

.footer-left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.location {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.15px;
  line-height: 20px;
}

.budget {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #62748E;
}

/* Actions */
.card-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-refuse {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 16px;
  height: 36px;
  border: none;
  border-radius: 14px;
  background: none;
  color: #62748E;
  font-size: 14px;
  font-weight: 400;
  font-family: inherit;
  letter-spacing: -0.15px;
  cursor: pointer;
  transition: background 0.15s;
  white-space: nowrap;
}
.btn-refuse:hover:not(:disabled) { background: #F5F6FA; }
.btn-refuse:disabled { opacity: 0.45; cursor: not-allowed; }

.btn-accept {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 24px;
  height: 40px;
  border: none;
  border-radius: 14px;
  background: linear-gradient(180deg, #FC5A15 0%, #FF6B2B 100%);
  color: #fff;
  font-size: 14px;
  font-weight: 400;
  font-family: inherit;
  letter-spacing: -0.15px;
  cursor: pointer;
  transition: opacity 0.15s, box-shadow 0.15s;
  white-space: nowrap;
}
.btn-accept:hover { opacity: 0.92; box-shadow: 0 4px 16px rgba(252,90,21,0.3); }

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
.modal-title { font-size: 20px; font-weight: 700; color: #314158; margin: 0 0 20px; }

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
.summary-info { display: flex; flex-direction: column; gap: 3px; }
.summary-category { font-size: 12px; font-weight: 600; color: #FC5A15; text-transform: uppercase; letter-spacing: 0.5px; }
.summary-title    { font-size: 15px; font-weight: 700; color: #314158; }
.summary-client, .summary-budget { font-size: 13px; color: #62748E; }

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
  font-family: inherit;
}
.form-input:focus { border-color: #FC5A15; background: #fff; }
.input-suffix { position: absolute; right: 14px; font-size: 13px; font-weight: 600; color: #62748E; pointer-events: none; }
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
  font-family: inherit;
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
  font-family: inherit;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 2px 8px rgba(252,90,21,0.25);
}
.btn-send:hover:not(:disabled) { opacity: 0.92; }
.btn-send:disabled { opacity: 0.7; cursor: not-allowed; }
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
@keyframes fadeInUp {
  from { opacity: 0; transform: translateX(-50%) translateY(16px); }
  to   { opacity: 1; transform: translateX(-50%) translateY(0); }
}

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 768px) {
  .cards-list { padding: 16px; gap: 16px; }
  .request-card { padding: 16px 18px; }
  .card-top { flex-direction: column; }
  .card-badge { align-self: flex-start; }
  .req-photo { height: 140px; }
  .photo-more { height: 140px; }
  .card-footer { flex-direction: column; align-items: flex-start; }
  .card-actions { width: 100%; justify-content: flex-end; }
  .btn-accept { flex: 1; justify-content: center; }
}

@media (max-width: 480px) {
  .filters-bar { flex-direction: column; }
  .search-wrap, .filter-select { min-width: 100%; width: 100%; }
  .form-row.two-col { grid-template-columns: 1fr; }
}
</style>

<template>
  <div class="detail-page">

    <!-- ── Loading ──────────────────────────────────────────────────── -->
    <div v-if="loading" class="loading-state">
      <div class="spinner" />
      <p>Chargement de la demande…</p>
    </div>

    <!-- ── Error ────────────────────────────────────────────────────── -->
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button class="btn-back" @click="$router.back()">← Retour</button>
    </div>

    <!-- ── Content ──────────────────────────────────────────────────── -->
    <template v-else-if="req">

      <!-- Back -->
      <div class="page-top">
        <button class="btn-back" @click="$router.back()">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.67">
            <polyline points="15 18 9 12 15 6" />
          </svg>
          Retour
        </button>
      </div>

      <!-- ── Hero card ─────────────────────────────────────────────── -->
      <div class="hero-card">

        <div class="hero-header">
          <div class="hero-heading">
            <div class="cat-row">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.9)" stroke-width="1.67">
                <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z" />
              </svg>
              <span>{{ req.category?.name }}</span>
            </div>
            <h1>{{ req.title || req.service_type?.name || 'Demande de service' }}</h1>
            <p class="req-id">Demande #{{ String(req.id).padStart(6, '0') }}</p>
          </div>

          <span v-if="req.is_urgent" class="urgency-badge">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.33">
              <circle cx="12" cy="12" r="10" />
              <line x1="12" y1="8" x2="12" y2="12" />
              <line x1="12" y1="16" x2="12.01" y2="16" />
            </svg>
            Urgent
          </span>
        </div>

        <!-- Date / Heure / Lieu -->
        <div class="hero-meta-row">
          <div class="meta-item">
            <div class="meta-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.67">
                <rect x="3" y="4" width="18" height="18" rx="2" /><line x1="16" y1="2" x2="16" y2="6" />
                <line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" />
              </svg>
            </div>
            <div>
              <span class="meta-label">Date</span>
              <span class="meta-val">{{ formatDate(req.created_at) }}</span>
            </div>
          </div>

          <div class="meta-item">
            <div class="meta-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.67">
                <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
              </svg>
            </div>
            <div>
              <span class="meta-label">Heure</span>
              <span class="meta-val">{{ formatTime(req.created_at) }}</span>
            </div>
          </div>

          <div class="meta-item">
            <div class="meta-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.67">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
              </svg>
            </div>
            <div>
              <span class="meta-label">Lieu</span>
              <span class="meta-val">{{ req.city }}</span>
            </div>
          </div>
        </div>

        <!-- Description + address -->
        <div class="desc-section">
          <h3>Description de votre demande</h3>
          <p class="desc-text">{{ req.description || '—' }}</p>
          <div v-if="req.notes || req.city" class="address-box">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="1.67">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" />
            </svg>
            <div>
              <span class="addr-label">Adresse d'intervention</span>
              <span class="addr-val">{{ req.notes || req.city }}</span>
            </div>
          </div>
        </div>

      </div><!-- /hero-card -->

      <!-- ── Two-column grid ───────────────────────────────────────── -->
      <div class="content-grid">

        <!-- ── LEFT column ─────────────────────────────────────────── -->
        <div class="left-col">

          <!-- Artisan / Client card -->
          <div v-if="counterpart" class="card">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="1.67">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" /><circle cx="12" cy="7" r="4" />
              </svg>
              {{ isClientView ? 'Votre artisan' : 'Votre client' }}
            </h3>

            <div class="counterpart-row">
              <div class="cp-avatar">{{ initials(counterpart.name) }}</div>

              <div class="cp-info">
                <p class="cp-name">{{ counterpart.name }}</p>
                <p class="cp-detail">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.33">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                    <polyline points="22,6 12,13 2,6" />
                  </svg>
                  {{ counterpart.email }}
                </p>
                <p v-if="counterpart.phone" class="cp-detail">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.33">
                    <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                  </svg>
                  {{ counterpart.phone }}
                </p>
              </div>

              <button class="btn-primary" @click="openConversation">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.33">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
                Contacter
              </button>
            </div>
          </div>

          <!-- Timeline -->
          <div class="card">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="1.67">
                <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
              </svg>
              Historique de la demande
            </h3>

            <div class="timeline">
              <div v-for="(ev, i) in sortedTimeline" :key="ev.id" class="tl-item">
                <div class="tl-col">
                  <div class="tl-dot">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#00A63E" stroke-width="2.5">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  </div>
                  <div v-if="i < sortedTimeline.length - 1" class="tl-line" />
                </div>
                <div class="tl-body">
                  <p class="tl-label">{{ timelineLabel(ev.event_type) }}</p>
                  <p class="tl-date">{{ formatDateTime(ev.created_at) }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Photos -->
          <div v-if="req.photos?.length" class="card">
            <h3 class="card-title">Photos du problème</h3>
            <div class="photos-grid">
              <img
                v-for="p in req.photos"
                :key="p.id"
                :src="p.photo_url"
                alt="Photo du problème"
                class="photo"
              />
            </div>
          </div>

          <!-- Review (client only) -->
          <div v-if="isClientView && req.status === 'completed'" class="card review-card">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F0B100" stroke-width="1.67">
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
              </svg>
              Donner votre avis
            </h3>
            <p class="review-hint">Partagez votre expérience avec cet artisan.</p>
            <div class="star-row">
              <svg
                v-for="n in 5"
                :key="n"
                width="28"
                height="28"
                viewBox="0 0 24 24"
                :fill="n <= reviewStars ? '#FDC700' : 'none'"
                stroke="#FDC700"
                stroke-width="1.5"
                class="star"
                @click="reviewStars = n"
              >
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
              </svg>
            </div>
            <div class="review-input-row">
              <input
                v-model="reviewText"
                type="text"
                placeholder="Laisser un avis…"
                class="review-input"
              />
              <button class="btn-primary" @click="submitReview" :disabled="!reviewStars">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.33">
                  <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
                </svg>
              </button>
            </div>
          </div>

        </div><!-- /left-col -->

        <!-- ── RIGHT column ────────────────────────────────────────── -->
        <div class="right-col">

          <!-- Payment info -->
          <div class="card">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="1.67">
                <line x1="12" y1="1" x2="12" y2="23" />
                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
              </svg>
              Informations de paiement
            </h3>

            <div class="amount-box">
              <p class="amount-label">Montant total</p>
              <p class="amount-val">{{ formatAmount(paymentAmount) }} MAD</p>
            </div>

            <div class="payment-rows">
              <div class="pd-row">
                <span class="pd-key">Méthode</span>
                <span class="pd-val">{{ paymentMethod }}</span>
              </div>
              <div v-if="transactionId" class="pd-row">
                <span class="pd-key">Transaction ID</span>
                <span class="pd-val pd-mono">{{ transactionId }}</span>
              </div>
              <div class="pd-row">
                <span class="pd-key">Statut</span>
                <span :class="['status-pill', paymentStatusClass]">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" :stroke="paymentStatusIcon" stroke-width="2.5">
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                  {{ paymentStatusLabel }}
                </span>
              </div>
            </div>

            <button class="btn-outline w-full">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.33">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
              </svg>
              Télécharger la facture
            </button>
          </div>

          <!-- Quick actions -->
          <div class="card">
            <h3 class="card-title">Actions rapides</h3>

            <div class="actions-list">
              <button class="btn-primary w-full" @click="openConversation">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.33">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
                Envoyer un message
              </button>

              <a v-if="counterpart?.phone" :href="`tel:${counterpart.phone}`" class="btn-outline w-full">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.33">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                </svg>
                {{ isClientView ? "Appeler l'artisan" : "Appeler le client" }}
              </a>
              <button v-else class="btn-outline w-full" disabled>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.33">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                </svg>
                {{ isClientView ? "Appeler l'artisan" : "Appeler le client" }}
              </button>

              <button class="btn-outline w-full">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.33">
                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                  <line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" />
                </svg>
                Signaler un problème
              </button>
            </div>
          </div>

          <!-- Help -->
          <div class="card help-card">
            <h4 class="help-title">Besoin d'aide ?</h4>
            <p class="help-text">
              Contactez notre support si vous rencontrez un problème avec cette demande.
            </p>
            <a href="#" class="help-link">Contacter le support →</a>
          </div>

        </div><!-- /right-col -->

      </div><!-- /content-grid -->

    </template>

    <!-- ── Toast ─────────────────────────────────────────────────────── -->
    <transition name="toast">
      <div v-if="toast.show" class="toast" :class="`toast-${toast.type}`">
        {{ toast.message }}
      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getServiceRequest, getArtisanServiceRequest } from '../api/serviceRequests.js'
import { getOrCreateConversation } from '../api/messages.js'

// ── Props ─────────────────────────────────────────────────────────────────
const props = defineProps({
  /** 'client' | 'artisan' */
  role: { type: String, default: 'client' },
})

const route  = useRoute()
const router = useRouter()

// ── State ─────────────────────────────────────────────────────────────────
const req         = ref(null)
const artisanOffer = ref(null) // artisan role only
const loading     = ref(false)
const error       = ref('')
const reviewStars = ref(0)
const reviewText  = ref('')
const toast       = ref({ show: false, message: '', type: 'success' })

// ── Computed ──────────────────────────────────────────────────────────────
const isClientView = computed(() => props.role === 'client')

/** The "other party" shown in the info card */
const counterpart = computed(() => {
  if (!req.value) return null
  if (isClientView.value) {
    const artisan = req.value.accepted_offer?.artisan?.user
    return artisan ? { name: artisan.name, email: artisan.email, phone: artisan.phone } : null
  } else {
    const client = req.value.client?.user
    return client ? { name: client.name, email: client.email, phone: client.phone } : null
  }
})

const sortedTimeline = computed(() =>
  [...(req.value?.timeline ?? [])].sort(
    (a, b) => new Date(a.created_at) - new Date(b.created_at)
  )
)

// ── Payment helpers ───────────────────────────────────────────────────────
const payment = computed(() => req.value?.payment)

const paymentAmount = computed(() =>
  payment.value?.total_amount
    ?? req.value?.accepted_offer?.proposed_price
    ?? artisanOffer.value?.proposed_price
    ?? 0
)

const paymentMethod = computed(() => {
  const type = payment.value?.payment_type
  return { card: 'Carte bancaire', cash: 'Espèces', bank_transfer: 'Virement bancaire' }[type] ?? '—'
})

const transactionId = computed(() => payment.value?.transaction_id ?? null)

const paymentStatusLabel = computed(() => {
  const s = payment.value?.status
  if (!s) return req.value?.status === 'completed' ? 'Payé' : 'En attente'
  return { paid: 'Payé', pending: 'En attente', failed: 'Échoué', refunded: 'Remboursé' }[s] ?? s
})

const paymentStatusClass = computed(() => {
  const s = payment.value?.status
  if (!s) return req.value?.status === 'completed' ? 'pill-paid' : 'pill-pending'
  return { paid: 'pill-paid', pending: 'pill-pending', failed: 'pill-failed', refunded: 'pill-refunded' }[s] ?? 'pill-pending'
})

const paymentStatusIcon = computed(() =>
  paymentStatusClass.value === 'pill-paid' ? '#008236' : '#A65F00'
)

// ── Fetch ─────────────────────────────────────────────────────────────────
onMounted(fetchRequest)

async function fetchRequest() {
  loading.value = true
  error.value   = ''
  try {
    const id  = route.params.id
    const res = isClientView.value
      ? await getServiceRequest(id)
      : await getArtisanServiceRequest(id)

    const body = res.data
    req.value   = body.data
    if (body.offer) artisanOffer.value = body.offer
  } catch (e) {
    error.value = e.response?.data?.error || 'Impossible de charger la demande.'
  } finally {
    loading.value = false
  }
}

// ── Actions ───────────────────────────────────────────────────────────────
async function openConversation() {
  if (!req.value) return
  try {
    const params = isClientView.value
      ? { artisan_id: req.value.accepted_offer?.artisan?.id, service_request_id: req.value.id }
      : { client_id: req.value.client?.id, service_request_id: req.value.id }

    const { data } = await getOrCreateConversation(params)
    router.push(`/messages/${data.data.id}`)
  } catch {
    showToast('Impossible d\'ouvrir la conversation.', 'error')
  }
}

function submitReview() {
  // Placeholder — wire to a review API when available
  showToast('Merci pour votre avis !')
  reviewStars.value = 0
  reviewText.value  = ''
}

// ── Formatters ────────────────────────────────────────────────────────────
function formatDate(iso) {
  if (!iso) return '—'
  return new Date(iso).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function formatTime(iso) {
  if (!iso) return '—'
  return new Date(iso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

function formatDateTime(iso) {
  if (!iso) return '—'
  const d = new Date(iso)
  return (
    d.toLocaleDateString('fr-FR', { year: 'numeric', month: '2-digit', day: '2-digit' }) +
    ' ' +
    d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  )
}

function formatAmount(val) {
  return Number(val || 0).toLocaleString('fr-FR', { minimumFractionDigits: 0 })
}

function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}

const TIMELINE_LABELS = {
  created:          'Demande créée par le client',
  offer_submitted:  'Offre reçue d\'un artisan',
  offer_accepted:   'Artisan sélectionné',
  completed:        'Service effectué',
  payment_received: 'Paiement reçu',
  cancelled:        'Demande annulée',
  closed:           'Demande clôturée',
}

function timelineLabel(type) {
  return TIMELINE_LABELS[type] ?? type
}

// ── Toast ─────────────────────────────────────────────────────────────────
let _toastTimer = null
function showToast(message, type = 'success') {
  clearTimeout(_toastTimer)
  toast.value = { show: true, message, type }
  _toastTimer = setTimeout(() => { toast.value.show = false }, 3500)
}
</script>

<style scoped>
/* ── Page wrapper ────────────────────────────────────────────────────────── */
.detail-page {
  font-family: 'Inter', sans-serif;
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  color: #314158;
  padding-bottom: 64px;
}

/* ── States ──────────────────────────────────────────────────────────────── */
.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  gap: 16px;
  color: #62748E;
  font-size: 16px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #E8ECF0;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

/* ── Back button ─────────────────────────────────────────────────────────── */
.page-top {
  max-width: 1248px;
  margin: 0 auto;
  padding: 24px 24px 0;
}

.btn-back {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  color: #62748E;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  padding: 0;
  letter-spacing: -0.3125px;
}
.btn-back:hover { color: #314158; }

/* ── Hero card ───────────────────────────────────────────────────────────── */
.hero-card {
  max-width: 1248px;
  margin: 16px auto 0;
  padding: 0 24px;
}

.hero-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  border-radius: 16px 16px 0 0;
  padding: 24px;
}

.hero-heading { display: flex; flex-direction: column; gap: 8px; }

.cat-row {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255,255,255,0.9);
  font-size: 14px;
  letter-spacing: -0.15px;
}

.hero-heading h1 {
  font-size: 30px;
  font-weight: 500;
  color: #fff;
  margin: 0;
  letter-spacing: 0.4px;
  line-height: 36px;
}

.req-id {
  font-size: 16px;
  color: rgba(255,255,255,0.8);
  margin: 0;
  letter-spacing: -0.3125px;
}

.urgency-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #FB2C36;
  color: #fff;
  font-size: 14px;
  padding: 4px 12px;
  border-radius: 999px;
  white-space: nowrap;
}

/* Date / Heure / Lieu row */
.hero-meta-row {
  display: flex;
  gap: 40px;
  flex-wrap: wrap;
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  padding: 0 24px 24px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.meta-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.meta-label {
  display: block;
  font-size: 14px;
  color: rgba(255,255,255,0.7);
  letter-spacing: -0.15px;
}
.meta-val {
  display: block;
  font-size: 16px;
  font-weight: 500;
  color: #fff;
  letter-spacing: -0.3125px;
}

/* Description section */
.desc-section {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-top: none;
  border-radius: 0 0 16px 16px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.desc-section h3 {
  font-size: 18px;
  font-weight: 400;
  color: #314158;
  margin: 0;
  letter-spacing: -0.44px;
}

.desc-text {
  font-size: 16px;
  color: #62748E;
  margin: 0;
  letter-spacing: -0.3125px;
  line-height: 26px;
}

.address-box {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background: #F9FAFB;
  border-radius: 10px;
  padding: 16px;
}

.addr-label {
  display: block;
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.15px;
}
.addr-val {
  display: block;
  font-size: 16px;
  color: #314158;
  letter-spacing: -0.3125px;
}

/* ── Two-column grid ─────────────────────────────────────────────────────── */
.content-grid {
  max-width: 1248px;
  margin: 24px auto 0;
  padding: 0 24px;
  display: grid;
  grid-template-columns: 1fr 400px;
  gap: 24px;
  align-items: start;
}

.left-col,
.right-col {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* ── Generic card ────────────────────────────────────────────────────────── */
.card {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 400;
  color: #314158;
  margin: 0;
  letter-spacing: -0.44px;
}

/* ── Counterpart (artisan / client) card ─────────────────────────────────── */
.counterpart-row {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #F9FAFB;
  border-radius: 14px;
  padding: 16px;
}

.cp-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  color: #fff;
  font-size: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.cp-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.cp-name {
  font-size: 18px;
  font-weight: 400;
  color: #314158;
  margin: 0;
  letter-spacing: -0.44px;
}

.cp-detail {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #62748E;
  margin: 0;
  letter-spacing: -0.15px;
}

/* ── Timeline ────────────────────────────────────────────────────────────── */
.timeline { display: flex; flex-direction: column; }

.tl-item {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.tl-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 40px;
  flex-shrink: 0;
}

.tl-dot {
  width: 40px;
  height: 40px;
  background: #DCFCE7;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tl-line {
  width: 2px;
  flex: 1;
  min-height: 48px;
  background: #E5E7EB;
  margin: 8px 0;
}

.tl-body {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding-top: 8px;
  padding-bottom: 24px;
}

.tl-label {
  font-size: 16px;
  color: #314158;
  margin: 0;
  letter-spacing: -0.3125px;
}

.tl-date {
  font-size: 14px;
  color: #62748E;
  margin: 0;
  letter-spacing: -0.15px;
}

/* ── Photos ──────────────────────────────────────────────────────────────── */
.photos-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.photo {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
  border-radius: 14px;
  background: #F3F4F6;
}

/* ── Review card ─────────────────────────────────────────────────────────── */
.review-card {
  background: linear-gradient(135deg, rgba(254,252,232,0.28) 0%, rgba(255,247,237,0.28) 100%);
  border: 1px solid rgba(252,90,21,0.3);
}

.review-hint {
  font-size: 14px;
  color: #62748E;
  margin: 0;
  font-style: italic;
}

.star-row { display: flex; gap: 6px; }

.star { cursor: pointer; transition: transform 0.1s; }
.star:hover { transform: scale(1.15); }

.review-input-row {
  display: flex;
  gap: 8px;
}

.review-input {
  flex: 1;
  border: 1px solid #FC5A15;
  border-radius: 7px;
  padding: 10px 14px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  color: #314158;
  outline: none;
}
.review-input::placeholder { color: #62748E; }

/* ── Payment card ────────────────────────────────────────────────────────── */
.amount-box {
  background: linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%);
  border: 1px solid #B9F8CF;
  border-radius: 14px;
  padding: 17px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.amount-label {
  font-size: 14px;
  color: #008236;
  margin: 0;
}

.amount-val {
  font-size: 30px;
  font-weight: 400;
  color: #016630;
  margin: 0;
  letter-spacing: 0.4px;
}

.payment-rows { display: flex; flex-direction: column; gap: 12px; }

.pd-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pd-key {
  font-size: 16px;
  color: #62748E;
  letter-spacing: -0.3125px;
}

.pd-val {
  font-size: 16px;
  color: #314158;
  letter-spacing: -0.3125px;
}

.pd-mono { font-size: 13px; font-family: monospace; }

/* Status pill */
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 14px;
}

.pill-paid    { background: #DCFCE7; color: #008236; }
.pill-pending { background: #FEF9C2; color: #A65F00; }
.pill-failed  { background: #FEF2F2; color: #C10007; }
.pill-refunded{ background: #EFF6FF; color: #1D4ED8; }

/* ── Actions card ────────────────────────────────────────────────────────── */
.actions-list { display: flex; flex-direction: column; gap: 12px; }

/* ── Help card ───────────────────────────────────────────────────────────── */
.help-card {
  background: linear-gradient(135deg, #EFF6FF 0%, #DBEAFE 100%);
  border: 1px solid #BEDBFF;
}

.help-title {
  font-size: 16px;
  font-weight: 400;
  color: #314158;
  margin: 0;
  letter-spacing: -0.3125px;
}

.help-text {
  font-size: 14px;
  color: #62748E;
  margin: 0;
  letter-spacing: -0.15px;
  line-height: 20px;
}

.help-link {
  font-size: 14px;
  color: #1D4ED8;
  text-decoration: none;
  letter-spacing: -0.15px;
}
.help-link:hover { text-decoration: underline; }

/* ── Shared buttons ──────────────────────────────────────────────────────── */
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 0 20px;
  height: 40px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  text-decoration: none;
  transition: background 0.15s;
  white-space: nowrap;
}
.btn-primary:hover { background: #e04e0f; }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-outline {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 0 20px;
  height: 48px;
  background: #fff;
  color: #FC5A15;
  border: 2px solid #FC5A15;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  text-decoration: none;
  transition: background 0.15s;
  white-space: nowrap;
}
.btn-outline:hover { background: #FFF7ED; }
.btn-outline:disabled { opacity: 0.5; cursor: not-allowed; border-color: #D1D5DC; color: #314158; }

/* Secondary outline (grey) */
a.btn-outline,
button.btn-outline:not(:first-of-type) {
  border-color: #D1D5DC;
  color: #314158;
  height: 50px;
}
a.btn-outline:hover,
button.btn-outline:not(:first-of-type):hover { background: #F9FAFB; }

.w-full { width: 100%; }

/* ── Toast ───────────────────────────────────────────────────────────────── */
.toast {
  position: fixed;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  padding: 14px 28px;
  border-radius: 12px;
  font-size: 15px;
  z-index: 9999;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.toast-success { background: #16A34A; color: #fff; }
.toast-error   { background: #EF4444; color: #fff; }
.toast-enter-active, .toast-leave-active { transition: opacity 0.3s, transform 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }

/* ── Responsive ──────────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
  .content-grid { grid-template-columns: 1fr; }
  .right-col    { display: grid; grid-template-columns: repeat(2, 1fr); }
  .help-card    { grid-column: span 2; }
}

@media (max-width: 640px) {
  .page-top, .hero-card, .content-grid { padding-left: 16px; padding-right: 16px; }
  .hero-meta-row  { flex-direction: column; gap: 16px; }
  .content-grid   { grid-template-columns: 1fr; }
  .right-col      { display: flex; flex-direction: column; }
  .photos-grid    { grid-template-columns: 1fr; }
  .counterpart-row{ flex-wrap: wrap; }
}
</style>

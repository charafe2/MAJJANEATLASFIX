<template>
  <transition name="bm-fade">
    <div v-if="show" class="bm-overlay" @click.self="handleClose">
      <div class="bm-card">

        <!-- ── Header ─────────────────────────────────────────────── -->
        <div class="bm-header">
          <div class="bm-header-left">
            <div class="bm-icon-wrap">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M13 2L3 14h8l-1 8 10-12h-8l1-8z"/>
              </svg>
            </div>
            <span class="bm-title">Booster votre service</span>
          </div>
          <button class="bm-close" @click="handleClose" :disabled="submitting">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <!-- ── Step 1: Package picker ──────────────────────────────── -->
        <div v-if="step === 1" class="bm-body">
          <p class="bm-intro-label">Qu'est-ce que le Boost ?</p>
          <p class="bm-intro-text">
            Le boost permet de placer votre service en tête des résultats de recherche pour attirer plus de clients.
            Votre service sera mis en avant avec un badge spécial.
          </p>

          <p class="bm-section-label">Choisissez un boost pour plus de visibilité</p>

          <div class="bm-packages">
            <label
              v-for="pkg in packages"
              :key="pkg.id"
              class="bm-pkg-row"
              :class="{ 'bm-pkg-row--selected': selectedPackageId === pkg.id }"
            >
              <div class="bm-pkg-left">
                <div class="bm-pkg-icon" :class="selectedPackageId === pkg.id ? 'bm-pkg-icon--active' : ''">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M13 2L3 14h8l-1 8 10-12h-8l1-8z"/>
                  </svg>
                </div>
                <div class="bm-pkg-info">
                  <span class="bm-pkg-name">{{ pkg.name }}</span>
                  <span v-if="pkg.is_popular" class="bm-pkg-popular">Populaire</span>
                </div>
              </div>
              <div class="bm-pkg-right">
                <span class="bm-pkg-price">{{ formatPrice(pkg.price) }} MAD</span>
                <input
                  type="radio"
                  :value="pkg.id"
                  v-model="selectedPackageId"
                  class="bm-radio"
                />
              </div>
            </label>
          </div>

          <p v-if="errorMsg" class="bm-error">{{ errorMsg }}</p>

          <button class="bm-btn-primary" @click="goToPayment" :disabled="!selectedPackageId || loadingPackages">
            <span>Suivant</span>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M5 12h14M12 5l7 7-7 7"/>
            </svg>
          </button>
        </div>

        <!-- ── Step 2: Payment ─────────────────────────────────────── -->
        <div v-else-if="step === 2" class="bm-body">
          <button class="bm-back-btn" @click="step = 1" :disabled="submitting">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            Retour
          </button>

          <div class="bm-summary-box">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M13 2L3 14h8l-1 8 10-12h-8l1-8z"/>
            </svg>
            <span>{{ selectedPackage?.name }} — <strong>{{ formatPrice(selectedPackage?.price) }} MAD</strong></span>
          </div>

          <p class="bm-section-label">Informations de paiement</p>

          <div class="bm-form">
            <div class="bm-field">
              <label class="bm-label">Numéro de carte</label>
              <input
                v-model="cardNumber"
                type="text"
                class="bm-input"
                placeholder="1234 5678 9012 3456"
                maxlength="19"
                @input="formatCardNumber"
              />
            </div>

            <div class="bm-field">
              <label class="bm-label">Nom du titulaire</label>
              <input
                v-model="holderName"
                type="text"
                class="bm-input"
                placeholder="PRÉNOM NOM"
              />
            </div>

            <div class="bm-row">
              <div class="bm-field">
                <label class="bm-label">Date d'expiration</label>
                <input
                  v-model="expiry"
                  type="text"
                  class="bm-input"
                  placeholder="MM/AA"
                  maxlength="5"
                  @input="formatExpiry"
                />
              </div>
              <div class="bm-field">
                <label class="bm-label">CVV</label>
                <input
                  v-model="cvv"
                  type="password"
                  class="bm-input"
                  placeholder="•••"
                  maxlength="4"
                />
              </div>
            </div>
          </div>

          <p v-if="errorMsg" class="bm-error">{{ errorMsg }}</p>
          <p v-if="successMsg" class="bm-success">{{ successMsg }}</p>

          <button
            class="bm-btn-primary"
            @click="submitPayment"
            :disabled="submitting || !!successMsg"
          >
            <svg v-if="submitting" class="bm-spinner-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>
            </svg>
            <span>{{ submitting ? 'Traitement…' : `Payer ${formatPrice(selectedPackage?.price)} MAD` }}</span>
          </button>
        </div>

      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  show:              { type: Boolean, default: false },
  serviceCategoryId: { type: [Number, String], default: null },
})

const emit = defineEmits(['close', 'boosted'])

// ── State ────────────────────────────────────────────────────────────────
const step              = ref(1)
const packages          = ref([])
const loadingPackages   = ref(false)
const selectedPackageId = ref(null)

const cardNumber  = ref('')
const holderName  = ref('')
const expiry      = ref('')
const cvv         = ref('')

const submitting  = ref(false)
const errorMsg    = ref('')
const successMsg  = ref('')

// ── Computed ─────────────────────────────────────────────────────────────
const selectedPackage = computed(() =>
  packages.value.find(p => p.id === selectedPackageId.value) ?? null
)

// ── Watchers ─────────────────────────────────────────────────────────────
watch(() => props.show, async (val) => {
  if (val) {
    step.value              = 1
    selectedPackageId.value = null
    cardNumber.value        = ''
    holderName.value        = ''
    expiry.value            = ''
    cvv.value               = ''
    errorMsg.value          = ''
    successMsg.value        = ''
    await loadPackages()
  }
})

// ── Helpers ───────────────────────────────────────────────────────────────
function formatPrice(price) {
  if (price == null) return ''
  return Number(price).toLocaleString('fr-MA', { minimumFractionDigits: 0, maximumFractionDigits: 0 })
}

function formatCardNumber(e) {
  let val = e.target.value.replace(/\D/g, '').slice(0, 16)
  cardNumber.value = val.replace(/(.{4})/g, '$1 ').trim()
}

function formatExpiry(e) {
  let val = e.target.value.replace(/\D/g, '').slice(0, 4)
  if (val.length >= 3) val = val.slice(0, 2) + '/' + val.slice(2)
  expiry.value = val
}

function handleClose() {
  if (submitting.value) return
  emit('close')
}

// ── API calls ─────────────────────────────────────────────────────────────
async function loadPackages() {
  loadingPackages.value = true
  try {
    const token = localStorage.getItem('token')
    const res = await fetch('/api/artisan/boost/packages', {
      headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' },
    })
    const body = await res.json()
    packages.value = body.data ?? []
    if (packages.value.length) {
      // Pre-select the popular one, or the first
      const popular = packages.value.find(p => p.is_popular)
      selectedPackageId.value = popular ? popular.id : packages.value[0].id
    }
  } catch {
    errorMsg.value = 'Impossible de charger les forfaits.'
  } finally {
    loadingPackages.value = false
  }
}

function goToPayment() {
  if (!selectedPackageId.value) return
  errorMsg.value = ''
  step.value = 2
}

async function submitPayment() {
  errorMsg.value  = ''
  successMsg.value = ''

  const rawCard = cardNumber.value.replace(/\s/g, '')
  if (rawCard.length < 13) { errorMsg.value = 'Numéro de carte invalide.'; return }
  if (!holderName.value.trim()) { errorMsg.value = 'Nom du titulaire requis.'; return }
  if (expiry.value.length < 5) { errorMsg.value = 'Date d\'expiration invalide.'; return }
  if (cvv.value.length < 3) { errorMsg.value = 'CVV invalide.'; return }

  submitting.value = true
  try {
    const token = localStorage.getItem('token')
    const res = await fetch('/api/artisan/boost/buy', {
      method: 'POST',
      headers: {
        Authorization:  `Bearer ${token}`,
        Accept:         'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        boost_package_id:    selectedPackageId.value,
        service_category_id: props.serviceCategoryId ?? undefined,
        card_number:         rawCard,
        holder_name:         holderName.value.trim(),
        expiry:              expiry.value,
        cvv:                 cvv.value,
      }),
    })
    const body = await res.json()
    if (!res.ok) throw new Error(body.message || body.error || 'Erreur')
    successMsg.value = body.message ?? 'Boost activé !'
    emit('boosted', body)
    setTimeout(() => emit('close'), 2200)
  } catch (e) {
    errorMsg.value = e.message || 'Une erreur est survenue.'
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
/* ── Overlay ─────────────────────────────────────────────────────────── */
.bm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.52);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 24px;
  backdrop-filter: blur(3px);
}

/* ── Card ────────────────────────────────────────────────────────────── */
.bm-card {
  background: #fff;
  border-radius: 20px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 28px 72px rgba(0,0,0,0.18);
  overflow: hidden;
}

/* ── Header ──────────────────────────────────────────────────────────── */
.bm-header {
  background: linear-gradient(135deg, #FC5A15 0%, #e04a0a 100%);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.bm-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bm-icon-wrap {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.bm-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
}

.bm-close {
  background: rgba(255,255,255,0.15);
  border: none;
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  cursor: pointer;
  transition: background 0.15s;
}
.bm-close:hover { background: rgba(255,255,255,0.28); }
.bm-close:disabled { opacity: 0.5; cursor: not-allowed; }

/* ── Body ────────────────────────────────────────────────────────────── */
.bm-body {
  padding: 22px 24px 26px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.bm-intro-label {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
  margin: 0;
}

.bm-intro-text {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #62748E;
  line-height: 1.55;
  margin: 0;
}

.bm-section-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin: 0;
}

/* ── Package rows ────────────────────────────────────────────────────── */
.bm-packages {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.bm-pkg-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 13px 16px;
  border: 1.5px solid #E5E7EB;
  border-radius: 14px;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
  background: #fff;
}

.bm-pkg-row:hover { border-color: rgba(252,90,21,0.4); background: rgba(252,90,21,0.02); }

.bm-pkg-row--selected {
  border-color: #FC5A15;
  background: rgba(252,90,21,0.04);
}

.bm-pkg-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bm-pkg-icon {
  width: 38px;
  height: 38px;
  background: #F3F4F6;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #62748E;
  transition: background 0.15s, color 0.15s;
}

.bm-pkg-icon--active {
  background: #FC5A15;
  color: #fff;
}

.bm-pkg-info {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.bm-pkg-name {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 600;
  color: #1E293B;
}

.bm-pkg-popular {
  display: inline-block;
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  font-weight: 600;
  color: #FC5A15;
  background: rgba(252,90,21,0.1);
  border-radius: 20px;
  padding: 1px 8px;
}

.bm-pkg-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bm-pkg-price {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 700;
  color: #1E293B;
}

.bm-radio {
  width: 18px;
  height: 18px;
  accent-color: #FC5A15;
  cursor: pointer;
}

/* ── Payment form ────────────────────────────────────────────────────── */
.bm-back-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: #62748E;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  padding: 0;
  transition: color 0.15s;
}
.bm-back-btn:hover { color: #FC5A15; }
.bm-back-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.bm-summary-box {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(252,90,21,0.06);
  border: 1px solid rgba(252,90,21,0.2);
  border-radius: 12px;
  padding: 10px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
}

.bm-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bm-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.bm-field {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.bm-label {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
}

.bm-input {
  width: 100%;
  box-sizing: border-box;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  padding: 10px 12px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  background: #FAFAFA;
  outline: none;
  transition: border-color 0.15s;
}
.bm-input:focus { border-color: #FC5A15; background: #fff; }

/* ── Primary button ──────────────────────────────────────────────────── */
.bm-btn-primary {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  height: 50px;
  background: linear-gradient(135deg, #FC5A15 0%, #e04a0a 100%);
  color: #fff;
  border: none;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.15s, transform 0.1s;
}
.bm-btn-primary:hover:not(:disabled) { opacity: 0.92; }
.bm-btn-primary:active:not(:disabled) { transform: scale(0.98); }
.bm-btn-primary:disabled { opacity: 0.55; cursor: not-allowed; }

/* ── Spinner ─────────────────────────────────────────────────────────── */
@keyframes bm-spin { to { transform: rotate(360deg); } }
.bm-spinner-icon { animation: bm-spin 0.8s linear infinite; flex-shrink: 0; }

/* ── Messages ────────────────────────────────────────────────────────── */
.bm-error {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

.bm-success {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #16A34A;
  background: #F0FDF4;
  border: 1px solid #BBF7D0;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

/* ── Transition ──────────────────────────────────────────────────────── */
.bm-fade-enter-active,
.bm-fade-leave-active { transition: opacity 0.2s; }
.bm-fade-enter-active .bm-card,
.bm-fade-leave-active .bm-card { transition: transform 0.2s, opacity 0.2s; }
.bm-fade-enter-from,
.bm-fade-leave-to { opacity: 0; }
.bm-fade-enter-from .bm-card,
.bm-fade-leave-to .bm-card { transform: scale(0.95) translateY(10px); opacity: 0; }
</style>

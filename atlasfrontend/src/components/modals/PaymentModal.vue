<template>
  <transition name="modal-fade">
    <div v-if="show" class="pm-overlay" @click.self="$emit('close')">
      <div class="pm-card">

        <!-- Header -->
        <div class="pm-header">
          <div class="pm-header-left">
            <div class="pm-icon-wrap">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8">
                <rect x="1" y="4" width="22" height="16" rx="2" ry="2" />
                <line x1="1" y1="10" x2="23" y2="10" />
              </svg>
            </div>
            <span class="pm-title">Informations de paiement</span>
          </div>
          <button class="pm-close" @click="$emit('close')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="pm-body">

          <!-- Card number -->
          <div class="pm-field">
            <label class="pm-label">Numéro de carte</label>
            <div class="pm-input-wrap">
              <svg class="pm-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="1.6">
                <rect x="1" y="4" width="22" height="16" rx="2" ry="2" /><line x1="1" y1="10" x2="23" y2="10" />
              </svg>
              <input
                v-model="cardNumber"
                class="pm-input"
                type="text"
                inputmode="numeric"
                placeholder="1234 5678 9012 3456"
                maxlength="19"
                @input="formatCardNumber"
              />
            </div>
          </div>

          <!-- Holder name -->
          <div class="pm-field">
            <label class="pm-label">Titulaire de la carte</label>
            <input
              v-model="holderName"
              class="pm-input pm-input--full"
              type="text"
              placeholder="AHMED BENNANI"
              style="text-transform:uppercase"
            />
          </div>

          <!-- Expiry + CVV -->
          <div class="pm-row">
            <div class="pm-field">
              <label class="pm-label">Date d'expiration</label>
              <input
                v-model="expiry"
                class="pm-input pm-input--full"
                type="text"
                placeholder="MM/AA"
                maxlength="5"
                @input="formatExpiry"
              />
            </div>
            <div class="pm-field">
              <label class="pm-label">CVV</label>
              <input
                v-model="cvv"
                class="pm-input pm-input--full"
                type="text"
                inputmode="numeric"
                placeholder="123"
                maxlength="4"
              />
            </div>
          </div>

          <!-- Security notice -->
          <div class="pm-notice">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#16A34A" stroke-width="1.8">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <polyline points="9 12 11 14 15 10" />
            </svg>
            <span>Vos informations de paiement sont sécurisées et cryptées</span>
          </div>

          <!-- Error -->
          <p v-if="error" class="pm-error">{{ error }}</p>

          <!-- Amount display -->
          <div v-if="amount" class="pm-amount-row">
            <span class="pm-amount-label">Montant total</span>
            <span class="pm-amount-val">{{ formatAmount(amount) }} MAD</span>
          </div>

          <!-- Submit -->
          <button
            class="pm-pay-btn"
            :disabled="submitting"
            @click="submit"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
              <path d="M7 11V7a5 5 0 0 1 10 0v4" />
            </svg>
            {{ submitting ? 'Traitement en cours…' : 'Payer' }}
          </button>

        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show:             { type: Boolean, default: false },
  amount:           { type: Number,  default: 0 },
  serviceRequestId: { type: [Number, String], required: true },
})

const emit = defineEmits(['close', 'success'])

const cardNumber = ref('')
const holderName = ref('')
const expiry     = ref('')
const cvv        = ref('')
const submitting = ref(false)
const error      = ref('')

// Reset when modal opens
watch(() => props.show, (val) => {
  if (val) {
    cardNumber.value = ''
    holderName.value = ''
    expiry.value     = ''
    cvv.value        = ''
    error.value      = ''
  }
})

function formatCardNumber() {
  const raw = cardNumber.value.replace(/\D/g, '').slice(0, 16)
  cardNumber.value = raw.replace(/(.{4})/g, '$1 ').trim()
}

function formatExpiry() {
  const raw = expiry.value.replace(/\D/g, '').slice(0, 4)
  if (raw.length >= 3) {
    expiry.value = raw.slice(0, 2) + '/' + raw.slice(2)
  } else {
    expiry.value = raw
  }
}

function formatAmount(val) {
  return Number(val || 0).toLocaleString('fr-FR', { minimumFractionDigits: 0 })
}

async function submit() {
  error.value = ''

  const rawCard = cardNumber.value.replace(/\s/g, '')
  if (rawCard.length < 13) { error.value = 'Numéro de carte invalide.'; return }
  if (!holderName.value.trim()) { error.value = 'Veuillez saisir le nom du titulaire.'; return }
  if (expiry.value.length < 5) { error.value = 'Date d\'expiration invalide.'; return }
  if (cvv.value.length < 3) { error.value = 'CVV invalide.'; return }

  submitting.value = true
  try {
    const token = localStorage.getItem('token')
    const res = await fetch(`/api/client/service-requests/${props.serviceRequestId}/pay`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        card_number: rawCard,
        holder_name: holderName.value.trim().toUpperCase(),
        expiry:      expiry.value,
        cvv:         cvv.value,
      }),
    })
    const body = await res.json()
    if (!res.ok) throw new Error(body.error || body.message || 'Erreur de paiement')
    emit('success', body)
  } catch (e) {
    error.value = e.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.pm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 24px;
  backdrop-filter: blur(3px);
}

.pm-card {
  background: #fff;
  border-radius: 18px;
  width: 100%;
  max-width: 420px;
  box-shadow: 0 24px 64px rgba(0,0,0,0.18);
  overflow: hidden;
}

.pm-header {
  background: linear-gradient(135deg, #16A34A, #15803D);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.pm-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.pm-icon-wrap {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.pm-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
}

.pm-close {
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
.pm-close:hover { background: rgba(255,255,255,0.28); }

.pm-body {
  padding: 22px 24px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.pm-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 1;
}

.pm-label {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  letter-spacing: 0.2px;
}

.pm-input-wrap {
  position: relative;
  display: flex;
  align-items: center;
}

.pm-input-icon {
  position: absolute;
  left: 12px;
  pointer-events: none;
  flex-shrink: 0;
}

.pm-input {
  width: 100%;
  box-sizing: border-box;
  height: 46px;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  padding: 0 14px 0 38px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  outline: none;
  background: #FAFAFA;
  transition: border-color 0.15s, background 0.15s;
}

.pm-input--full {
  padding-left: 14px;
}

.pm-input:focus {
  border-color: #16A34A;
  background: #fff;
}

.pm-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.pm-notice {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #F0FDF4;
  border: 1px solid #BBF7D0;
  border-radius: 10px;
  padding: 10px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #15803D;
}

.pm-amount-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 14px;
  background: #F8FAFC;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
}

.pm-amount-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #64748B;
}

.pm-amount-val {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #1E293B;
}

.pm-error {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

.pm-pay-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  height: 50px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
  margin-top: 4px;
}
.pm-pay-btn:hover:not(:disabled) { background: #e04e0e; }
.pm-pay-btn:active:not(:disabled) { transform: scale(0.98); }
.pm-pay-btn:disabled { opacity: 0.6; cursor: not-allowed; }

/* Transition */
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.2s; }
.modal-fade-enter-active .pm-card,
.modal-fade-leave-active .pm-card { transition: transform 0.2s, opacity 0.2s; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }
.modal-fade-enter-from .pm-card,
.modal-fade-leave-to .pm-card { transform: scale(0.95) translateY(8px); opacity: 0; }
</style>

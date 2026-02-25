<template>
  <transition name="modal-fade">
    <div v-if="show" class="cm-overlay" @click.self="$emit('close')">
      <div class="cm-card">

        <!-- Header -->
        <div class="cm-header">
          <div class="cm-header-left">
            <div class="cm-icon-wrap">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
            </div>
            <div>
              <div class="cm-title">Annuler la demande</div>
              <div class="cm-subtitle">{{ requestTitle }}</div>
            </div>
          </div>
          <button class="cm-close" @click="$emit('close')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="cm-body">

          <!-- Attention box -->
          <div class="cm-warn-box">
            <p class="cm-warn-text">
              <strong>Attention :</strong> Cette action supprimera définitivement votre demande.
            </p>
            <div v-if="artisanCount > 0" class="cm-artisan-warn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#C10007" stroke-width="2">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
              {{ artisanCount }} artisan{{ artisanCount > 1 ? 's' : '' }} ont déjà répondu.
            </div>
          </div>

          <!-- Cancellation policy (shown when artisans involved) -->
          <div v-if="hasActiveArtisans" class="cm-policy">
            <div class="cm-policy-header">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#92400E" stroke-width="1.8">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              Politique d'annulation
            </div>
            <ul class="cm-policy-list">
              <li :class="{ 'cm-policy-active': feeLevel === 'free' }">
                Annulation gratuite jusqu'à 24h avant le rendez-vous
              </li>
              <li :class="{ 'cm-policy-active': feeLevel === 'fee25' }">
                Frais de 25% entre 24h et 12h avant
              </li>
              <li :class="{ 'cm-policy-active': feeLevel === 'fee50' }">
                Frais de 50% moins de 12h avant
              </li>
              <li>Remboursement complet si l'artisan annule</li>
            </ul>
          </div>

          <!-- Reason (optional) -->
          <div class="cm-field">
            <label class="cm-label">
              Raison de l'annulation
              <span class="cm-optional">(optionnel)</span>
            </label>
            <textarea
              v-model="reason"
              class="cm-textarea"
              rows="3"
              placeholder="Pourquoi annulez-vous cette demande ?"
            />
          </div>

          <!-- Error -->
          <p v-if="error" class="cm-error">{{ error }}</p>

          <!-- Footer buttons -->
          <div class="cm-footer">
            <button class="cm-btn-keep" @click="$emit('close')">Garder</button>
            <button class="cm-btn-cancel" :disabled="submitting" @click="submit">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
              </svg>
              {{ submitting ? 'Annulation…' : 'Annuler' }}
            </button>
          </div>

        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  show:    { type: Boolean, default: false },
  request: { type: Object,  default: null  },
})

const emit = defineEmits(['close', 'success'])

const reason     = ref('')
const submitting = ref(false)
const error      = ref('')

// Reset on open
watch(() => props.show, (val) => {
  if (val) {
    reason.value     = ''
    error.value      = ''
    submitting.value = false
  }
})

const requestTitle = computed(() =>
  props.request?.category?.name
  ?? props.request?.service_type?.name
  ?? 'Demande'
)

const artisanCount = computed(() => props.request?.offers?.length ?? 0)

const hasActiveArtisans = computed(() =>
  artisanCount.value > 0 || props.request?.status === 'in_progress'
)

/**
 * Fee tier based on time since the offer was accepted.
 * Uses updated_at as proxy for when the request moved to in_progress.
 *  < 12 h since acceptance → free
 * 12–24 h                  → 25 %
 *  > 24 h                  → 50 %
 */
const feeLevel = computed(() => {
  if (!props.request || props.request.status !== 'in_progress') return 'free'
  const acceptedAt = new Date(props.request.updated_at)
  const hoursAgo   = (Date.now() - acceptedAt.getTime()) / 3_600_000
  if (hoursAgo < 12) return 'free'
  if (hoursAgo < 24) return 'fee25'
  return 'fee50'
})

async function submit() {
  error.value      = ''
  submitting.value = true
  try {
    const token = localStorage.getItem('token')
    const body  = reason.value.trim() ? { reason: reason.value.trim() } : {}
    const res   = await fetch(
      `/api/client/service-requests/${props.request.id}/cancel`,
      {
        method:  'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Accept:          'application/json',
          Authorization:  `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      }
    )
    const data = await res.json()
    if (!res.ok) throw new Error(data.error || data.message || 'Erreur lors de l\'annulation')
    emit('success')
  } catch (e) {
    error.value = e.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.cm-overlay {
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

.cm-card {
  background: #fff;
  border-radius: 18px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 24px 64px rgba(0,0,0,0.18);
  overflow: hidden;
}

/* ── Header ── */
.cm-header {
  background: linear-gradient(135deg, #EF4444, #DC2626);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.cm-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.cm-icon-wrap {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.cm-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  line-height: 1.2;
}
.cm-subtitle {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: rgba(255,255,255,0.75);
  margin-top: 2px;
}
.cm-close {
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
  flex-shrink: 0;
}
.cm-close:hover { background: rgba(255,255,255,0.28); }

/* ── Body ── */
.cm-body {
  padding: 20px 22px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* Warning box */
.cm-warn-box {
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 10px;
  padding: 12px 14px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.cm-warn-text {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #7F1D1D;
  margin: 0;
  line-height: 1.5;
}
.cm-artisan-warn {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #C10007;
}

/* Policy box */
.cm-policy {
  background: #FFFBEB;
  border: 1px solid #FDE68A;
  border-radius: 10px;
  padding: 12px 14px;
}
.cm-policy-header {
  display: flex;
  align-items: center;
  gap: 7px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #92400E;
  margin-bottom: 8px;
}
.cm-policy-list {
  margin: 0;
  padding-left: 18px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.cm-policy-list li {
  font-family: 'Inter', sans-serif;
  font-size: 12.5px;
  color: #78350F;
  line-height: 1.5;
}
.cm-policy-active {
  font-weight: 700;
  color: #92400E !important;
}

/* Reason field */
.cm-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.cm-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}
.cm-optional {
  font-weight: 400;
  color: #9CA3AF;
  margin-left: 4px;
}
.cm-textarea {
  width: 100%;
  box-sizing: border-box;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  padding: 10px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  resize: vertical;
  outline: none;
  background: #FAFAFA;
  transition: border-color 0.15s;
}
.cm-textarea:focus { border-color: #EF4444; background: #fff; }

/* Error */
.cm-error {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

/* Footer */
.cm-footer {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 2px;
}
.cm-btn-keep {
  height: 46px;
  background: #fff;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  color: #374151;
  cursor: pointer;
  transition: background 0.15s;
}
.cm-btn-keep:hover { background: #F9FAFB; }

.cm-btn-cancel {
  height: 46px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  background: #EF4444;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}
.cm-btn-cancel:hover:not(:disabled) { background: #DC2626; }
.cm-btn-cancel:disabled { opacity: 0.6; cursor: not-allowed; }

/* Transition */
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.2s; }
.modal-fade-enter-active .cm-card,
.modal-fade-leave-active .cm-card { transition: transform 0.2s, opacity 0.2s; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }
.modal-fade-enter-from .cm-card,
.modal-fade-leave-to .cm-card { transform: scale(0.95) translateY(8px); opacity: 0; }
</style>

<template>
  <transition name="modal-fade">
    <div v-if="show" class="crm-overlay" @click.self="handleClose">
      <div class="crm-card">

        <!-- Header -->
        <div class="crm-header">
          <div class="crm-header-left">
            <div class="crm-icon-wrap">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="12"/>
                <circle cx="12" cy="16" r="0.5" fill="white"/>
              </svg>
            </div>
            <span class="crm-title">Signaler cet utilisateur</span>
          </div>
          <button class="crm-close" @click="handleClose">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="crm-body">

          <!-- Reason -->
          <div class="crm-field">
            <label class="crm-label">Motif du signalement</label>
            <select v-model="reason" class="crm-select">
              <option value="">Sélectionnez un motif…</option>
              <option value="spam">Spam ou messages indésirables</option>
              <option value="inappropriate">Contenu inapproprié</option>
              <option value="fraud">Fraude ou arnaque</option>
              <option value="no_show">Absence sans prévenir</option>
              <option value="other">Autre</option>
            </select>
          </div>

          <!-- Description -->
          <div class="crm-field">
            <label class="crm-label">Description</label>
            <textarea
              v-model="description"
              class="crm-textarea"
              rows="4"
              placeholder="Décrivez le problème rencontré…"
            ></textarea>
          </div>

          <!-- Error -->
          <p v-if="error" class="crm-error">{{ error }}</p>

          <!-- Success -->
          <p v-if="success" class="crm-success">{{ success }}</p>

          <!-- Submit -->
          <button
            class="crm-submit-btn"
            :disabled="submitting || !!success"
            @click="submit"
          >
            {{ submitting ? 'Envoi en cours…' : 'Envoyer le signalement' }}
          </button>

        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show:           { type: Boolean, default: false },
  conversationId: { type: [Number, String], required: true },
})

const emit = defineEmits(['close'])

const reason      = ref('')
const description = ref('')
const submitting  = ref(false)
const error       = ref('')
const success     = ref('')

watch(() => props.show, (val) => {
  if (val) {
    reason.value      = ''
    description.value = ''
    error.value       = ''
    success.value     = ''
  }
})

function handleClose() {
  if (submitting.value) return
  emit('close')
}

async function submit() {
  error.value   = ''
  success.value = ''

  if (!reason.value) {
    error.value = 'Veuillez sélectionner un motif.'
    return
  }
  if (!description.value.trim()) {
    error.value = 'Veuillez décrire le problème.'
    return
  }

  submitting.value = true
  try {
    const token = localStorage.getItem('token')
    const res = await fetch(`/api/conversations/${props.conversationId}/report`, {
      method:  'POST',
      headers: {
        Authorization:  `Bearer ${token}`,
        Accept:         'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        reason:      reason.value,
        description: description.value.trim(),
      }),
    })
    const body = await res.json()
    if (!res.ok) throw new Error(body.error || body.message || 'Erreur')
    success.value = body.message || 'Votre signalement a été envoyé.'
    setTimeout(() => emit('close'), 2000)
  } catch (e) {
    error.value = e.message || 'Impossible d\'envoyer le signalement.'
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.crm-overlay {
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

.crm-card {
  background: #fff;
  border-radius: 18px;
  width: 100%;
  max-width: 420px;
  box-shadow: 0 24px 64px rgba(0,0,0,0.18);
  overflow: hidden;
}

.crm-header {
  background: linear-gradient(135deg, #EF4444, #DC2626);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.crm-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.crm-icon-wrap {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.crm-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
}

.crm-close {
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
.crm-close:hover { background: rgba(255,255,255,0.28); }

.crm-body {
  padding: 22px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.crm-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.crm-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}

.crm-select {
  width: 100%;
  box-sizing: border-box;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  padding: 10px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  background: #FAFAFA;
  outline: none;
  transition: border-color 0.15s;
  cursor: pointer;
}
.crm-select:focus { border-color: #EF4444; background: #fff; }

.crm-textarea {
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
.crm-textarea:focus { border-color: #EF4444; background: #fff; }

.crm-error {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

.crm-success {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #16A34A;
  background: #F0FDF4;
  border: 1px solid #BBF7D0;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

.crm-submit-btn {
  width: 100%;
  height: 48px;
  background: #EF4444;
  color: #fff;
  border: none;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
}
.crm-submit-btn:hover:not(:disabled) { background: #DC2626; }
.crm-submit-btn:active:not(:disabled) { transform: scale(0.98); }
.crm-submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }

/* Transition */
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.2s; }
.modal-fade-enter-active .crm-card,
.modal-fade-leave-active .crm-card { transition: transform 0.2s, opacity 0.2s; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }
.modal-fade-enter-from .crm-card,
.modal-fade-leave-to .crm-card { transform: scale(0.95) translateY(8px); opacity: 0; }
</style>

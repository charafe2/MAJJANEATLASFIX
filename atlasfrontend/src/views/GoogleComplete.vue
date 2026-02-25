<template>
  <div class="page">
    <div class="card">

      <!-- Google avatar + name pulled from query params -->
      <div class="google-header">
        <div class="google-badge">
          <svg width="20" height="20" viewBox="0 0 48 48">
            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.08 17.74 9.5 24 9.5z"/>
            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-3.59-13.46-8.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
          </svg>
        </div>
        <div class="google-info">
          <p class="greeting">Bienvenue, <strong>{{ fullName }}</strong></p>
          <p class="email-hint">{{ email }}</p>
        </div>
      </div>

      <h2 class="title">Complétez votre profil</h2>
      <p class="subtitle">Quelques informations supplémentaires pour finaliser votre compte.</p>

      <!-- Account type toggle -->
      <div class="type-toggle">
        <button
          :class="['type-btn', accountType === 'client'  && 'active-client']"
          @click="accountType = 'client'">
          👤 Client
        </button>
        <button
          :class="['type-btn', accountType === 'artisan' && 'active-artisan']"
          @click="accountType = 'artisan'">
          🔧 Artisan
        </button>
      </div>

      <!-- Phone -->
      <div class="field">
        <label>Numéro de téléphone</label>
        <div class="input-wrap" :class="{ error: errors.phone }">
          <span class="prefix">🇲🇦 +212</span>
          <input
            v-model="phone"
            type="tel"
            placeholder="6 XX XX XX XX"
            @input="errors.phone = ''"
          />
        </div>
        <span v-if="errors.phone" class="err-msg">{{ errors.phone }}</span>
      </div>

      <!-- Birth date -->
      <div class="field">
        <label>Date de naissance</label>
        <input
          v-model="birthDate"
          type="date"
          class="date-input"
          :class="{ error: errors.birthDate }"
          :max="maxDate"
          @change="errors.birthDate = ''"
        />
        <span v-if="errors.birthDate" class="err-msg">{{ errors.birthDate }}</span>
      </div>

      <!-- General error -->
      <div v-if="errors.general" class="general-error">{{ errors.general }}</div>

      <button class="submit-btn" :disabled="loading" @click="submit">
        <span v-if="loading" class="btn-spinner"></span>
        <span v-else>Créer mon compte</span>
      </button>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const route  = useRoute()

// ── Query params passed by GoogleSuccessView ─────────────────────────────────
const tempKey  = ref('')
const fullName = ref('')
const email    = ref('')

// ── Form state ───────────────────────────────────────────────────────────────
const accountType = ref('client')
const phone       = ref('')
const birthDate   = ref('')
const loading     = ref(false)
const errors      = ref({})

// Max date = 18 years ago
const maxDate = computed(() => {
  const d = new Date()
  d.setFullYear(d.getFullYear() - 18)
  return d.toISOString().split('T')[0]
})

onMounted(() => {
  tempKey.value  = route.query.temp_key  ?? ''
  fullName.value = route.query.full_name ?? ''
  email.value    = route.query.email     ?? ''

  if (!tempKey.value) {
    router.replace('/login')
  }
})

function validate() {
  errors.value = {}
  const cleaned = phone.value.replace(/\s/g, '')
  if (!/^[67]\d{8}$/.test(cleaned))
    errors.value.phone = 'Numéro invalide (ex: 6 12 34 56 78)'
  if (!birthDate.value)
    errors.value.birthDate = 'Date de naissance requise'
  return Object.keys(errors.value).length === 0
}

async function submit() {
  if (!validate()) return
  loading.value = true
  errors.value  = {}
  try {
    const res = await axios.post('/api/auth/google/complete', {
      temp_key:     tempKey.value,
      account_type: accountType.value,
      phone:        '+212' + phone.value.replace(/\s/g, ''),
      birth_date:   birthDate.value,
    })

    localStorage.setItem('token', res.data.token)
    localStorage.setItem('user',  JSON.stringify(res.data.user))

    if (res.data.account_type === 'artisan') {
      const uid = res.data.user?.id
      if (uid) localStorage.setItem('pending_user_id', uid)
      router.replace({ path: '/register/artisan/pricing', query: { uid } })
    } else {
      router.replace('/client/profile')
    }
  } catch (e) {
    const data = e.response?.data
    if (data?.errors) {
      if (data.errors.phone)      errors.value.phone     = data.errors.phone[0]
      if (data.errors.birth_date) errors.value.birthDate = data.errors.birth_date[0]
    } else {
      errors.value.general = data?.error ?? 'Une erreur est survenue, réessayez.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #fff8f5 0%, #ffffff 100%);
  font-family: 'Poppins', sans-serif;
  padding: 24px;
}

.card {
  background: white;
  border-radius: 24px;
  padding: 40px 36px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 12px 40px rgba(0,0,0,0.08);
}

/* Google header */
.google-header {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f8f9fa;
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 24px;
}

.google-badge {
  width: 40px; height: 40px;
  background: white;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  flex-shrink: 0;
}

.greeting { font-size: 14px; margin: 0 0 2px; color: #111; }
.email-hint { font-size: 12px; color: #888; margin: 0; }

/* Title */
.title    { font-size: 22px; font-weight: 700; color: #111; margin: 0 0 6px; }
.subtitle { font-size: 13px; color: #888; margin: 0 0 24px; }

/* Account type toggle */
.type-toggle {
  display: flex;
  gap: 10px;
  margin-bottom: 24px;
}

.type-btn {
  flex: 1;
  padding: 10px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  background: white;
  font-family: 'Poppins', sans-serif;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  color: #555;
}

.active-client  { border-color: #2563eb; color: #2563eb; background: #eff6ff; }
.active-artisan { border-color: #FC5A15; color: #FC5A15; background: #fff5f0; }

/* Fields */
.field { margin-bottom: 18px; }
.field label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #555;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.input-wrap {
  display: flex;
  align-items: center;
  border: 1.5px solid #e5e7eb;
  border-radius: 10px;
  overflow: hidden;
  transition: border-color 0.15s;
}

.input-wrap:focus-within { border-color: #FC5A15; }
.input-wrap.error        { border-color: #ef4444; }

.prefix {
  padding: 0 12px;
  font-size: 13px;
  color: #555;
  background: #f8f9fa;
  border-right: 1px solid #e5e7eb;
  height: 100%;
  display: flex;
  align-items: center;
  white-space: nowrap;
  height: 46px;
}

.input-wrap input {
  flex: 1;
  border: none;
  outline: none;
  padding: 12px 14px;
  font-size: 14px;
  font-family: 'Poppins', sans-serif;
  background: white;
}

.date-input {
  width: 100%;
  border: 1.5px solid #e5e7eb;
  border-radius: 10px;
  padding: 12px 14px;
  font-size: 14px;
  font-family: 'Poppins', sans-serif;
  outline: none;
  box-sizing: border-box;
  transition: border-color 0.15s;
}

.date-input:focus { border-color: #FC5A15; }
.date-input.error { border-color: #ef4444; }

.err-msg { font-size: 11px; color: #ef4444; margin-top: 4px; display: block; }

.general-error {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #dc2626;
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 16px;
}

/* Submit */
.submit-btn {
  width: 100%;
  padding: 14px;
  background: #FC5A15;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 700;
  font-family: 'Poppins', sans-serif;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  transition: opacity 0.15s;
}

.submit-btn:disabled { opacity: 0.65; cursor: not-allowed; }

.btn-spinner {
  width: 18px; height: 18px;
  border: 2.5px solid rgba(255,255,255,0.35);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }
</style>
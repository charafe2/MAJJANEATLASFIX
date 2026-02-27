<template>
  <div>
    <Navbar />
    <AuthBackground>
      <div class="forgot-wrapper">

        <div class="forgot-card">

          <!-- ── STEP 1 : Enter phone/email ── -->
          <template v-if="step === 1">
            <div class="forgot-icon">🔐</div>
            <h2 class="forgot-title">Mot de passe oublié ?</h2>
            <p class="forgot-subtitle">
              Entrez votre numéro de téléphone ou votre email.
              Nous vous enverrons un code de réinitialisation.
            </p>

            <div class="field full">
              <label>📞 Téléphone ou Email *</label>
              <input v-model="identifier" type="text" placeholder="06 XX XX XX XX ou exemple@email.com"
                :class="{ 'input-error': identifierError }" @keyup.enter="handleSend" />
              <span class="error-msg" v-if="identifierError">{{ identifierError }}</span>
            </div>

            <div class="alert-error" v-if="authError">{{ authError }}</div>

            <button class="btn-primary" :disabled="loading" @click="handleSend">
              <span v-if="loading" class="spinner"></span>
              <span v-else>Envoyer le code</span>
            </button>

            <button class="btn-back-link" @click="$router.push('/login')">← Retour à la connexion</button>
          </template>

          <!-- ── STEP 2 : Code + new password ── -->
          <template v-if="step === 2">
            <div class="forgot-icon">✉️</div>
            <h2 class="forgot-title">Réinitialiser le mot de passe</h2>
            <p class="forgot-subtitle">
              Entrez le code reçu et votre nouveau mot de passe.
            </p>

            <!-- OTP -->
            <div class="field full">
              <label>Code de vérification *</label>
              <div class="otp-row">
                <input v-for="(digit, i) in otp" :key="i"
                  :ref="el => inputs[i] = el"
                  v-model="otp[i]"
                  type="text" inputmode="numeric" maxlength="1"
                  class="otp-input" :class="{ 'input-error': errors.code }"
                  @input="onInput(i, $event)"
                  @keydown="onKeydown(i, $event)"
                  @paste="onPaste($event)" />
              </div>
              <span class="error-msg" v-if="errors.code">{{ errors.code }}</span>
            </div>

            <div class="field full">
              <label>🔒 Nouveau mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password" :type="showPwd ? 'text' : 'password'"
                  placeholder="••••••••" :class="{ 'input-error': errors.password }" />
                <button type="button" class="toggle-pass" @click="showPwd = !showPwd">
                  {{ showPwd ? '🙈' : '👁' }}
                </button>
              </div>
              <span class="error-msg" v-if="errors.password">{{ errors.password }}</span>
            </div>

            <div class="field full">
              <label>🔒 Confirmer le mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password_confirmation" :type="showPwd2 ? 'text' : 'password'"
                  placeholder="••••••••" :class="{ 'input-error': errors.password_confirmation }" />
                <button type="button" class="toggle-pass" @click="showPwd2 = !showPwd2">
                  {{ showPwd2 ? '🙈' : '👁' }}
                </button>
              </div>
              <span class="error-msg" v-if="errors.password_confirmation">{{ errors.password_confirmation }}</span>
            </div>

            <div class="alert-error" v-if="authError">{{ authError }}</div>
            <div class="alert-success" v-if="successMsg">{{ successMsg }}</div>

            <button class="btn-primary" :disabled="loading" @click="handleReset">
              <span v-if="loading" class="spinner"></span>
              <span v-else>Réinitialiser le mot de passe</span>
            </button>

            <!-- Resend -->
            <div class="resend-row">
              <span>Vous n'avez pas reçu le code ?</span>
              <button class="resend-btn" :disabled="resendCooldown > 0 || resendLoading" @click="handleSend">
                <span v-if="resendLoading">Envoi...</span>
                <span v-else-if="resendCooldown > 0">Renvoyer ({{ resendCooldown }}s)</span>
                <span v-else>Renvoyer</span>
              </button>
            </div>

            <button class="btn-back-link" @click="step = 1">← Retour</button>
          </template>

        </div>
      </div>
    </AuthBackground>
    <Footer />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import Navbar from '../../components/navbar.vue'
import AuthBackground from '../../components/auth/Authbackground.vue'
import Footer from '../../components/footer.vue'
import { forgotPassword, resetPassword } from '../../api/auth.js'
import '../../assets/css/auth/forgot.css'

const router = useRouter()

const step           = ref(1)
const identifier     = ref('')
const identifierError = ref('')
const loading        = ref(false)
const resendLoading  = ref(false)
const authError      = ref('')
const successMsg     = ref('')
const resendCooldown = ref(0)
const showPwd        = ref(false)
const showPwd2       = ref(false)

const otp    = reactive(['', '', '', ''])
const inputs = ref([])
const errors = reactive({})
const form   = reactive({ password: '', password_confirmation: '' })

let cooldownInterval = null
onUnmounted(() => { if (cooldownInterval) clearInterval(cooldownInterval) })

// ── OTP helpers ──────────────────────────────────────────────────────────
function onInput(i, e) {
  errors.code = ''
  const val = e.target.value.replace(/\D/g, '').slice(-1)
  otp[i] = val
  if (val && i < 3) inputs.value[i + 1]?.focus()
}
function onKeydown(i, e) {
  if (e.key === 'Backspace' && !otp[i] && i > 0) {
    otp[i - 1] = ''; inputs.value[i - 1]?.focus()
  }
}
function onPaste(e) {
  e.preventDefault()
  const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 4)
  text.split('').forEach((ch, i) => { otp[i] = ch })
  inputs.value[Math.min(text.length, 3)]?.focus()
}

function startCooldown() {
  resendCooldown.value = 60
  cooldownInterval = setInterval(() => {
    resendCooldown.value--
    if (resendCooldown.value <= 0) { clearInterval(cooldownInterval); cooldownInterval = null }
  }, 1000)
}

// ── Step 1 : Send code ──────────────────────────────────────────────────
async function handleSend() {
  identifierError.value = ''
  authError.value       = ''
  if (!identifier.value) { identifierError.value = 'Veuillez entrer votre téléphone ou email'; return }

  loading.value = true
  try {
    await forgotPassword({ identifier: identifier.value })
    step.value = 2
    otp.fill('')
    startCooldown()
  } catch (err) {
    const errData = err.response?.data
    identifierError.value = errData?.message || errData?.error || 'Compte introuvable'
  } finally { loading.value = false }
}

// ── Step 2 : Reset password ─────────────────────────────────────────────
async function handleReset() {
  Object.keys(errors).forEach(k => delete errors[k])
  authError.value  = ''
  successMsg.value = ''

  const code = otp.join('')
  if (code.length < 4)                              { errors.code = 'Entrez le code complet'; return }
  if (!form.password)                               { errors.password = 'Mot de passe requis'; return }
  if (form.password.length < 8)                     { errors.password = 'Minimum 8 caractères'; return }
  if (form.password !== form.password_confirmation)  { errors.password_confirmation = 'Les mots de passe ne correspondent pas'; return }

  loading.value = true
  try {
    await resetPassword({
      identifier:            identifier.value,
      code,
      password:              form.password,
      password_confirmation: form.password_confirmation,
    })
    successMsg.value = 'Mot de passe réinitialisé avec succès !'
    setTimeout(() => router.push('/login'), 1500)
  } catch (err) {
    const errData = err.response?.data
    if (errData?.errors) {
      Object.entries(errData.errors).forEach(([f, msgs]) => { errors[f] = msgs[0] })
    } else if (errData?.error?.toLowerCase().includes('code')) {
      errors.code = 'Code incorrect ou expiré'
    } else {
      authError.value = errData?.message || 'Une erreur est survenue'
    }
  } finally { loading.value = false }
}
</script>
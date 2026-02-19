<template>
  <div>
    <Navbar />
    <AuthBackground>
      <div class="verify-wrapper">

        <div class="verify-card">
          <!-- Icon -->
          <div class="verify-icon">📱</div>
          <h2 class="verify-title">Vérifiez votre compte</h2>
          <p class="verify-subtitle">
            Un code de vérification a été envoyé à votre numéro de téléphone.
            Entrez le code ci-dessous pour activer votre compte.
          </p>

          <!-- OTP inputs -->
          <div class="otp-row">
            <input
              v-for="(digit, i) in otp"
              :key="i"
              :ref="el => inputs[i] = el"
              v-model="otp[i]"
              type="text"
              inputmode="numeric"
              maxlength="1"
              class="otp-input"
              :class="{ 'input-error': codeError }"
              @input="onInput(i, $event)"
              @keydown="onKeydown(i, $event)"
              @paste="onPaste($event)"
            />
          </div>

          <span class="error-msg center" v-if="codeError">{{ codeError }}</span>
          <div class="alert-error" v-if="authError">{{ authError }}</div>
          <div class="alert-success" v-if="successMsg">{{ successMsg }}</div>

          <!-- Verify button -->
          <button class="btn-verify" :disabled="loading || otp.join('').length < 4" @click="handleVerify">
            <span v-if="loading" class="spinner"></span>
            <span v-else>Vérifier mon compte</span>
          </button>

          <!-- Resend -->
          <div class="resend-row">
            <span>Vous n'avez pas reçu le code ?</span>
            <button
              class="resend-btn"
              :disabled="resendCooldown > 0 || resendLoading"
              @click="handleResend"
            >
              <span v-if="resendLoading">Envoi...</span>
              <span v-else-if="resendCooldown > 0">Renvoyer ({{ resendCooldown }}s)</span>
              <span v-else>Renvoyer le code</span>
            </button>
          </div>
        </div>

      </div>
    </AuthBackground>
    <Footer />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Navbar from '../components/navbar.vue'
import AuthBackground from '../components/Authbackground.vue'
// import Footer from '../components/footer.vue'
import { verifyCode, resendCode } from '../api/auth.js'
import '../assets/css/verify.css'

const router = useRouter()
const route  = useRoute()

const userId      = ref(route.query.user_id || null)
const otp         = reactive(['', '', '', ''])
const inputs      = ref([])
const loading     = ref(false)
const resendLoading = ref(false)
const authError   = ref('')
const codeError   = ref('')
const successMsg  = ref('')
const resendCooldown = ref(0)
let cooldownInterval = null

// Focus first input on mount
onMounted(() => { inputs.value[0]?.focus() })
onUnmounted(() => { if (cooldownInterval) clearInterval(cooldownInterval) })

function onInput(i, e) {
  codeError.value = ''
  const val = e.target.value.replace(/\D/g, '').slice(-1)
  otp[i] = val
  if (val && i < 3) inputs.value[i + 1]?.focus()
}

function onKeydown(i, e) {
  if (e.key === 'Backspace') {
    if (!otp[i] && i > 0) {
      otp[i - 1] = ''
      inputs.value[i - 1]?.focus()
    }
  }
}

function onPaste(e) {
  e.preventDefault()
  const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 4)
  text.split('').forEach((ch, i) => { otp[i] = ch })
  inputs.value[Math.min(text.length, 3)]?.focus()
}

async function handleVerify() {
  const code = otp.join('')
  if (code.length < 4) { codeError.value = 'Entrez le code complet'; return }

  loading.value = true; authError.value = ''; codeError.value = ''
  try {
    const { data } = await verifyCode({ user_id: userId.value, code })

    // Save token and user
    localStorage.setItem('token', data.token)
    localStorage.setItem('user',  JSON.stringify(data.user))

    // Redirect based on account type
    if (data.account_type === 'artisan') {
      router.push('/artisan/dashboard')
    } else {
      router.push('/client/dashboard')
    }
  } catch (err) {
    const status  = err.response?.status
    const errData = err.response?.data
    if (status === 422 && errData?.error?.toLowerCase().includes('invalid')) {
      codeError.value = 'Code incorrect, veuillez réessayer'
    } else if (status === 422 && errData?.error?.toLowerCase().includes('expired')) {
      codeError.value = 'Code expiré, veuillez en demander un nouveau'
    } else {
      authError.value = errData?.message || errData?.error || 'Une erreur est survenue'
    }
  } finally { loading.value = false }
}

async function handleResend() {
  resendLoading.value = true; authError.value = ''; successMsg.value = ''
  try {
    await resendCode({ user_id: userId.value })
    successMsg.value = 'Un nouveau code a été envoyé !'
    otp.fill('')
    inputs.value[0]?.focus()
    startCooldown()
  } catch (err) {
    authError.value = err.response?.data?.message || 'Impossible d\'envoyer le code'
  } finally { resendLoading.value = false }
}

function startCooldown() {
  resendCooldown.value = 60
  cooldownInterval = setInterval(() => {
    resendCooldown.value--
    if (resendCooldown.value <= 0) { clearInterval(cooldownInterval); cooldownInterval = null }
  }, 1000)
}
</script>
<template>
  <div class="login-wrapper">

    <!-- Back button -->
    <button class="back-btn" @click="$router.push('/')">
      ← Retour
    </button>

    <!-- Card -->
    <div class="login-card">

      <!-- Header -->
      <div class="card-header">
        <div class="avatar">H</div>
        <h2 class="title">Bienvenue</h2>
        <p class="subtitle">Connectez-vous à votre compte</p>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleLogin">

        <!-- Email -->
        <div class="field">
          <label>
            <span class="field-icon">✉</span>
            Adresse email
          </label>
          <input
            v-model="form.email"
            type="email"
            placeholder="exemple@email.com"
            :class="{ 'input-error': errors.email }"
          />
          <span class="error-msg" v-if="errors.email">{{ errors.email }}</span>
        </div>

        <!-- Password -->
        <div class="field">
          <label>
            <span class="field-icon">🔒</span>
            Mot de passe
          </label>
          <div class="password-wrapper">
            <input
              v-model="form.password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="••••••••"
              :class="{ 'input-error': errors.password }"
            />
            <button type="button" class="toggle-pass" @click="showPassword = !showPassword">
              {{ showPassword ? '🙈' : '👁' }}
            </button>
          </div>
          <span class="error-msg" v-if="errors.password">{{ errors.password }}</span>
        </div>

        <!-- Remember + Forgot -->
        <div class="row-between">
          <label class="checkbox-label">
            <input type="checkbox" v-model="form.remember" />
            Se souvenir de moi
          </label>
          <button type="button" class="forgot-btn" @click="$router.push('/forgot-password')">
            Mot de passe oublié ?
          </button>
        </div>

        <!-- Error -->
        <div class="alert-error" v-if="authError">{{ authError }}</div>

        <!-- Submit -->
        <button type="submit" class="btn-primary" :disabled="loading">
          <span v-if="loading" class="spinner"></span>
          <span v-else>Se connecter</span>
        </button>

      </form>

      <!-- OU Divider -->
      <div class="divider"><span>OU</span></div>

      <!-- Social buttons -->
      <div class="social-buttons">

        <button class="btn-social btn-app" @click="handleAppLogin">
          <!-- <img src="/icons/app-icon.svg" alt="" class="social-icon" /> -->
          S'inscrire avec l'application
        </button>

        <button class="btn-social btn-google" @click="handleGoogleLogin">
          <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" class="social-icon" />
          Continuer avec Google
        </button>

        <button class="btn-social btn-facebook" @click="handleFacebookLogin">
          <img src="https://www.svgrepo.com/show/448224/facebook.svg" alt="Facebook" class="social-icon" />
          Continuer avec Facebook
        </button>

      </div>

      <!-- Register link -->
      <p class="register-link">
        <span>Vous n'avez pas de compte ?&nbsp;</span>
        <a @click="$router.push('/register')">Créer un compte</a>
      </p>

    </div>
  </div>
</template>

<script setup>
import '../assets/css/login.css'
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { login } from '../api/auth.js'

const router = useRouter()

const form = reactive({ email: '', password: '', remember: false })
const errors       = reactive({})
const authError    = ref('')
const loading      = ref(false)
const showPassword = ref(false)

function validate() {
  Object.keys(errors).forEach(k => delete errors[k])
  if (!form.email)                             errors.email    = 'Email requis'
  else if (!/\S+@\S+\.\S+/.test(form.email))  errors.email    = 'Email invalide'
  if (!form.password)                          errors.password = 'Mot de passe requis'
  else if (form.password.length < 8)           errors.password = 'Minimum 8 caractères'
  return Object.keys(errors).length === 0
}

async function handleLogin() {
  if (!validate()) return
  loading.value = true; authError.value = ''
  try {
    const { data } = await login({ email: form.email, password: form.password })

    localStorage.setItem('token', data.token)
    localStorage.setItem('user',  JSON.stringify(data.user))

    if (data.account_type === 'client') {
      router.push('/client/profile')
    } else {
      router.push('/Home')
    }
  } catch (err) {
    const status  = err.response?.status
    const errData = err.response?.data

    if (status === 403 && errData?.error === 'Account not verified') {
      router.push(`/verify?user_id=${errData.user_id}`)
    } else if (status === 403 && errData?.error?.toLowerCase().includes('banned')) {
      authError.value = errData.error
    } else if (status === 403 && errData?.error?.toLowerCase().includes('suspended')) {
      authError.value = `Votre compte est suspendu jusqu'au ${errData.suspended_until}`
    } else if (status === 401 || status === 422) {
      authError.value = 'Email ou mot de passe incorrect'
    } else {
      authError.value = errData?.message || 'Une erreur est survenue'
    }
  } finally { loading.value = false }
}

function handleGoogleLogin() {
  window.location.href = '/auth/google'
}

function handleFacebookLogin() {
  window.location.href = '/auth/facebook/redirect'
}

function handleAppLogin() {
  router.push('/register')
}
</script>
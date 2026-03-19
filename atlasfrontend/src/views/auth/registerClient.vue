<template>
  <div>
    <AuthBackground>
      <div class="register-wrapper">

        <button class="back-btn" @click="$router.push('/register')">← Retour</button>

        <div class="register-header">
          <h1 class="register-title">Créer un compte Client</h1>
          <p class="register-subtitle">Trouvez les meilleurs artisans près de chez vous</p>
        </div>
        <div class="register-card">
          <div class="register-inner">
            <h2 class="section-title">Informations personnelles</h2>

            <div class="field">
              <label>Nom complet *</label>
              <input v-model="form.full_name" type="text" placeholder="Ex: Mohammed Bennani"
                :class="{ 'input-error': errors.full_name }" />
              <span class="error-msg" v-if="errors.full_name">{{ errors.full_name }}</span>
            </div>

            <div class="field">
              <label>Adresse email *</label>
              <input v-model="form.email" type="email" placeholder="exemple@email.com"
                :class="{ 'input-error': errors.email }" />
              <span class="error-msg" v-if="errors.email">{{ errors.email }}</span>
            </div>

            <div class="field">
              <label>Numéro de téléphone *</label>
              <input v-model="form.phone" type="tel" placeholder="+212 6XX XX XX XX"
                :class="{ 'input-error': errors.phone }" />
              <span class="error-msg" v-if="errors.phone">{{ errors.phone }}</span>
            </div>

            <div class="field">
              <label>Date de naissance *</label>
              <input v-model="form.birth_date" type="date"
                :class="{ 'input-error': errors.birth_date }" />
              <span class="error-msg" v-if="errors.birth_date">{{ errors.birth_date }}</span>
            </div>

            <div class="field">
              <label>Ville *</label>
              <div class="select-wrapper">
                <select v-model="form.city" :class="{ 'input-error': errors.city }">
                  <option value="" disabled>Sélectionnez une ville</option>
                  <option v-for="c in cities" :key="c" :value="c">{{ c }}</option>
                </select>
                <span class="select-arrow">▾</span>
              </div>
              <span class="error-msg" v-if="errors.city">{{ errors.city }}</span>
            </div>

            <div class="field">
              <label>Adresse *</label>
              <div class="address-row">
                <input v-model="form.address" type="text" placeholder="Adresse complète"
                  :class="{ 'input-error': errors.address }" />
                <button type="button" class="locate-btn" @click="getLocation">📍 Me localiser</button>
              </div>
              <span class="error-msg" v-if="errors.address">{{ errors.address }}</span>
            </div>

            <div class="field">
              <label>Mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password" :type="showPwd ? 'text' : 'password'"
                  placeholder="••••••••" :class="{ 'input-error': errors.password }" />
                <button type="button" class="toggle-pass" @click="showPwd = !showPwd">
                  <svg v-if="!showPwd" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                </button>
              </div>
              <span class="error-msg" v-if="errors.password">{{ errors.password }}</span>
            </div>

            <div class="field">
              <label>Confirmer le mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password_confirmation" :type="showPwd2 ? 'text' : 'password'"
                  placeholder="••••••••" :class="{ 'input-error': errors.password_confirmation }" />
                <button type="button" class="toggle-pass" @click="showPwd2 = !showPwd2">
                  <svg v-if="!showPwd2" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                </button>
              </div>
              <span class="error-msg" v-if="errors.password_confirmation">{{ errors.password_confirmation }}</span>
            </div>

            <div class="terms-row">
              <input type="checkbox" id="terms-client" v-model="form.terms" />
              <label for="terms-client">
                J'accepte les <a href="#">conditions générales d'utilisation</a>
              </label>
            </div>
            <span class="error-msg" v-if="errors.terms">{{ errors.terms }}</span>

            <div class="alert-error" v-if="authError">{{ authError }}</div>
          </div>

          <div class="card-footer-right">
            <button class="btn-submit" :disabled="loading" @click="handleSubmit">
              <span v-if="loading" class="spinner"></span>
              <span v-else>Créer mon compte</span>
            </button>
          </div>
        </div>

        <div class="why-box">
          <h3>Pourquoi créer un compte ?</h3>
          <ul class="why-list">
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Créez et gérez vos demandes de service facilement</span>
            </li>
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Recevez des devis de plusieurs artisans qualifiés</span>
            </li>
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Suivez l'état de vos demandes en temps réel</span>
            </li>
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Communiquez directement avec les artisans</span>
            </li>
          </ul>
        </div>
      </div>
    </AuthBackground>
    <Footer />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import Navbar from '../../components/navbar.vue'
import AuthBackground from '../../components/auth/Authbackground.vue'
// import Footer from '../../components/footer.vue'
import { registerClient } from '../../api/auth.js'
import '../../assets/css/auth/registerform.css'

const router    = useRouter()
const loading   = ref(false)
const authError = ref('')
const showPwd   = ref(false)
const showPwd2  = ref(false)

const form = reactive({
  full_name: '', email: '', phone: '', birth_date: '',
  city: '', address: '', password: '', password_confirmation: '',
  verification_method: 'phone',
  terms: false,
})
const errors = reactive({})
const cities = [
  'Casablanca','Rabat','Marrakech','Fès','Tanger',
  'Agadir','Meknès','Oujda','Kenitra','Tétouan','Salé','Temara',
]

function clearErrors() { Object.keys(errors).forEach(k => delete errors[k]) }

function validate() {
  clearErrors()
  if (!form.full_name)                               errors.full_name  = 'Nom complet requis'
  if (!form.email)                                   errors.email      = 'Email requis'
  else if (!/\S+@\S+\.\S+/.test(form.email))         errors.email      = 'Email invalide'
  if (!form.phone)                                   errors.phone      = 'Téléphone requis'
  if (!form.birth_date)                              errors.birth_date = 'Date requise'
  if (!form.city)                                    errors.city       = 'Ville requise'
  if (!form.address)                                 errors.address    = 'Adresse requise'
  if (!form.password)                                errors.password   = 'Mot de passe requis'
  else if (form.password.length < 8)                 errors.password   = 'Minimum 8 caractères'
  if (form.password !== form.password_confirmation)  errors.password_confirmation = 'Les mots de passe ne correspondent pas'
  if (!form.terms)                                   errors.terms      = 'Veuillez accepter les conditions'
  return Object.keys(errors).length === 0
}

function getLocation() {
  if (!navigator.geolocation) return
  navigator.geolocation.getCurrentPosition(pos => {
    form.address = `${pos.coords.latitude.toFixed(6)}, ${pos.coords.longitude.toFixed(6)}`
  })
}

async function handleSubmit() {
  if (!validate()) return
  loading.value = true
  authError.value = ''
  try {
    const { data } = await registerClient({
      account_type: 'client',
      full_name: form.full_name, email: form.email, phone: form.phone,
      birth_date: form.birth_date, city: form.city, address: form.address,
      password: form.password, password_confirmation: form.password_confirmation,
      verification_method: form.verification_method,
    })
    // Save token & user — go straight to dashboard, no verify step
    localStorage.setItem('token', data.token)
    localStorage.setItem('user',  JSON.stringify(data.user))
    router.push('/client/profile')
  } catch (err) {
    const errData = err.response?.data
    if (errData?.errors) {
      Object.entries(errData.errors).forEach(([f, msgs]) => { errors[f] = msgs[0] })
    } else {
      authError.value = errData?.message || errData?.error || 'Une erreur est survenue'
    }
  } finally { loading.value = false }
}
</script>
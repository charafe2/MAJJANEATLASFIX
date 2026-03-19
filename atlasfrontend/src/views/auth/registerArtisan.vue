<template>
  <div>
    <AuthBackground>
      <div class="artisan-wrapper">
        <button class="back-btn" @click="step === 1 ? $router.push('/register') : step--">← Retour</button>

        <div class="artisan-header">
          <h1 class="artisan-title">Devenez Artisan Partenaire</h1>
          <p class="artisan-subtitle">Rejoignez notre plateforme et développez votre activité</p>
        </div>

        <!-- Referral banner (shown when arriving via a referral link) -->
        <div v-if="referrerName" class="referral-banner">
          <span class="referral-icon">🔗</span>
          Vous avez été invité par <strong>{{ referrerName }}</strong> — bienvenue !
        </div>

        <!-- Stepper -->
        <div class="stepper">
          <div class="step-item">
            <div class="step-circle" :class="{ active: step >= 1, done: step > 1 }">
              <span v-if="step > 1">✓</span><span v-else>1</span>
            </div>
            <span class="step-label">Informations</span>
          </div>
          <div class="step-line" :class="{ active: step >= 2 }"></div>
          <div class="step-item">
            <div class="step-circle" :class="{ active: step >= 2, done: step > 2 }">
              <span v-if="step > 2">✓</span><span v-else>2</span>
            </div>
            <span class="step-label">Professionnel</span>
          </div>
          <div class="step-line" :class="{ active: step >= 3 }"></div>
          <div class="step-item">
            <div class="step-circle" :class="{ active: step >= 3 }">3</div>
            <span class="step-label">Portfolio</span>
          </div>
        </div>

        <!-- ─── STEP 1 ─── -->
        <div class="artisan-card" v-show="step === 1">
          <div class="artisan-fields">
            <h2 class="section-title">Informations personnelles</h2>
            <div class="field"><label>Nom complet *</label>
              <input v-model="form.full_name" type="text" placeholder="Ex: Mohammed Bennani" :class="{'input-error':errors.full_name}"/>
              <span class="error-msg" v-if="errors.full_name">{{errors.full_name}}</span></div>
            <div class="field"><label>Date de naissance *</label>
              <input v-model="form.birth_date" type="date" :class="{'input-error':errors.birth_date}"/>
              <span class="error-msg" v-if="errors.birth_date">{{errors.birth_date}}</span></div>
            <div class="field"><label>Adresse email *</label>
              <input v-model="form.email" type="email" placeholder="exemple@email.com" :class="{'input-error':errors.email}"/>
              <span class="error-msg" v-if="errors.email">{{errors.email}}</span></div>
            <div class="field"><label>Numéro de téléphone *</label>
              <input v-model="form.phone" type="tel" placeholder="+212 6XX XX XX XX" :class="{'input-error':errors.phone}"/>
              <span class="error-msg" v-if="errors.phone">{{errors.phone}}</span></div>
            <div class="field"><label>Mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password" :type="showPwd?'text':'password'" placeholder="••••••••" :class="{'input-error':errors.password}"/>
                <button type="button" class="toggle-pass" @click="showPwd=!showPwd">
                  <svg v-if="!showPwd" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                </button>
              </div>
              <span class="error-msg" v-if="errors.password">{{errors.password}}</span></div>
            <div class="field"><label>Confirmer le mot de passe *</label>
              <div class="password-wrapper">
                <input v-model="form.password_confirmation" :type="showPwd2?'text':'password'" placeholder="••••••••" :class="{'input-error':errors.password_confirmation}"/>
                <button type="button" class="toggle-pass" @click="showPwd2=!showPwd2">
                  <svg v-if="!showPwd2" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                </button>
              </div>
              <span class="error-msg" v-if="errors.password_confirmation">{{errors.password_confirmation}}</span></div>
          </div>
          <div class="card-footer">
            <button class="btn-next" @click="nextStep">Suivant →</button>
          </div>
        </div>

        <!-- ─── STEP 2 ─── -->
        <div class="artisan-card" v-show="step === 2">
          <div class="artisan-fields">
            <h2 class="section-title">Informations professionnelles</h2>
            <div class="field"><label>Service principal *</label>
              <div class="select-wrapper">
                <select v-model="form.service" :class="{'input-error':errors.service}">
                  <option value="" disabled>Sélectionnez un service</option>
                  <option v-for="s in services" :key="s.value" :value="s.value">{{s.label}}</option>
                </select><span class="select-arrow">▾</span>
              </div>
              <span class="error-msg" v-if="errors.service">{{errors.service}}</span></div>
            <div class="field"><label>Type de service *</label>
              <input v-model="form.service_type" type="text" placeholder="Ex: Installation, Réparation..." :class="{'input-error':errors.service_type}"/>
              <span class="error-msg" v-if="errors.service_type">{{errors.service_type}}</span></div>
            <div class="field"><label>Ville *</label>
              <div class="select-wrapper">
                <select v-model="form.city" :class="{'input-error':errors.city}">
                  <option value="" disabled>Sélectionnez une ville</option>
                  <option v-for="c in cities" :key="c" :value="c">{{c}}</option>
                </select><span class="select-arrow">▾</span>
              </div>
              <span class="error-msg" v-if="errors.city">{{errors.city}}</span></div>
            <div class="field"><label>Adresse *</label>
              <div class="address-row">
                <input v-model="form.address" type="text" placeholder="Adresse complète" :class="{'input-error':errors.address}"/>
                <button type="button" class="locate-btn" @click="getLocation">📍 Me localiser</button>
              </div>
              <span class="error-msg" v-if="errors.address">{{errors.address}}</span></div>
            <div class="field"><label>Copie de votre diplôme *</label>
              <div class="scan-wrapper" @click="$refs.diplomaInput.click()">
                <input type="file" ref="diplomaInput" accept=".pdf,.jpg,.jpeg,.png" style="display:none" @change="handleDiploma"/>
                <input readonly :value="diplomaFile?diplomaFile.name:''" placeholder="Cliquez pour sélectionner..." :class="{'input-error':errors.diploma}"/>
                <span class="scan-icon">⊡</span>
              </div>
              <span class="error-msg" v-if="errors.diploma">{{errors.diploma}}</span></div>
          </div>
          <div class="card-footer two-btns">
            <button class="btn-prev" @click="step--">← Précédent</button>
            <button class="btn-next" @click="nextStep">Suivant →</button>
          </div>
        </div>

        <!-- ─── STEP 3 ─── -->
        <div class="artisan-card" v-show="step === 3">
          <div class="artisan-fields">
            <h2 class="section-title">Portfolio et description</h2>
            <div class="field"><label>Description *</label>
              <textarea v-model="form.description" placeholder="Décrivez votre expérience, vos qualifications..." :class="{'input-error':errors.description}"></textarea>
              <span class="char-count">{{form.description.length}} caractères</span>
              <span class="error-msg" v-if="errors.description">{{errors.description}}</span></div>
            <div class="field"><label>Photos de vos réalisations * (min. 3)</label>
              <div class="upload-zone" @dragover.prevent @drop.prevent="handleDrop" @click="$refs.fileInput.click()">
                <div class="upload-circle"><span>↑</span></div>
                <p>Cliquez pour télécharger ou glissez vos images</p>
                <span>PNG, JPG jusqu'à 10MB</span>
                <input ref="fileInput" type="file" multiple accept="image/*" style="display:none" @change="handleFiles"/>
              </div>
              <div class="photo-preview" v-if="photos.length">
                <div class="thumb" v-for="(p,i) in photos" :key="i">
                  <img :src="p.url" :alt="p.name"/>
                  <button class="thumb-remove" @click="photos.splice(i,1)">×</button>
                </div>
              </div>
              <span class="error-msg" v-if="errors.photos">{{errors.photos}}</span></div>

            <div class="terms-row">
              <input type="checkbox" id="terms-artisan" v-model="form.terms"/>
              <label for="terms-artisan">J'accepte les <a href="#">conditions générales d'utilisation</a></label>
            </div>
            <span class="error-msg" v-if="errors.terms">{{errors.terms}}</span>
          </div>

          <div class="alert-error" v-if="authError" style="margin:0 34px 16px">{{authError}}</div>

          <div class="card-footer two-btns">
            <button class="btn-prev" @click="step--">← Précédent</button>
            <button class="btn-submit" :disabled="loading" @click="handleSubmit">
              <span v-if="loading" class="spinner"></span>
              <span v-else>Continuer → Choisir un abonnement</span>
            </button>
          </div>
        </div>

        <div class="why-box artisan-why">
          <h3>Pourquoi nous rejoindre ?</h3>
          <ul class="why-list">
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Accédez à des milliers de clients potentiels</span>
            </li>
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Gérez vos rendez-vous et paiements facilement</span>
            </li>
            <li>
              <span class="why-check">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <span>Développez votre réputation avec les avis clients</span>
            </li>
          </ul>
        </div>
      </div>
    </AuthBackground>
    <Footer />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Navbar from '../../components/navbar.vue'
import AuthBackground from '../../components/auth/Authbackground.vue'
// import Footer from '../../components/footer.vue'
import { registerArtisan, validateReferral } from '../../api/auth.js'
import '../../assets/css/auth/registerartisan.css'

const router      = useRouter()
const route       = useRoute()
const step        = ref(1)
const loading     = ref(false)
const authError   = ref('')
const photos      = ref([])
const diplomaFile = ref(null)
const showPwd     = ref(false)
const showPwd2    = ref(false)
const referrerName = ref('')

const form = reactive({
  full_name: '', birth_date: '', email: '', phone: '',
  password: '', password_confirmation: '',
  verification_method: 'phone',
  service: '', service_type: '', city: '', address: '',
  description: '', terms: false,
  referral_code: '',
})

onMounted(async () => {
  const refCode = route.query.ref
  if (refCode) {
    form.referral_code = refCode
    try {
      const { data } = await validateReferral(refCode)
      if (data?.valid) referrerName.value = data.referrer_name
    } catch (_) { /* invalid or unknown code — ignore */ }
  }
})
const errors = reactive({})

const cities  = ['Casablanca','Rabat','Marrakech','Fès','Tanger','Agadir','Meknès','Oujda','Kenitra','Tétouan','Salé','Temara']
const services = [
  { value:'plomberie',     label:'Plomberie'     },
  { value:'electricite',   label:'Électricité'   },
  { value:'menuiserie',    label:'Menuiserie'     },
  { value:'peinture',      label:'Peinture'       },
  { value:'maconnerie',    label:'Maçonnerie'     },
  { value:'climatisation', label:'Climatisation'  },
  { value:'carrelage',     label:'Carrelage'      },
  { value:'jardinage',     label:'Jardinage'      },
]

function clearErrors() { Object.keys(errors).forEach(k => delete errors[k]) }

function validateStep1() {
  clearErrors()
  if (!form.full_name)                              errors.full_name  = 'Nom complet requis'
  if (!form.birth_date)                             errors.birth_date = 'Date requise'
  if (!form.email)                                  errors.email      = 'Email requis'
  else if (!/\S+@\S+\.\S+/.test(form.email))        errors.email      = 'Email invalide'
  if (!form.phone)                                  errors.phone      = 'Téléphone requis'
  if (!form.password)                               errors.password   = 'Mot de passe requis'
  else if (form.password.length < 8)                errors.password   = 'Minimum 8 caractères'
  if (form.password !== form.password_confirmation) errors.password_confirmation = 'Les mots de passe ne correspondent pas'
  return Object.keys(errors).length === 0
}
function validateStep2() {
  clearErrors()
  if (!form.service)      errors.service      = 'Service requis'
  if (!form.service_type) errors.service_type = 'Type requis'
  if (!form.city)         errors.city         = 'Ville requise'
  if (!form.address)      errors.address      = 'Adresse requise'
  if (!diplomaFile.value) errors.diploma      = 'Diplôme requis'
  return Object.keys(errors).length === 0
}
function validateStep3() {
  clearErrors()
  if (!form.description || form.description.length < 20) errors.description = 'Description requise (min. 20 caractères)'
  if (photos.value.length < 3)                           errors.photos      = 'Minimum 3 photos requises'
  if (!form.terms)                                       errors.terms       = 'Veuillez accepter les conditions'
  return Object.keys(errors).length === 0
}

function nextStep() {
  const validators = { 1: validateStep1, 2: validateStep2 }
  if (!validators[step.value]()) return
  step.value++
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function getLocation() {
  if (!navigator.geolocation) return
  navigator.geolocation.getCurrentPosition(pos => {
    form.address = `${pos.coords.latitude.toFixed(6)}, ${pos.coords.longitude.toFixed(6)}`
  })
}
function handleDiploma(e) { diplomaFile.value = e.target.files[0] || null }
function handleFiles(e)   { Array.from(e.target.files).forEach(f => photos.value.push({ name: f.name, url: URL.createObjectURL(f), file: f })) }
function handleDrop(e)    { Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/')).forEach(f => photos.value.push({ name: f.name, url: URL.createObjectURL(f), file: f })) }

async function handleSubmit() {
  if (!validateStep3()) return
  loading.value  = true
  authError.value = ''

  try {
    const fd = new FormData()
    fd.append('account_type',          'artisan')
    fd.append('full_name',             form.full_name)
    fd.append('birth_date',            form.birth_date)
    fd.append('email',                 form.email)
    fd.append('phone',                 form.phone)
    fd.append('password',              form.password)
    fd.append('password_confirmation', form.password_confirmation)
    fd.append('verification_method',   form.verification_method)
    fd.append('service',               form.service)
    fd.append('service_type',          form.service_type)
    fd.append('city',                  form.city)
    fd.append('address',               form.address)
    fd.append('bio',                   form.description)
    if (form.referral_code) fd.append('referral_code', form.referral_code)
    if (diplomaFile.value) fd.append('diploma', diplomaFile.value)
    photos.value.forEach((p, i) => fd.append(`photos[${i}]`, p.file))

    const { data } = await registerArtisan(fd)

    if (data.requires_plan) {
      // Artisan: no token yet — carry user_id to the pricing page
      // Store user_id temporarily so pricing page can read it
      localStorage.setItem('pending_user_id', data.user_id)

      router.push({
        path:  '/register/artisan/pricing',
        query: { uid: data.user_id },
      })
      return
    }

    // Client (or fallback): store token and go to dashboard
    localStorage.setItem('token', data.token)
    localStorage.setItem('user',  JSON.stringify(data.user))
    router.push('/client/profile')

  } catch (err) {
    const errData = err.response?.data
    if (errData?.errors) {
      Object.entries(errData.errors).forEach(([f, msgs]) => { errors[f] = msgs[0] })
      const s1 = ['full_name','birth_date','email','phone','password','password_confirmation']
      const s2 = ['service','service_type','city','address','diploma']
      if      (s1.some(f => errors[f])) step.value = 1
      else if (s2.some(f => errors[f])) step.value = 2
    } else {
      authError.value = errData?.message || errData?.error || 'Une erreur est survenue'
    }
  } finally {
    loading.value = false
  }
}
</script>
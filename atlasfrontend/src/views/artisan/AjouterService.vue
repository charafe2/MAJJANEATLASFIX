<template>
  <div class="as-page">

    <!-- ── Top header bar ────────────────────────────────────────────────── -->
    <div class="as-topbar">
      <div class="as-topbar-inner">
        <button class="back-btn" @click="goBack">
          <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
            <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour
        </button>
        <div class="as-header-content">
          <h1 class="as-title">Ajouter un service</h1>
          <p class="as-subtitle">Complétez les informations pour proposer un nouveau service à vos clients</p>
        </div>
      </div>
    </div>

    <!-- ── Stepper ────────────────────────────────────────────────────────── -->
    <div class="as-stepper-wrap">
      <div class="as-stepper">
        <div class="stepper-item" :class="{ active: step >= 1, done: step > 1 }">
          <div class="stepper-circle">
            <svg v-if="step > 1" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <path d="M5 12l5 5L20 7" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span v-else>1</span>
          </div>
          <span class="stepper-label">Choisissez un service</span>
        </div>
        <div class="stepper-line" :class="{ done: step > 1 }"></div>
        <div class="stepper-item" :class="{ active: step >= 2 }">
          <div class="stepper-circle"><span>2</span></div>
          <span class="stepper-label">Portfolio et description</span>
        </div>
      </div>
    </div>

    <!-- ── Body ──────────────────────────────────────────────────────────── -->
    <div class="as-body">

      <!-- ══ STEP 1 ══════════════════════════════════════════════════════ -->
      <div v-if="step === 1" class="step-card">
        <h2 class="step-heading">Choisissez un service</h2>
        <p class="step-sub">Sélectionnez le type de service que voulez-vous ajouter</p>

        <!-- Service principal -->
        <div class="form-group">
          <label class="form-label">
            <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.4 2.4-7.4L2 9.4h7.6L12 2z"/>
            </svg>
            Service principal *
          </label>
          <div class="select-wrap">
            <select v-model="form.categoryId" class="form-input" @change="onCategoryChange">
              <option value="" disabled>Sélectionnez une service</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </select>
            <svg class="select-arrow" width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M6 9l6 6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
        </div>

        <!-- Type de service -->
        <div class="form-group">
          <label class="form-label">
            <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
              <rect x="3" y="3" width="18" height="18" rx="2"/>
              <path d="M9 9h6M9 12h6M9 15h4" stroke-linecap="round"/>
            </svg>
            Type de service *
          </label>
          <div class="type-row">
            <div class="select-wrap flex-1">
              <select v-model="selectedTypeId" class="form-input" :disabled="!form.categoryId || loadingTypes">
                <option value="" disabled>{{ loadingTypes ? 'Chargement…' : 'Type de service' }}</option>
                <option v-for="t in serviceTypes" :key="t.id" :value="t.id">{{ t.name }}</option>
              </select>
              <svg class="select-arrow" width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.5" viewBox="0 0 24 24">
                <path d="M6 9l6 6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <button class="btn-ajouter" :disabled="!selectedTypeId" @click="addType">Ajouter</button>
          </div>
          <!-- Tags -->
          <div v-if="form.typeIds.length" class="tags-row">
            <span
              v-for="tid in form.typeIds"
              :key="tid"
              class="service-tag"
            >
              {{ typeName(tid) }}
              <button class="tag-remove" @click="removeType(tid)">×</button>
            </span>
          </div>
        </div>

        <!-- Ville -->
        <div class="form-group">
          <label class="form-label">
            <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
              <circle cx="12" cy="9" r="2.5"/>
            </svg>
            Ville *
          </label>
          <input v-model="form.ville" type="text" class="form-input" placeholder="Entrez votre ville" />
        </div>

        <!-- Diplôme -->
        <div class="form-group">
          <label class="form-label">
            <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z"/>
              <path d="M14 2v6h6M12 18v-6M9 15l3 3 3-3" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Scannez le diplôme
          </label>
          <label class="diplome-row">
            <span class="diplome-name">{{ form.diplome ? form.diplome.name : 'Aucun fichier sélectionné' }}</span>
            <span class="btn-scanner">Scanner</span>
            <input type="file" accept=".pdf,.jpg,.jpeg,.png" hidden @change="onDiplomeChange" />
          </label>
        </div>

        <!-- Footer -->
        <div class="step-footer">
          <button class="btn-ghost" @click="goBack">Précédent</button>
          <button class="btn-orange" :disabled="!canProceed" @click="step = 2">Suivant</button>
        </div>
      </div>

      <!-- ══ STEP 2 ══════════════════════════════════════════════════════ -->
      <div v-else-if="step === 2" class="step-card">
        <h2 class="step-heading">Portfolio et description</h2>
        <p class="step-sub">Sélectionnez le type de service dont vous avez besoin</p>

        <!-- Description -->
        <div class="form-group">
          <textarea
            v-model="form.description"
            class="form-textarea"
            placeholder="Décrivez votre expérience..."
            rows="6"
          ></textarea>
          <span class="char-count">{{ form.description.length }} / 2000 caractères</span>
        </div>

        <!-- Photo upload -->
        <div class="form-group">
          <label
            class="dropzone"
            @dragover.prevent
            @drop.prevent="onPhotosDrop"
          >
            <div class="dropzone-icon">
              <svg width="40" height="40" fill="none" stroke="#FC5A15" stroke-width="2" viewBox="0 0 24 24">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="17 8 12 3 7 8"/>
                <line x1="12" y1="3" x2="12" y2="15"/>
              </svg>
            </div>
            <p class="dropzone-title">
              {{ form.photos.length ? form.photos.length + ' photo(s) sélectionnée(s)' : 'Cliquez pour télécharger ou glissez vos images' }}
            </p>
            <p class="dropzone-hint">PNG, JPG jusqu'à 10MB</p>
            <input type="file" multiple accept="image/*" hidden @change="onPhotosChange" />
          </label>
          <!-- Photo previews -->
          <div v-if="photoPreviews.length" class="photo-previews">
            <div v-for="(src, i) in photoPreviews" :key="i" class="photo-thumb-wrap">
              <img :src="src" class="photo-thumb" />
              <button class="photo-remove" @click="removePhoto(i)">×</button>
            </div>
          </div>
        </div>

        <!-- Terms -->
        <label class="terms-row">
          <input type="checkbox" v-model="form.acceptTerms" class="terms-check" />
          <span class="terms-text">
            J'accepte les conditions générales d'utilisation et la politique de confidentialité
          </span>
        </label>

        <!-- Error -->
        <p v-if="submitError" class="error-msg">{{ submitError }}</p>

        <!-- Footer -->
        <div class="step-footer">
          <button class="btn-ghost" @click="step = 1">Précédent</button>
          <button class="btn-orange" :disabled="submitting || !form.acceptTerms" @click="submit">
            <span v-if="submitting" class="spinner"></span>
            {{ submitting ? 'Envoi en cours…' : 'Confirmer' }}
          </button>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCategories, getServiceTypes } from '../../api/serviceRequests'
import axios from 'axios'

const router = useRouter()

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  withCredentials: true,
})
api.interceptors.request.use(cfg => {
  const t = localStorage.getItem('token')
  if (t) cfg.headers.Authorization = `Bearer ${t}`
  return cfg
})

// ── State ─────────────────────────────────────────────────────────────────────
const step         = ref(1)
const categories   = ref([])
const serviceTypes = ref([])
const loadingTypes = ref(false)
const submitting   = ref(false)
const submitError  = ref('')

const selectedTypeId = ref('')
const photoPreviews  = ref([])

const form = ref({
  categoryId:  '',
  typeIds:     [],
  ville:       '',
  diplome:     null,
  description: '',
  photos:      [],
  acceptTerms: false,
})

// ── Computed ──────────────────────────────────────────────────────────────────
const canProceed = computed(() =>
  form.value.categoryId && form.value.typeIds.length > 0 && form.value.ville.trim()
)

// ── Lifecycle ─────────────────────────────────────────────────────────────────
onMounted(async () => {
  try {
    const { data } = await getCategories()
    categories.value = data.data
  } catch {
    categories.value = []
  }
})

// ── Methods ───────────────────────────────────────────────────────────────────
async function onCategoryChange() {
  form.value.typeIds = []
  selectedTypeId.value = ''
  serviceTypes.value = []
  if (!form.value.categoryId) return
  loadingTypes.value = true
  try {
    const { data } = await getServiceTypes(form.value.categoryId)
    serviceTypes.value = data.data
  } catch {
    serviceTypes.value = []
  } finally {
    loadingTypes.value = false
  }
}

function addType() {
  if (!selectedTypeId.value) return
  if (!form.value.typeIds.includes(selectedTypeId.value)) {
    form.value.typeIds.push(selectedTypeId.value)
  }
  selectedTypeId.value = ''
}

function removeType(id) {
  form.value.typeIds = form.value.typeIds.filter(t => t !== id)
}

function typeName(id) {
  return serviceTypes.value.find(t => t.id === id)?.name ?? id
}

function onDiplomeChange(e) {
  form.value.diplome = e.target.files[0] ?? null
}

function onPhotosChange(e) {
  addPhotos(Array.from(e.target.files))
}

function onPhotosDrop(e) {
  addPhotos(Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/')))
}

function addPhotos(files) {
  form.value.photos.push(...files)
  files.forEach(f => {
    const reader = new FileReader()
    reader.onload = ev => photoPreviews.value.push(ev.target.result)
    reader.readAsDataURL(f)
  })
}

function removePhoto(i) {
  form.value.photos.splice(i, 1)
  photoPreviews.value.splice(i, 1)
}

async function submit() {
  submitError.value = ''
  if (!form.value.acceptTerms) return

  submitting.value = true
  try {
    const fd = new FormData()
    fd.append('service_category_id', form.value.categoryId)
    form.value.typeIds.forEach(id => fd.append('service_type_ids[]', id))
    fd.append('ville', form.value.ville)
    if (form.value.diplome) fd.append('diplome', form.value.diplome)
    if (form.value.description.trim()) fd.append('description', form.value.description)
    form.value.photos.forEach(p => fd.append('photos[]', p))

    await api.post('/artisan/service', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
    router.push('/artisan/profile')
  } catch (err) {
    const errs = err.response?.data?.errors
    if (errs) {
      const first = Object.values(errs)[0]
      submitError.value = Array.isArray(first) ? first[0] : first
    } else {
      submitError.value = err.response?.data?.message ?? 'Une erreur est survenue.'
    }
  } finally {
    submitting.value = false
  }
}

function goBack() {
  if (step.value > 1) { step.value--; return }
  router.push('/artisan/profile')
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&family=Inter:wght@400;500;600&display=swap');

/* ── Page ─────────────────────────────────────────────────────────────────── */
.as-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Inter', sans-serif;
}

/* ── Top bar ──────────────────────────────────────────────────────────────── */
.as-topbar {
  background: #ffffff;
  border-bottom: 1px solid #E5E7EB;
}
.as-topbar-inner {
  max-width: 800px;
  margin: 0 auto;
  padding: 28px 24px 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  cursor: pointer;
  color: #62748E;
  font-size: 15px;
  padding: 0;
  width: fit-content;
}
.as-title {
  font-family: 'Poppins', sans-serif;
  font-size: 26px;
  font-weight: 500;
  color: #314158;
  margin: 0 0 4px;
}
.as-subtitle {
  font-size: 15px;
  color: #62748E;
  margin: 0;
}

/* ── Stepper ──────────────────────────────────────────────────────────────── */
.as-stepper-wrap {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
  padding: 14px 24px;
}
.as-stepper {
  max-width: 480px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.stepper-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  opacity: 0.4;
  transition: opacity .2s;
}
.stepper-item.active { opacity: 1; }
.stepper-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #E5E7EB;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #62748E;
  transition: background .2s, color .2s;
}
.stepper-item.active .stepper-circle,
.stepper-item.done   .stepper-circle { background: #FC5A15; color: #fff; }
.stepper-label { font-size: 12px; color: #62748E; white-space: nowrap; }
.stepper-item.active .stepper-label { color: #FC5A15; font-weight: 600; }
.stepper-line {
  flex: 1;
  height: 2px;
  background: #E5E7EB;
  margin: 0 8px 18px;
  transition: background .2s;
}
.stepper-line.done { background: #FC5A15; }

/* ── Body ─────────────────────────────────────────────────────────────────── */
.as-body {
  max-width: 800px;
  margin: 0 auto;
  padding: 32px 24px 64px;
}

/* ── Card ─────────────────────────────────────────────────────────────────── */
.step-card {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 16px;
  padding: 32px;
}
.step-heading {
  font-family: 'Poppins', sans-serif;
  font-size: 22px;
  font-weight: 600;
  color: #314158;
  margin: 0 0 6px;
}
.step-sub {
  font-size: 14px;
  color: #62748E;
  margin: 0 0 28px;
}

/* ── Form ─────────────────────────────────────────────────────────────────── */
.form-group { margin-bottom: 20px; }
.form-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #314158;
  margin-bottom: 8px;
}
.select-wrap { position: relative; }
.select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}
.form-input {
  width: 100%;
  padding: 12px 16px;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  font-size: 15px;
  color: #314158;
  font-family: 'Inter', sans-serif;
  outline: none;
  box-sizing: border-box;
  transition: border-color .15s;
  background: #fff;
  appearance: none;
  padding-right: 40px;
}
.form-input:focus { border-color: #FC5A15; }
.form-input:disabled { background: #F9FAFB; color: #9CA3AF; cursor: not-allowed; }

/* Type de service row */
.type-row {
  display: flex;
  gap: 10px;
  align-items: stretch;
}
.flex-1 { flex: 1; }
.btn-ajouter {
  padding: 0 20px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  white-space: nowrap;
  transition: background .15s;
  flex-shrink: 0;
}
.btn-ajouter:hover    { background: #e04e0d; }
.btn-ajouter:disabled { opacity: .5; cursor: not-allowed; }

/* Tags */
.tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
}
.service-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 12px;
  background: #FFF7ED;
  border: 1px solid #FC5A15;
  border-radius: 20px;
  font-size: 13px;
  color: #FC5A15;
  font-weight: 500;
}
.tag-remove {
  background: none;
  border: none;
  cursor: pointer;
  color: #FC5A15;
  font-size: 16px;
  line-height: 1;
  padding: 0;
  display: flex;
  align-items: center;
}

/* Diplôme row */
.diplome-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  cursor: pointer;
  background: #fff;
  transition: border-color .15s;
}
.diplome-row:hover { border-color: #FC5A15; }
.diplome-name {
  font-size: 14px;
  color: #62748E;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
}
.btn-scanner {
  padding: 6px 18px;
  background: #FC5A15;
  color: #fff;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  flex-shrink: 0;
}

/* Textarea */
.form-textarea {
  width: 100%;
  padding: 14px 16px;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  font-size: 15px;
  color: #314158;
  font-family: 'Inter', sans-serif;
  outline: none;
  box-sizing: border-box;
  transition: border-color .15s;
  background: #fff;
  resize: vertical;
  min-height: 140px;
}
.form-textarea:focus { border-color: #FC5A15; }
.char-count { display: block; text-align: right; font-size: 12px; color: #9CA3AF; margin-top: 4px; }

/* Dropzone */
.dropzone {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: 100%;
  min-height: 160px;
  border: 1.5px dashed #D1D5DB;
  border-radius: 12px;
  background: #FAFAFA;
  cursor: pointer;
  transition: border-color .15s, background .15s;
  box-sizing: border-box;
  padding: 24px;
}
.dropzone:hover { border-color: #FC5A15; background: #FFF7ED; }
.dropzone-icon { display: flex; align-items: center; justify-content: center; }
.dropzone-title { font-size: 14px; color: #62748E; font-weight: 500; text-align: center; margin: 0; }
.dropzone-hint  { font-size: 12px; color: #9CA3AF; margin: 0; }

/* Photo previews */
.photo-previews {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 12px;
}
.photo-thumb-wrap { position: relative; }
.photo-thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #E5E7EB;
}
.photo-remove {
  position: absolute;
  top: -6px;
  right: -6px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #EF4444;
  color: #fff;
  border: none;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Terms */
.terms-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  cursor: pointer;
  margin-top: 4px;
  margin-bottom: 24px;
}
.terms-check {
  accent-color: #FC5A15;
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  margin-top: 1px;
  cursor: pointer;
}
.terms-text { font-size: 13px; color: #62748E; line-height: 1.5; }

/* ── Footer buttons ───────────────────────────────────────────────────────── */
.step-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 28px;
  padding-top: 24px;
  border-top: 1px solid #F3F4F6;
}
.btn-orange {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 13px 32px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  cursor: pointer;
  transition: background .15s;
  min-width: 140px;
}
.btn-orange:hover    { background: #e04e0d; }
.btn-orange:disabled { opacity: .6; cursor: not-allowed; }
.btn-ghost {
  padding: 13px 32px;
  background: none;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  font-size: 15px;
  color: #62748E;
  cursor: pointer;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  transition: border-color .15s;
}
.btn-ghost:hover { border-color: #9CA3AF; }

/* ── Misc ─────────────────────────────────────────────────────────────────── */
.error-msg { color: #EF4444; font-size: 14px; margin-bottom: 12px; }
.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin .6s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Responsive ──────────────────────────────────────────────────────────── */
@media (max-width: 600px) {
  .step-card { padding: 20px 16px; }
  .step-heading { font-size: 18px; }
  .type-row { flex-direction: column; }
  .btn-ajouter { padding: 12px 20px; }
  .btn-orange, .btn-ghost { width: 100%; }
  .step-footer { flex-direction: column-reverse; }
}
</style>

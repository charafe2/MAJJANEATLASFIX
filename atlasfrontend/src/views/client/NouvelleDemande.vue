<template>
  <div class="nd-page">

    <!-- ── Top header bar ─────────────────────────────────────────── -->
    <div class="nd-topbar">
      <div class="nd-topbar-inner">
        <button class="back-btn" @click="goBack">
          <svg width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.67" viewBox="0 0 24 24">
            <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour
        </button>

        <div class="nd-header-content">
          <h1 class="nd-title">Nouvelle demande</h1>
          <p class="nd-subtitle">
            Les meilleurs artisans de votre région seront automatiquement avertis et vous
            recevrez différentes offres par mail dans les 4 heures.
          </p>
        </div>
      </div>
    </div>

    <!-- ── Stepper ────────────────────────────────────────────────── -->
    <div class="nd-stepper-wrap">
      <div class="nd-stepper">
        <div class="stepper-item" :class="{ active: step >= 1, done: step > 1 }">
          <div class="stepper-circle">
            <svg v-if="step > 1" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <path d="M5 12l5 5L20 7" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span v-else>1</span>
          </div>
          <span class="stepper-label">Catégorie</span>
        </div>

        <div class="stepper-line" :class="{ done: step > 1 }"></div>

        <div class="stepper-item" :class="{ active: step >= 2, done: step > 2 }">
          <div class="stepper-circle">
            <svg v-if="step > 2" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <path d="M5 12l5 5L20 7" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span v-else>2</span>
          </div>
          <span class="stepper-label">Service</span>
        </div>

        <div class="stepper-line" :class="{ done: step > 2 }"></div>

        <div class="stepper-item" :class="{ active: step >= 3 }">
          <div class="stepper-circle"><span>3</span></div>
          <span class="stepper-label">Détails</span>
        </div>
      </div>
    </div>

    <!-- ── Step content ───────────────────────────────────────────── -->
    <div class="nd-body">

      <!-- ── STEP 1 : Categories ─────────────────────────────────── -->
      <div v-if="step === 1">
        <div v-if="loadingCats" class="loading-msg">Chargement des catégories…</div>
        <p v-else-if="errorCats" class="error-msg">{{ errorCats }}</p>
        <div v-else class="cat-grid">
          <button
            v-for="(cat, i) in categories"
            :key="cat.id"
            class="cat-card"
            :class="{ selected: selectedCategory?.id === cat.id }"
            @click="pickCategory(cat, i)"
          >
            <div class="cat-icon" :style="{ background: catColors[i % catColors.length] }">
              {{ cat.icon }}
            </div>
            <span class="cat-name">{{ cat.name }}</span>
          </button>
        </div>
      </div>

      <!-- ── STEP 2 : Service types ──────────────────────────────── -->
      <div v-else-if="step === 2" class="step2-wrap">
        <div class="step2-category-header">
          <div class="cat-icon cat-icon--md" :style="{ background: selectedCategoryColor }">
            {{ selectedCategory?.icon }}
          </div>
          <h2 class="step2-cat-name">{{ selectedCategory?.name }}</h2>
        </div>

        <h3 class="step2-heading">Choisissez les services</h3>
        <p class="step2-sub">Sélectionnez un ou plusieurs services dans la catégorie</p>

        <div v-if="loadingTypes" class="loading-msg">Chargement…</div>
        <div v-else class="types-list">
          <label
            v-for="t in serviceTypes"
            :key="t.id"
            class="type-item"
            :class="{ checked: selectedTypeIds.includes(t.id) }"
          >
            <input
              type="checkbox"
              :value="t.id"
              v-model="selectedTypeIds"
              class="type-checkbox"
            />
            {{ t.name }}
          </label>
        </div>

        <div class="step2-footer">
          <button class="btn-orange btn-full" :disabled="!selectedTypeIds.length" @click="step = 3">
            Continuer
          </button>
        </div>
      </div>

      <!-- ── STEP 3 : Details form ───────────────────────────────── -->
      <div v-else-if="step === 3" class="step3-wrap">
        <div class="step3-card">
          <h2 class="step3-heading">Détails de votre demande</h2>
          <p class="step3-sub">Fournissez les informations nécessaires pour que les artisans puissent vous faire une offre précise</p>

          <p v-if="submitError" class="error-msg">{{ submitError }}</p>

          <!-- Mode de prestation -->
          <div class="form-group">
            <label class="form-label">
              <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3" stroke-linecap="round"/>
              </svg>
              Mode de prestation *
            </label>
            <div class="select-wrap">
              <select v-model="form.service_mode" class="form-input">
                <option value="">Sélectionnez un mode de prestation</option>
                <option value="sur_place">Sur place</option>
                <option value="a_distance">À distance</option>
              </select>
              <svg class="select-arrow" width="20" height="20" fill="none" stroke="#62748E" stroke-width="1.5" viewBox="0 0 24 24">
                <path d="M6 9l6 6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
          </div>

          <!-- Description -->
          <div class="form-group">
            <label class="form-label">
              <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
                <path d="M9 12h6M9 16h6M9 8h6M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z"/>
              </svg>
              Description du travail *
            </label>
            <textarea
              v-model="form.description"
              class="form-textarea"
              placeholder="Décrivez en détail le travail à réaliser…"
              rows="5"
            ></textarea>
          </div>

          <!-- Adresse -->
          <div class="form-group">
            <label class="form-label">
              <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                <circle cx="12" cy="9" r="2.5"/>
              </svg>
              Adresse *
            </label>
            <input
              v-model="form.city"
              type="text"
              class="form-input"
              placeholder="Entrez votre adresse complète"
            />
          </div>

          <!-- Infos complémentaires -->
          <div class="form-group">
            <label class="form-label">
              <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/>
                <path d="M12 8v4M12 16h.01" stroke-linecap="round"/>
              </svg>
              Informations complémentaires
            </label>
            <textarea
              v-model="form.notes"
              class="form-textarea"
              placeholder="Ajoutez des informations qui peuvent aider l'artisan (accès, contraintes, horaires préférés…)"
              rows="4"
            ></textarea>
          </div>

          <!-- Photos -->
          <div class="form-group">
            <label class="form-label">
              <svg width="16" height="16" fill="none" stroke="#FC5A15" stroke-width="1.5" viewBox="0 0 24 24">
                <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>
                <path d="M21 15l-5-5L5 21"/>
              </svg>
              Photos (optionnel)
            </label>
            <p class="form-hint">Ajoutez des photos pour mieux illustrer votre demande</p>
            <label class="upload-btn">
              <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
                <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>
                <path d="M21 15l-5-5L5 21"/>
              </svg>
              Ajouter des photos
              <input type="file" multiple accept="image/jpg,image/jpeg,image/png,image/webp" @change="handlePhotos" hidden />
            </label>
            <div v-if="photoPreviews.length" class="photo-previews">
              <div v-for="(src, i) in photoPreviews" :key="i" class="photo-thumb-wrap">
                <img :src="src" class="photo-thumb" />
                <button class="photo-remove" @click="removePhoto(i)">×</button>
              </div>
            </div>
          </div>

          <!-- Footer buttons -->
          <div class="step3-footer">
            <button class="btn-ghost" @click="step = 2">Précédent</button>
            <button class="btn-orange" :disabled="submitting || !form.city" @click="submit">
              <svg v-if="!submitting" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M12 19V5M5 12l7-7 7 7" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              {{ submitting ? 'Envoi en cours…' : 'Publier la demande' }}
            </button>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCategories, getServiceTypes, createServiceRequest } from '../../api/serviceRequests'

const router = useRouter()

// ── State ────────────────────────────────────────────────────────────────────
const step              = ref(1)
const categories        = ref([])
const serviceTypes      = ref([])
const loadingCats       = ref(false)
const loadingTypes      = ref(false)
const errorCats         = ref('')
const submitError       = ref('')
const submitting        = ref(false)

const selectedCategory      = ref(null)
const selectedCategoryIndex = ref(0)
const selectedTypeIds       = ref([])

const photos        = ref([])
const photoPreviews = ref([])

const form = ref({
  service_mode: '',
  description: '',
  city: '',
  notes: '',
})

// Category icon background colours (one per slot, cycling if needed)
const catColors = [
  '#6B7280','#3B82F6','#F59E0B','#F472B6','#EF4444',
  '#10B981','#8B5CF6','#0EA5E9','#374151','#F97316',
  '#DC2626','#FBBF24','#14B8A6','#A855F7','#22C55E',
  '#F43F5E','#6366F1','#D97706','#0891B2','#7C3AED',
  '#059669','#BE123C','#2563EB','#DB2777','#16A34A',
  '#0D9488','#B45309',
]

const selectedCategoryColor = computed(
  () => catColors[selectedCategoryIndex.value % catColors.length]
)

// ── Lifecycle ────────────────────────────────────────────────────────────────
onMounted(async () => {
  loadingCats.value = true
  try {
    const { data } = await getCategories()
    categories.value = data.data
  } catch {
    errorCats.value = 'Impossible de charger les catégories. Veuillez réessayer.'
  } finally {
    loadingCats.value = false
  }
})

// ── Step 1 → 2 ───────────────────────────────────────────────────────────────
async function pickCategory(cat, index) {
  selectedCategory.value      = cat
  selectedCategoryIndex.value = index
  selectedTypeIds.value       = []
  step.value                  = 2
  loadingTypes.value          = true
  try {
    const { data } = await getServiceTypes(cat.id)
    serviceTypes.value = data.data
  } catch {
    serviceTypes.value = []
  } finally {
    loadingTypes.value = false
  }
}

// ── Photo handling ────────────────────────────────────────────────────────────
function handlePhotos(e) {
  const files = Array.from(e.target.files).slice(0, 5)
  photos.value        = files
  photoPreviews.value = []
  files.forEach(f => {
    const reader = new FileReader()
    reader.onload = ev => photoPreviews.value.push(ev.target.result)
    reader.readAsDataURL(f)
  })
}

function removePhoto(i) {
  photos.value.splice(i, 1)
  photoPreviews.value.splice(i, 1)
}

// ── Step 3 submit ─────────────────────────────────────────────────────────────
async function submit() {
  submitError.value = ''
  if (!form.value.city) {
    submitError.value = "L'adresse est obligatoire."
    return
  }

  submitting.value = true
  try {
    const fd = new FormData()
    fd.append('service_category_id', selectedCategory.value.id)
    fd.append('service_type_id',     selectedTypeIds.value[0])
    fd.append('service_mode',        form.value.service_mode || 'sur_place')
    fd.append('city',                form.value.city)
    if (form.value.description) fd.append('description', form.value.description)
    if (form.value.notes)       fd.append('notes',       form.value.notes)
    photos.value.forEach((p, i) => fd.append(`photos[${i}]`, p))

    await createServiceRequest(fd)
    router.push('/client/mes-demandes')
  } catch (err) {
    submitError.value =
      err.response?.data?.message ||
      err.response?.data?.error   ||
      'Une erreur est survenue. Veuillez réessayer.'
  } finally {
    submitting.value = false
  }
}

// ── Back navigation ───────────────────────────────────────────────────────────
function goBack() {
  if (step.value > 1) step.value--
  else router.push('/client/mes-demandes')
}
</script>

<style scoped>
/* ── Page background ──────────────────────────────────────────────────────── */
.nd-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Inter', sans-serif;
}

/* ── Top bar ──────────────────────────────────────────────────────────────── */
.nd-topbar {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
}
.nd-topbar-inner {
  max-width: 1248px;
  margin: 0 auto;
  padding: 32px 24px 24px;
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
  font-size: 16px;
  padding: 0;
  width: fit-content;
}
.nd-title {
  font-family: 'Inter', sans-serif;
  font-size: 30px;
  font-weight: 400;
  color: #314158;
  margin: 0 0 4px;
}
.nd-subtitle {
  font-size: 16px;
  color: #62748E;
  margin: 0;
}
.nd-header-content { display: flex; flex-direction: column; gap: 4px; }

/* ── Stepper ──────────────────────────────────────────────────────────────── */
.nd-stepper-wrap {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
  padding: 16px 24px;
}
.nd-stepper {
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
.stepper-item.active .stepper-circle {
  background: #FC5A15;
  color: #fff;
}
.stepper-item.done .stepper-circle {
  background: #FC5A15;
  color: #fff; 
}
.stepper-label {
  font-size: 12px;
  color: #62748E;
  white-space: nowrap;
}
.stepper-item.active .stepper-label { color: #FC5A15; font-weight: 600; }
.stepper-line {
  flex: 1;
  height: 2px;
  background: #E5E7EB;
  margin: 0 8px;
  margin-bottom: 18px;
  transition: background .2s;
}
.stepper-line.done { background: #FC5A15; }

/* ── Body ─────────────────────────────────────────────────────────────────── */
.nd-body {
  max-width: 1248px;
  margin: 0 auto;
  padding: 32px 24px 64px;
}

/* ── Category grid ────────────────────────────────────────────────────────── */
.cat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 16px;
}
.cat-card {
font-family: "Poppins";
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 16px 8px;
  background: #fff;
  border: 2px solid transparent;
  border-radius: 14px;
  cursor: pointer;
  transition: border-color .15s, box-shadow .15s;
  box-shadow: 0 1px 3px rgba(0,0,0,.07);
}
.cat-card:hover  { border-color: #FC5A15; box-shadow: 0 4px 12px rgba(252,90,21,.15); }
.cat-card.selected { border-color: #FC5A15; box-shadow: 0 4px 12px rgba(252,90,21,.2); }

.cat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
}
.cat-name {
  font-size: 12px;
  color: #314158;
  text-align: center;
  font-weight: 500;
  line-height: 1.3;
}

/* ── Step 2 ───────────────────────────────────────────────────────────────── */
.step2-wrap { max-width: 640px; }
.step2-category-header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 20px;
}
.cat-icon--md {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  font-size: 22px;
}
.step2-cat-name { font-family: 'Poppins', sans-serif; font-size: 22px; font-weight: 600; color: #314158; margin: 0; }
.step2-heading  { font-size: 20px; font-weight: 600; color: #314158; margin: 0 0 4px; }
.step2-sub      { font-size: 14px; color: #62748E; margin: 0 0 20px; }

.types-list { display: flex; flex-direction: column; gap: 10px; }
.type-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: #fff;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  cursor: pointer;
  font-size: 15px;
  color: #314158;
  transition: border-color .15s, background .15s;
  user-select: none;
}
.type-item:hover  { border-color: #FC5A15; }
.type-item.checked {
  border-color: #FC5A15;
  background: #FFF7ED;
  color: #FC5A15;
  font-weight: 500;
}
.type-checkbox {
  accent-color: #FC5A15;
  width: 18px;
  height: 18px;
  cursor: pointer;
}
.step2-footer { margin-top: 24px; }

/* ── Step 3 ───────────────────────────────────────────────────────────────── */
.step3-wrap { max-width: 680px; }
.step3-card {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 14px;
  padding: 32px;
}
.step3-heading { font-family: 'Poppins', sans-serif; font-size: 22px; font-weight: 600; color: #314158; margin: 0 0 6px; }
.step3-sub     { font-size: 14px; color: #62748E; margin: 0 0 28px; }

/* ── Form elements ────────────────────────────────────────────────────────── */
.form-group   { margin-bottom: 20px; }
.form-label   { display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 500; color: #314158; margin-bottom: 8px; }
.form-hint    { font-size: 13px; color: #62748E; margin: 0 0 8px; }
.select-wrap  { position: relative; }
.select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}
.form-input, .form-textarea {
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
}
.form-input:focus, .form-textarea:focus { border-color: #FC5A15; }
.form-textarea { resize: vertical; min-height: 100px; }
select.form-input { appearance: none; padding-right: 40px; cursor: pointer; }

/* ── Photo upload ─────────────────────────────────────────────────────────── */
.upload-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 14px;
  border: 1.5px dashed #D1D5DB;
  border-radius: 10px;
  background: #F9FAFB;
  color: #62748E;
  font-size: 14px;
  cursor: pointer;
  transition: border-color .15s, background .15s;
  box-sizing: border-box;
}
.upload-btn:hover { border-color: #FC5A15; background: #FFF7ED; }

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
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ── Footer buttons ───────────────────────────────────────────────────────── */
.step3-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 32px;
}

/* ── Shared buttons ───────────────────────────────────────────────────────── */
.btn-orange {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 28px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  transition: background .15s, opacity .15s;
}
.btn-orange:hover    { background: #e04e0d; }
.btn-orange:disabled { opacity: .6; cursor: not-allowed; }
.btn-orange.btn-full { width: 100%; }

.btn-ghost {
  padding: 12px 28px;
  background: none;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  font-size: 16px;
  color: #62748E;
  cursor: pointer;
  font-family: 'Inter', sans-serif;
  transition: border-color .15s;
}
.btn-ghost:hover { border-color: #9CA3AF; }

/* ── Misc ─────────────────────────────────────────────────────────────────── */
.loading-msg { text-align: center; padding: 40px; color: #62748E; }
.error-msg   { color: #EF4444; font-size: 14px; margin-bottom: 12px; }

/* ── Responsive ──────────────────────────────────────────────────────────── */
@media (max-width: 640px) {
  .page-wrap   { padding: 20px 16px 20px; }
  .step-header { padding: 12px 16px; }
  .step-title  { font-size: 22px; }
  .step1-wrap,
  .step2-wrap,
  .step3-wrap  { padding: 20px 16px 48px; }
  .step2-heading,
  .step2-cat-name { font-size: 18px; }
  .step3-heading  { font-size: 18px; }
  .step3-wrap     { padding: 20px 16px; }
}

@media (max-width: 480px) {
  .page-wrap   { padding: 16px 12px; }
  .step-title  { font-size: 18px; }
  .btn-orange,
  .btn-ghost   { width: 100%; }
}
</style>

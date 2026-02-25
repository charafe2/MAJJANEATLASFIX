<template>
  <div class="service-page">

    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-bg"></div>

      <div class="hero-container">
        <!-- Left Content -->
        <div class="hero-left">
          <button class="back-link" @click="$router.push('/services')">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M12.5 15l-5-5 5-5" stroke="#62748E" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span>Retour aux services</span>
          </button>

          <h1 class="hero-title">
            Votre <span class="orange-text">{{ config.title }}</span><br>de Confiance
          </h1>

          <p class="hero-description">{{ config.description }}</p>
          <p class="hero-description-2">{{ config.description2 }}</p>

          <!-- Stats -->
          <div class="hero-stats">
            <div class="stat-box">
              <div class="stat-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <path d="M10 2C6.69 2 4 4.69 4 8c0 4.5 6 10 6 10s6-5.5 6-10c0-3.31-2.69-6-6-6z" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
                  <circle cx="10" cy="8" r="2" stroke="#FC5A15" stroke-width="1.67"/>
                </svg>
              </div>
              <div class="stat-text">
                <div class="stat-number">+{{ totalArtisans }}</div>
                <div class="stat-label">Artisans disponibles</div>
              </div>
            </div>

            <div class="stat-box">
              <div class="stat-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <path d="M10 3l1.8 5.4H17l-4.5 3.3 1.7 5.3L10 14l-4.2 3 1.7-5.3L3 8.6h5.2L10 3z" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <div class="stat-text">
                <div class="stat-number">4.8/5</div>
                <div class="stat-label">Note moyenne</div>
              </div>
            </div>

            <div class="stat-box">
              <div class="stat-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <circle cx="10" cy="10" r="7.5" stroke="#FC5A15" stroke-width="1.67"/>
                  <path d="M7 10l2 2 4-4" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <div class="stat-text">
                <div class="stat-number">100%</div>
                <div class="stat-label">Profils vérifiés</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Right Image -->
        <div class="hero-right">
          <div class="hero-image-container">
            <img :src="config.image" :alt="config.title" class="hero-image">
            <div class="image-overlay"></div>

            <!-- Floating review card -->
            <div class="floating-review">
              <div class="review-stars">
                <svg v-for="i in 5" :key="i" width="18" height="18" viewBox="0 0 18 18">
                  <path d="M9 2l1.6 4.8h5l-4 3 1.5 4.7L9 11.5l-4.1 3 1.5-4.7-4-3h5L9 2z" fill="#F0B100"/>
                </svg>
              </div>
              <p class="review-text">"Service impeccable et rapide!"</p>
              <div class="reviewer">
                <div class="reviewer-avatar">M</div>
                <div class="reviewer-info">
                  <div class="reviewer-name">Mohammed</div>
                  <div class="reviewer-badge">Client vérifié</div>
                </div>
              </div>
            </div>

            <!-- Floating stats -->
            <div class="floating-stats">
              <div class="stats-content">
                <div class="stats-number">500+</div>
                <div class="stats-labels">
                  <div>Avis</div>
                  <div>clients</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Search Bar -->
    <section class="search-section">
      <div class="search-container">
        <div class="search-input-wrapper">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none" class="search-icon">
            <circle cx="9" cy="9" r="6" stroke="#62748E" stroke-width="1.67"/>
            <path d="M13.5 13.5l3 3" stroke="#62748E" stroke-width="1.67" stroke-linecap="round"/>
          </svg>
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Rechercher un artisan..."
            class="search-input"
            @input="onSearch"
          >
        </div>

        <div class="filter-dropdown">
          <div class="filter-icon-wrapper">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <circle cx="8" cy="8" r="5" stroke="#FC5A15" stroke-width="1.6"/>
            </svg>
          </div>
          <div class="filter-content">
            <span class="filter-text">{{ config.categoryName }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Loading State -->
    <section v-if="loading" class="artisans-section">
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Chargement des artisans...</p>
      </div>
    </section>

    <!-- Error State -->
    <section v-else-if="error" class="artisans-section">
      <div class="empty-state">
        <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
          <circle cx="32" cy="32" r="30" stroke="#E5E7EB" stroke-width="2"/>
          <path d="M32 20v14M32 40v2" stroke="#FC5A15" stroke-width="2.5" stroke-linecap="round"/>
        </svg>
        <p class="empty-title">Impossible de charger les artisans</p>
        <p class="empty-sub">Veuillez réessayer ultérieurement.</p>
        <button class="retry-btn" @click="loadArtisans">Réessayer</button>
      </div>
    </section>

    <!-- Artisan Cards -->
    <section v-else class="artisans-section">
      <!-- Empty State -->
      <div v-if="artisans.length === 0" class="empty-state">
        <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
          <circle cx="32" cy="32" r="30" stroke="#E5E7EB" stroke-width="2"/>
          <path d="M24 40c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="#9CA3AF" stroke-width="2" stroke-linecap="round"/>
          <circle cx="32" cy="26" r="4" stroke="#9CA3AF" stroke-width="2"/>
        </svg>
        <p class="empty-title">Aucun artisan trouvé</p>
        <p class="empty-sub">Essayez une autre recherche ou revenez plus tard.</p>
      </div>

      <div v-else class="artisans-container">
        <div class="artisan-card" v-for="artisan in artisans" :key="artisan.id">
          <!-- Header -->
          <div class="card-header">
            <div class="avatar-wrapper avatar-clickable" @click="viewProfile(artisan.id)">
              <img
                v-if="artisan.avatar"
                :src="artisan.avatar"
                :alt="artisan.name"
                class="avatar-image"
              >
              <div v-else class="avatar-initials">
                {{ getInitials(artisan.name) }}
              </div>
              <div class="avatar-border"></div>
            </div>

            <div class="artisan-details">
              <div class="name-row">
                <span class="artisan-name artisan-name-clickable" @click="viewProfile(artisan.id)">{{ artisan.name }}</span>
                <svg v-if="artisan.verified" width="16" height="16" viewBox="0 0 16 16">
                  <circle cx="8" cy="8" r="8" fill="#155DFC"/>
                  <path d="M5 8l2 2 4-4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>

              <div class="artisan-specialty">{{ config.categoryName }}</div>

              <div class="artisan-location">
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                  <path d="M7 2a4 4 0 0 0-4 4c0 3 4 6 4 6s4-3 4-6a4 4 0 0 0-4-4z" stroke="#62748E" stroke-width="1.17"/>
                  <circle cx="7" cy="6" r="1.5" stroke="#62748E" stroke-width="1.17"/>
                </svg>
                <span>{{ artisan.city }}</span>
              </div>

              <div class="artisan-rating">
                <svg width="14" height="14" viewBox="0 0 14 14">
                  <path d="M7 2l1.2 3.6h3.8l-3 2.2 1.1 3.6L7 9.2l-3.1 2.2 1.1-3.6-3-2.2h3.8L7 2z" fill="#FF8904"/>
                </svg>
                <span>{{ artisan.rating }} ({{ artisan.reviews }} avis)</span>
              </div>
            </div>
          </div>

          <!-- About -->
          <div class="card-about">
            <div class="about-title">À propos</div>
            <p class="about-text">{{ artisan.bio }}</p>
          </div>

          <!-- Experience badge if available -->
          <div v-if="artisan.experience_years" class="card-badge">
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
              <circle cx="7" cy="7" r="6" stroke="#FC5A15" stroke-width="1.17"/>
              <path d="M7 4v3l2 2" stroke="#FC5A15" stroke-width="1.17" stroke-linecap="round"/>
            </svg>
            <span>{{ artisan.experience_years }} ans d'expérience</span>
          </div>

          <!-- Actions -->
          <div class="card-actions">
            <button class="btn-profile" @click="viewProfile(artisan.id)">Voir Profil</button>
            <button class="btn-contact" @click="contactArtisan(artisan.id)">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <path d="M12 2H2a1 1 0 0 0-1 1v7a1 1 0 0 0 1 1h3l2 2 2-2h3a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1z" stroke="white" stroke-width="1.17" stroke-linejoin="round"/>
              </svg>
              <span>Contacter</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="pagination">
        <button class="page-btn" :class="{ disabled: currentPage === 1 }" @click="changePage(currentPage - 1)">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M12.5 5l-5 5 5 5" stroke="#314158" stroke-width="1.67" stroke-linecap="round"/>
          </svg>
        </button>

        <button
          v-for="page in totalPages"
          :key="page"
          class="page-btn"
          :class="{ active: page === currentPage }"
          @click="changePage(page)"
        >
          {{ page }}
        </button>

        <button class="page-btn" :class="{ disabled: currentPage === totalPages }" @click="changePage(currentPage + 1)">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M7.5 5l5 5-5 5" stroke="#314158" stroke-width="1.67" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPublicCategories, getPublicArtisans } from '../api/artisans.js'

const route  = useRoute()
const router = useRouter()

// ── Service config map ────────────────────────────────────────────────────────
const SERVICE_CONFIGS = {
  plomberie: {
    title:        'Plombier',
    description:  "Trouvez le professionnel idéal pour vos travaux. Dépannage d'urgence ou rénovation complète, nos artisans qualifiés sont à votre service avec des tarifs clairs et sans surprises.",
    description2: "Que ce soit pour une simple fuite ou une installation complète, nos plombiers certifiés interviennent rapidement avec du matériel professionnel. Devis gratuit et transparence garantie.",
    image:        'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=700&q=80',
    categoryName: 'Plomberie',
  },
  electricite: {
    title:        'Électricien',
    description:  "Vos installations électriques entre les mains de professionnels certifiés. Sécurité et conformité garanties pour toutes vos interventions.",
    description2: "De l'installation de luminaires à la mise aux normes, nos électriciens qualifiés répondent à tous vos besoins avec rapidité et professionnalisme.",
    image:        'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=700&q=80',
    categoryName: 'Électricité',
  },
  peinture: {
    title:        'Peintre',
    description:  "Transformez votre intérieur avec nos peintres professionnels. Des finitions impeccables et des matériaux de qualité pour sublimer votre espace.",
    description2: "Travaux de peinture intérieure et extérieure réalisés avec soin par des artisans expérimentés. Couleurs tendances et techniques modernes.",
    image:        'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=700&q=80',
    categoryName: 'Peinture',
  },
  'reparations-generales': {
    title:        'Artisan Multi-services',
    description:  "Des artisans polyvalents pour tous vos petits travaux. Montage, réparation, installation — tout ce dont vous avez besoin en une seule intervention.",
    description2: "Montage de meubles, réparation de portes et serrures, joints et bien plus encore. Nos artisans interviennent rapidement chez vous.",
    image:        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=700&q=80',
    categoryName: 'Réparations générales',
  },
  demenagement: {
    title:        'Déménageur',
    description:  "Un déménagement serein avec des professionnels expérimentés. Emballage, transport, installation — tout est pris en charge avec soin.",
    description2: "Que ce soit un studio ou une grande maison, nos équipes de déménagement s'occupent de tout. Matériel professionnel et assurance inclus.",
    image:        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
    categoryName: 'Déménagement',
  },
  electromenager: {
    title:        'Technicien Électroménager',
    description:  "Réparez vos appareils ménagers sans les remplacer. Nos techniciens spécialisés interviennent rapidement à domicile pour diagnostiquer et réparer.",
    description2: "Lave-linge, réfrigérateur, four, cuisinière — nos experts réparent tous vos appareils électroménagers avec des pièces d'origine.",
    image:        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=700&q=80',
    categoryName: 'Électroménager',
  },
  nettoyage: {
    title:        'Agent de Nettoyage',
    description:  "Un espace propre et sain grâce à nos professionnels du nettoyage. Service standard, en profondeur ou après déménagement selon vos besoins.",
    description2: "Nettoyage résidentiel et commercial réalisé avec des produits écologiques. Nos équipes laissent tout impeccable dans les délais convenus.",
    image:        'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=700&q=80',
    categoryName: 'Nettoyage',
  },
  'chauffage-ventilation-climatisation': {
    title:        'Technicien CVC',
    description:  "Maintenez le confort de votre foyer toute l'année avec nos experts en chauffage, ventilation et climatisation. Interventions rapides garanties.",
    description2: "Entretien, réparation et installation de systèmes de climatisation et de chauffage par des professionnels certifiés avec garantie sur les travaux.",
    image:        'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=700&q=80',
    categoryName: 'Chauffage, Ventilation et Climatisation',
  },
}

const DEFAULT_CONFIG = {
  title:        'Artisan',
  description:  'Trouvez le professionnel idéal pour vos besoins parmi nos artisans qualifiés et vérifiés.',
  description2: 'Des artisans certifiés interviennent rapidement avec du matériel professionnel et des tarifs transparents.',
  image:        'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=700&q=80',
  categoryName: 'Service',
}

// ── State ─────────────────────────────────────────────────────────────────────
const artisans     = ref([])
const loading      = ref(true)
const error        = ref(false)
const searchQuery  = ref('')
const currentPage  = ref(1)
const totalPages   = ref(1)
const totalArtisans = ref(0)
const categoryId   = ref(null)

let searchTimeout = null

// ── Computed config ───────────────────────────────────────────────────────────
const config = computed(() =>
  SERVICE_CONFIGS[route.params.slug] ?? DEFAULT_CONFIG
)

// ── Helpers ───────────────────────────────────────────────────────────────────
function getInitials(name = '') {
  return name
    .split(' ')
    .slice(0, 2)
    .map(w => w[0]?.toUpperCase() ?? '')
    .join('')
}

// ── Data fetching ─────────────────────────────────────────────────────────────
async function resolveCategory() {
  try {
    const { data } = await getPublicCategories()
    const categories = data.data ?? []
    const slug       = route.params.slug
    const cfg        = SERVICE_CONFIGS[slug]

    if (!cfg) return null

    // Match by name (case-insensitive)
    const found = categories.find(
      c => c.name.toLowerCase() === cfg.categoryName.toLowerCase()
    )
    return found?.id ?? null
  } catch {
    return null
  }
}

async function loadArtisans() {
  loading.value = true
  error.value   = false

  try {
    const params = {
      page:     currentPage.value,
      per_page: 9,
    }

    if (categoryId.value) params.category_id = categoryId.value
    if (searchQuery.value.trim()) params.search = searchQuery.value.trim()

    const { data } = await getPublicArtisans(params)

    artisans.value     = data.data ?? []
    totalPages.value   = data.meta?.last_page ?? 1
    totalArtisans.value = data.meta?.total ?? artisans.value.length
  } catch {
    error.value = true
  } finally {
    loading.value = false
  }
}

// ── Search with debounce ──────────────────────────────────────────────────────
function onSearch() {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 1
    loadArtisans()
  }, 400)
}

// ── Pagination ────────────────────────────────────────────────────────────────
function changePage(page) {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  loadArtisans()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// ── Navigation actions ────────────────────────────────────────────────────────
function viewProfile(artisanId) {
  router.push(`/artisans/profile/${artisanId}`)
}

function contactArtisan(artisanId) {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }
  router.push(`/messages?artisan=${artisanId}`)
}

// ── Init ──────────────────────────────────────────────────────────────────────
onMounted(async () => {
  categoryId.value = await resolveCategory()
  await loadArtisans()
})

// Re-fetch when slug changes (e.g., navigating between service pages)
watch(() => route.params.slug, async () => {
  currentPage.value = 1
  searchQuery.value = ''
  categoryId.value  = await resolveCategory()
  await loadArtisans()
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&family=Inter:wght@400;500&display=swap');

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.service-page {
  font-family: 'Poppins', sans-serif;
  background: white;
}

/* ══════════════════════════════════════════════════════════════
   HERO SECTION
   ══════════════════════════════════════════════════════════════ */

.hero-section {
  position: relative;
  min-height: 852px;
  display: flex;
  align-items: center;
  overflow: hidden;
}

.hero-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(255,247,237,0) 9.21%, #FFFFFF 89.42%),
    linear-gradient(0deg, rgba(255,255,255,0.39), rgba(255,255,255,0.39)),
    url("data:image/svg+xml,%3Csvg width='120' height='60' xmlns='http://www.w3.org/2000/svg'%3E%3Crect width='120' height='60' fill='%23f5f5f5'/%3E%3Crect x='0' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0'/%3E%3Crect x='62' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0'/%3E%3Crect x='-30' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0'/%3E%3Crect x='31' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0'/%3E%3Crect x='92' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0'/%3E%3C/svg%3E") repeat;
  z-index: 0;
}

.hero-container {
  position: relative;
  z-index: 1;
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: flex;
  gap: 80px;
  padding: 80px 0;
}

.hero-left {
  flex: 0 0 560px;
  display: flex;
  flex-direction: column;
  gap: 22px;
}

.back-link {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #62748E;
  cursor: pointer;
  padding: 0;
  width: fit-content;
  transition: color 0.2s;
}

.back-link:hover { color: #FC5A15; }

.hero-title {
  font-size: 55px;
  font-weight: 600;
  line-height: 79px;
  letter-spacing: 0.26px;
  color: #314158;
  margin: 0;
}

.orange-text { color: #FC5A15; }

.hero-description,
.hero-description-2 {
  font-size: 18px;
  line-height: 30px;
  letter-spacing: -0.4px;
  color: #62748E;
  margin: 0;
}

.hero-stats {
  display: flex;
  gap: 40px;
  margin-top: 10px;
  flex-wrap: wrap;
}

.stat-box {
  display: flex;
  gap: 8px;
  align-items: flex-start;
}

.stat-icon {
  width: 40px;
  height: 40px;
  background: rgba(252, 90, 21, 0.1);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-text { display: flex; flex-direction: column; }

.stat-number {
  font-size: 28px;
  font-weight: 500;
  line-height: 34px;
  letter-spacing: 0.4px;
  color: #314158;
}

.stat-label {
  font-size: 13px;
  line-height: 20px;
  color: #62748E;
}

.hero-right {
  position: relative;
  flex: 1;
  display: flex;
  align-items: center;
}

.hero-image-container {
  position: relative;
  width: 100%;
  max-width: 560px;
  height: 560px;
  border-radius: 16px;
  overflow: visible;
}

.hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 16px;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
}

.image-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(0deg, rgba(0,0,0,0.5) 0%, rgba(0,0,0,0) 50%);
  border-radius: 16px;
  pointer-events: none;
}

.floating-review {
  position: absolute;
  top: -34px;
  right: -24px;
  width: 220px;
  padding: 18px 18px 10px;
  background: white;
  border: 1px solid #F3F4F6;
  box-shadow: 0 20px 28px -6px rgba(0,0,0,0.1);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.review-stars { display: flex; gap: 4px; }

.review-text {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  line-height: 22px;
  color: #314158;
  margin: 0;
}

.reviewer { display: flex; align-items: center; gap: 8px; }

.reviewer-avatar {
  width: 36px;
  height: 36px;
  background: #FC5A15;
  border-radius: 50%;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  flex-shrink: 0;
}

.reviewer-info { display: flex; flex-direction: column; }
.reviewer-name { font-family: 'Inter', sans-serif; font-size: 13px; color: #314158; }
.reviewer-badge { font-family: 'Inter', sans-serif; font-size: 12px; color: #62748E; }

.floating-stats {
  position: absolute;
  bottom: -34px;
  left: -24px;
  padding: 18px;
  background: #FC5A15;
  border-radius: 16px;
  box-shadow: 0 20px 28px -6px rgba(0,0,0,0.1);
}

.stats-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stats-number {
  font-size: 32px;
  font-weight: 500;
  color: white;
}

.stats-labels {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  color: white;
  display: flex;
  flex-direction: column;
  line-height: 22px;
}

/* ══════════════════════════════════════════════════════════════
   SEARCH SECTION
   ══════════════════════════════════════════════════════════════ */

.search-section { padding: 60px 0; }

.search-container {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: flex;
  gap: 11px;
}

.search-input-wrapper {
  flex: 1;
  height: 63px;
  background: white;
  border: 1px solid #99A1AF;
  border-radius: 10px;
  padding: 12px 16px 12px 44px;
  display: flex;
  align-items: center;
  position: relative;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
}

.search-input {
  flex: 1;
  border: none;
  outline: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #314158;
}

.search-input::placeholder { color: rgba(49,65,88,0.5); }

.filter-dropdown {
  width: 280px;
  height: 63px;
  background: white;
  border: 1px solid #99A1AF;
  border-radius: 11px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  gap: 9px;
}

.filter-icon-wrapper {
  width: 32px;
  height: 32px;
  background: rgba(252, 90, 21, 0.08);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.filter-content {
  flex: 1;
  display: flex;
  align-items: center;
}

.filter-text {
  font-size: 15px;
  font-weight: 500;
  color: #000;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ══════════════════════════════════════════════════════════════
   LOADING / EMPTY / ERROR STATES
   ══════════════════════════════════════════════════════════════ */

.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 80px 24px;
  font-family: 'Inter', sans-serif;
  color: #62748E;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #F3F4F6;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.empty-title {
  font-size: 20px;
  font-weight: 500;
  color: #314158;
}

.empty-sub { font-size: 15px; }

.retry-btn {
  margin-top: 8px;
  padding: 10px 24px;
  background: #FC5A15;
  color: white;
  border: none;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  cursor: pointer;
  transition: opacity 0.2s;
}

.retry-btn:hover { opacity: 0.85; }

/* ══════════════════════════════════════════════════════════════
   ARTISAN CARDS
   ══════════════════════════════════════════════════════════════ */

.artisans-section { padding-bottom: 80px; }

.artisans-container {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 28px 24px;
}

.artisan-card {
  background: white;
  box-shadow: 0 6px 14px -1px rgba(0,0,0,0.07), 0 1px 8px 3px rgba(0,0,0,0.06);
  border-radius: 14px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 18px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.artisan-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px -4px rgba(0,0,0,0.12);
}

.card-header { display: flex; gap: 14px; }

.avatar-wrapper {
  position: relative;
  width: 80px;
  height: 80px;
  flex-shrink: 0;
}

.avatar-image {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-initials {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, #FC5A15, #E54D0F);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Inter', sans-serif;
  font-size: 22px;
  font-weight: 500;
}

.avatar-border {
  position: absolute;
  inset: 0;
  border: 2px solid #FC5A15;
  border-radius: 50%;
}

.artisan-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.name-row { display: flex; align-items: center; gap: 6px; }

.artisan-name {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 500;
  color: #314158;
}

.artisan-specialty { font-family: 'Inter', sans-serif; font-size: 12px; color: #FC5A15; }

.artisan-location {
  display: flex;
  align-items: center;
  gap: 4px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #62748E;
}

.artisan-rating {
  display: flex;
  align-items: center;
  gap: 5px;
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  color: #314158;
}

.card-about { display: flex; flex-direction: column; gap: 5px; }

.about-title {
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 500;
  color: #314158;
}

.about-text {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 18px;
  color: #45556C;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #62748E;
}

.card-actions { display: flex; gap: 8px; }

.btn-profile {
  flex: 1;
  height: 38px;
  background: #EFEFEF;
  border: none;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #314158;
  cursor: pointer;
  transition: opacity 0.2s;
}

.btn-profile:hover { opacity: 0.8; }

.btn-contact {
  flex: 1;
  height: 38px;
  background: #FC5A15;
  border: none;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: opacity 0.2s;
}

.btn-contact:hover { opacity: 0.9; }

/* ══════════════════════════════════════════════════════════════
   PAGINATION
   ══════════════════════════════════════════════════════════════ */

.pagination {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  padding: 40px 0;
}

.page-btn {
  width: 40px;
  height: 40px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  background: white;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  color: #314158;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.page-btn.active { background: #FC5A15; color: white; border-color: #FC5A15; }
.page-btn.disabled { opacity: 0.4; cursor: not-allowed; pointer-events: none; }
.page-btn:not(.disabled):not(.active):hover { border-color: #FC5A15; }

.avatar-clickable { cursor: pointer; }
.avatar-clickable:hover .avatar-image,
.avatar-clickable:hover .avatar-initials { opacity: 0.82; }
.artisan-name-clickable { cursor: pointer; transition: color 0.15s; }
.artisan-name-clickable:hover { color: #FC5A15; }

/* ══════════════════════════════════════════════════════════════
   RESPONSIVE
   ══════════════════════════════════════════════════════════════ */

@media (max-width: 1200px) {
  .artisans-container { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 1100px) {
  .hero-container { flex-direction: column; align-items: center; gap: 60px; }
  .hero-left { flex: none; max-width: 100%; }
  .hero-right { flex: none; width: 100%; justify-content: center; }
  .hero-image-container { max-width: 500px; height: 400px; }
}

@media (max-width: 700px) {
  .artisans-container { grid-template-columns: 1fr; }
  .search-container { flex-direction: column; }
  .filter-dropdown { width: 100%; }
  .hero-title { font-size: 36px; line-height: 1.3; }
  .hero-stats { gap: 20px; }
  .floating-review { display: none; }
  .floating-stats { display: none; }
}
</style>

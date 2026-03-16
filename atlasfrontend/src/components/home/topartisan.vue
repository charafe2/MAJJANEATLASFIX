<!-- src/components/TopArtisansSection.vue -->
<template>
  <section class="ta-section">
    <div class="ta-wrapper">

      <!-- Header -->
      <div class="ta-header">
        <h2 class="ta-title">Nos artisans les mieux notés</h2>
        <p class="ta-subtitle">Des professionnels bien notés, prêts à vous aider dans vos projets.</p>
      </div>

      <!-- Carousel area -->
      <div class="ta-carousel-area">

        <!-- Left arrow -->
        <button class="ta-arrow ta-arrow-prev" @click="prev" aria-label="Précédent">
          <svg viewBox="0 0 8 16" fill="none">
            <path d="M7 1L1 8l6 7" stroke="#D9D9D9" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>

        <!-- Cards -->
        <div class="ta-track">
          <div v-for="(artisan, i) in visible" :key="i" class="ta-card" :class="{ 'ta-card-boosted': artisan.is_boosted }">

            <!-- Boost badge -->
            <div v-if="artisan.is_boosted" class="ta-boost-badge">
              <svg viewBox="0 0 16 16" fill="none" width="12" height="12">
                <path d="M8 1l1.5 3.5H14l-3 2.5 1.2 3.5L8 8.2 3.8 10.5 5 7 2 4.5h4.5z" fill="#FC5A15"/>
              </svg>
              Mis en avant
            </div>

            <!-- Top: avatar + info -->
            <div class="ta-card-top">
              <img :src="avatarUrl(artisan)" :alt="artisan.name" class="ta-avatar" />
              <div class="ta-info">
                <div class="ta-name-row">
                  <span class="ta-name">{{ artisan.name }}</span>
                  <!-- Blue verified check -->
                  <svg class="ta-verified" viewBox="0 0 16 16" fill="none">
                    <rect x="1" y="1" width="14" height="14" rx="3" stroke="#155DFC" stroke-width="1.33"/>
                    <path d="M5 8l2.5 2.5 4-4" stroke="#155DFC" stroke-width="1.33" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="ta-meta">
                  <span class="ta-specialty">{{ artisan.specialty ?? 'Artisan' }}</span>
                  <!-- Location -->
                  <div class="ta-location">
                    <svg viewBox="0 0 14 18" fill="none">
                      <path d="M7 1C4.24 1 2 3.24 2 6c0 4 5 11 5 11s5-7 5-11c0-2.76-2.24-5-5-5z" stroke="#62748E" stroke-width="1.2"/>
                      <circle cx="7" cy="6" r="1.5" stroke="#62748E" stroke-width="1.2"/>
                    </svg>
                    <span>{{ artisan.city }}</span>
                  </div>
                  <!-- Rating -->
                  <div class="ta-rating">
                    <svg viewBox="0 0 14 14" fill="#FF8904">
                      <path d="M7 1l1.5 4H13l-3.5 2.5 1.3 4L7 9 3.2 11.5l1.3-4L1 5h4.5L7 1z"/>
                    </svg>
                    <span>{{ artisan.rating }}/5 ({{ artisan.reviews }} avis)</span>

                  </div>
                </div>
              </div>
            </div>

            <!-- About -->
            <div class="ta-about">
              <span class="ta-about-title">À propos</span>
              <p class="ta-about-text">{{ artisan.bio }}</p>
            </div>

            <!-- Last review -->
            <div v-if="artisan.last_review" class="ta-review">
              <span class="ta-review-header">Dernier avis de {{ artisan.last_review.reviewer }} {{ artisan.last_review.rating }}/5</span>
              <span class="ta-review-date">{{ artisan.last_review.date }}</span>
              <span class="ta-review-text">{{ artisan.last_review.comment }}</span>
            </div>
            <div v-else class="ta-review">
              <span class="ta-review-header">Pas encore d'avis</span>
            </div>

            <!-- Buttons -->
            <div class="ta-btns">
              <button class="ta-btn-profile" @click="router.push(`/artisans/profile/${artisan.id}`)">Voir le profil</button>
              <button class="ta-btn-contact" @click="router.push(`/artisans/profile/${artisan.id}`)">
                <svg viewBox="0 0 14 14" fill="none">
                  <rect x="1" y="1" width="12" height="12" rx="2" stroke="white" stroke-width="1.18"/>
                  <path d="M4 5h6M4 8h4" stroke="white" stroke-width="1.18" stroke-linecap="round"/>
                </svg>
                Contacter
              </button>
            </div>

          </div>
        </div>

        <!-- Right arrow -->
        <button class="ta-arrow ta-arrow-next" @click="next" aria-label="Suivant">
          <svg viewBox="0 0 8 16" fill="none">
            <path d="M1 1l6 7-6 7" stroke="#FC5A15" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>

      </div>

      <!-- Dots -->
      <div class="ta-dots">
        <span
          v-for="(_, i) in artisans"
          :key="i"
          class="ta-dot"
          :class="{ 'ta-dot-active': i === current }"
          @click="current = i"
        ></span>

      </div>

    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router   = useRouter()
const artisans = ref([])
const current  = ref(0)

onMounted(async () => {
  try {
    const res  = await fetch('/api/public/artisans?per_page=6')
    const json = await res.json()
    artisans.value = json.data ?? []
  } catch {
    // keep empty
  }
})

function avatarUrl(a) {
  return a.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(a.name)}&background=FC5A15&color=fff&size=96`
}

const visible = computed(() => {
  const total = artisans.value.length
  if (total === 0) return []
  return [0, 1, 2].map(offset => artisans.value[(current.value + offset) % total])
})

const prev = () => { current.value = (current.value - 1 + artisans.value.length) % artisans.value.length }
const next = () => { current.value = (current.value + 1) % artisans.value.length }
</script>

<style scoped>
.ta-section {
  background: #ffffff;
  padding: 80px 0;
}

.ta-wrapper {
  max-width: 1246px;
  margin: 0 auto;
  padding: 0 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 43px;
}

/* Header */
.ta-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  text-align: center;
}

.ta-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 40px;
  line-height: 1.2;
  letter-spacing: -0.45px;
  color: #0a0a0a;
  margin: 0;
}

.ta-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 18px;
  line-height: 1.35;
  letter-spacing: -0.31px;
  color: #4a5565;
  margin: 0;
}

/* Carousel area */
.ta-carousel-area {
  display: flex;
  align-items: center;
  gap: 16px;
  width: 100%;
}

/* Arrows */
.ta-arrow {
  flex-shrink: 0;
  width: 30px;
  height: 40px;
  border-radius: 100px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.2s;
}

.ta-arrow svg { width: 8px; height: 16px; }

.ta-arrow-prev { border: 1px solid #D9D9D9; }
.ta-arrow-prev:hover { background: #f9f9f9; }
.ta-arrow-next { border: 1px solid #FC5A15; }
.ta-arrow-next:hover { background: #fff5f0; }

/* Track */
.ta-track {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 23px;
  flex: 1;
}

/* Card */
.ta-card {
  background: #ffffff;
  border-radius: 14px;
  box-shadow: 0px 6px 14.3px -1px rgba(0,0,0,0.07), 0px 1px 8.6px 3px rgba(0,0,0,0.08);
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  position: relative;
}

.ta-card-boosted {
  border: 1.5px solid #FC5A15;
  box-shadow: 0px 6px 14.3px -1px rgba(252,90,21,0.12), 0px 1px 8.6px 3px rgba(252,90,21,0.1);
}

.ta-boost-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  background: #FFF5F0;
  color: #FC5A15;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 10px;
  padding: 3px 10px;
  border-radius: 20px;
  width: fit-content;
}

/* Top row */
.ta-card-top {
  display: flex;
  align-items: center;
  gap: 16px;
}

.ta-avatar {
  width: 96px;
  height: 96px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
  background: #eee;
}

.ta-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.ta-name-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ta-name {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 15px;
  line-height: 1.4;
  letter-spacing: -0.27px;
  color: #314158;
}

.ta-verified {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.ta-meta {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.ta-specialty {
  font-family: 'Poppins', sans-serif;
  font-weight: 300;
  font-size: 10px;
  line-height: 1.4;
  color: #45556C;
}

.ta-location {
  display: flex;
  align-items: center;
  gap: 4px;
}

.ta-location svg { width: 12px; height: 14px; flex-shrink: 0; }

.ta-location span {
  font-family: 'Poppins', sans-serif;
  font-weight: 300;
  font-size: 12px;
  color: #62748E;
}

.ta-rating {
  display: flex;
  align-items: center;
  gap: 4px;
}

.ta-rating svg { width: 14px; height: 14px; flex-shrink: 0; }

.ta-rating span {
  font-family: 'Poppins', sans-serif;
  font-weight: 300;
  font-size: 10px;
  color: #314158;
}

/* About */
.ta-about {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.ta-about-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 15px;
  line-height: 1.8;
  letter-spacing: -0.44px;
  color: #314158;
}

.ta-about-text {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 12px;
  line-height: 1.58;
  letter-spacing: -0.31px;
  color: #45556C;
  margin: 0;
}

/* Review */
.ta-review {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.ta-review-header {
  font-family: 'Inter', 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 12px;
  line-height: 1.75;
  letter-spacing: -0.27px;
  color: #314158;
}

.ta-review-date {
  font-family: 'Inter', 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 12px;
  line-height: 1.4;
  color: #62748E;
}

.ta-review-text {
  font-family: 'Inter', 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 12px;
  line-height: 1.75;
  color: #02BB05;
}

/* Buttons */
.ta-btns {
  display: flex;
  align-items: center;
  gap: 4px;
}

.ta-btn-profile {
  flex: 1;
  height: 37px;
  background: #EFEFEF;
  border: none;
  border-radius: 9999px;
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 11.35px;
  color: #000000;
  cursor: pointer;
  transition: background 0.2s;
}

.ta-btn-profile:hover { background: #e0e0e0; }

.ta-btn-contact {
  flex: 1;
  height: 37px;
  background: #FC5A15;
  border: none;
  border-radius: 9999px;
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 11.35px;
  color: #ffffff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  transition: background 0.2s;
}

.ta-btn-contact svg { width: 14px; height: 14px; }
.ta-btn-contact:hover { background: #e04e12; }

/* Dots */
.ta-dots {
  display: flex;
  align-items: center;
  gap: 10px;
}

.ta-dot {
  width: 10px;
  height: 10px;
  border-radius: 4px;
  background: #D9D9D9;
  cursor: pointer;
  transition: background 0.2s;
}

.ta-dot-active {
  background: #FC5A15;
  border: 1px solid #FC5A15;
}

/* Responsive */
@media (max-width: 1024px) {
  .ta-track { grid-template-columns: repeat(2, 1fr); }
  .ta-track .ta-card:last-child { display: none; }
}

@media (max-width: 640px) {
  .ta-section { padding: 60px 0; }
  .ta-wrapper { padding: 0 16px; gap: 32px; }
  .ta-title { font-size: 28px; }
  .ta-track { grid-template-columns: 1fr; }
  .ta-track .ta-card:not(:first-child) { display: none; }
}
</style>
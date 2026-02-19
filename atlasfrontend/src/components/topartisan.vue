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
          <div v-for="(artisan, i) in visible" :key="i" class="ta-card">

            <!-- Top: avatar + info -->
            <div class="ta-card-top">
              <img :src="artisan.avatar" :alt="artisan.name" class="ta-avatar" />
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
                  <span class="ta-specialty">{{ artisan.specialty }}</span>
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
              <p class="ta-about-text">{{ artisan.about }}</p>
            </div>

            <!-- Last review -->
            <div class="ta-review">
              <span class="ta-review-header">{{ artisan.reviewTitle }}</span>
              <span class="ta-review-date">{{ artisan.reviewDate }}</span>
              <span class="ta-review-text">{{ artisan.reviewText }}</span>
            </div>

            <!-- Buttons -->
            <div class="ta-btns">
              <button class="ta-btn-profile">Voir le profil</button>
              <button class="ta-btn-contact">
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
import { ref, computed } from 'vue'

const artisans = [
  {
    name: 'Karim Benali',
    specialty: 'Spécialiste en Rénovation de Maison',
    city: 'Casablanca',
    rating: '4.8',
    reviews: 89,
    avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
    about: "J'offre des services professionnels de rénovation pour vous accompagner dans tous vos projets d'amélioration de l'habitat, des petites réparations aux rénovations complètes. Un travail de qualité, garanti avec une grande attention aux détails.",
    reviewTitle: 'Dernier avis de Michael 5/5',
    reviewDate: 'Mardi à 14h',
    reviewText: 'Excellent travail',
  },
  {
    name: 'Youssef Alami',
    specialty: 'Expert en Plomberie',
    city: 'Rabat',
    rating: '4.9',
    reviews: 124,
    avatar: 'https://randomuser.me/api/portraits/men/44.jpg',
    about: "Plombier professionnel avec plus de 10 ans d'expérience. Intervention rapide pour toutes urgences, installation et réparation de toutes canalisations. Devis gratuit et transparent.",
    reviewTitle: 'Dernier avis de Sara 5/5',
    reviewDate: 'Lundi à 10h',
    reviewText: 'Très professionnel',
  },
  {
    name: 'Omar Tazi',
    specialty: 'Électricien Certifié',
    city: 'Marrakech',
    rating: '4.7',
    reviews: 67,
    avatar: 'https://randomuser.me/api/portraits/men/55.jpg',
    about: "Électricien certifié spécialisé dans l'installation électrique résidentielle et commerciale. Mise aux normes, dépannage rapide, installation de tableaux électriques et domotique.",
    reviewTitle: 'Dernier avis de Ahmed 5/5',
    reviewDate: 'Mercredi à 9h',
    reviewText: 'Travail soigné',
  },
  {
    name: 'Hassan Idrissi',
    specialty: 'Peintre Décorateur',
    city: 'Fès',
    rating: '4.6',
    reviews: 43,
    avatar: 'https://randomuser.me/api/portraits/men/67.jpg',
    about: "Peintre décorateur avec une expertise en revêtements intérieurs et extérieurs. Maîtrise des techniques modernes et traditionnelles pour sublimer vos espaces.",
    reviewTitle: 'Dernier avis de Nadia 5/5',
    reviewDate: 'Jeudi à 16h',
    reviewText: 'Magnifique résultat',
  },
  {
    name: 'Rachid Moussaoui',
    specialty: 'Menuisier Ébéniste',
    city: 'Tanger',
    rating: '4.9',
    reviews: 98,
    avatar: 'https://randomuser.me/api/portraits/men/78.jpg',
    about: "Menuisier ébéniste passionné, création de meubles sur mesure, pose de parquet, installation de cuisines et de dressings. Bois massif et matériaux nobles.",
    reviewTitle: 'Dernier avis de Leila 5/5',
    reviewDate: 'Vendredi à 11h',
    reviewText: 'Chef d\'œuvre !',
  },
]

const current = ref(0)

const visible = computed(() => {
  return [0, 1, 2].map(offset => artisans[(current.value + offset) % artisans.length])
})

const prev = () => { current.value = (current.value - 1 + artisans.length) % artisans.length }
const next = () => { current.value = (current.value + 1) % artisans.length }
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
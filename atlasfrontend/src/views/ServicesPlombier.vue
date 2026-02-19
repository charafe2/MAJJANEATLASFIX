<template>
  <div class="plumber-service">
    
    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-bg"></div>
      
      <div class="hero-container">
        <!-- Left Content -->
        <div class="hero-left">
          <button class="back-link">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M12.5 15l-5-5 5-5" stroke="#62748E" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span>Retour aux services</span>
          </button>

          <h1 class="hero-title">
            Votre <span class="orange-text">Plombier</span> de<br>Confiance
          </h1>

          <p class="hero-description">
            Trouvez le professionnel idéal pour vos travaux. Dépannage d'urgence ou rénovation complète, nos artisans qualifiés sont à votre service avec des tarifs clairs et sans surprises.
          </p>

          <p class="hero-description-2">
            Que ce soit pour une simple fuite ou une installation complète, nos plombiers certifiés interviennent rapidement avec du matériel professionnel. Devis gratuit et transparence garantie.
          </p>

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
                <div class="stat-number">+50</div>
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
                <div class="stat-number">+50</div>
                <div class="stat-label">Profils certifiés</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Right Image -->
        <div class="hero-right">
          <div class="hero-image-container">
            <img src="https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=700&q=80" alt="Plombier" class="hero-image">
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
          <input type="text" placeholder="Rechercher un artisan..." class="search-input">
        </div>

        <div class="filter-dropdown">
          <div class="filter-icon-wrapper">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <circle cx="8" cy="8" r="5" stroke="#FC5A15" stroke-width="1.6"/>
            </svg>
          </div>
          <div class="filter-content">
            <span class="filter-text">Type de services</span>
            <svg width="10" height="6" viewBox="0 0 10 6" fill="none">
              <path d="M1 1l4 4 4-4" stroke="#314158" stroke-width="1.7" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
      </div>
    </section>

    <!-- Artisan Cards -->
    <section class="artisans-section">
      <div class="artisans-container">
        <div class="artisan-card" v-for="artisan in artisans" :key="artisan.id">
          <!-- Header -->
          <div class="card-header">
            <div class="avatar-wrapper">
              <img :src="artisan.avatar" :alt="artisan.name" class="avatar-image">
              <div class="avatar-border"></div>
            </div>
            
            <div class="artisan-details">
              <div class="name-row">
                <span class="artisan-name">{{ artisan.name }}</span>
                <svg v-if="artisan.verified" width="16" height="16" viewBox="0 0 16 16">
                  <circle cx="8" cy="8" r="8" fill="#155DFC"/>
                  <path d="M5 8l2 2 4-4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              
              <div class="artisan-specialty">{{ artisan.specialty }}</div>
              
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
                <span>{{ artisan.rating }} ({{ artisan.reviews }} reviews)</span>
              </div>
            </div>
          </div>

          <!-- About -->
          <div class="card-about">
            <div class="about-title">À propos</div>
            <p class="about-text">{{ artisan.about }}</p>
          </div>

          <!-- Last Review -->
          <div class="card-review">
            <div class="review-title">Dernier avis {{ artisan.lastReview.name }} : 5/5</div>
            <div class="review-date">{{ artisan.lastReview.date }}</div>
            <div class="review-comment">{{ artisan.lastReview.comment }}</div>
          </div>

          <!-- Actions -->
          <div class="card-actions">
            <button class="btn-profile">Voir Profile</button>
            <button class="btn-contact">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <circle cx="7" cy="7" r="6" stroke="white" stroke-width="1.17"/>
              </svg>
              <span>Connecter</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div class="pagination">
        <button class="page-btn disabled">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M12.5 5l-5 5 5 5" stroke="#314158" stroke-width="1.67" stroke-linecap="round"/>
          </svg>
        </button>
        <button class="page-btn active">1</button>
        <button class="page-btn">2</button>
        <button class="page-btn">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M7.5 5l5 5-5 5" stroke="#314158" stroke-width="1.67" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref } from 'vue'

const artisans = ref([
  {
    id: 1,
    name: 'Ahmed Bennani',
    verified: true,
    specialty: 'Plomberie & Sanitaire',
    city: 'Casablanca',
    rating: '4.9/5',
    reviews: 127,
    avatar: 'https://i.pravatar.cc/96?img=12',
    about: "Expert en plomberie avec 15 ans d'expérience. Je prends en charge tous types d'interventions avec garantie de qualité.",
    lastReview: { name: 'Fatima', date: 'Lundi à 10h', comment: 'Très professionnel' }
  },
  {
    id: 2,
    name: 'Youssef Alami',
    verified: true,
    specialty: 'Spécialiste Chauffage',
    city: 'Rabat',
    rating: '4.7/5',
    reviews: 89,
    avatar: 'https://i.pravatar.cc/96?img=33',
    about: "Spécialisé dans l'installation et la maintenance de systèmes de chauffage modernes et écologiques.",
    lastReview: { name: 'Karim', date: 'Hier à 14h', comment: 'Excellent service' }
  },
  {
    id: 3,
    name: 'Hassan Idrissi',
    verified: true,
    specialty: 'Plomberie Générale',
    city: 'Casablanca',
    rating: '4.8/5',
    reviews: 156,
    avatar: 'https://i.pravatar.cc/96?img=51',
    about: 'Plombier professionnel offrant un service complet pour particuliers et entreprises.',
    lastReview: { name: 'Sara', date: 'Mardi à 9h', comment: 'Rapide et efficace' }
  },
  {
    id: 4,
    name: 'Omar Berrada',
    verified: true,
    specialty: 'Dépannage Urgence',
    city: 'Marrakech',
    rating: '4.6/5',
    reviews: 78,
    avatar: 'https://i.pravatar.cc/96?img=68',
    about: "Service de dépannage plomberie disponible 24/7. Intervention rapide garantie dans l'heure.",
    lastReview: { name: 'Rachid', date: 'Mercredi à 8h', comment: 'Intervention rapide' }
  },
  {
    id: 5,
    name: 'Samir Tahiri',
    verified: true,
    specialty: 'Installation Sanitaire',
    city: 'Tanger',
    rating: '4.8/5',
    reviews: 112,
    avatar: 'https://i.pravatar.cc/96?img=15',
    about: 'Expert en installation de salles de bain et cuisines avec matériaux haut de gamme.',
    lastReview: { name: 'Malika', date: 'Jeudi à 15h', comment: 'Très satisfaite' }
  },
  {
    id: 6,
    name: 'Driss Mansouri',
    verified: true,
    specialty: 'Plomberie Écologique',
    city: 'Casablanca',
    rating: '4.9/5',
    reviews: 95,
    avatar: 'https://i.pravatar.cc/96?img=56',
    about: "Spécialiste en solutions écologiques pour économiser l'eau et réduire votre empreinte.",
    lastReview: { name: 'Hicham', date: 'Vendredi à 11h', comment: 'Solutions innovantes' }
  },
  {
    id: 7,
    name: 'Ahmed Bennani',
    verified: true,
    specialty: 'Plomberie & Sanitaire',
    city: 'Casablanca',
    rating: '4.9/5',
    reviews: 127,
    avatar: 'https://i.pravatar.cc/96?img=12',
    about: "Expert en plomberie avec 15 ans d'expérience. Je prends en charge tous types d'interventions avec garantie de qualité.",
    lastReview: { name: 'Fatima', date: 'Lundi à 10h', comment: 'Très professionnel' }
  },
  {
    id: 8,
    name: 'Youssef Alami',
    verified: true,
    specialty: 'Spécialiste Chauffage',
    city: 'Rabat',
    rating: '4.7/5',
    reviews: 89,
    avatar: 'https://i.pravatar.cc/96?img=33',
    about: "Spécialisé dans l'installation et la maintenance de systèmes de chauffage modernes et écologiques.",
    lastReview: { name: 'Karim', date: 'Hier à 14h', comment: 'Excellent service' }
  },
  {
    id: 9,
    name: 'Hassan Idrissi',
    verified: true,
    specialty: 'Plomberie Générale',
    city: 'Casablanca',
    rating: '4.8/5',
    reviews: 156,
    avatar: 'https://i.pravatar.cc/96?img=51',
    about: 'Plombier professionnel offrant un service complet pour particuliers et entreprises.',
    lastReview: { name: 'Sara', date: 'Mardi à 9h', comment: 'Rapide et efficace' }
  }
])
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&family=Inter:wght@400;500&display=swap');

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.plumber-service {
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
  gap: 126px;
  padding: 80px 0;
}

.hero-left {
  flex: 0 0 618px;
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
}

.hero-title {
  font-size: 55px;
  font-weight: 600;
  line-height: 79px;
  letter-spacing: 0.26px;
  color: #314158;
  margin: 0;
}

.orange-text {
  color: #FC5A15;
}

.hero-description,
.hero-description-2 {
  font-size: 20px;
  line-height: 32px;
  letter-spacing: -0.45px;
  color: #62748E;
  margin: 0;
}

.hero-stats {
  display: flex;
  gap: 55px;
  margin-top: 10px;
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

.stat-text {
  display: flex;
  flex-direction: column;
}

.stat-number {
  font-size: 30px;
  font-weight: 500;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
}

.stat-label {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.hero-right {
  position: relative;
  flex: 0 0 600px;
}

.hero-image-container {
  position: relative;
  width: 600px;
  height: 606px;
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
  background: linear-gradient(0deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 50%, rgba(0,0,0,0) 100%);
  border-radius: 16px;
  pointer-events: none;
}

/* Floating cards */
.floating-review {
  position: absolute;
  top: -34px;
  right: -24px;
  width: 230px;
  padding: 19.55px 19.55px 1.15px;
  background: white;
  border: 1.15px solid #F3F4F6;
  box-shadow: 0 23px 29px -6px rgba(0,0,0,0.1), 0 9px 12px -7px rgba(0,0,0,0.1);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 9.2px;
}

.review-stars {
  display: flex;
  gap: 4.6px;
}

.review-text {
  font-family: 'Inter', sans-serif;
  font-size: 16.1px;
  line-height: 23px;
  letter-spacing: -0.17px;
  color: #314158;
  margin: 0;
}

.reviewer {
  display: flex;
  align-items: center;
  gap: 9.2px;
}

.reviewer-avatar {
  width: 36.8px;
  height: 36.8px;
  background: #FC5A15;
  border-radius: 50%;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Inter', sans-serif;
  font-size: 16.1px;
  font-weight: 400;
  flex-shrink: 0;
}

.reviewer-info {
  display: flex;
  flex-direction: column;
}

.reviewer-name {
  font-family: 'Inter', sans-serif;
  font-size: 13.8px;
  line-height: 18px;
  color: #314158;
}

.reviewer-badge {
  font-family: 'Inter', sans-serif;
  font-size: 13.8px;
  line-height: 18px;
  color: #62748E;
}

.floating-stats {
  position: absolute;
  bottom: -34px;
  left: -24px;
  padding: 19px;
  background: #FC5A15;
  border-radius: 16.66px;
  box-shadow: 0 23.8px 29.74px -5.95px rgba(0,0,0,0.1), 0 9.52px 11.9px -7.14px rgba(0,0,0,0.1);
}

.stats-content {
  display: flex;
  align-items: center;
  gap: 14.28px;
}

.stats-number {
  font-size: 35.69px;
  font-weight: 500;
  line-height: 43px;
  letter-spacing: 0.47px;
  color: white;
}

.stats-labels {
  font-family: 'Inter', sans-serif;
  font-size: 16.66px;
  line-height: 24px;
  letter-spacing: -0.18px;
  color: white;
  display: flex;
  flex-direction: column;
}

/* ══════════════════════════════════════════════════════════════
   SEARCH SECTION
   ══════════════════════════════════════════════════════════════ */

.search-section {
  padding: 60px 0;
}

.search-container {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: flex;
  gap: 11px;
}

.search-input-wrapper {
  flex: 1;
  max-width: 893px;
  height: 63px;
  background: white;
  border: 1px solid #99A1AF;
  border-radius: 10px;
  padding: 12px 16px 12px 40px;
  display: flex;
  align-items: center;
  gap: 8px;
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
  line-height: 19px;
  letter-spacing: -0.31px;
  color: #314158;
}

.search-input::placeholder {
  color: rgba(49,65,88,0.5);
}

.filter-dropdown {
  width: 344px;
  height: 63px;
  background: white;
  border: 1px solid #99A1AF;
  box-shadow: 0 0.85px 2.55px rgba(0,0,0,0.1), 0 0.85px 1.7px -0.85px rgba(0,0,0,0.1);
  border-radius: 11.88px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  gap: 9px;
  cursor: pointer;
}

.filter-icon-wrapper {
  width: 32px;
  height: 32px;
  background: rgba(252, 90, 21, 0.08);
  border-radius: 5.25px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.filter-content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.filter-text {
  font-size: 16px;
  font-weight: 500;
  line-height: 27px;
  letter-spacing: 0.06px;
  color: #000;
}

/* ══════════════════════════════════════════════════════════════
   ARTISAN CARDS
   ══════════════════════════════════════════════════════════════ */

.artisans-section {
  padding-bottom: 80px;
}

.artisans-container {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 400px);
  gap: 30px 24px;
  justify-content: center;
}

.artisan-card {
  width: 400px;
  background: white;
  box-shadow: 0 6px 14.3px -1px rgba(0,0,0,0.07), 0 1px 8.6px 3px rgba(0,0,0,0.08);
  border-radius: 14px;
  padding: 20px 0 20px 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.card-header {
  display: flex;
  gap: 16px;
  padding-right: 20px;
}

.avatar-wrapper {
  position: relative;
  width: 96px;
  height: 96px;
  flex-shrink: 0;
}

.avatar-image {
  width: 96px;
  height: 96px;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-border {
  position: absolute;
  inset: 0;
  border: 1.5px solid #FC5A15;
  border-radius: 50%;
}

.artisan-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.artisan-name {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.artisan-specialty {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 18px;
  color: #45556C;
}

.artisan-location {
  display: flex;
  align-items: center;
  gap: 4px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 18px;
  color: #62748E;
}

.artisan-rating {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 10px;
  line-height: 15px;
  letter-spacing: 0.12px;
  color: #314158;
}

.card-about {
  padding-right: 20px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.about-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 500;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.about-text {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 19px;
  color: #45556C;
  margin: 0;
}

.card-review {
  padding-right: 20px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.review-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.review-date {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
}

.review-comment {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #02BB05;
}

.card-actions {
  padding-right: 20px;
  display: flex;
  gap: 4px;
}

.btn-profile {
  flex: 1;
  height: 37px;
  background: #EFEFEF;
  border: none;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 11.35px;
  line-height: 17px;
  letter-spacing: 0.04px;
  text-align: center;
  color: #000;
  cursor: pointer;
  transition: opacity 0.2s;
  padding: 10px;
}

.btn-profile:hover {
  opacity: 0.8;
}

.btn-contact {
  flex: 1;
  height: 37px;
  background: #FC5A15;
  border: none;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 11.35px;
  line-height: 17px;
  letter-spacing: 0.04px;
  text-align: center;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  transition: opacity 0.2s;
  padding: 10px;
}

.btn-contact:hover {
  opacity: 0.9;
}

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
  padding: 30px 0;
}

.page-btn {
  width: 40px;
  height: 40px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  background: white;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  text-align: center;
  letter-spacing: -0.31px;
  color: #314158;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.page-btn.active {
  background: #FC5A15;
  color: white;
  border-color: #FC5A15;
}

.page-btn.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-btn:not(.disabled):not(.active):hover {
  border-color: #FC5A15;
}

/* ══════════════════════════════════════════════════════════════
   RESPONSIVE
   ══════════════════════════════════════════════════════════════ */

@media (max-width: 1300px) {
  .artisans-container {
    grid-template-columns: repeat(2, 400px);
  }
}

@media (max-width: 1100px) {
  .hero-container {
    flex-direction: column;
    align-items: center;
    gap: 60px;
  }
  
  .hero-left {
    flex: none;
    max-width: 100%;
  }
  
  .hero-right {
    flex: none;
  }
}

@media (max-width: 900px) {
  .artisans-container {
    grid-template-columns: 1fr;
  }
  
  .artisan-card {
    width: 100%;
    max-width: 400px;
    margin: 0 auto;
  }
  
  .search-container {
    flex-direction: column;
  }
  
  .filter-dropdown {
    width: 100%;
  }
}

@media (max-width: 650px) {
  .hero-title {
    font-size: 36px;
    line-height: 1.3;
  }
  
  .hero-stats {
    flex-direction: column;
    gap: 20px;
  }
  
  .hero-image-container {
    width: 100%;
  }
  
  .floating-review {
    right: 10px;
  }
  
  .floating-stats {
    left: 10px;
  }
}
</style>
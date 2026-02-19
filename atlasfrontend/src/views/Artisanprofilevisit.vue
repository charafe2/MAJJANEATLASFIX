<template>
  <div class="artisan-profile-page">
    
    <!-- Back Button -->
    <button class="back-button" @click="$router.push('/services')">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path d="M12.5 15l-5-5 5-5" stroke="#62748E" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      <span>Retour à la liste</span>
    </button>

    <div class="profile-container">
      <!-- LEFT SIDEBAR -->
      <aside class="profile-sidebar">
        <!-- Profile Card -->
        <div class="profile-card">
          <div class="profile-header">
            <img src="https://i.pravatar.cc/128?img=12" alt="Ahmed Bennani" class="profile-avatar">
            <h2 class="profile-name">Ahmed Bennani</h2>
            <p class="profile-specialty">Plomberie & Sanitaire</p>
            
            <div class="profile-location">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M8 2a4 4 0 0 0-4 4c0 3 4 6 4 6s4-3 4-6a4 4 0 0 0-4-4z" stroke="#62748E" stroke-width="1.33"/>
                <circle cx="8" cy="6" r="1.5" stroke="#62748E" stroke-width="1.33"/>
              </svg>
              <span>Casablanca</span>
            </div>

            <div class="profile-badge">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <circle cx="8" cy="8" r="7" stroke="#008236" stroke-width="1.33"/>
                <path d="M6 8l2 2 4-4" stroke="#008236" stroke-width="1.33" stroke-linecap="round"/>
              </svg>
              <span>Profil vérifié</span>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="profile-actions">
            <button class="btn-call">
              <svg width="27" height="27" viewBox="0 0 27 27" fill="none">
                <path d="M16 11l4-4m0 0l-4-4m4 4H7" stroke="white" stroke-width="1.67" stroke-linecap="round"/>
              </svg>
            </button>
            <button class="btn-request">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <circle cx="7" cy="7" r="6" stroke="white" stroke-width="1.25"/>
              </svg>
              <span>Demandez maintenant.</span>
            </button>
            <button class="btn-report">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="white">
                <path d="M10 2l8 16H2L10 2z"/>
              </svg>
            </button>
          </div>

          <!-- Rating Summary -->
          <div class="rating-summary">
            <div class="rating-header">
              <div class="rating-score">
                <svg width="20" height="20" viewBox="0 0 20 20">
                  <path d="M10 2l2 6h6l-5 4 2 6-5-4-5 4 2-6-5-4h6l2-6z" fill="#F0B100"/>
                </svg>
                <span class="score">4.9</span>
              </div>
              <span class="review-count">127 avis</span>
            </div>

            <div class="rating-bars">
              <div class="rating-bar" v-for="star in [5,4,3,2,1]" :key="star">
                <span class="star-num">{{ star }}</span>
                <div class="bar-container">
                  <div class="bar-fill" :style="{width: getRatingWidth(star)}"></div>
                </div>
                <span class="percentage">{{ getRatingPercent(star) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Statistics Card -->
        <div class="stats-card">
          <h3 class="card-title">Statistiques</h3>
          <div class="stats-list">
            <div class="stat-item">
              <span class="stat-label">Taux de réponse</span>
              <span class="stat-value">98%</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Temps de réponse</span>
              <span class="stat-value">2h</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Projets complétés</span>
              <span class="stat-value">156</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Membre depuis</span>
              <span class="stat-value">2020</span>
            </div>
          </div>
        </div>

        <!-- Trust Badges -->
        <div class="trust-badges">
          <h4 class="badges-title">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <circle cx="10" cy="10" r="8" stroke="#00A63E" stroke-width="1.67"/>
              <path d="M7 10l2 2 4-4" stroke="#00A63E" stroke-width="1.67" stroke-linecap="round"/>
            </svg>
            <span>Badges de confiance</span>
          </h4>
          
          <div class="badge-item">
            <div class="badge-icon green">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8" stroke="white" stroke-width="1.67"/>
                <path d="M7 10l2 2 4-4" stroke="white" stroke-width="1.67" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="badge-info">
              <div class="badge-name">Identité vérifiée</div>
              <div class="badge-desc">Document officiel validé</div>
            </div>
          </div>

          <div class="badge-item">
            <div class="badge-icon blue">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8" stroke="white" stroke-width="1.67"/>
                <circle cx="10" cy="10" r="2" stroke="white" stroke-width="1.67"/>
              </svg>
            </div>
            <div class="badge-info">
              <div class="badge-name">Profession licenciée</div>
              <div class="badge-desc">License professionnelle valide</div>
            </div>
          </div>

          <div class="badge-item">
            <div class="badge-icon orange">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M10 2C6 2 3 5 3 9c0 5 7 9 7 9s7-4 7-9c0-4-3-7-7-7z" stroke="white" stroke-width="1.67"/>
              </svg>
            </div>
            <div class="badge-info">
              <div class="badge-name">Réponse rapide</div>
              <div class="badge-desc">Répond en moins de 2h</div>
            </div>
          </div>
        </div>
      </aside>

      <!-- RIGHT CONTENT -->
      <main class="profile-content">
        <!-- About Section -->
        <section class="content-card">
          <h3 class="section-title">À propos</h3>
          <p class="about-text">
            Expert en plomberie avec 15 ans d'expérience. Je prends en charge tous types d'interventions avec garantie de qualité.
          </p>
          
          <div class="service-types">
            <h4 class="subsection-title">Type de services</h4>
            <div class="service-tags">
              <span class="tag">Réparation de fuite</span>
              <span class="tag">Installation de robinet</span>
            </div>
          </div>
        </section>

        <!-- Project Gallery -->
        <section class="content-card">
          <h3 class="section-title">Galerie de projets</h3>
          <div class="project-gallery">
            <div class="gallery-item">
              <img src="https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&q=80" alt="Projet 1">
            </div>
            <div class="gallery-item">
              <img src="https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400&q=80" alt="Projet 2">
            </div>
            <div class="gallery-item">
              <img src="https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400&q=80" alt="Projet 3">
            </div>
            <div class="gallery-item">
              <img src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400&q=80" alt="Projet 4">
            </div>
          </div>
        </section>

        <!-- Certifications -->
        <section class="content-card certifications">
          <h3 class="section-title">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.67"/>
              <path d="M7 10l2 2 4-4" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
            </svg>
            <span>Certifications</span>
          </h3>
          
          <div class="cert-list">
            <div class="cert-item green-cert">
              <div class="cert-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" r="10" stroke="#00A63E" stroke-width="2"/>
                  <path d="M8 12l3 3 5-5" stroke="#00A63E" stroke-width="2" stroke-linecap="round"/>
                </svg>
              </div>
              <div class="cert-info">
                <div class="cert-name">Certification professionnelle de plomberie</div>
                <div class="cert-date">Délivrée en 2020</div>
              </div>
            </div>

            <div class="cert-item blue-cert">
              <div class="cert-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" r="10" stroke="#155DFC" stroke-width="2"/>
                  <path d="M8 12l3 3 5-5" stroke="#155DFC" stroke-width="2" stroke-linecap="round"/>
                </svg>
              </div>
              <div class="cert-info">
                <div class="cert-name">Formation en installation de chauffe-eau</div>
                <div class="cert-date">Délivrée en 2019</div>
              </div>
            </div>
          </div>
        </section>

        <!-- Booking Section -->
        <section class="content-card booking-section">
          <h3 class="section-title">Réserver un artisan</h3>
          <p class="booking-subtitle">Planifiez votre demande par date et heure</p>
          
          <div class="booking-form">
            <div class="form-group">
              <label class="form-label">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <rect x="3" y="4" width="14" height="13" rx="2" stroke="#FC5A15" stroke-width="1.67"/>
                  <path d="M7 2v4M13 2v4M3 8h14" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
                </svg>
                <span>Sélectionner une date</span>
              </label>
              <div class="date-input">
                <input type="text" placeholder="jj/mm/aaa" class="input-field">
                <svg width="27" height="27" viewBox="0 0 27 27" class="input-icon">
                  <rect x="3" y="5" width="21" height="18" rx="2" stroke="#FC5A15" stroke-width="2"/>
                  <circle cx="9" cy="13" r="1" fill="#FC5A15"/>
                  <circle cx="14" cy="13" r="1" fill="#FC5A15"/>
                  <circle cx="19" cy="13" r="1" fill="#FC5A15"/>
                </svg>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <circle cx="10" cy="10" r="7" stroke="#FC5A15" stroke-width="1.67"/>
                  <path d="M10 6v4l3 2" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
                </svg>
                <span>Sélectionner une heure</span>
              </label>
              <div class="date-input">
                <input type="text" placeholder="00:00" class="input-field">
                <svg width="27" height="27" viewBox="0 0 27 27" class="input-icon">
                  <circle cx="13.5" cy="13.5" r="10" stroke="#FC5A15" stroke-width="2"/>
                  <path d="M13.5 8v6l4 2" stroke="#FC5A15" stroke-width="2" stroke-linecap="round"/>
                </svg>
              </div>
            </div>

            <button class="btn-book">Demandez maintenant.</button>
          </div>
        </section>

        <!-- Payment Security -->
        <section class="content-card payment-section">
          <h3 class="section-title">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
              <rect x="3" y="6" width="18" height="13" rx="2" stroke="#FC5A15" stroke-width="2"/>
            </svg>
            <span>Paiement sécurisé</span>
          </h3>
          <p class="payment-desc">
            Vos paiements sont protégés par notre système d'entiercement jusqu'à la fin des travaux.
          </p>

          <!-- Payment Method -->
          <div class="payment-method">
            <div class="method-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <rect x="3" y="6" width="18" height="12" rx="2" stroke="#FC5A15" stroke-width="2"/>
                <path d="M3 10h18" stroke="#FC5A15" stroke-width="2"/>
              </svg>
            </div>
            <div class="method-info">
              <div class="method-name">Carte bancaire</div>
              <div class="method-types">Visa, Mastercard, Amex</div>
            </div>
          </div>

          <!-- Security Info -->
          <div class="security-info blue-info">
            <svg width="17" height="17" viewBox="0 0 17 17" fill="none">
              <rect x="2" y="5" width="13" height="10" rx="2" stroke="#155DFC" stroke-width="1.42"/>
            </svg>
            <div class="info-content">
              <div class="info-title">Protection Entiercement</div>
              <p class="info-text">
                Votre paiement est sécurisé dans un compte d'entiercement et n'est libéré qu'après validation du travail.
              </p>
            </div>
          </div>

          <!-- Cancellation Policy -->
          <div class="security-info yellow-info">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <circle cx="10" cy="10" r="8" stroke="#E17100" stroke-width="1.67"/>
              <path d="M10 6v4M10 14h.01" stroke="#E17100" stroke-width="1.67" stroke-linecap="round"/>
            </svg>
            <div class="info-content">
              <div class="info-title">Politique d'annulation</div>
              <ul class="policy-list">
                <li>• Annulation gratuite jusqu'à 24h avant le rendez-vous</li>
                <li>• Frais de 25% entre 24h et 12h avant</li>
                <li>• Frais de 50% moins de 12h avant</li>
                <li>• Remboursement complet si l'artisan annule</li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Reviews Section -->
        <section class="content-card reviews-section">
          <h3 class="section-title">Avis clients (4)</h3>
          
          <div class="reviews-list">
            <div class="review-item" v-for="review in reviews" :key="review.id">
              <div class="review-header">
                <div class="reviewer-avatar">{{ review.initial }}</div>
                <div class="reviewer-info">
                  <div class="reviewer-meta">
                    <div class="reviewer-details">
                      <div class="reviewer-name">{{ review.name }}</div>
                      <div class="review-time">{{ review.time }}</div>
                    </div>
                    <div class="review-stars">
                      <svg v-for="i in review.rating" :key="i" width="16" height="16" viewBox="0 0 16 16">
                        <path d="M8 2l1.5 4.5h4.5l-3.6 2.6 1.4 4.4L8 11l-3.8 2.5 1.4-4.4L2 6.5h4.5L8 2z" fill="#F0B100"/>
                      </svg>
                    </div>
                  </div>
                  <p class="review-text">{{ review.text }}</p>
                </div>
              </div>
            </div>
          </div>

          <button class="btn-leave-review">
            <span>Laisser un avis..</span>
            <svg width="21" height="21" viewBox="0 0 21 21" fill="none">
              <path d="M2 19l2-7L18 2l2 2L6 18l-4 1z" fill="#0047AB"/>
            </svg>
          </button>
        </section>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const ratings = {
  5: 75,
  4: 20,
  3: 5,
  2: 0,
  1: 0
}

const getRatingWidth = (star) => {
  return `${(ratings[star] / 100) * 100}%`
}

const getRatingPercent = (star) => {
  return `${ratings[star]}%`
}

const reviews = ref([
  {
    id: 1,
    initial: 'F',
    name: 'Fatima Zahra',
    time: 'Il y a 2 jours',
    rating: 5,
    text: 'Excellent travail! Très professionnel et ponctuel.'
  },
  {
    id: 2,
    initial: 'A',
    name: 'Ahmed Bennani',
    time: 'Il y a 1 semaine',
    rating: 5,
    text: 'Travail de qualité, finitions impeccables. Prix très correct.'
  },
  {
    id: 3,
    initial: 'K',
    name: 'Karim El Idrissi',
    time: 'Il y a 2 semaines',
    rating: 4,
    text: 'Bon artisan, quelques retards mais le résultat final est satisfaisant.'
  },
  {
    id: 4,
    initial: 'S',
    name: 'Samira Tahiri',
    time: 'Il y a 3 semaines',
    rating: 5,
    text: 'Très content du service. Explications claires et conseils utiles.'
  }
])
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;600&family=Inter:wght@400;500&display=swap');

.artisan-profile-page {
  font-family: 'Open Sans', sans-serif;
  background: #fff;
  min-height: 100vh;
  padding-bottom: 60px;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  cursor: pointer;
  padding: 0;
  margin: 134px 0 0 96px;
}

.profile-container {
  width: 1248px;
  max-width: calc(100% - 48px);
  margin: 56px auto 0;
  display: flex;
  gap: 32px;
}

/* ══════════════════════════════════════════════════════════════
   LEFT SIDEBAR
   ══════════════════════════════════════════════════════════════ */

.profile-sidebar {
  width: 395px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.profile-card {
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1);
  border-radius: 14px;
  padding: 24px 24px 0;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.profile-avatar {
  width: 128px;
  height: 128px;
  border-radius: 50%;
  border: 4px solid rgba(252,90,21,0.2);
  object-fit: cover;
  margin-bottom: 16px;
}

.profile-name {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 700;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0 0 4px;
}

.profile-specialty {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 500;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0 0 8px;
}

.profile-location {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  margin-bottom: 16px;
}

.profile-badge {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  background: #DCFCE7;
  border-radius: 999px;
  padding: 4px 12px 4px 12px;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #008236;
}

.profile-actions {
  display: flex;
  justify-content: center;
  gap: 5px;
  padding: 0 24px;
}

.btn-call {
  width: 45px;
  height: 40px;
  background: #02BB05;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.btn-request {
  flex: 1;
  height: 40px;
  background: #FC5A15;
  border: none;
  border-radius: 8px;
  font-family: 'Montserrat', sans-serif;
  font-size: 13.35px;
  font-weight: 600;
  line-height: 20px;
  letter-spacing: -0.26px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.btn-report {
  width: 40px;
  height: 40px;
  background: #FF0000;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.rating-summary {
  padding: 17px 0 0;
  border-top: 1px solid #F3F4F6;
}

.rating-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.rating-score {
  display: flex;
  align-items: center;
  gap: 4px;
}

.score {
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #314158;
}

.review-count {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.rating-bars {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rating-bar {
  display: flex;
  align-items: center;
  gap: 8px;
}

.star-num {
  width: 12px;
  font-size: 12px;
  line-height: 16px;
  color: #62748E;
}

.bar-container {
  flex: 1;
  height: 8px;
  background: #F3F4F6;
  border-radius: 999px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  background: #0047AB;
  border-radius: 999px;
}

.percentage {
  width: 26px;
  font-size: 12px;
  line-height: 16px;
  color: #62748E;
  text-align: right;
}

/* Stats Card */
.stats-card {
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1);
  border-radius: 14px;
  padding: 24px 24px 0;
}

.card-title {
  font-size: 18px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0 0 16px;
}

.stats-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-label {
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.stat-value {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 700;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

/* Trust Badges */
.trust-badges {
  background: linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%);
  border: 1px solid #B9F8CF;
  box-shadow: 0 1px 5px rgba(0,0,0,0.25);
  border-radius: 14px;
  padding: 25px 25px 1px;
}

.badges-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 18px;
  line-height: 27px;
  letter-spacing: -0.44px;
  color: #314158;
  margin: 0 0 16px;
}

.badge-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border-radius: 14px;
  padding: 12px;
  margin-bottom: 12px;
}

.badge-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.badge-icon.green { background: #00C950; }
.badge-icon.blue { background: #2B7FFF; }
.badge-icon.orange { background: #FF6900; }

.badge-info {
  flex: 1;
}

.badge-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 21px;
  letter-spacing: -0.15px;
  color: #314158;
}

.badge-desc {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 18px;
  color: #62748E;
}

/* ══════════════════════════════════════════════════════════════
   RIGHT CONTENT
   ══════════════════════════════════════════════════════════════ */

.profile-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 21px;
}

.content-card {
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1);
  border-radius: 14px;
  padding: 24px;
}

.section-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 18px;
  font-weight: 600;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0 0 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.about-text {
  font-size: 16px;
  line-height: 26px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0 0 16px;
}

.service-types {
  padding-top: 17px;
  border-top: 1px solid #F3F4F6;
}

.subsection-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 600;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0 0 12px;
}

.service-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 9px;
}

.tag {
  background: rgba(252,90,21,0.1);
  border-radius: 999px;
  padding: 4px 12px;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #FC5A15;
}

/* Project Gallery */
.project-gallery {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.gallery-item {
  aspect-ratio: 1;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);
}

.gallery-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Certifications */
.certifications {
  border: 1px solid #F3F4F6;
  box-shadow: 0 1px 4px rgba(0,0,0,0.11);
}

.cert-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cert-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 0 0 16px;
  height: 82px;
  border-radius: 10px;
}

.cert-item.green-cert {
  background: #F0FDF4;
  border: 1px solid #B9F8CF;
}

.cert-item.blue-cert {
  background: #EFF6FF;
  border: 1px solid #BEDBFF;
}

.cert-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.green-cert .cert-icon { background: #DCFCE7; }
.blue-cert .cert-icon { background: #DBEAFE; }

.cert-info {
  flex: 1;
}

.cert-name {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.cert-date {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

/* Booking Section */
.booking-subtitle {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0 0 16px;
}

.booking-form {
  padding-top: 25px;
  border-top: 1px solid #F3F4F6;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Montserrat', sans-serif;
  font-size: 18px;
  font-weight: 700;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.date-input {
  position: relative;
}

.input-field {
  width: 100%;
  height: 42px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  padding: 11px 50px 11px 19px;
  font-size: 18px;
  line-height: 17px;
  letter-spacing: 0.04px;
  color: #62748E;
}

.input-icon {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
}

.btn-book {
  grid-column: 1 / -1;
  height: 48px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 700;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: white;
  cursor: pointer;
}

/* Payment Section */
.payment-desc {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0 0 24px;
}

.payment-method {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 0 0 16px;
  height: 80px;
  background: white;
  border: 2px solid #E5E7EB;
  border-radius: 10px;
  margin-bottom: 16px;
}

.method-icon {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
}

.method-info {
  flex: 1;
}

.method-name {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 700;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.method-types {
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.security-info {
  display: flex;
  gap: 12px;
  padding: 17px 17px 1px;
  border-radius: 10px;
  margin-bottom: 16px;
}

.security-info.blue-info {
  background: #EFF6FF;
  border: 1px solid #BEDBFF;
}

.security-info.yellow-info {
  background: #FFFBEB;
  border: 1px solid #FEE685;
}

.security-info svg {
  flex-shrink: 0;
  margin-top: 2px;
}

.info-content {
  flex: 1;
}

.info-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #314158;
  margin-bottom: 4px;
}

.info-text {
  font-size: 12px;
  line-height: 16px;
  color: #62748E;
  margin: 0;
}

.policy-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.policy-list li {
  font-size: 12px;
  line-height: 16px;
  color: #62748E;
  margin-bottom: 4px;
}

/* Reviews Section */
.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 24px;
}

.review-item {
  padding-bottom: 24px;
  border-bottom: 1px solid #F3F4F6;
}

.review-item:last-child {
  border-bottom: none;
}

.review-header {
  display: flex;
  gap: 16px;
}

.reviewer-avatar {
  width: 48px;
  height: 48px;
  background: #FC5A15;
  border-radius: 50%;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  flex-shrink: 0;
}

.reviewer-info {
  flex: 1;
}

.reviewer-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.reviewer-name {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.review-time {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.review-stars {
  display: flex;
  gap: 4px;
}

.review-text {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

.btn-leave-review {
  width: 100%;
  height: 50px;
  background: white;
  border: 1px solid #0047AB;
  border-radius: 10px;
  font-size: 16px;
  line-height: 24px;
  text-align: center;
  letter-spacing: -0.31px;
  color: #58595B;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
}

/* ══════════════════════════════════════════════════════════════
   RESPONSIVE
   ══════════════════════════════════════════════════════════════ */

@media (max-width: 1200px) {
  .profile-container {
    flex-direction: column;
  }
  
  .profile-sidebar {
    width: 100%;
  }
  
  .project-gallery {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .booking-form {
    grid-template-columns: 1fr;
  }
  
  .project-gallery {
    grid-template-columns: 1fr;
  }
}
</style>
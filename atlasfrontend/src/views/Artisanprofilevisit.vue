<template>
  <div class="apv-page">

    <!-- ── Loading ─────────────────────────────────────────────────────── -->
    <div v-if="loading" class="apv-state">
      <div class="spinner"></div>
      <p>Chargement du profil…</p>
    </div>

    <!-- ── Error ───────────────────────────────────────────────────────── -->
    <div v-else-if="error" class="apv-state">
      <p>{{ error }}</p>
      <button class="btn-retry" @click="fetchProfile">Réessayer</button>
    </div>

    <template v-else>
      <!-- Back button -->
      <div class="apv-back-wrap">
        <button class="apv-back" @click="$router.back()">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M12.5 15l-5-5 5-5" stroke="#62748E" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour à la liste
        </button>
      </div>

      <div class="apv-layout">

        <!-- ══════════════════════════════════════════════════════════════
             LEFT SIDEBAR
        ══════════════════════════════════════════════════════════════ -->
        <aside class="apv-sidebar">

          <!-- Profile card -->
          <div class="apv-card profile-card">
            <div class="profile-header">
              <!-- Avatar -->
              <div class="avatar-ring">
                <img v-if="artisan.avatar" :src="artisan.avatar" :alt="artisan.name" class="avatar-img" />
                <div v-else class="avatar-initials" :style="{ background: avatarColor(artisan.name) }">
                  {{ initials(artisan.name) }}
                </div>
              </div>

              <h2 class="profile-name">{{ artisan.name }}</h2>
              <p class="profile-specialty">{{ artisan.specialty }}</p>

              <div class="profile-location">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 2a4 4 0 0 0-4 4c0 3 4 6 4 6s4-3 4-6a4 4 0 0 0-4-4z" stroke="#62748E" stroke-width="1.33"/>
                  <circle cx="8" cy="6" r="1.5" stroke="#62748E" stroke-width="1.33"/>
                </svg>
                <span>{{ artisan.city }}</span>
              </div>

              <span v-if="artisan.verified" class="badge-verified">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <circle cx="8" cy="8" r="7" stroke="#008236" stroke-width="1.33"/>
                  <path d="M5.5 8l2 2 3-3" stroke="#008236" stroke-width="1.33" stroke-linecap="round"/>
                </svg>
                Profil vérifié
              </span>

              <span class="badge-atelier" v-if="artisan.experience_years">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <circle cx="8" cy="8" r="7" stroke="#155DFC" stroke-width="1.33"/>
                  <path d="M8 5v3l2 1" stroke="#155DFC" stroke-width="1.33" stroke-linecap="round"/>
                </svg>
                Option dépôt en atelier disponible
              </span>
            </div>

            <!-- Action buttons -->
            <div class="profile-actions">
              <button class="btn-call" title="Appeler">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.67">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z" stroke-linejoin="round"/>
                </svg>
              </button>
              <button class="btn-request" @click="scrollToBooking">
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                  <circle cx="7" cy="7" r="6" stroke="white" stroke-width="1.25"/>
                  <path d="M7 4v3l2 1" stroke="white" stroke-width="1.25" stroke-linecap="round"/>
                </svg>
                Demandez maintenant.
              </button>
              <button class="btn-report" title="Signaler">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke-width="1.8">
                  <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12" stroke-linecap="round"/>
                  <circle cx="12" cy="16" r="0.6" fill="#EF4444"/>
                </svg>
              </button>
            </div>

            <!-- Rating summary -->
            <div class="rating-summary">
              <div class="rating-top">
                <div class="rating-score-wrap">
                  <svg width="20" height="20" viewBox="0 0 20 20">
                    <path d="M10 2l2 6h6l-5 4 2 6-5-4-5 4 2-6-5-4h6l2-6z" fill="#F0B100"/>
                  </svg>
                  <span class="rating-score">{{ artisan.rating.toFixed(1) }}</span>
                </div>
                <span class="rating-count">{{ artisan.reviews_count }} avis</span>
              </div>
              <div class="rating-bars">
                <div v-for="star in [5,4,3,2,1]" :key="star" class="rating-bar-row">
                  <span class="bar-star">{{ star }}</span>
                  <div class="bar-track">
                    <div class="bar-fill" :style="{ width: (artisan.rating_breakdown?.[star]?.percent ?? 0) + '%' }"></div>
                  </div>
                  <span class="bar-pct">{{ artisan.rating_breakdown?.[star]?.percent ?? 0 }}%</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Statistics card -->
          <div class="apv-card stats-card">
            <h3 class="card-title">Statistiques</h3>
            <div class="stats-list">
              <div class="stat-row">
                <span class="stat-lbl">Taux de réponse</span>
                <span class="stat-val">{{ artisan.response_rate ?? 98 }}%</span>
              </div>
              <div v-if="artisan.experience_years" class="stat-row">
                <span class="stat-lbl">Expérience</span>
                <span class="stat-val">{{ artisan.experience_years }} ans</span>
              </div>
              <div class="stat-row">
                <span class="stat-lbl">Projets complétés</span>
                <span class="stat-val">{{ artisan.jobs_completed }}</span>
              </div>
              <div v-if="artisan.member_since" class="stat-row">
                <span class="stat-lbl">Membre depuis</span>
                <span class="stat-val">{{ artisan.member_since }}</span>
              </div>
            </div>
          </div>

          <!-- Trust badges -->
          <div class="trust-badges-card">
            <h4 class="trust-title">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8" stroke="#00A63E" stroke-width="1.67"/>
                <path d="M7 10l2 2 4-4" stroke="#00A63E" stroke-width="1.67" stroke-linecap="round"/>
              </svg>
              Badges de confiance
            </h4>
            <div class="trust-item">
              <div class="trust-icon green-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <circle cx="10" cy="10" r="8" stroke="white" stroke-width="1.67"/>
                  <path d="M7 10l2 2 4-4" stroke="white" stroke-width="1.67" stroke-linecap="round"/>
                </svg>
              </div>
              <div class="trust-info">
                <div class="trust-name">Identité vérifiée</div>
                <div class="trust-desc">Document officiel validé</div>
              </div>
            </div>
            <div class="trust-item">
              <div class="trust-icon blue-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <circle cx="10" cy="10" r="8" stroke="white" stroke-width="1.67"/>
                  <path d="M10 6v4M10 14h.01" stroke="white" stroke-width="1.67" stroke-linecap="round"/>
                </svg>
              </div>
              <div class="trust-info">
                <div class="trust-name">Profession licenciée</div>
                <div class="trust-desc">License professionnelle valide</div>
              </div>
            </div>
            <div class="trust-item">
              <div class="trust-icon orange-icon">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <path d="M10 2C7 2 4.5 4.5 4.5 7.5c0 4 5.5 8.5 5.5 8.5s5.5-4.5 5.5-8.5C15.5 4.5 13 2 10 2z" stroke="white" stroke-width="1.67"/>
                </svg>
              </div>
              <div class="trust-info">
                <div class="trust-name">Réponse rapide</div>
                <div class="trust-desc">Répond en moins de 2h</div>
              </div>
            </div>
          </div>

        </aside>

        <!-- ══════════════════════════════════════════════════════════════
             RIGHT CONTENT
        ══════════════════════════════════════════════════════════════ -->
        <main class="apv-content">

          <!-- À propos -->
          <div class="apv-card">
            <h3 class="section-title">À propos</h3>
            <p class="about-text">{{ artisan.bio }}</p>
            <div v-if="artisan.services && artisan.services.length" class="service-types-section">
              <h4 class="sub-title">Type de services</h4>
              <div class="service-tags">
                <span v-for="s in artisan.services" :key="s.id" class="service-tag">{{ s.name }}</span>
              </div>
            </div>
          </div>

          <!-- Galerie de projets -->
          <div v-if="artisan.portfolio && artisan.portfolio.length" class="apv-card">
            <h3 class="section-title">Galerie de projets</h3>
            <div class="gallery-grid">
              <div v-for="photo in artisan.portfolio" :key="photo.id" class="gallery-item">
                <img :src="photo.url" :alt="artisan.name" />
              </div>
            </div>
          </div>

          <!-- Certifications -->
          <div v-if="artisan.certifications && artisan.certifications.length" class="apv-card apv-card--bordered">
            <h3 class="section-title">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.67"/>
                <path d="M7 10l2 2 4-4" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
              </svg>
              Certifications
            </h3>
            <div class="cert-list">
              <div
                v-for="(cert, i) in artisan.certifications"
                :key="cert.id"
                class="cert-item"
                :class="i % 2 === 0 ? 'cert-green' : 'cert-blue'"
              >
                <div class="cert-icon" :class="i % 2 === 0 ? 'cert-icon-green' : 'cert-icon-blue'">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="10" :stroke="i % 2 === 0 ? '#00A63E' : '#155DFC'" stroke-width="2"/>
                    <path d="M8 12l3 3 5-5" :stroke="i % 2 === 0 ? '#00A63E' : '#155DFC'" stroke-width="2" stroke-linecap="round"/>
                  </svg>
                </div>
                <div class="cert-info">
                  <div class="cert-name">{{ cert.name }}</div>
                  <div v-if="cert.issued_at" class="cert-date">Délivrée en {{ new Date(cert.issued_at).getFullYear() }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Réserver un artisan -->
          <div class="apv-card booking-card">
            <h3 class="section-title">Réserver un artisan</h3>
            <p class="booking-subtitle">Planifiez votre demande par date et heure</p>

            <div class="booking-form">
              <!-- Date -->
              <div class="booking-field">
                <label class="field-label">
                  <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                    <rect x="3" y="4" width="14" height="13" rx="2" stroke="#FC5A15" stroke-width="1.67"/>
                    <path d="M7 2v4M13 2v4M3 8h14" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
                  </svg>
                  Sélectionner une date
                </label>
                <div class="field-input-wrap">
                  <input v-model="bookingDate" type="date" class="field-input" :min="today" />
                </div>
              </div>

              <!-- Time -->
              <div class="booking-field">
                <label class="field-label">
                  <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                    <circle cx="10" cy="10" r="7" stroke="#FC5A15" stroke-width="1.67"/>
                    <path d="M10 6v4l3 2" stroke="#FC5A15" stroke-width="1.67" stroke-linecap="round"/>
                  </svg>
                  Sélectionner une heure
                </label>
                <div class="field-input-wrap">
                  <input v-model="bookingTime" type="time" class="field-input" />
                </div>
              </div>

              <!-- Validation error -->
              <p v-if="bookingError" class="booking-error">{{ bookingError }}</p>

              <!-- Submit -->
              <button class="btn-book" @click="submitBooking" :disabled="bookingSubmitting">
                {{ bookingSubmitting ? 'Envoi en cours…' : 'Demandez maintenant.' }}
              </button>
            </div>
          </div>

          <!-- Paiement sécurisé -->
          <div class="apv-card payment-card">
            <h3 class="section-title">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <rect x="3" y="6" width="18" height="13" rx="2" stroke="#FC5A15" stroke-width="2"/>
                <path d="M3 10h18" stroke="#FC5A15" stroke-width="2"/>
              </svg>
              Paiement sécurisé
            </h3>
            <p class="payment-desc">
              Vos paiements sont protégés par notre système d'entiercement jusqu'à la fin des travaux.
            </p>

            <!-- Card method -->
            <div class="payment-method">
              <div class="method-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <rect x="3" y="6" width="18" height="12" rx="2" stroke="#FC5A15" stroke-width="2"/>
                  <path d="M3 10h18" stroke="#FC5A15" stroke-width="2"/>
                </svg>
              </div>
              <div>
                <div class="method-name">Carte bancaire</div>
                <div class="method-types">Visa, Mastercard, Amex</div>
              </div>
            </div>

            <!-- Escrow info -->
            <div class="info-box info-box--blue">
              <svg width="17" height="17" viewBox="0 0 17 17" fill="none">
                <rect x="2" y="5" width="13" height="10" rx="2" stroke="#155DFC" stroke-width="1.42"/>
                <path d="M2 9h13" stroke="#155DFC" stroke-width="1.42"/>
              </svg>
              <div>
                <div class="info-title">Protection Entiercement</div>
                <p class="info-text">Votre paiement est sécurisé dans un compte d'entiercement et n'est libéré qu'après validation du travail.</p>
              </div>
            </div>

            <!-- Cancellation policy -->
            <div class="info-box info-box--yellow">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8" stroke="#E17100" stroke-width="1.67"/>
                <path d="M10 6v4M10 14h.01" stroke="#E17100" stroke-width="1.67" stroke-linecap="round"/>
              </svg>
              <div>
                <div class="info-title">Politique d'annulation</div>
                <ul class="policy-list">
                  <li>Annulation gratuite jusqu'à 24h avant le rendez-vous</li>
                  <li>Frais de 25% entre 24h et 12h avant</li>
                  <li>Frais de 50% moins de 12h avant</li>
                  <li>Remboursement complet si l'artisan annule</li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Avis clients -->
          <div class="apv-card reviews-card">
            <h3 class="section-title">Avis clients ({{ artisan.reviews_count }})</h3>

            <div v-if="artisan.reviews && artisan.reviews.length" class="reviews-list">
              <div v-for="rev in artisan.reviews" :key="rev.id" class="review-item">
                <div class="review-header">
                  <!-- Avatar -->
                  <div class="review-avatar" :style="{ background: avatarColor(rev.client.name) }">
                    {{ rev.client.avatar ? '' : initials(rev.client.name) }}
                    <img v-if="rev.client.avatar" :src="rev.client.avatar" :alt="rev.client.name" class="review-avatar-img" />
                  </div>
                  <div class="review-body">
                    <div class="review-top">
                      <div>
                        <div class="reviewer-name">{{ rev.client.name }}</div>
                        <div class="review-date">{{ timeAgo(rev.created_at) }}</div>
                      </div>
                      <div class="review-stars">
                        <svg v-for="i in 5" :key="i" width="16" height="16" viewBox="0 0 16 16">
                          <path d="M8 2l1.5 4.5h4.5l-3.6 2.6 1.4 4.4L8 11l-3.8 2.5 1.4-4.4L2 6.5h4.5L8 2z"
                            :fill="i <= rev.rating ? '#F0B100' : '#E5E7EB'"/>
                        </svg>
                      </div>
                    </div>
                    <p class="review-text">{{ rev.comment }}</p>
                  </div>
                </div>
              </div>
            </div>

            <div v-else class="reviews-empty">
              <p>Aucun avis pour le moment.</p>
            </div>

            <!-- Review action – shown based on eligibility status -->
            <div v-if="reviewStatus === 'loading'" class="review-status-msg">
              <div class="spinner-sm"></div>
              <span>Vérification…</span>
            </div>

            <div v-else-if="reviewStatus === 'not_logged_in'" class="review-warning-box">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E17100" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01" stroke-linecap="round"/>
              </svg>
              <div>
                <div class="review-warning-title">Connexion requise</div>
                <p class="review-warning-text">Connectez-vous pour laisser un avis sur cet artisan.</p>
                <button class="btn-login-review" @click="$router.push('/login')">Se connecter</button>
              </div>
            </div>

            <div v-else-if="reviewStatus === 'not_worked'" class="review-warning-box">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E17100" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01" stroke-linecap="round"/>
              </svg>
              <div>
                <div class="review-warning-title">Avis non disponible</div>
                <p class="review-warning-text">Vous devez avoir complété une demande avec cet artisan pour pouvoir laisser un avis.</p>
              </div>
            </div>

            <div v-else-if="reviewStatus === 'already_reviewed'" class="review-success-box">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#16A34A" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><path d="M8 12l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <span>Vous avez déjà laissé un avis pour cet artisan.</span>
            </div>

            <button v-else-if="reviewStatus === 'worked'" class="btn-leave-review" @click="showReviewModal = true">
              <span>Laisser un avis..</span>
              <svg width="21" height="21" viewBox="0 0 21 21" fill="none">
                <path d="M2 19l2-7L18 2l2 2L6 18l-4 1z" fill="#0047AB"/>
              </svg>
            </button>
          </div>

        </main>
      </div>
    </template>

  <!-- ── Review modal ──────────────────────────────────────────────────────── -->
  <transition name="modal-fade">
    <div v-if="showReviewModal" class="modal-overlay" @click.self="showReviewModal = false">
      <div class="modal-card">

        <!-- Blue header -->
        <div class="modal-header" style="background: linear-gradient(135deg, #1D4ED8, #2563EB)">
          <div class="modal-check">
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <circle cx="14" cy="14" r="13" stroke="white" stroke-width="1.5" stroke-opacity="0.5"/>
              <path d="M14 7l1.8 5.4h5.4l-4.4 3.2 1.7 5.3L14 18l-4.5 2.9 1.7-5.3L6.8 12.4h5.4L14 7z" fill="white"/>
            </svg>
          </div>
          <div>
            <p class="modal-title">Laisser un avis</p>
            <p class="modal-artisan">{{ artisan.name }}</p>
          </div>
        </div>

        <!-- Body -->
        <div class="modal-body">
          <!-- Star rating picker -->
          <div class="star-selector">
            <p class="star-label">Votre note</p>
            <div class="stars-row">
              <button
                v-for="i in 5"
                :key="i"
                class="star-btn"
                @click="reviewRating = i"
              >
                <svg width="34" height="34" viewBox="0 0 24 24">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"
                    :fill="i <= reviewRating ? '#F0B100' : '#E5E7EB'" stroke="none"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- Comment -->
          <textarea
            v-model="reviewComment"
            class="review-textarea"
            rows="4"
            placeholder="Partagez votre expérience avec cet artisan…"
          ></textarea>

          <!-- Error -->
          <p v-if="reviewError" class="booking-error" style="margin-top:8px">{{ reviewError }}</p>

          <div class="modal-actions" style="margin-top:16px">
            <button class="modal-btn-cancel" @click="showReviewModal = false">Annuler</button>
            <button class="modal-btn-pay" @click="submitReview" :disabled="reviewSubmitting">
              {{ reviewSubmitting ? 'Envoi…' : 'Soumettre' }}
            </button>
          </div>
        </div>

      </div>
    </div>
  </transition>

  <!-- ── Toast ──────────────────────────────────────────────────────────────── -->
  <transition name="toast-fade">
    <div v-if="toastVisible" class="apv-toast">{{ toastMessage }}</div>
  </transition>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route  = useRoute()
const router = useRouter()

const loading = ref(true)
const error   = ref(null)
const artisan = ref({
  name: '', avatar: null, city: '', bio: '', specialty: '',
  rating: 0, reviews_count: 0, rating_breakdown: {},
  verified: false, experience_years: null,
  jobs_completed: 0, response_rate: 98, member_since: null,
  category_id: null,
  portfolio: [], certifications: [], services: [], reviews: [],
})

// ── Booking ──────────────────────────────────────────────────────────────────
const bookingDate       = ref('')
const bookingTime       = ref('')
const bookingError      = ref('')
const bookingSubmitting = ref(false)
const today = new Date().toISOString().split('T')[0]

// ── Review eligibility ───────────────────────────────────────────────────────
// null | 'loading' | 'not_logged_in' | 'not_worked' | 'worked' | 'already_reviewed'
const reviewStatus           = ref(null)
const reviewServiceRequestId = ref(null)
const showReviewModal        = ref(false)
const reviewRating           = ref(0)
const reviewComment          = ref('')
const reviewSubmitting       = ref(false)
const reviewError            = ref('')

// ── Toast ─────────────────────────────────────────────────────────────────────
const toastMessage = ref('')
const toastVisible = ref(false)
let _toastTimer = null
function showToast(msg) {
  clearTimeout(_toastTimer)
  toastMessage.value = msg
  toastVisible.value = true
  _toastTimer = setTimeout(() => { toastVisible.value = false }, 3000)
}

// ── Axios instance ───────────────────────────────────────────────────────────
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
})
api.interceptors.request.use(cfg => {
  const t = localStorage.getItem('token')
  if (t) cfg.headers.Authorization = `Bearer ${t}`
  return cfg
})
api.interceptors.response.use(
  r => r,
  err => {
    if (err.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

// ── Fetch artisan profile ────────────────────────────────────────────────────
async function fetchProfile() {
  loading.value = true
  error.value   = null
  try {
    const { data } = await api.get(`/public/artisans/${route.params.id}`)
    artisan.value = data.data
  } catch {
    error.value = 'Profil introuvable.'
  } finally {
    loading.value = false
  }
}

// ── Booking: create service request directly ─────────────────────────────────
function scrollToBooking() {
  document.querySelector('.booking-card')?.scrollIntoView({ behavior: 'smooth' })
}

async function submitBooking() {
  bookingError.value = ''
  const token = localStorage.getItem('token')
  if (!token) { router.push('/login'); return }

  if (!bookingDate.value) {
    bookingError.value = 'Veuillez sélectionner une date.'
    return
  }
  if (!bookingTime.value) {
    bookingError.value = 'Veuillez sélectionner une heure.'
    return
  }

  const serviceTypeId = artisan.value.services?.[0]?.id ?? null

  if (!artisan.value.category_id) {
    bookingError.value = 'Impossible de réserver cet artisan pour le moment. Contactez-le via la messagerie.'
    return
  }

  bookingSubmitting.value = true
  try {
    await api.post('/client/service-requests', {
      service_category_id: artisan.value.category_id,
      service_type_id:     serviceTypeId,
      city:                artisan.value.city || 'Maroc',
      notes:               `Date souhaitée: ${bookingDate.value} à ${bookingTime.value}`,
      target_artisan_id:   artisan.value.id,
      request_type:        'direct',
    })
    showToast('Demande envoyée avec succès !')
    bookingDate.value = ''
    bookingTime.value = ''
    setTimeout(() => router.push('/client/mes-demandes'), 1800)
  } catch (e) {
    bookingError.value = e.response?.data?.error || e.response?.data?.message || 'Impossible d\'envoyer la demande.'
  } finally {
    bookingSubmitting.value = false
  }
}

// ── Review eligibility check ─────────────────────────────────────────────────
async function checkReviewEligibility() {
  reviewStatus.value = 'loading'
  try {
    const { data } = await api.get(`/client/artisans/${route.params.id}/worked-with`)
    if (data.already_reviewed) {
      reviewStatus.value = 'already_reviewed'
    } else if (data.worked_together) {
      reviewStatus.value           = 'worked'
      reviewServiceRequestId.value = data.service_request_id
    } else {
      reviewStatus.value = 'not_worked'
    }
  } catch {
    reviewStatus.value = 'not_worked'
  }
}

// ── Submit review ─────────────────────────────────────────────────────────────
async function submitReview() {
  reviewError.value = ''
  if (!reviewRating.value) {
    reviewError.value = 'Veuillez sélectionner une note.'
    return
  }
  reviewSubmitting.value = true
  try {
    await api.post(`/client/artisans/${route.params.id}/reviews`, {
      rating:             reviewRating.value,
      comment:            reviewComment.value.trim() || null,
      service_request_id: reviewServiceRequestId.value,
    })
    showReviewModal.value = false
    reviewStatus.value    = 'already_reviewed'
    reviewRating.value    = 0
    reviewComment.value   = ''
    showToast('Avis soumis avec succès. Merci !')
    await fetchProfile()
  } catch (e) {
    reviewError.value = e.response?.data?.error || 'Impossible de soumettre votre avis.'
  } finally {
    reviewSubmitting.value = false
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
const COLORS = ['#FC5A15', '#3B82F6', '#8B5CF6', '#10B981', '#F59E0B', '#EF4444', '#06B6D4', '#84CC16']
function avatarColor(name) {
  if (!name) return COLORS[0]
  let h = 0
  for (const c of name) h = (h * 31 + c.charCodeAt(0)) % COLORS.length
  return COLORS[h]
}
function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}
function timeAgo(iso) {
  if (!iso) return ''
  const diff = Math.floor((Date.now() - new Date(iso)) / 86400000)
  if (diff === 0) return "Aujourd'hui"
  if (diff === 1) return 'Hier'
  if (diff < 7)   return `Il y a ${diff} jours`
  if (diff < 30)  return `Il y a ${Math.floor(diff / 7)} semaine${Math.floor(diff / 7) > 1 ? 's' : ''}`
  if (diff < 365) return `Il y a ${Math.floor(diff / 30)} mois`
  return `Il y a ${Math.floor(diff / 365)} an${Math.floor(diff / 365) > 1 ? 's' : ''}`
}

onMounted(async () => {
  await fetchProfile()
  const token = localStorage.getItem('token')
  if (token) {
    checkReviewEligibility()
  } else {
    reviewStatus.value = 'not_logged_in'
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Open+Sans:wght@400;600&family=Inter:wght@400;500;600&family=Poppins:wght@400;500;600&display=swap');

/* ── Base ──────────────────────────────────────────────────────────────────── */
.apv-page {
  font-family: 'Open Sans', sans-serif;
  background: #F8FAFC;
  min-height: 100vh;
  padding-bottom: 80px;
}

/* ── Loading / Error ──────────────────────────────────────────────────────── */
.apv-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  gap: 16px;
  color: #62748E;
  font-size: 16px;
}
.spinner {
  width: 36px;
  height: 36px;
  border: 3px solid #E8ECF0;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.btn-retry {
  padding: 10px 24px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Inter', sans-serif;
  font-weight: 600;
  font-size: 14px;
  transition: background 0.15s;
}
.btn-retry:hover { background: #e04e0e; }

/* ── Back button ──────────────────────────────────────────────────────────── */
.apv-back-wrap {
  max-width: 1296px;
  margin: 0 auto;
  padding: 28px 24px 0;
}
.apv-back {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 500;
  color: #62748E;
  cursor: pointer;
  padding: 6px 0;
  transition: color 0.15s;
}
.apv-back:hover { color: #314158; }

/* ── Layout ───────────────────────────────────────────────────────────────── */
.apv-layout {
  display: flex;
  gap: 28px;
  max-width: 1296px;
  margin: 24px auto 0;
  padding: 0 24px;
  align-items: flex-start;
}

/* ── Sidebar ──────────────────────────────────────────────────────────────── */
.apv-sidebar {
  width: 380px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ── Cards ────────────────────────────────────────────────────────────────── */
.apv-card {
  background: #fff;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 1px 2px -1px rgba(0,0,0,0.06);
  border-radius: 16px;
  padding: 24px;
}
.apv-card--bordered {
  border: 1px solid #F0F2F5;
}

/* ── Profile card ─────────────────────────────────────────────────────────── */
.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.avatar-ring {
  margin-bottom: 16px;
}
.avatar-img {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 4px solid rgba(252,90,21,0.18);
  object-fit: cover;
  box-shadow: 0 4px 16px rgba(252,90,21,0.12);
}
.avatar-initials {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 34px;
  font-weight: 700;
  border: 4px solid rgba(252,90,21,0.18);
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
  font-family: 'Montserrat', sans-serif;
}

.profile-name {
  font-family: 'Montserrat', sans-serif;
  font-size: 18px;
  font-weight: 700;
  color: #1E293B;
  margin: 0 0 4px;
}
.profile-specialty {
  font-family: 'Poppins', sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #FC5A15;
  margin: 0 0 10px;
}
.profile-location {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #62748E;
  margin-bottom: 14px;
}

.badge-verified {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #DCFCE7;
  border: 1px solid #BBF7D0;
  border-radius: 999px;
  padding: 4px 12px;
  font-size: 13px;
  font-weight: 600;
  color: #15803D;
  margin-bottom: 8px;
  font-family: 'Inter', sans-serif;
}
.badge-atelier {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #EFF6FF;
  border: 1px solid #BFDBFE;
  border-radius: 999px;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 500;
  color: #1D4ED8;
  margin-bottom: 16px;
  font-family: 'Inter', sans-serif;
}

/* ── Action buttons ───────────────────────────────────────────────────────── */
.profile-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 16px 0;
  border-top: 1px solid #F1F5F9;
  border-bottom: 1px solid #F1F5F9;
  margin: 4px 0 0;
}
.btn-call {
  width: 44px;
  height: 42px;
  background: #16A34A;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: background 0.15s;
}
.btn-call:hover { background: #15803D; }
.btn-request {
  flex: 1;
  height: 42px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  font-family: 'Poppins', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: background 0.15s, transform 0.1s;
}
.btn-request:hover  { background: #e04e0e; }
.btn-request:active { transform: scale(0.98); }
.btn-report {
  width: 44px;
  height: 42px;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: background 0.15s;
}
.btn-report:hover { background: #FEE2E2; }
.btn-report svg { stroke: #EF4444; }

/* ── Rating summary ───────────────────────────────────────────────────────── */
.rating-summary {
  padding: 16px 0 0;
}
.rating-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.rating-score-wrap {
  display: flex;
  align-items: center;
  gap: 6px;
}
.rating-score {
  font-family: 'Montserrat', sans-serif;
  font-size: 26px;
  font-weight: 700;
  color: #1E293B;
  line-height: 1;
}
.rating-count {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #62748E;
}
.rating-bars {
  display: flex;
  flex-direction: column;
  gap: 7px;
}
.rating-bar-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.bar-star {
  width: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #94A3B8;
  text-align: right;
  flex-shrink: 0;
}
.bar-track {
  flex: 1;
  height: 7px;
  background: #F1F5F9;
  border-radius: 999px;
  overflow: hidden;
}
.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #0047AB, #155DFC);
  border-radius: 999px;
  transition: width 0.5s ease;
}
.bar-pct {
  width: 30px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #94A3B8;
  text-align: right;
  flex-shrink: 0;
}

/* ── Stats card ───────────────────────────────────────────────────────────── */
.card-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #1E293B;
  margin: 0 0 16px;
}
.stats-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.stat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: #F8FAFC;
  border-radius: 10px;
}
.stat-lbl {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #64748B;
}
.stat-val {
  font-family: 'Montserrat', sans-serif;
  font-size: 15px;
  font-weight: 700;
  color: #1E293B;
}

/* ── Trust badges ─────────────────────────────────────────────────────────── */
.trust-badges-card {
  background: linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%);
  border: 1px solid #BBF7D0;
  box-shadow: 0 2px 8px rgba(0, 200, 80, 0.08);
  border-radius: 16px;
  padding: 20px;
}
.trust-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Montserrat', sans-serif;
  font-size: 15px;
  font-weight: 700;
  color: #1E293B;
  margin: 0 0 14px;
}
.trust-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border-radius: 12px;
  padding: 12px 14px;
  margin-bottom: 10px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  transition: transform 0.15s;
}
.trust-item:last-child { margin-bottom: 0; }
.trust-item:hover { transform: translateY(-1px); }
.trust-icon {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.green-icon  { background: #16A34A; }
.blue-icon   { background: #2563EB; }
.orange-icon { background: #EA580C; }

.trust-info { flex: 1; }
.trust-name {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #1E293B;
}
.trust-desc {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #64748B;
  margin-top: 1px;
}

/* ── Content area ─────────────────────────────────────────────────────────── */
.apv-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ── Section title ────────────────────────────────────────────────────────── */
.section-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 17px;
  font-weight: 700;
  color: #1E293B;
  margin: 0 0 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ── About ────────────────────────────────────────────────────────────────── */
.about-text {
  font-size: 15px;
  line-height: 1.7;
  color: #475569;
  margin: 0;
}
.service-types-section {
  padding: 16px 0 0;
  margin-top: 16px;
  border-top: 1px solid #F1F5F9;
}
.sub-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
  margin: 0 0 10px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.service-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.service-tag {
  background: rgba(252,90,21,0.08);
  border: 1px solid rgba(252,90,21,0.2);
  border-radius: 999px;
  padding: 5px 14px;
  font-size: 13px;
  font-weight: 500;
  color: #EA580C;
  font-family: 'Inter', sans-serif;
  transition: background 0.15s;
}
.service-tag:hover { background: rgba(252,90,21,0.14); }

/* ── Gallery ──────────────────────────────────────────────────────────────── */
.gallery-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}
.gallery-item {
  aspect-ratio: 1;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  transition: transform 0.2s, box-shadow 0.2s;
}
.gallery-item:hover {
  transform: scale(1.02);
  box-shadow: 0 6px 20px rgba(0,0,0,0.14);
}
.gallery-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

/* ── Certifications ───────────────────────────────────────────────────────── */
.cert-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.cert-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  border-radius: 12px;
  transition: transform 0.15s;
}
.cert-item:hover { transform: translateX(2px); }
.cert-green { background: #F0FDF4; border: 1px solid #BBF7D0; }
.cert-blue  { background: #EFF6FF; border: 1px solid #BFDBFE; }

.cert-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.cert-icon-green { background: #DCFCE7; }
.cert-icon-blue  { background: #DBEAFE; }

.cert-info { flex: 1; }
.cert-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
}
.cert-date {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #64748B;
  margin-top: 2px;
}

/* ── Booking ──────────────────────────────────────────────────────────────── */
.booking-subtitle {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #64748B;
  margin: -8px 0 20px;
}
.booking-form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  padding-top: 16px;
  border-top: 1px solid #F1F5F9;
}
.booking-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.field-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}
.field-input-wrap { position: relative; }
.field-input {
  width: 100%;
  height: 44px;
  border: 1.5px solid #E2E8F0;
  border-radius: 10px;
  padding: 0 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  outline: none;
  box-sizing: border-box;
  cursor: pointer;
  background: #FAFAFA;
  transition: border-color 0.15s, background 0.15s;
}
.field-input:focus {
  border-color: #FC5A15;
  background: #fff;
}

.btn-book {
  grid-column: 1 / -1;
  height: 48px;
  background: #FC5A15;
  border: none;
  border-radius: 12px;
  font-family: 'Poppins', sans-serif;
  font-size: 15px;
  font-weight: 700;
  color: white;
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
  margin-top: 4px;
  letter-spacing: 0.2px;
}
.btn-book:hover  { background: #e04e0e; }
.btn-book:active { transform: scale(0.99); }

/* ── Payment ──────────────────────────────────────────────────────────────── */
.payment-desc {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 1.6;
  color: #64748B;
  margin: -4px 0 20px;
}
.payment-method {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  background: #FAFAFA;
  border: 1.5px solid #E2E8F0;
  border-radius: 12px;
  margin-bottom: 14px;
}
.method-icon { width: 24px; height: 24px; flex-shrink: 0; }
.method-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 700;
  color: #1E293B;
}
.method-types {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #64748B;
  margin-top: 1px;
}
.info-box {
  display: flex;
  gap: 12px;
  padding: 14px 16px;
  border-radius: 12px;
  margin-bottom: 12px;
}
.info-box:last-child { margin-bottom: 0; }
.info-box svg { flex-shrink: 0; margin-top: 2px; }
.info-box--blue   { background: #EFF6FF; border: 1px solid #BFDBFE; }
.info-box--yellow { background: #FFFBEB; border: 1px solid #FDE68A; }

.info-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 4px;
}
.info-text {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 1.5;
  color: #64748B;
  margin: 0;
}
.policy-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.policy-list li {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 1.6;
  color: #64748B;
  padding-left: 12px;
  position: relative;
}
.policy-list li::before {
  content: "•";
  position: absolute;
  left: 0;
  color: #94A3B8;
}

/* ── Reviews ──────────────────────────────────────────────────────────────── */
.reviews-list {
  display: flex;
  flex-direction: column;
  margin-bottom: 16px;
}
.review-item {
  padding: 16px 0;
  border-bottom: 1px solid #F1F5F9;
}
.review-item:first-child { padding-top: 0; }
.review-item:last-child  { border-bottom: none; }
.review-header {
  display: flex;
  gap: 14px;
}
.review-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-family: 'Montserrat', sans-serif;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
  overflow: hidden;
  position: relative;
}
.review-avatar-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.review-body { flex: 1; min-width: 0; }
.review-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 6px;
}
.reviewer-name {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
}
.review-date {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #94A3B8;
  margin-top: 1px;
}
.review-stars  { display: flex; gap: 2px; flex-shrink: 0; }
.review-text {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 1.6;
  color: #475569;
  margin: 0;
}

.reviews-empty {
  text-align: center;
  color: #94A3B8;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  padding: 32px 0;
}

.btn-leave-review {
  width: 100%;
  height: 48px;
  background: white;
  border: 1.5px solid #1D4ED8;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1D4ED8;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
  transition: background 0.15s, border-color 0.15s;
}
.btn-leave-review:hover {
  background: #EFF6FF;
  border-color: #2563EB;
}

/* ── Booking error ────────────────────────────────────────────────────────── */
.booking-error {
  grid-column: 1 / -1;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

/* ── Booking extras ───────────────────────────────────────────────────────── */
.booking-full    { grid-column: 1 / -1; }
.field-textarea  { height: auto; resize: vertical; padding-top: 10px; padding-bottom: 10px; }
.field-input select,
.booking-form select.field-input { appearance: auto; cursor: pointer; }
.booking-no-services {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #64748B;
  background: #F8FAFC;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  padding: 10px 14px;
  margin: 0;
}
.btn-book:disabled { opacity: 0.6; cursor: not-allowed; }

/* ── Review status UI ─────────────────────────────────────────────────────── */
.review-status-msg {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #64748B;
  padding: 8px 0;
}
.spinner-sm {
  width: 16px;
  height: 16px;
  border: 2px solid #E2E8F0;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  flex-shrink: 0;
}
.review-warning-box {
  display: flex;
  gap: 12px;
  background: #FFFBEB;
  border: 1px solid #FDE68A;
  border-radius: 12px;
  padding: 14px 16px;
}
.review-warning-box svg { flex-shrink: 0; margin-top: 2px; }
.review-warning-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 700;
  color: #92400E;
  margin-bottom: 4px;
}
.review-warning-text {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #78350F;
  margin: 0 0 10px;
  line-height: 1.5;
}
.btn-login-review {
  padding: 6px 14px;
  background: #FC5A15;
  color: white;
  border: none;
  border-radius: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-login-review:hover { background: #e04e0e; }
.review-success-box {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #F0FDF4;
  border: 1px solid #BBF7D0;
  border-radius: 12px;
  padding: 12px 16px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #15803D;
}

/* ── Review modal extras ──────────────────────────────────────────────────── */
.star-selector { margin-bottom: 16px; }
.star-label {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin: 0 0 10px;
}
.stars-row { display: flex; gap: 4px; }
.star-btn {
  background: none;
  border: none;
  padding: 2px;
  cursor: pointer;
  transition: transform 0.1s;
}
.star-btn:hover { transform: scale(1.15); }
.review-textarea {
  width: 100%;
  box-sizing: border-box;
  border: 1.5px solid #E2E8F0;
  border-radius: 10px;
  padding: 12px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  outline: none;
  resize: vertical;
  background: #FAFAFA;
  transition: border-color 0.15s;
}
.review-textarea:focus { border-color: #2563EB; background: #fff; }

/* ── Toast ────────────────────────────────────────────────────────────────── */
.apv-toast {
  position: fixed;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  background: #1E293B;
  color: #fff;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  padding: 12px 24px;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.18);
  z-index: 3000;
  white-space: nowrap;
}
.toast-fade-enter-active, .toast-fade-leave-active { transition: opacity 0.25s, transform 0.25s; }
.toast-fade-enter-from, .toast-fade-leave-to { opacity: 0; transform: translateX(-50%) translateY(12px); }

/* ── Modal overlay ────────────────────────────────────────────────────────── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 24px;
  backdrop-filter: blur(3px);
}

.modal-card {
  background: white;
  border-radius: 20px;
  width: 100%;
  max-width: 420px;
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.18), 0 4px 16px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* ── Modal green header ───────────────────────────────────────────────────── */
.modal-header {
  background: linear-gradient(135deg, #16A34A, #15803D);
  padding: 22px 24px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.modal-check {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.modal-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 17px;
  font-weight: 700;
  color: white;
  margin: 0 0 3px;
}

.modal-artisan {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.82);
  margin: 0;
}

/* ── Modal body ───────────────────────────────────────────────────────────── */
.modal-body {
  padding: 24px;
}

.modal-info-box {
  background: #F0FDF4;
  border: 1px solid #BBF7D0;
  border-radius: 12px;
  padding: 14px 16px;
  margin-bottom: 16px;
}

.modal-info-box p {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 1.6;
  color: #166534;
  margin: 0;
  text-align: center;
}

.modal-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 20px;
  padding: 12px 14px;
  background: #F8FAFC;
  border-radius: 10px;
}

.modal-detail-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #374151;
}

.modal-detail-row svg { flex-shrink: 0; }

/* ── Modal actions ────────────────────────────────────────────────────────── */
.modal-actions {
  display: flex;
  gap: 12px;
}

.modal-btn-cancel {
  flex: 1;
  height: 46px;
  background: white;
  border: 1.5px solid #E2E8F0;
  border-radius: 12px;
  font-family: 'Poppins', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}
.modal-btn-cancel:hover {
  background: #F8FAFC;
  border-color: #CBD5E1;
}

.modal-btn-pay {
  flex: 1.6;
  height: 46px;
  background: #FC5A15;
  border: none;
  border-radius: 12px;
  font-family: 'Poppins', sans-serif;
  font-size: 15px;
  font-weight: 700;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: background 0.15s, transform 0.1s;
}
.modal-btn-pay:hover  { background: #e04e0e; }
.modal-btn-pay:active { transform: scale(0.98); }

/* ── Modal transition ─────────────────────────────────────────────────────── */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
}
.modal-fade-enter-active .modal-card,
.modal-fade-leave-active .modal-card {
  transition: transform 0.2s ease, opacity 0.2s ease;
}
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
.modal-fade-enter-from .modal-card,
.modal-fade-leave-to .modal-card {
  transform: scale(0.95) translateY(8px);
  opacity: 0;
}

/* ── Responsive ───────────────────────────────────────────────────────────── */
@media (max-width: 1100px) {
  .apv-layout   { flex-direction: column; }
  .apv-sidebar  { width: 100%; }
  .gallery-grid { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 768px) {
  .apv-back-wrap { padding: 20px 16px 0; }
  .apv-layout    { padding: 0 16px; margin-top: 16px; }
  .booking-form  { grid-template-columns: 1fr; }
  .gallery-grid  { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 480px) {
  .gallery-grid { grid-template-columns: 1fr; }
  .profile-name { font-size: 16px; }
}
</style>

<template>
  <div>
    <AuthBackground>
      <div class="pricing-wrapper">

        <!-- Header -->
        <div class="pricing-header">
          <h1 class="pricing-title">
            Choisissez votre <span class="orange">abonnement</span>
          </h1>
          <p class="pricing-subtitle">Développez votre activité avec nos plans adaptés à vos besoins</p>

          <!-- Toggle -->
          <div class="billing-toggle">
            <button :class="['toggle-btn', billing === 'monthly' ? 'active' : '']" @click="billing = 'monthly'">Mensuel</button>
            <button :class="['toggle-btn', billing === 'annual' ? 'active' : '']" @click="billing = 'annual'">
              Annuel <span class="badge-discount">-20%</span>
            </button>
          </div>
        </div>

        <!-- Error banner -->
        <div v-if="error" class="error-banner">{{ error }}</div>

        <!-- Cards -->
        <div class="plans-grid">

          <!-- BASIC -->
          <div class="plan-card plan-basic">
            <div class="plan-icon basic-icon">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <path d="M6 17l7 7L26 8" stroke="white" stroke-width="2.67" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <h3 class="plan-name">Basic</h3>
            <p class="plan-desc">Pour démarrer votre activité</p>
            <div class="plan-price">
              <span class="price-amount">0</span>
              <span class="price-unit">MAD/Gratuit</span>
            </div>
            <button class="plan-btn basic-btn" :disabled="loading" @click="choosePlan('basic')">
              {{ loading && selectedPlan === 'basic' ? 'Chargement...' : 'Choisir Basic' }}
            </button>
            <div class="plan-features">
              <p class="features-label">Ce plan inclut :</p>
              <ul>
                <li class="feat-yes">Profil de base</li>
                <li class="feat-yes">Jusqu'à 5 demandes par mois</li>
                <li class="feat-yes">Support client standard</li>
                <li class="feat-yes">Portfolio jusqu'à 3 photos</li>
                <li class="feat-yes">Visibilité locale de base</li>
                <li class="feat-no">Badge vérifié</li>
                <li class="feat-no">Statistiques</li>
                <li class="feat-no">Support prioritaire</li>
                <li class="feat-no">Réponse automatique</li>
              </ul>
            </div>
          </div>

          <!-- PRO -->
          <div class="plan-card plan-pro">
            <div class="plan-icon pro-icon">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <path d="M4 10l6 4 6-8 6 8 6-4-3 14H7L4 10Z" stroke="white" stroke-width="2.67" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <h3 class="plan-name">Pro</h3>
            <p class="plan-desc">Idéal pour les artisans indépendants</p>
            <div class="plan-price">
              <span class="price-amount">30</span>
              <span class="price-unit">MAD/mois</span>
            </div>
            <button class="plan-btn pro-btn" :disabled="loading" @click="choosePlan('pro')">
              {{ loading && selectedPlan === 'pro' ? 'Chargement...' : 'Choisir Pro' }}
            </button>
            <div class="plan-features">
              <p class="features-label">Ce plan inclut :</p>
              <ul>
                <li class="feat-yes">Profil vérifié et badge Pro</li>
                <li class="feat-yes">Jusqu'à 20 demandes par mois</li>
                <li class="feat-yes">Support client prioritaire</li>
                <li class="feat-yes">Statistiques de base</li>
                <li class="feat-yes">Portfolio jusqu'à 10 photos</li>
                <li class="feat-yes">Visibilité locale améliorée</li>
                <li class="feat-no">Réponse automatique aux demandes</li>
                <li class="feat-no">Publicité ciblée</li>
                <li class="feat-no">Gestionnaire de compte dédié</li>
              </ul>
            </div>
          </div>

          <!-- PREMIUM (highlighted) -->
          <div class="plan-card plan-premium featured">
            <div class="popular-badge">⭐ Plus populaire</div>
            <div class="plan-icon premium-icon">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <path d="M16 4l3.09 6.26L26 11.27l-5 4.87 1.18 6.86L16 20l-6.18 3-1-6.86L4 11.27l6.91-1.01L16 4Z" stroke="white" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <h3 class="plan-name">Premium</h3>
            <p class="plan-desc">Le choix des professionnels</p>
            <div class="plan-price">
              <span class="price-amount">75</span>
              <span class="price-unit">MAD/mois</span>
            </div>
            <button class="plan-btn premium-btn" :disabled="loading" @click="choosePlan('premium')">
              {{ loading && selectedPlan === 'premium' ? 'Chargement...' : 'Choisir Premium' }}
            </button>
            <div class="plan-features">
              <p class="features-label">Ce plan inclut :</p>
              <ul>
                <li class="feat-yes">Tout du plan Pro</li>
                <li class="feat-yes">Demandes illimitées</li>
                <li class="feat-yes">Support client 24/7</li>
                <li class="feat-yes">Statistiques avancées et analytics</li>
                <li class="feat-yes">Portfolio jusqu'à 50 photos</li>
                <li class="feat-yes">Visibilité nationale</li>
                <li class="feat-yes">Réponse automatique aux demandes</li>
                <li class="feat-yes">Badge Premium visible</li>
                <li class="feat-no">Gestionnaire de compte dédié</li>
              </ul>
            </div>
          </div>

          <!-- BUSINESS -->
          <div class="plan-card plan-business">
            <div class="plan-icon business-icon">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <rect x="4" y="10" width="24" height="18" rx="2" stroke="white" stroke-width="2.67"/>
                <path d="M11 10V7a5 5 0 0 1 10 0v3" stroke="white" stroke-width="2.67" stroke-linecap="round"/>
              </svg>
            </div>
            <h3 class="plan-name">Business</h3>
            <p class="plan-desc">Pour les entreprises et équipes</p>
            <div class="plan-price">
              <span class="price-amount">250</span>
              <span class="price-unit">MAD/mois</span>
            </div>
            <button class="plan-btn business-btn" :disabled="loading" @click="choosePlan('business')">
              {{ loading && selectedPlan === 'business' ? 'Chargement...' : 'Choisir Business' }}
            </button>
            <div class="plan-features">
              <p class="features-label">Ce plan inclut :</p>
              <ul>
                <li class="feat-yes">Tout du plan Premium</li>
                <li class="feat-yes">Multi-utilisateurs (jusqu'à 10)</li>
                <li class="feat-yes">API et intégrations avancées</li>
                <li class="feat-yes">Portfolio illimité</li>
                <li class="feat-yes">Visibilité maximale</li>
                <li class="feat-yes">Publicité ciblée premium</li>
                <li class="feat-yes">Gestionnaire de compte dédié</li>
                <li class="feat-yes">Formation personnalisée</li>
                <li class="feat-yes">Badge Business exclusif</li>
              </ul>
            </div>
          </div>

        </div>
      </div>
    </AuthBackground>
    <Footer />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import Navbar from '../components/navbar.vue'
import AuthBackground from '../components/Authbackground.vue'
import Footer from '../components/footer.vue'
import '../assets/css/pricing.css'

const router       = useRouter()
const route        = useRoute()
const billing      = ref('annual')
const loading      = ref(false)
const selectedPlan = ref(null)
const error        = ref(null)

// uid is set by registerArtisan.vue when it redirects here
// e.g. /register/artisan/pricing?uid=42
const userId = route.query.uid || localStorage.getItem('pending_user_id')

async function choosePlan(plan) {
  if (!userId) {
    // No user_id means they landed here directly — send back to register
    router.push('/register/artisan')
    return
  }

  loading.value      = true
  selectedPlan.value = plan
  error.value        = null

  try {
    const { data } = await axios.post('/api/complete-plan', {
      user_id: userId,
      plan,
    })

    // Registration complete — store token and user
    localStorage.setItem('token', data.token)
    localStorage.setItem('user',  JSON.stringify(data.user))
    localStorage.removeItem('pending_user_id')

    // Paid plan → redirect to payment gateway
    if (data.payment && data.payment.status === 'pending') {
      router.push({
        path:  '/payment',
        query: {
          payment_id: data.payment.id,
          amount:     data.payment.amount,
          plan,
        },
      })
      return
    }

    // Basic (free) → go straight to dashboard
    router.push('/artisan/profile')

  } catch (err) {
    error.value = err.response?.data?.error
      ?? 'Une erreur est survenue. Veuillez réessayer.'
  } finally {
    loading.value      = false
    selectedPlan.value = null
  }
}
</script>
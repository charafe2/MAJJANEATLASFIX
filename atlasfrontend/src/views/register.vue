<template>
  <div>
    <AuthBackground>
      <div class="register-wrapper">

        <!-- Back button -->
        <button class="back-btn" @click="$router.push('/login')">
          ← Retour
        </button>

        <!-- Header -->
        <div class="register-header">
          <h1 class="register-title">Créer un compte</h1>
          <p class="register-subtitle">Choisissez le type de compte qui vous correspond</p>
        </div>

        <!-- Cards -->
        <div class="cards-container">

          <!-- Client card -->
          <div class="account-card">
            <div class="card-corner-gradient"></div>
            <div class="card-inner">

              <div class="card-icon">
                <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                  <path d="M20 20C23.3 20 26 17.3 26 14C26 10.7 23.3 8 20 8C16.7 8 14 10.7 14 14C14 17.3 16.7 20 20 20Z" stroke="white" stroke-width="3.33" stroke-linecap="round"/>
                  <path d="M8 32C8 26.5 13.4 22 20 22C26.6 22 32 26.5 32 32" stroke="white" stroke-width="3.33" stroke-linecap="round"/>
                </svg>
              </div>

              <h2 class="card-title">Je suis un Client</h2>
              <p class="card-desc">Trouvez des artisans qualifiés pour tous vos projets de rénovation et d'entretien</p>

              <ul class="card-features">
                <li>
                  <span class="check-icon">✓</span>
                  Accès à des centaines d'artisans certifiés
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Comparez les devis rapidement
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Consultez les avis et notes des artisans
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Service client disponible 7j/7
                </li>
              </ul>

              <button class="card-btn" @click="goToForm('client')">
                Se connecter
              </button>

            </div>
          </div>

          <!-- Artisan card -->
          <div class="account-card">
            <div class="card-corner-gradient"></div>
            <div class="card-inner">

              <div class="card-icon">
                <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                  <path d="M28 8L32 12L14 30L8 32L10 26L28 8Z" stroke="white" stroke-width="3.33" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>

              <h2 class="card-title">Je suis un Artisan</h2>
              <p class="card-desc">Développez votre activité et trouvez de nouveaux clients en rejoignant notre plateforme</p>

              <ul class="card-features">
                <li>
                  <span class="check-icon">✓</span>
                  Recevez des demandes de clients locaux
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Créez votre profil et portfolio
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Gérez vos interventions facilement
                </li>
                <li>
                  <span class="check-icon">✓</span>
                  Construisez votre réputation en ligne
                </li>
              </ul>

              <button class="card-btn" @click="goToForm('artisan')">
                Se connecter
              </button>

            </div>
          </div>

        </div>

      </div>
    </AuthBackground>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import Navbar from '../components/navbar.vue'
import AuthBackground from '../components/Authbackground.vue'
import Footer from '../components/footer.vue'
import '../assets/css/register.css'

const router = useRouter()

function goToForm(accountType) {
  if (accountType === 'client') {
    router.push('/register/client')
  } else {
    router.push('/register/artisan')
  }
}
</script>
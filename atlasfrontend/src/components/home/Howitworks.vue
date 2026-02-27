<!-- src/components/HowItWorksSection.vue -->
<template>
  <section class="hiw-section">
    <div class="hiw-wrapper">

      <h2 class="hiw-title">Comment ça marche ?</h2>

      <div class="hiw-steps">

        <div v-for="(step, i) in steps" :key="i" class="hiw-step">

          <!-- Connector line (hidden on last step) -->
          <div class="hiw-connector" v-if="i < steps.length - 1"></div>

          <!-- Orange circle icon -->
          <div class="hiw-circle">
            <!-- Number badge -->
            <div class="hiw-badge">{{ i + 1 }}</div>
            <component :is="step.icon" />
          </div>

          <!-- Text -->
          <h3 class="hiw-step-title">{{ step.title }}</h3>
          <p class="hiw-step-desc">{{ step.desc }}</p>

        </div>

      </div>
    </div>
  </section>
</template>

<script setup>
// Search icon
const IconSearch = {
  template: `<svg viewBox="0 0 32 32" fill="none">
    <circle cx="14" cy="14" r="7" stroke="white" stroke-width="2.6"/>
    <path d="M19.5 19.5L26 26" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
  </svg>`
}

// Person / profile icon
const IconPerson = {
  template: `<svg viewBox="0 0 32 32" fill="none">
    <path d="M22 10l-6 8-4-4" stroke="white" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M8 26c0-4 3.58-7 8-7s8 3 8 7" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
    <circle cx="16" cy="10" r="4" stroke="white" stroke-width="2.6"/>
  </svg>`
}

// Calendar / payment icon
const IconCalendar = {
  template: `<svg viewBox="0 0 32 32" fill="none">
    <rect x="5" y="7" width="22" height="20" rx="2" stroke="white" stroke-width="2.6"/>
    <path d="M5 13h22" stroke="white" stroke-width="2.6"/>
    <path d="M11 5v4M21 5v4" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
    <path d="M10 19h5M10 23h8" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
  </svg>`
}

// Star / review icon
const IconStar = {
  template: `<svg viewBox="0 0 32 32" fill="none">
    <path d="M16 5l2.9 8.9H28l-7.5 5.5 2.9 8.9L16 23l-7.4 5.3 2.9-8.9L4 13.9h9.1L16 5z" stroke="white" stroke-width="2.6" stroke-linejoin="round"/>
  </svg>`
}

const steps = [
  {
    icon:  IconSearch,
    title: 'Cherchez un service',
    desc:  'Parcourez les catégories ou publiez votre besoin spécifique pour trouver le bon artisan.',
  },
  {
    icon:  IconPerson,
    title: 'Choisissez un artisan vérifié',
    desc:  'Comparez les profils, notes, avis et devis des prestataires disponibles.',
  },
  {
    icon:  IconCalendar,
    title: 'Réservez & payez',
    desc:  'Choisissez votre prestataire et planifiez à un moment qui vous convient.',
  },
  {
    icon:  IconStar,
    title: 'Évaluez le service',
    desc:  'Profitez d\'un service de qualité et laissez un avis pour aider la communauté.',
  },
]
</script>

<style scoped>
.hiw-section {
  background: #ffffff;
  padding: 80px 0;
}

.hiw-wrapper {
  max-width: 1219px;
  margin: 0 auto;
  padding: 0 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 64px;
}

/* Title */
.hiw-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 40px;
  line-height: 1;
  text-align: center;
  letter-spacing: -0.44px;
  color: #0a0a0a;
  margin: 0;
}

/* Steps row */
.hiw-steps {
  display: flex;
  align-items: flex-start;
  justify-content: center;
  gap: 0;
  width: 100%;
}

/* Individual step */
.hiw-step {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  flex: 1;
  max-width: 274px;
  text-align: center;
  padding-top: 0;
}

/* Dashed connector line between steps */
.hiw-connector {
  position: absolute;
  top: 31px; /* center of the 63px circle */
  left: calc(50% + 45px);
  width: calc(100% - 10px);
  height: 0;
  border-top: 2px dashed #D1D5DC;
  z-index: 0;
  pointer-events: none;
}

/* Orange circle */
.hiw-circle {
  position: relative;
  z-index: 1;
  width: 63px;
  height: 63px;
  background: #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.hiw-circle svg {
  width: 31px;
  height: 31px;
}

/* Number badge */
.hiw-badge {
  position: absolute;
  top: -8px;
  left: -8px;
  width: 24px;
  height: 24px;
  background: #ffffff;
  border: 1px solid #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Poppins', sans-serif;
  font-size: 12px;
  font-weight: 500;
  color: #FC5A15;
  z-index: 2;
}

/* Step title */
.hiw-step-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 15.65px;
  line-height: 1.5;
  text-align: center;
  letter-spacing: -0.31px;
  color: #0a0a0a;
  margin: 0;
}

/* Step description */
.hiw-step-desc {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 13.7px;
  line-height: 1.45;
  text-align: center;
  letter-spacing: -0.15px;
  color: #4a5565;
  margin: 0;
  max-width: 250px;
}

/* Responsive */
@media (max-width: 900px) {
  .hiw-steps {
    flex-direction: column;
    align-items: center;
    gap: 40px;
  }
  .hiw-connector {
    display: none;
  }
  .hiw-step {
    max-width: 320px;
  }
}

@media (max-width: 640px) {
  .hiw-section { padding: 60px 0; }
  .hiw-title { font-size: 30px; }
  .hiw-wrapper { gap: 48px; padding: 0 24px; }
}
</style>
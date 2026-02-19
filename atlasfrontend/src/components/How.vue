<!-- src/components/HowItWorksSection.vue -->
<template>
  <section class="hiw-section">
    <div class="hiw-root hiw-wrapper">

      <h2 class="hiw-title">Comment ça marche ?</h2>

      <div class="hiw-steps">

        <div v-for="(step, i) in steps" :key="i" class="hiw-step">

          <!-- connector line (not on last item) -->
          <div v-if="i < steps.length - 1" class="hiw-connector"></div>

          <!-- circle icon -->
          <div class="hiw-icon-circle">
            <!-- step number badge -->
            <div class="hiw-badge">{{ i + 1 }}</div>
            <svg viewBox="0 0 32 32" fill="none" v-html="step.icon"></svg>
          </div>

          <!-- text -->
          <div class="hiw-step-text">
            <span class="hiw-step-title">{{ step.title }}</span>
            <span class="hiw-step-desc">{{ step.desc }}</span>
          </div>

        </div>

      </div>

    </div>
  </section>
</template>

<script setup>
const steps = [
  {
    title: 'Cherchez un service',
    desc:  'Parcourez les catégories ou publiez votre besoin spécifique pour trouver le bon artisan.',
    icon:  `<path d="M13 24C19.0751 24 24 19.0751 24 13C24 6.92487 19.0751 2 13 2C6.92487 2 2 6.92487 2 13C2 19.0751 6.92487 24 13 24Z" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
            <path d="M21 21L29 29" stroke="white" stroke-width="2.6" stroke-linecap="round"/>`,
  },
  {
    title: 'Choisissez un artisan vérifié',
    desc:  'Comparez les profils, notes, avis et devis des prestataires disponibles.',
    icon:  `<path d="M6 16l5 5L26 8" stroke="white" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M4 8h14M4 16h8M4 24h10" stroke="white" stroke-width="2.6" stroke-linecap="round"/>`,
  },
  {
    title: 'Réservez & payez',
    desc:  'Choisissez votre prestataire et planifiez à un moment qui vous convient.',
    icon:  `<rect x="4" y="5" width="24" height="22" rx="2" stroke="white" stroke-width="2.6"/>
            <path d="M4 12h24" stroke="white" stroke-width="2.6"/>
            <path d="M10 3v4M22 3v4" stroke="white" stroke-width="2.6" stroke-linecap="round"/>`,
  },
  {
    title: 'Évaluez le service',
    desc:  'Profitez du service et laissez un avis pour aider la communauté.',
    icon:  `<path d="M16 3l3.09 6.26L26 10.27l-5 4.87 1.18 6.88L16 18.77l-6.18 3.25L11 15.14 6 10.27l6.91-1.01L16 3z" stroke="white" stroke-width="2.6" stroke-linejoin="round"/>`,
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
  gap: 60px;
}

.hiw-root .hiw-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 40px;
  line-height: 1.2;
  letter-spacing: -0.44px;
  color: #0a0a0a;
  text-align: center;
  margin: 0;
}

/* ── Steps row ────────────────────────────────────────────────────────── */
.hiw-root .hiw-steps {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: center;
  gap: 0;
  width: 100%;
}

.hiw-root .hiw-step {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  flex: 1;
  max-width: 274px;
}

/* Dashed connector line between steps */
.hiw-root .hiw-connector {
  position: absolute;
  top: 31px; /* half of icon circle height (62px / 2) */
  left: calc(50% + 31px); /* start after the icon circle */
  width: calc(100% - 0px);
  height: 0;
  border-top: 2px dashed #D1D5DC;
  pointer-events: none;
  z-index: 0;
}

/* Orange circle icon */
.hiw-root .hiw-icon-circle {
  position: relative;
  width: 62px;
  height: 62px;
  background: #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  z-index: 1;
}

.hiw-root .hiw-icon-circle svg {
  width: 31px;
  height: 31px;
}

/* Number badge */
.hiw-root .hiw-badge {
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

/* Step text */
.hiw-root .hiw-step-text {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  text-align: center;
}

.hiw-root .hiw-step-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 15px;
  line-height: 1.5;
  letter-spacing: -0.3px;
  color: #0a0a0a;
}

.hiw-root .hiw-step-desc {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 13px;
  line-height: 1.5;
  letter-spacing: -0.15px;
  color: #4a5565;
  max-width: 220px;
}

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 900px) {
  .hiw-root .hiw-steps {
    flex-direction: column;
    align-items: center;
    gap: 40px;
  }

  .hiw-root .hiw-connector {
    display: none;
  }

  .hiw-root .hiw-step {
    max-width: 100%;
  }

  .hiw-root .hiw-title {
    font-size: 30px;
  }
}

@media (max-width: 640px) {
  .hiw-section { padding: 60px 0; }
  .hiw-wrapper { padding: 0 24px; gap: 40px; }
  .hiw-root .hiw-title { font-size: 26px; }
}
</style>
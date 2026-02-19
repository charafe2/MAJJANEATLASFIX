<!-- src/components/PublishNeedSection.vue -->
<template>
  <section class="pn-section">
    <div class="pn-wrapper pn-root">

      <div class="pn-left">
        <div class="pn-title-block">
          <h2 class="pn-title">Vous ne trouvez pas le service qu'il vous faut ?</h2>
          <p class="pn-subtitle">
            Publiez votre besoin de service et recevez les propositions de
            professionnels qualifiés. Comparez plusieurs devis et choisissez
            celui qui correspond le mieux à votre projet.
          </p>
        </div>

        <div class="pn-steps">
          <div class="pn-step">
            <div class="step-icon-box">
              <svg viewBox="0 0 19 19" fill="none">
                <rect x="1" y="1" width="17" height="17" rx="2" stroke="#FC5A15" stroke-width="1.57"/>
                <line x1="4" y1="6"  x2="15" y2="6"  stroke="#FC5A15" stroke-width="1.5" stroke-linecap="round"/>
                <line x1="4" y1="9.5" x2="11" y2="9.5" stroke="#FC5A15" stroke-width="1.5" stroke-linecap="round"/>
                <line x1="4" y1="13" x2="13" y2="13" stroke="#FC5A15" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="step-text">
              <span class="step-title">Décrivez votre besoin</span>
              <span class="step-desc">Dites-nous ce qui doit être fait et pour quand.</span>
            </div>
          </div>

          <div class="pn-step">
            <div class="step-icon-box">
              <svg viewBox="0 0 19 19" fill="none">
                <rect x="1" y="1" width="17" height="17" rx="2" stroke="#FC5A15" stroke-width="1.57"/>
                <path d="M4 5h11v7H4z" stroke="#FC5A15" stroke-width="1.4" stroke-linejoin="round"/>
                <line x1="9.5" y1="12" x2="9.5" y2="15" stroke="#FC5A15" stroke-width="1.4" stroke-linecap="round"/>
                <line x1="6.5" y1="15" x2="12.5" y2="15" stroke="#FC5A15" stroke-width="1.4" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="step-text">
              <span class="step-title">Recevez des devis</span>
              <span class="step-desc">Obtenir des réponses de prestataires intéressés.</span>
            </div>
          </div>

          <div class="pn-step">
            <div class="step-icon-box">
              <svg viewBox="0 0 19 19" fill="none">
                <rect x="1" y="1" width="17" height="17" rx="2" stroke="#FC5A15" stroke-width="1.57"/>
                <path d="M5.5 9.5l3 3 5-5" stroke="#FC5A15" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <div class="step-text">
              <span class="step-title">Choisissez et réservez</span>
              <span class="step-desc">Comparez les devis et engagez le professionnel le plus adapté.</span>
            </div>
          </div>
        </div>

        <button class="pn-btn">Publier mon besoin</button>
      </div>

      <div class="pn-right">
        <div class="pn-tag">Pourquoi Publier Votre Besoin ?</div>
        <ul class="pn-bullets">
          <li v-for="b in bullets" :key="b">
            <svg class="bullet-icon" viewBox="0 0 22 22" fill="none">
              <circle cx="11" cy="11" r="10" stroke="white" stroke-width="1.8"/>
              <path d="M6.5 11.5l3 3 6-6" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span>{{ b }}</span>
          </li>
        </ul>
      </div>

    </div>
  </section>
</template>

<script setup>
const bullets = [
  "Aucun engagement requis avant l'embauche",
  'Comparez plusieurs devis côte à côte',
  'Tous les prestataires sont vérifiés et notés',
  'Paiement garanti et sécurité',
]
</script>

<style scoped>
.pn-section {
  background: rgba(229, 231, 235, 0.21);
  padding: 60px 0;
}

.pn-wrapper {
  max-width: 1174px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 1fr;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0px 19px 24px -5px rgba(0,0,0,0.10), 0px 8px 10px -6px rgba(0,0,0,0.10);
}

/* All left-panel rules prefixed with .pn-root to beat Tailwind specificity */
.pn-root .pn-left {
  background: #ffffff;
  padding: 44px 40px 44px 46px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.pn-root .pn-title-block {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.pn-root .pn-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 22px;
  line-height: 1.35;
  color: #0a0a0a;
  margin: 0;
}

.pn-root .pn-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 15px;
  line-height: 1.6;
  color: #4a5565;
  margin: 0;
}

.pn-root .pn-steps {
  display: flex;
  flex-direction: column;
  gap: 22px;
}

.pn-root .pn-step {
  display: flex;
  align-items: flex-start;
  gap: 15px;
}

.pn-root .step-icon-box {
  flex-shrink: 0;
  width: 38px;
  height: 38px;
  background: rgba(252, 90, 21, 0.09);
  border: 0.5px solid #FC5A15;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.pn-root .step-icon-box svg {
  width: 19px;
  height: 19px;
}

.pn-root .step-text {
  display: flex;
  flex-direction: column;
  gap: 3px;
  padding-top: 2px;
}

.pn-root .step-title {
  font-family: 'Poppins', sans-serif;
  font-size: 15px;
  font-weight: 400;
  line-height: 1.5;
  color: #0a0a0a;
}

.pn-root .step-desc {
  font-family: 'Poppins', sans-serif;
  font-size: 13px;
  font-weight: 400;
  line-height: 1.45;
  color: #4a5565;
}

.pn-root .pn-btn {
  align-self: flex-start;
  height: 44px;
  padding: 0 24px;
  background: #FC5A15;
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 13px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  box-shadow: 0 3px 5px -1px rgba(0,0,0,0.12), 0 2px 3px -2px rgba(0,0,0,0.10);
  transition: background 0.2s ease;
}

.pn-root .pn-btn:hover {
  background: #e04e12;
}

/* RIGHT */
.pn-root .pn-right {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  padding: 44px 40px 44px 46px;
  gap: 32px;
  background-image:
    linear-gradient(rgba(0,0,0,0.67), rgba(0,0,0,0.67)),
    url('https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=900&q=80');
  background-size: cover;
  background-position: center;
}

.pn-root .pn-tag {
  display: inline-flex;
  align-items: center;
  height: 38px;
  padding: 0 20px;
  background: #FC5A15;
  border-radius: 9999px;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 14px;
  color: #ffffff;
  white-space: nowrap;
}

.pn-root .pn-bullets {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pn-root .pn-bullets li {
  display: flex;
  align-items: center;
  gap: 11px;
}

.pn-root .bullet-icon {
  flex-shrink: 0;
  width: 22px;
  height: 22px;
}

.pn-root .pn-bullets li span {
  font-family: 'Poppins', sans-serif;
  font-size: 15px;
  font-weight: 400;
  color: #ffffff;
}

@media (max-width: 900px) {
  .pn-wrapper { grid-template-columns: 1fr; margin: 0 20px; }
  .pn-right { min-height: 280px; }
}

@media (max-width: 640px) {
  .pn-section { padding: 40px 0; }
  .pn-root .pn-left { padding: 32px 24px; }
  .pn-root .pn-title { font-size: 19px; }
}
</style>
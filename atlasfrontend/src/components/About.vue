<!-- src/components/AboutSection.vue -->
<template>
  <section class="ab-section">
    <div class="ab-root ab-wrapper">

      <!-- ── LEFT: image + stat card ───────────────────────────────────── -->
      <div class="ab-image-wrap">
        <img
          src="https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=700&q=80"
          alt="Artisan AtlasFix"
          class="ab-image"
        />
        <!-- Stat card top-right -->
        <div class="ab-stat">
          <span class="ab-stat-number">128 <span class="ab-stat-plus">+</span></span>
          <span class="ab-stat-label">des artisans</span>
        </div>
      </div>

      <!-- ── RIGHT: text + features ────────────────────────────────────── -->
      <div class="ab-content">

        <!-- Sub heading -->
        <div class="ab-subheading">
          <span class="ab-subheading-bar"></span>
          <span class="ab-subheading-text">Pourquoi choisir AtlasFix ?</span>
        </div>

        <!-- Main heading -->
        <h2 class="ab-heading">La confiance, au cœur de notre plateforme</h2>

        <!-- Feature rows -->
        <div class="ab-features">

          <div class="ab-feature">
            <div class="ab-icon-box">
              <svg viewBox="0 0 24 24" fill="none">
                <path d="M12 2C9.24 2 7 4.24 7 7s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5z" stroke="#FC5A15" stroke-width="1.6"/>
                <path d="M3 21c0-4.42 4.03-8 9-8s9 3.58 9 8" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M16 7l1.5 1.5L20 6" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <div class="ab-feature-text">
              <span class="ab-feature-title">Artisans vérifiés</span>
              <span class="ab-feature-desc">Documents, certifications et contrôles manuels.</span>
            </div>
          </div>

          <div class="ab-feature">
            <div class="ab-icon-box">
              <svg viewBox="0 0 24 24" fill="none">
                <rect x="3" y="4" width="18" height="17" rx="2" stroke="#FC5A15" stroke-width="1.6"/>
                <path d="M3 9h18" stroke="#FC5A15" stroke-width="1.6"/>
                <path d="M8 2v4M16 2v4" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M7 13h4M7 17h6" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="ab-feature-text">
              <span class="ab-feature-title">Réservation simple et rapide</span>
              <span class="ab-feature-desc">Planifiez votre service en quelques minutes.</span>
            </div>
          </div>

          <div class="ab-feature">
            <div class="ab-icon-box">
              <svg viewBox="0 0 24 24" fill="none">
                <rect x="3" y="11" width="18" height="11" rx="2" stroke="#FC5A15" stroke-width="1.6"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
                <circle cx="12" cy="16" r="1.5" fill="#FC5A15"/>
              </svg>
            </div>
            <div class="ab-feature-text">
              <span class="ab-feature-title">Paiements sécurisés</span>
              <span class="ab-feature-desc">En ligne ou à la livraison.</span>
            </div>
          </div>

          <div class="ab-feature">
            <div class="ab-icon-box">
              <svg viewBox="0 0 24 24" fill="none">
                <circle cx="9" cy="8" r="3" stroke="#FC5A15" stroke-width="1.6"/>
                <circle cx="17" cy="8" r="3" stroke="#FC5A15" stroke-width="1.6"/>
                <path d="M2 20c0-3.31 3.13-6 7-6" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M10 20c0-3.31 3.13-6 7-6s7 2.69 7 6" stroke="#FC5A15" stroke-width="1.6" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="ab-feature-text">
              <span class="ab-feature-title">Évaluations transparentes</span>
              <span class="ab-feature-desc">Avis authentiques de clients réels.</span>
            </div>
          </div>

        </div>
      </div>

    </div>
  </section>
</template>

<script setup></script>

<style scoped>
/* ── Section ────────────────────────────────────────────────────────────── */
.ab-section {
  background: #ffffff;
  padding: 80px 0;
}

.ab-wrapper {
  max-width: 1235px;
  margin: 0 auto;
  padding: 0 40px;
  display: flex;
  align-items: center;
  gap: 72px;
}

/* ── LEFT: image ────────────────────────────────────────────────────────── */
.ab-image-wrap {
  position: relative;
  flex-shrink: 0;
  width: 595px;
  height: 618px;
}

.ab-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 19px;
  display: block;
}

/* Stat card */
.ab-stat {
  position: absolute;
  top: 20px;
  right: -20px;
  width: 148px;
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.10);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 14px 16px;
  gap: 2px;
}

.ab-stat-number {
  font-family: 'Onest', 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 44px;
  line-height: 1.2;
  color: #030302;
  display: flex;
  align-items: center;
  gap: 4px;
}

.ab-stat-plus {
  color: #FC5A15;
  font-size: 36px;
}

.ab-stat-label {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 14px;
  letter-spacing: 0.05em;
  color: #030302;
}

/* ── RIGHT: content ─────────────────────────────────────────────────────── */
.ab-content {
  display: flex;
  flex-direction: column;
  gap: 44px;
  flex: 1;
}

/* Sub heading row */
.ab-subheading {
  display: flex;
  align-items: center;
  gap: 14px;
}

.ab-subheading-bar {
  display: block;
  width: 2px;
  height: 20px;
  background: #99A1AF;
  border-radius: 2px;
}

.ab-subheading-text {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 16px;
  color: #99A1AF;
}

/* Main heading */
.ab-heading {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 40px;
  line-height: 1.4;
  color: #030302;
  margin: -24px 0 0;  /* pull up to close the gap-44 between subheading + heading */
}

/* Features list */
.ab-features {
  display: flex;
  flex-direction: column;
  gap: 36px;
  margin-top: -8px;
}

.ab-feature {
  display: flex;
  align-items: center;
  gap: 24px;
}

/* Orange icon box */
.ab-icon-box {
  flex-shrink: 0;
  width: 46px;
  height: 46px;
  background: rgba(252, 90, 21, 0.05);
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ab-icon-box svg {
  width: 24px;
  height: 24px;
}

.ab-feature-text {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.ab-feature-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 18px;
  line-height: 1.4;
  color: #030302;
}

.ab-feature-desc {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 15px;
  line-height: 1.6;
  color: #838383;
}

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 1100px) {
  .ab-wrapper { gap: 48px; }
  .ab-image-wrap { width: 460px; height: 480px; }
  .ab-heading { font-size: 34px; }
}

@media (max-width: 900px) {
  .ab-wrapper {
    flex-direction: column;
    gap: 40px;
    padding: 0 24px;
  }
  .ab-image-wrap { width: 100%; height: 360px; }
  .ab-stat { right: 12px; }
  .ab-heading { font-size: 30px; }
}

@media (max-width: 640px) {
  .ab-section { padding: 60px 0; }
  .ab-heading { font-size: 26px; }
  .ab-feature-title { font-size: 16px; }
}
</style>
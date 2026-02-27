<!-- src/components/AppDownloadSection.vue -->
<template>
  <section class="ad-section">

    <!-- Phone mockup left -->
    <div class="ad-phone-wrap">
      <div class="ad-phone">
        <div class="ad-screen">
          <span class="ad-screen-text">ATLASFIX</span>
        </div>
      </div>
    </div>

    <!-- Right content -->
    <div class="ad-content">
      <h2 class="ad-title">Téléchargez<br/>l'application AtlasFix</h2>
      <p class="ad-subtitle">
        Trouvez le bon artisan au bon moment, directement depuis votre smartphone.
      </p>

      <div class="ad-buttons">
        <!-- Google Play -->
        <a href="#" class="ad-store-btn">
          <!-- Play Store icon -->
          <svg class="ad-store-icon" viewBox="0 0 32 36" fill="none">
            <path d="M0.5 1.5C0.5 0.7 1.3 0.2 2 0.6L30.5 16.1C31.2 16.5 31.2 17.5 30.5 17.9L2 33.4C1.3 33.8 0.5 33.3 0.5 32.5V1.5Z" fill="#4285F4"/>
            <path d="M0.5 1.5L16.5 17.5L2 33.4C1.3 33.8 0.5 33.3 0.5 32.5V1.5Z" fill="#34A853"/>
            <path d="M0.5 1.5C0.5 0.7 1.3 0.2 2 0.6L16.5 8.5L0.5 17.5V1.5Z" fill="#EA4335"/>
            <path d="M16.5 17.5L30.5 17.9C31.2 17.5 31.2 16.5 30.5 16.1L16.5 8.5V17.5Z" fill="#FBBC04"/>
          </svg>
          <div class="ad-store-text">
            <span class="ad-store-sub">GET IT ON</span>
            <span class="ad-store-name">Google Play</span>
          </div>
        </a>

        <!-- App Store -->
        <a href="#" class="ad-store-btn">
          <!-- Apple icon -->
          <svg class="ad-store-icon" viewBox="0 0 24 30" fill="none">
            <path d="M20.5 23.5C19.5 25.3 18.4 27 16.6 27C14.9 27 14.2 25.9 12.1 25.9C10 25.9 9.2 27 7.6 27C5.9 27 4.7 25.2 3.7 23.4C1.4 19.4 0.7 14.7 2.4 11.9C3.6 9.9 5.7 8.7 7.7 8.7C9.6 8.7 10.8 9.8 12.1 9.8C13.4 9.8 14.4 8.7 16.6 8.7C18.4 8.7 20.2 9.7 21.4 11.4C17.7 13.4 18.3 18.7 20.5 23.5Z" fill="white"/>
            <path d="M15.5 3C16.3 4.1 16.5 5.6 16 7C14.7 7 13.3 6.2 12.5 5.1C11.7 4.1 11.4 2.6 12 1.3C13.4 1.2 14.8 2 15.5 3Z" fill="white"/>
          </svg>
          <div class="ad-store-text">
            <span class="ad-store-sub">Download on the</span>
            <span class="ad-store-name">App Store</span>
          </div>
        </a>
      </div>
    </div>

  </section>
</template>

<script setup></script>

<style scoped>
.ad-section {
  position: relative;
  background: #ffffff;
  min-height: 614px;
  display: flex;
  align-items: center;
  overflow: hidden;
  padding: 60px 0;
}

/* ── Phone mockup ───────────────────────────────────────────────────────── */
.ad-phone-wrap {
  flex-shrink: 0;
  width: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-left: 80px;
}

.ad-phone {
  position: relative;
  width: 260px;
  height: 520px;
  background: #1a1a1a;
  border-radius: 40px;
  box-shadow:
    0 0 0 10px #2a2a2a,
    0 0 0 12px #1a1a1a,
    0 30px 60px rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  /* Notch */
}

/* Notch */
.ad-phone::before {
  content: '';
  position: absolute;
  top: 16px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 22px;
  background: #1a1a1a;
  border-radius: 0 0 16px 16px;
  z-index: 2;
}

.ad-screen {
  width: 232px;
  height: 490px;
  background: #FC5A15;
  border-radius: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ad-screen-text {
  font-family: 'Poppins', sans-serif;
  font-weight: 700;
  font-size: 36px;
  line-height: 1.2;
  text-align: center;
  color: #ffffff;
  letter-spacing: 2px;
}

/* ── Right content ──────────────────────────────────────────────────────── */
.ad-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 31px;
  padding-right: 80px;
  max-width: 631px;
}

.ad-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 55px;
  line-height: 1.35;
  letter-spacing: -0.45px;
  color: #0a0a0a;
  margin: 0;
}

.ad-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 18px;
  line-height: 1.35;
  letter-spacing: -0.31px;
  color: #4a5565;
  margin: -16px 0 0;
  max-width: 587px;
}

/* ── Store buttons ──────────────────────────────────────────────────────── */
.ad-buttons {
  display: flex;
  gap: 6px;
}

.ad-store-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #000000;
  border: 1.5px solid #A6A6A6;
  border-radius: 9px;
  padding: 8px 14px;
  text-decoration: none;
  min-width: 160px;
  transition: opacity 0.2s;
}

.ad-store-btn:hover { opacity: 0.85; }

.ad-store-icon {
  width: 28px;
  height: 32px;
  flex-shrink: 0;
}

.ad-store-text {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.ad-store-sub {
  font-family: 'Poppins', sans-serif;
  font-weight: 300;
  font-size: 10px;
  line-height: 1.4;
  text-transform: uppercase;
  color: #ffffff;
  letter-spacing: 0.5px;
}

.ad-store-name {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 18px;
  line-height: 1.2;
  color: #ffffff;
  white-space: nowrap;
}

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 900px) {
  .ad-section {
    flex-direction: column;
    gap: 48px;
    padding: 60px 24px;
    text-align: center;
  }
  .ad-phone-wrap { width: 100%; padding-left: 0; }
  .ad-content {
    align-items: center;
    padding-right: 0;
    max-width: 100%;
  }
  .ad-subtitle { text-align: center; }
}

@media (max-width: 640px) {
  .ad-title { font-size: 38px; }
  .ad-phone { width: 200px; height: 400px; border-radius: 32px; }
  .ad-screen { width: 178px; height: 376px; }
  .ad-screen-text { font-size: 28px; }
  .ad-buttons { flex-direction: column; width: 100%; max-width: 200px; }
  .ad-store-btn { justify-content: center; }
}
</style>
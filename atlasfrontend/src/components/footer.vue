<template>
  <footer class="site-footer">

    <!-- ── Background image overlay ── -->
    <div class="footer-bg"></div>

    <!-- ── Main content ── -->
    <div class="footer-content">

      <!-- Col 1: Logo + tagline -->
      <div class="footer-brand">
        <div class="footer-logo">
          <img src="../assets/images/Exclude.svg" alt="">
           
        </div>
        <p class="footer-tagline">
          Une plateforme complète pour trouver,<br>
          réserver et suivre vos interventions, avec des<br>
          professionnels vérifiés et un service client<br>
          toujours à votre écoute.
        </p>
      </div>

      <!-- Col 2: À propos links -->
      <div class="footer-col">
        <a href="#" class="footer-link footer-link-bold">À propos</a>
        <a href="#" class="footer-link footer-link-bold">Services</a>
        <a href="#" class="footer-link footer-link-bold">Contact</a>
        <a href="#" class="footer-link footer-link-bold">FAQ's</a>
      </div>

      <!-- Col 3: Legal links -->
      <div class="footer-col">
        <a @click="navigate('/Litiges')" class="footer-link">Politique de Confidentialité</a>
        <a href="#" class="footer-link">Conditions Générales d'Utilisation</a>
        <a href="#" class="footer-link">Page Conseils</a>
        <a href="#" class="footer-link">Paiements &amp; Abonnements</a>
        <a href="/Litiges">Résolution des litiges</a>
      </div>

      <!-- Col 4: More links -->
      <div class="footer-col footer-col-right">
        <a href="#" class="footer-link">Politique de paiement</a>
        <a href="#" class="footer-link">Politique de confiance et sécurité</a>
        <a href="#" class="footer-link">Politique de remboursement</a>
        <a href="#" class="footer-link">Carrière</a>
      </div>

      <!-- Search bar top-right -->
      <div class="footer-search">
        <div class="search-bar">
          <svg class="search-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="7" cy="7" r="5.5" stroke="#99A1AF" stroke-width="1.5"/>
            <path d="M11 11L14 14" stroke="#99A1AF" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
          <input type="text" placeholder="Quel service recherchez-vous ?" class="search-input" />
          <div class="search-divider"></div>
          <svg class="search-chevron" width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M4 6l4 4 4-4" stroke="#99A1AF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <span class="search-location">localisation</span>
        </div>
        <button class="search-btn">Demander votre service</button>
      </div>

    </div>

    <!-- ── Bottom bar ── -->
    <div class="footer-bottom">
      <span class="footer-copy">© 2025 Atlas fix. All rights reserved.</span>
      <span class="footer-powered">powered by majjane</span>
    </div>

  </footer>
</template>

<script setup>
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Poppins:wght@400;600;700;800&display=swap');

/* ── Footer shell ─────────────────────────────────────────────────────────── */
.site-footer {
  position: relative;
  width: 100%;
  background-color: #181818;
  overflow: hidden;
  font-family: 'Inter', sans-serif;
}

/* ── Dark photo overlay ── */
.footer-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(rgba(18,18,18,0.78), rgba(18,18,18,0.78)),;
  z-index: 0;
}

/* ── Content grid ─────────────────────────────────────────────────────────── */
.footer-content {
  position: relative;
  z-index: 1;
  max-width: 1280px;
  margin: 0 auto;
  padding: 48px 40px 32px;
  display: grid;
  grid-template-columns: 240px 120px 1fr 1fr;
  grid-template-rows: auto auto;
  column-gap: 32px;
  row-gap: 32px;
}

/* ── Brand ── */
.footer-brand {
  grid-column: 1;
  grid-row: 1 / 3;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 6px;
}

.logo-atlas {
  font-family: 'Poppins', sans-serif;
  font-weight: 800;
  font-size: 32px;
  color: #ffffff;
  letter-spacing: -1px;
  line-height: 1;
}

.logo-fix-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #FC5A15;
  border-radius: 8px;
  padding: 3px 10px 3px 8px;
  height: 30px;
}

.logo-fix-pill svg text {
  font-family: 'Poppins', sans-serif;
  font-weight: 700;
}

.footer-tagline {
  font-size: 12.5px;
  line-height: 1.75;
  color: #C4C9D4;
  margin: 0;
}

/* ── Columns ── */
.footer-col {
  grid-row: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-top: 4px;
}

.footer-col:nth-child(2) { grid-column: 2; }
.footer-col:nth-child(3) { grid-column: 3; }
.footer-col-right        { grid-column: 4; }

.footer-link {
  font-size: 12.5px;
  color: #C4C9D4;
  text-decoration: none;
  line-height: 1.4;
  transition: color 0.18s;
  cursor: pointer;
  width: fit-content;
  
}
a{
  text-decoration: none;
    color: #C4C9D4;
  font-size: 12.5px;

}
.footer-link:hover { color: #FC5A15; }

.footer-link-bold {
  font-weight: 600;
  font-size: 13.5px;
  color: #FFFFFF;
}
.footer-link-bold:hover { color: #FC5A15; }

/* ── Search bar (top-right) ── */
.footer-search {
  grid-column: 3 / 5;
  grid-row: 2;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding-bottom: 8px;
}

.search-bar {
  display: flex;
  align-items: center;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 10px;
  padding: 0 14px;
  height: 44px;
  gap: 8px;
  min-width: 340px;
}

.search-icon { flex-shrink: 0; }

.search-input {
  background: none;
  border: none;
  outline: none;
  color: #D1D5DC;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  width: 170px;
}
.search-input::placeholder { color: #6B7280; }

.search-divider {
  width: 1px;
  height: 20px;
  background: rgba(255,255,255,0.15);
  flex-shrink: 0;
}

.search-chevron { flex-shrink: 0; }

.search-location {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #6B7280;
  white-space: nowrap;
}

.search-btn {
  background: #FC5A15;
  color: #ffffff;
  border: none;
  border-radius: 10px;
  padding: 0 20px;
  height: 44px;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  font-size: 13px;
  white-space: nowrap;
  cursor: pointer;
  transition: background 0.18s;
  flex-shrink: 0;
}
.search-btn:hover { background: #e0510f; }

/* ── Bottom bar ─────────────────────────────────────────────────────────── */
.footer-bottom {
  position: relative;
  z-index: 1;
  border-top: 1px solid rgba(255,255,255,0.08);
  max-width: 1280px;
  margin: 0 auto;
  padding: 14px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.footer-copy,
.footer-powered {
  font-size: 12px;
  color: #6B7280;
}

/* ── Responsive ── */
@media (max-width: 1024px) {
  .footer-content {
    grid-template-columns: 220px 110px 1fr;
    grid-template-rows: auto auto auto;
  }
  .footer-col-right  { grid-column: 3; grid-row: 2; }
  .footer-search     { grid-column: 1 / 4; grid-row: 3; justify-content: flex-start; }
}

@media (max-width: 640px) {
  .footer-content {
    grid-template-columns: 1fr;
    padding: 32px 20px 24px;
  }
  .footer-brand,
  .footer-col,
  .footer-col-right,
  .footer-search { grid-column: 1; grid-row: auto; }
  .search-bar    { min-width: unset; width: 100%; }
  .footer-search { flex-direction: column; align-items: stretch; }
  .footer-bottom { padding: 12px 20px; flex-direction: column; gap: 4px; text-align: center; }
}
</style>
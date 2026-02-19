<template>
  <section class="vision-section">

    <!-- Moroccan pattern background (left side) -->
    <div class="pattern-bg"></div>

    <div class="vision-inner">

      <!-- Header -->
      <div class="vision-header">
        <h2 class="vision-title">Notre Vision</h2>
        <p class="vision-subtitle">
          Nous croyons que la confiance est la base de toute relation de service réussie. AtlasFix
          a été créée pour répondre à deux besoins essentiels :
        </p>
      </div>

      <!-- Two cards -->
      <div class="vision-cards">

        <!-- Card 1 — Clients -->
        <div class="vision-card">
          <div class="card-body">
            <div class="card-header-row">
              <div class="icon-box blue">
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                  <path d="M9.33 21v-1.556C9.33 17.55 11.493 16 14 16s4.67 1.55 4.67 3.444V21" stroke="#155DFC" stroke-width="2.33" stroke-linecap="round"/>
                  <circle cx="14" cy="10" r="3.5" stroke="#155DFC" stroke-width="2.33"/>
                  <path d="M19.25 11.67a3.5 3.5 0 1 0-3.5-6.06" stroke="#155DFC" stroke-width="2.33" stroke-linecap="round"/>
                  <path d="M22.17 19.44v-1.11C22.17 16.55 21 15.4 19.25 15" stroke="#155DFC" stroke-width="2.33" stroke-linecap="round"/>
                </svg>
              </div>
              <h3 class="card-title">Pour les clients</h3>
            </div>
            <p class="card-desc">
              Faciliter la vie des clients en leur offrant un moyen simple et fiable de trouver des services de qualité.
            </p>
          </div>
        </div>

        <!-- Card 2 — Artisans -->
        <div class="vision-card">
          <div class="card-body">
            <div class="card-header-row">
              <div class="icon-box orange">
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                  <rect x="5" y="11" width="18" height="12" rx="2" stroke="#F54900" stroke-width="2.33"/>
                  <path d="M9.33 11V9.33A4.67 4.67 0 0 1 14 4.67v0a4.67 4.67 0 0 1 4.67 4.66V11" stroke="#F54900" stroke-width="2.33" stroke-linecap="round"/>
                  <circle cx="14" cy="17" r="1.5" fill="#F54900"/>
                </svg>
              </div>
              <h3 class="card-title">Pour les artisans</h3>
            </div>
            <p class="card-desc">
              Donner de la visibilité et des opportunités aux artisans et professionnels locaux.
            </p>
          </div>
        </div>

      </div>

      <!-- Footer text -->
      <p class="vision-footer">
        Ancrée dans les valeurs marocaines de proximité, de respect et de solidarité, AtlasFix
        est une plateforme moderne, pensée pour évoluer et s'ouvrir à d'autres marchés à l'avenir.
      </p>

    </div>
  </section>
</template>

<script setup>
// No logic needed — purely presentational
</script>

<style scoped>
/* ── SECTION ──────────────────────────────────────────────── */
.vision-section {
  position: relative;
  width: 100%;
  min-height: 646px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'Poppins', sans-serif;
}

/* ── MOROCCAN PATTERN (left decorative bg) ────────────────── */
.pattern-bg {
  position: absolute;
  left: 0;
  top: 0;
  width: 641px;
  height: 565px;
  background:
    linear-gradient(167.2deg, #FFFFFF 7.62%, rgba(255,255,255,0) 39.91%),
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80'%3E%3Cg fill='none' stroke-width='1'%3E%3Cpolygon points='40,5 55,15 65,30 65,50 55,65 40,75 25,65 15,50 15,30 25,15' stroke='%23FC5A15' opacity='0.15'/%3E%3Cpolygon points='40,12 52,20 60,32 60,48 52,60 40,68 28,60 20,48 20,32 28,20' stroke='%23155DFC' opacity='0.12'/%3E%3Cpolygon points='40,19 49,25 55,34 55,46 49,55 40,61 31,55 25,46 25,34 31,25' stroke='%2334F1AB' opacity='0.1'/%3E%3C/g%3E%3C/svg%3E") repeat;
  pointer-events: none;
  z-index: 0;
}

/* ── CONTENT ──────────────────────────────────────────────── */
.vision-inner {
  position: relative;
  z-index: 1;
  width: 1248px;
  max-width: calc(100% - 48px);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 38px;
  padding: 60px 0;
}

/* ── HEADER ───────────────────────────────────────────────── */
.vision-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 26px;
  width: 100%;
}

.vision-title {
  width: 100%;
  font-size: 40px;
  font-weight: 500;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
  text-align: center;
  margin: 0;
}

.vision-subtitle {
  max-width: 835px;
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  text-align: center;
  margin: 0;
}

/* ── CARDS ROW ────────────────────────────────────────────── */
.vision-cards {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 32px;
  width: 100%;
}

/* ── SINGLE CARD ──────────────────────────────────────────── */
.vision-card {
  flex: 1;
  min-height: 211px;
  background: #ffffff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  /* Orange left accent bar */
  box-shadow:
    -3px 0px 0px #FC5A15,
    0px 10px 15px -3px rgba(0,0,0,0.1),
    0px 4px 6px -4px rgba(0,0,0,0.1);
  box-sizing: border-box;
  transition: transform 0.2s, box-shadow 0.2s;
}

.vision-card:hover {
  transform: translateY(-4px);
  box-shadow:
    -3px 0px 0px #FC5A15,
    0px 20px 30px -6px rgba(0,0,0,0.12),
    0px 8px 12px -4px rgba(0,0,0,0.08);
}

.card-body {
  display: flex;
  flex-direction: column;
  gap: 24px;
  padding: 41px 41px 41px;
}

/* ── CARD HEADER ROW (icon + title) ───────────────────────── */
.card-header-row {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
}

/* Icon box */
.icon-box {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.icon-box.blue   { background: #DBEAFE; }
.icon-box.orange { background: #FFEDD4; }

/* Card title */
.card-title {
  font-size: 24px;
  font-weight: 400;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #314158;
  margin: 0;
}

/* Card description */
.card-desc {
  font-size: 18px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.44px;
  color: #62748E;
  margin: 0;
}

/* ── FOOTER TEXT ──────────────────────────────────────────── */
.vision-footer {
  max-width: 835px;
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  text-align: center;
  margin: 0;
}

/* ── RESPONSIVE ───────────────────────────────────────────── */
@media (max-width: 860px) {
  .vision-cards   { flex-direction: column; }
  .vision-title   { font-size: 30px; }
  .vision-subtitle,
  .vision-footer  { font-size: 16px; }
  .card-title     { font-size: 20px; }
  .card-desc      { font-size: 15px; }
  .card-body      { padding: 28px; }
  .pattern-bg     { width: 100%; opacity: 0.5; }
}
</style>
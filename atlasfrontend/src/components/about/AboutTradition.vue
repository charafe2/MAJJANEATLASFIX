<template>
  <section class="tradition-section">
    <div class="tradition-bg"></div>

    <div class="tradition-inner">

      <!-- Big centered title -->
      <h2 class="main-title">
        AtlasFix, entre <span class="orange">tradition</span> et <span class="orange">modernité</span>
      </h2>

      <!-- Content row -->
      <div class="content-row">

        <!-- LEFT — photo -->
        <div class="photo-wrap">
          <img
            src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800&q=80"
            alt="Artisan électricien"
            class="artisan-photo"
          />
        </div>

        <!-- RIGHT — text -->
        <div class="text-col">

          <div class="text-header">
            <h3 class="sub-title">AtlasFix, entre tradition et modernité</h3>
            <!-- Orange accent lines -->
            <div class="accent-lines">
              <span class="line-long"></span>
              <span class="line-short"></span>
            </div>
          </div>

          <div class="paragraphs">
            <p>
              AtlasFix est bien plus qu'un simple site de services. C'est un
              <span class="orange-underline">pont entre tradition et modernité</span>,
              entre le savoir-faire des artisans marocains et les attentes des familles
              et des entreprises d'aujourd'hui.
            </p>
            <p>
              Notre ambition est de devenir une référence des services de proximité,
              d'abord au Maroc, puis à l'international, tout en restant fidèles à nos valeurs :
              <span class="orange-underline">confiance, transparence et esprit communautaire.</span>
            </p>
          </div>

        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
// Purely presentational
</script>

<style scoped>
/* ── SECTION ──────────────────────────────────────────────── */
.tradition-section {
  position: relative;
  width: 100%;
  min-height: 705px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'Poppins', sans-serif;
}

/* Brick wall bg — same gradient as AboutWhy */
.tradition-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(269.47deg, rgba(255,255,255,0) 77.68%, #FFFFFF 99.17%),
    linear-gradient(180deg, rgba(255,255,255,0.75) 17.02%, rgba(255,255,255,0) 64.16%),
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='60'%3E%3Crect width='120' height='60' fill='%23f5f5f5'/%3E%3Crect x='0' y='0' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='62' y='0' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='-30' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='31' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='92' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3C/svg%3E") repeat;
  pointer-events: none;
  z-index: 0;
}

/* ── INNER ────────────────────────────────────────────────── */
.tradition-inner {
  position: relative;
  z-index: 1;
  width: 1260px;
  max-width: calc(100% - 48px);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 46px;
  padding: 60px 0;
}

/* ── BIG TITLE ────────────────────────────────────────────── */
.main-title {
  width: 100%;
  font-size: 40px;
  font-weight: 500;
  line-height: 60px;
  letter-spacing: -0.44px;
  color: #000000;
  text-align: center;
  margin: 0;
}

.orange { color: #FC5A15; }

/* ── CONTENT ROW ──────────────────────────────────────────── */
.content-row {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  gap: 59px;
  width: 100%;
}

/* ── PHOTO ────────────────────────────────────────────────── */
.photo-wrap {
  width: 536px;
  height: 383px;
  flex-shrink: 0;
  border-radius: 31px;
  overflow: hidden;
  box-shadow: 3px 5px 12px rgba(0, 0, 0, 0.25);
}

.artisan-photo {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  display: block;
}

/* ── TEXT COL ─────────────────────────────────────────────── */
.text-col {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 40px;
  width: 665px;
  flex-shrink: 0;
}

/* Header block — sub title + accent lines */
.text-header {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 15px;
}

.sub-title {
  font-size: 30px;
  font-weight: 400;
  line-height: 60px;
  letter-spacing: -0.44px;
  color: #000000;
  margin: 0;
}

/* Orange accent lines */
.accent-lines {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 8px;
}

.line-long {
  display: block;
  width: 95px;
  height: 0;
  border-top: 3px solid #FC5A15;
}

.line-short {
  display: block;
  width: 19px;
  height: 0;
  border-top: 3px solid #FC5A15;
}

/* Paragraphs block */
.paragraphs {
  display: flex;
  flex-direction: column;
  gap: 23px;
  width: 665px;
}

.paragraphs p {
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  margin: 0;
}

/* Orange underlined text spans */
.orange-underline {
  color: #FC5A15;
  text-decoration: underline;
  text-decoration-color: rgba(252, 90, 21, 0.4);
  text-underline-offset: 3px;
}

/* ── RESPONSIVE ───────────────────────────────────────────── */
@media (max-width: 1000px) {
  .content-row  { flex-direction: column; align-items: center; gap: 36px; }
  .photo-wrap   { width: 100%; height: 280px; }
  .text-col     { width: 100%; }
  .paragraphs   { width: 100%; }
  .main-title   { font-size: 28px; line-height: 1.3; }
  .sub-title    { font-size: 22px; line-height: 1.4; }
  .paragraphs p { font-size: 16px; }
}

@media (max-width: 580px) {
  .main-title   { font-size: 22px; }
  .sub-title    { font-size: 18px; }
  .paragraphs p { font-size: 14px; }
}
</style>
<template>
  <section class="community-section">
    <div class="community-bg"></div>

    <div class="community-inner">
      <div class="community-card">

        <!-- LEFT — Text -->
        <div class="card-left">

          <h2 class="card-title">
            Une plateforme au service<br>de la communauté
          </h2>

          <p class="card-desc">
            AtlasFix ne se limite pas à la mise en relation. Nous accompagnons les artisans dans leur
            développement digital et valorisons le savoir-faire local. Chaque service réservé contribue
            à soutenir l'économie locale et à renforcer un écosystème basé sur la confiance et l'équité.
          </p>

          <ul class="feature-list">
            <li v-for="item in features" :key="item.text" class="feature-item">
              <div class="feature-icon">
                <component :is="item.icon" />
              </div>
              <span class="feature-text">{{ item.text }}</span>
            </li>
          </ul>

        </div>

        <!-- RIGHT — Artisan photo -->
        <div class="card-right">
          <img
            src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800&q=80"
            alt="Artisan au travail"
            class="artisan-img"
          />
        </div>

      </div>
    </div>
  </section>
</template>

<script setup>
import { defineComponent, h } from 'vue'

const IconLocal = defineComponent({
  render: () => h('svg', { width: 20, height: 20, viewBox: '0 0 20 20', fill: 'none' }, [
    h('path', { d: 'M10 2C6.69 2 4 4.69 4 8c0 4.5 6 10 6 10s6-5.5 6-10c0-3.31-2.69-6-6-6z', stroke: '#FC5A15', 'stroke-width': '1.67', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
    h('circle', { cx: 10, cy: 8, r: 2, stroke: '#FC5A15', 'stroke-width': '1.67' }),
  ])
})

const IconSavoir = defineComponent({
  render: () => h('svg', { width: 20, height: 20, viewBox: '0 0 20 20', fill: 'none' }, [
    h('path', { d: 'M10 2l1.8 5.4H17l-4.5 3.3 1.7 5.3L10 13l-4.2 3 1.7-5.3L3 7.4h5.2L10 2z', stroke: '#FC5A15', 'stroke-width': '1.67', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconFormation = defineComponent({
  render: () => h('svg', { width: 20, height: 20, viewBox: '0 0 20 20', fill: 'none' }, [
    h('path', { d: 'M3 10l7-7 7 7', stroke: '#FC5A15', 'stroke-width': '1.67', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
    h('path', { d: 'M5 8v7h4v-4h2v4h4V8', stroke: '#FC5A15', 'stroke-width': '1.67', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconEco = defineComponent({
  render: () => h('svg', { width: 20, height: 20, viewBox: '0 0 20 20', fill: 'none' }, [
    h('path', { d: 'M10 2a8 8 0 1 0 0 16A8 8 0 0 0 10 2z', stroke: '#FC5A15', 'stroke-width': '1.67' }),
    h('path', { d: 'M7 10l2 2 4-4', stroke: '#FC5A15', 'stroke-width': '1.67', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const features = [
  { icon: IconLocal,    text: "Soutien à l'économie locale" },
  { icon: IconSavoir,   text: 'Valorisation du savoir-faire marocain' },
  { icon: IconFormation,text: 'Formation et accompagnement digital' },
  { icon: IconEco,      text: 'Écosystème équitable et transparent' },
]
</script>

<style scoped>
/* ── SECTION ──────────────────────────────────────────────── */
.community-section {
  position: relative;
  width: 100%;
  min-height: 863px;
  background: linear-gradient(180deg, #F9FAFB 0%, #FFFFFF 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'Poppins', sans-serif;
}

.community-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(118.32deg, #F9FAFB 10.84%, #FFFFFF 89.16%);
  pointer-events: none;
  z-index: 0;
}

/* ── WRAPPER ──────────────────────────────────────────────── */
.community-inner {
  position: relative;
  z-index: 1;
  width: 1248px;
  max-width: calc(100% - 48px);
  padding: 60px 0;
}

/* ── MAIN CARD ────────────────────────────────────────────── */
.community-card {
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 664px;
  background: #ffffff;
  border: 1px solid #F3F4F6;
  box-shadow: 0px 6px 11.3px -2px rgba(0,0,0,0.25);
  border-radius: 24px;
  overflow: hidden;
}

/* ── LEFT SIDE ────────────────────────────────────────────── */
.card-left {
  position: relative;
  width: 623px;
  flex-shrink: 0;
  padding: 74px 48px 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}

.card-title {
  font-size: 40px;
  font-weight: 500;
  line-height: 53px;
  color: #314158;
  margin: 0 0 0 0;
  width: 538px;
}

.card-desc {
  font-size: 18px;
  font-weight: 400;
  line-height: 29px;
  letter-spacing: -0.44px;
  color: #62748E;
  width: 501px;
  margin: 34px 0 0 0;
}

/* ── FEATURE LIST ─────────────────────────────────────────── */
.feature-list {
  list-style: none;
  padding: 0;
  margin: 36px 0 0 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  width: 527px;
}

.feature-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
  height: 40px;
}

.feature-icon {
  width: 40px;
  height: 40px;
  min-width: 40px;
  background: rgba(252, 90, 21, 0.08);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feature-text {
  font-size: 16px;
  font-weight: 400;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

/* ── RIGHT SIDE — photo ───────────────────────────────────── */
.card-right {
  flex: 1;
  overflow: hidden;
}

.artisan-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  display: block;
}

/* ── RESPONSIVE ───────────────────────────────────────────── */
@media (max-width: 960px) {
  .community-card  { flex-direction: column; height: auto; }
  .card-left       { width: 100%; padding: 40px 32px; }
  .card-title      { font-size: 28px; line-height: 1.3; width: 100%; }
  .card-desc       { width: 100%; font-size: 16px; }
  .feature-list    { width: 100%; }
  .card-right      { width: 100%; height: 300px; }
}

@media (max-width: 580px) {
  .card-title { font-size: 22px; }
  .card-desc  { font-size: 14px; }
}
</style>
<template>
  <section class="why-section">

    <!-- Brick wall background -->
    <div class="why-bg"></div>

    <div class="why-inner">

      <!-- Header -->
      <div class="why-header">
        <h2 class="why-title">Pourquoi choisir AtlasFix ?</h2>
        <p class="why-subtitle">
          AtlasFix se distingue par une approche centrée sur l'humain et la transparence :
        </p>
      </div>

      <!-- Cards grid -->
      <div class="why-grid">

        <!-- Row 1 — 3 cards -->
        <div class="why-row row-3">
          <div class="why-card" v-for="c in row1" :key="c.title">
            <div class="icon-box" :style="{ background: c.iconBg }">
              <component :is="c.icon" />
            </div>
            <h3 class="card-title">{{ c.title }}</h3>
            <p class="card-desc">{{ c.desc }}</p>
          </div>
        </div>

        <!-- Row 2 — 2 cards centered -->
        <div class="why-row row-2">
          <div class="why-card" v-for="c in row2" :key="c.title">
            <div class="icon-box" :style="{ background: c.iconBg }">
              <component :is="c.icon" />
            </div>
            <h3 class="card-title">{{ c.title }}</h3>
            <p class="card-desc">{{ c.desc }}</p>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>

<script setup>
import { defineComponent, h } from 'vue'

// ── Inline SVG icon components ──────────────────────────────
const IconShield = defineComponent({
  render: () => h('svg', { width: 28, height: 28, viewBox: '0 0 28 28', fill: 'none' }, [
    h('path', { d: 'M14 3L5 7v7c0 5.25 3.85 10.15 9 11.35C19.15 24.15 23 19.25 23 14V7L14 3z', stroke: '#155DFC', 'stroke-width': '2.33', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconStar = defineComponent({
  render: () => h('svg', { width: 28, height: 28, viewBox: '0 0 28 28', fill: 'none' }, [
    h('path', { d: 'M14 3l2.78 8.55H24l-7.09 5.15 2.71 8.33L14 19.88l-5.62 5.15 2.71-8.33L4 11.55h7.22L14 3z', stroke: '#D08700', 'stroke-width': '2.33', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconBolt = defineComponent({
  render: () => h('svg', { width: 28, height: 28, viewBox: '0 0 28 28', fill: 'none' }, [
    h('path', { d: 'M15.5 3.5L7 16h7l-1.5 8.5L23 13h-7l-.5-9.5z', stroke: '#9810FA', 'stroke-width': '2.33', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconCheck = defineComponent({
  render: () => h('svg', { width: 28, height: 28, viewBox: '0 0 28 28', fill: 'none' }, [
    h('circle', { cx: 14, cy: 14, r: 10.5, stroke: '#00A63E', 'stroke-width': '2.33' }),
    h('path', { d: 'M9.5 14l3 3 6-6', stroke: '#00A63E', 'stroke-width': '2.33', 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
  ])
})

const IconGlobe = defineComponent({
  render: () => h('svg', { width: 28, height: 28, viewBox: '0 0 28 28', fill: 'none' }, [
    h('circle', { cx: 14, cy: 14, r: 10.5, stroke: '#4F39F6', 'stroke-width': '2.33' }),
    h('path', { d: 'M3.5 14h21M14 3.5c-2.8 2.8-4.2 6.3-4.2 10.5s1.4 7.7 4.2 10.5M14 3.5c2.8 2.8 4.2 6.3 4.2 10.5s-1.4 7.7-4.2 10.5', stroke: '#4F39F6', 'stroke-width': '2.33', 'stroke-linecap': 'round' }),
  ])
})

const row1 = [
  {
    icon:    IconShield,
    iconBg:  '#DBEAFE',
    title:   'Des prestataires sélectionnés et évalués',
    desc:    'pour garantir la qualité des services.',
  },
  {
    icon:    IconStar,
    iconBg:  '#FEF9C2',
    title:   'Des avis clients authentiques',
    desc:    'pour vous aider à faire le bon choix.',
  },
  {
    icon:    IconBolt,
    iconBg:  '#F3E8FF',
    title:   'Une réservation simple et rapide',
    desc:    'sans démarches compliquées.',
  },
]

const row2 = [
  {
    icon:    IconCheck,
    iconBg:  '#DCFCE7',
    title:   'Des conditions claires,',
    desc:    'sans frais cachés',
  },
  {
    icon:    IconGlobe,
    iconBg:  '#E0E7FF',
    title:   'Une plateforme multilingue',
    desc:    'accessible à tous.',
  },
]
</script>

<style scoped>
/* ── SECTION ──────────────────────────────────────────────── */
.why-section {
  position: relative;
  width: 100%;
  min-height: 801px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'Poppins', sans-serif;
}

/* ── BRICK WALL BACKGROUND ────────────────────────────────── */
.why-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(269.47deg, rgba(255,255,255,0) 77.68%, #FFFFFF 99.17%),
    linear-gradient(180deg, rgba(255,255,255,0.75) 17.02%, rgba(255,255,255,0) 64.16%),
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='60'%3E%3Crect width='120' height='60' fill='%23f5f5f5'/%3E%3Crect x='0' y='0' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='62' y='0' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='-30' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='31' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3Crect x='92' y='31' width='58' height='28' rx='2' fill='none' stroke='%23e0e0e0' stroke-width='1'/%3E%3C/svg%3E") repeat;
  pointer-events: none;
  z-index: 0;
}

/* ── CONTENT ──────────────────────────────────────────────── */
.why-inner {
  position: relative;
  z-index: 1;
  width: 1248px;
  max-width: calc(100% - 48px);
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 48px;
  padding: 96px 0;
}

/* ── HEADER ───────────────────────────────────────────────── */
.why-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  width: 100%;
}

.why-title {
  width: 100%;
  font-size: 40px;
  font-weight: 500;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
  text-align: center;
  margin: 0;
}

.why-subtitle {
  max-width: 762px;
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  text-align: center;
  margin: 0;
}

/* ── CARDS GRID ───────────────────────────────────────────── */
.why-grid {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  width: 100%;
}

.why-row {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 24px;
}

.row-3 { width: 100%; justify-content: space-between; }
.row-2 { width: 824px; justify-content: center; }

/* ── SINGLE CARD ──────────────────────────────────────────── */
.why-card {
  position: relative;
  width: 400px;
  height: 234px;
  background: #ffffff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  box-shadow:
    0px 10px 15px -3px rgba(0,0,0,0.1),
    0px 4px 6px -4px rgba(0,0,0,0.1);
  box-sizing: border-box;
  flex-shrink: 0;
  transition: transform 0.2s, box-shadow 0.2s;
}

.why-card:hover {
  transform: translateY(-4px);
  box-shadow:
    0px 20px 30px -6px rgba(0,0,0,0.12),
    0px 8px 12px -4px rgba(0,0,0,0.08);
}

/* ── ICON BOX ─────────────────────────────────────────────── */
.icon-box {
  position: absolute;
  left: 33px;
  top: 33px;
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ── CARD TEXT ────────────────────────────────────────────── */
.card-title {
  position: absolute;
  left: 33px;
  top: 113px;
  width: 297px;
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0;
}

.card-desc {
  position: absolute;
  left: 33px;
  top: 177px;
  width: 310px;
  font-size: 16px;
  font-weight: 400;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

/* ── RESPONSIVE ───────────────────────────────────────────── */
@media (max-width: 1100px) {
  .row-3, .row-2 { flex-wrap: wrap; justify-content: center; width: 100%; }
  .why-card      { width: 340px; height: auto; min-height: 200px; padding: 28px; }
  .icon-box      { position: static; margin-bottom: 16px; }
  .card-title    { position: static; width: 100%; margin-bottom: 8px; }
  .card-desc     { position: static; width: 100%; }
  .why-title     { font-size: 30px; }
  .why-subtitle  { font-size: 16px; }
}

@media (max-width: 680px) {
  .why-card { width: 100%; }
}
</style>
<template>
    <ServicesHero/>
  <section class="services-section">

    <!-- Search bar -->
    <div class="search-wrapper">
      <svg class="search-icon" viewBox="0 0 20 20" fill="none">
        <circle cx="8.5" cy="8.5" r="5.5" stroke="#62748E" stroke-width="1.667"/>
        <path d="M13 13L17 17" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
      </svg>
      <input
        v-model="searchQuery"
        class="search-input"
        type="text"
        placeholder="Rechercher un service (plomberie, électricité, beauté...)"
      />
    </div>

    <!-- Card grid -->
    <div class="grid">
      <div
        v-for="(row, rowIdx) in filteredRows"
        :key="rowIdx"
        class="grid-row"
      >
        <div
          v-for="(card, cIdx) in row"
          :key="card.title"
          class="service-card"
          :style="{ animationDelay: `${(rowIdx * 4 + cIdx) * 0.06}s` }"
        >
          <!-- Colour band -->
          <div class="card-image" :style="{ background: card.bg }">
            <div class="img-overlay" />
            <div class="img-icon-badge">
              <component :is="card.icon" />
            </div>
          </div>

          <!-- Text content -->
          <div class="card-body">
            <h3 class="card-title">{{ card.title }}</h3>
            <ul class="card-services">
              <li v-for="s in card.services" :key="s">
                <span class="bullet-wrap">
                  <svg viewBox="0 0 16 16" fill="none">
                    <circle cx="8" cy="8" r="7" stroke="#FC5A15" stroke-width="1.333"/>
                    <path d="M5 8.5L7.5 11L11 6" stroke="#FC5A15" stroke-width="1.333"
                      stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </span>
                {{ s }}
              </li>
            </ul>
            <button class="card-btn">
              Voir les artisans
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M4 10h12M12 6l4 4-4 4" stroke="white" stroke-width="1.667"
                  stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </div>
        </div>
      </div>

      <p v-if="filteredRows.length === 0" class="no-results">
        Aucun service trouvé pour «&nbsp;{{ searchQuery }}&nbsp;»
      </p>
    </div>

  </section>
</template>

<script>
import { defineComponent, h } from 'vue'
import ServicesHero from './servicesHero.vue'

/**
 * makeIcon(shapes)
 * ─────────────────
 * Accepts an array of shape descriptors and returns a Vue component
 * that renders a 24×24 SVG.
 *
 * Each descriptor is a plain object:
 *   { tag?, ...svgAttrs }
 *
 * tag defaults to 'path'.
 * Other valid tags: 'circle', 'rect', 'polygon', 'polyline', 'line'
 *
 * This is the ONLY correct way to render mixed SVG elements from data.
 * Do NOT use v-bind on <path> to try to switch element types — it doesn't work.
 */
function makeIcon(shapes) {
  return defineComponent({
    render() {
      return h(
        'svg',
        { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' },
        shapes.map(({ tag = 'path', ...attrs }) => h(tag, attrs)),
      )
    },
  })
}

/* Stroke attribute shorthands */
const S  = '#FC5A15'
const W  = { stroke: S, 'stroke-width': '2' }
const R  = { ...W, 'stroke-linecap': 'round' }
const RJ = { ...R, 'stroke-linejoin': 'round' }
const NF = { fill: 'none' }

/* ─── All 28 service cards grouped into 7 rows of 4 ─────── */
const ROWS = [

  /* ══ ROW 1 ══════════════════════════════════════════════ */
  [
    {
      title: 'Plomberie',
      bg: 'linear-gradient(135deg,#b8d4e8,#3a8ab0)',
      services: ['Réparation de fuite', 'Installation sanitaire', 'Réparation de toilette', 'Débouchage'],
      icon: makeIcon([
        { d: 'M12 2v10', ...R },
        { d: 'M8 6l4-4 4 4', ...RJ },
        { d: 'M5 14h14', ...R },
        { d: 'M6 14v6a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-6', ...RJ, ...NF },
      ]),
    },
    {
      title: 'Électricité',
      bg: 'linear-gradient(135deg,#fde8b8,#c89800)',
      services: ['Installation de luminaires', 'Réparation prises & interrupteurs', 'Installation ventilateur de plafond'],
      icon: makeIcon([
        { d: 'M13 2L4.5 13.5H11L10 22l8.5-12H13z', ...RJ },
      ]),
    },
    {
      title: 'Peinture',
      bg: 'linear-gradient(135deg,#e8d4f5,#8040b0)',
      services: ['Travaux de peinture intérieure'],
      icon: makeIcon([
        { d: 'M4 20l4-4L18 6a2 2 0 0 0-2.83-2.83L5 13.17 4 20z', ...RJ },
        { d: 'M17 3l4 4', ...R },
      ]),
    },
    {
      title: 'Réparations générales',
      bg: 'linear-gradient(135deg,#d4e8d4,#307840)',
      services: ['Montage TV, étagères, tringles', 'Réparation portes & serrures', 'Petites menuiseries', 'Joints & silicone'],
      icon: makeIcon([
        { d: 'M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z', ...RJ, ...NF },
      ]),
    },
  ],

  /* ══ ROW 2 ══════════════════════════════════════════════ */
  [
    {
      title: 'Déménagement',
      bg: 'linear-gradient(135deg,#e8e0d4,#906020)',
      services: ['Déménagement local', 'Emballage & déballage', 'Transport de meubles'],
      icon: makeIcon([
        { d: 'M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z', ...RJ, ...NF },
        { d: 'M3.27 6.96L12 12l8.73-5.04M12 22V12', ...R },
      ]),
    },
    {
      title: 'Électroménager',
      bg: 'linear-gradient(135deg,#d4e4f5,#205098)',
      services: ['Réparation lave-linge / sèche-linge', 'Réparation réfrigérateur', 'Réparation four / cuisinière'],
      icon: makeIcon([
        { d: 'M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z', ...W, ...NF },
        { d: 'M3 9h18M9 21V9', ...W },
      ]),
    },
    {
      title: 'Nettoyage',
      bg: 'linear-gradient(135deg,#d4f5e8,#10804a)',
      services: ['Nettoyage standard', 'Nettoyage en profondeur', 'Nettoyage après déménagement'],
      icon: makeIcon([
        { d: 'M3 6h18M3 12h18M3 18h18', ...R },
        { d: 'M8 3v3M16 3v3M8 18v3M16 18v3', ...R },
      ]),
    },
    {
      title: 'Chauffage, Ventilation et Climatisation',
      bg: 'linear-gradient(135deg,#ffe4d4,#c04010)',
      services: ['Entretien climatisation', 'Réparation climatisation', 'Entretien chauffage'],
      icon: makeIcon([
        { d: 'M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83', ...R },
        { tag: 'circle', cx: '12', cy: '12', r: '3', ...W },
      ]),
    },
  ],

  /* ══ ROW 3 ══════════════════════════════════════════════ */
  [
    {
      title: 'Mécanicien Mobile',
      bg: 'linear-gradient(135deg,#e4e4e4,#505050)',
      services: ['Diagnostic de base', 'Remplacement plaquettes de frein', 'Remplacement batterie', 'Vérification alternateur'],
      icon: makeIcon([
        { d: 'M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z', ...RJ, ...NF },
      ]),
    },
    {
      title: 'Vidange Mobile',
      bg: 'linear-gradient(135deg,#f5e8d4,#904010)',
      services: ['Vidange standard', 'Vidange huile synthétique'],
      icon: makeIcon([
        { d: 'M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5S12.5 5 12 2.5C11.5 5 10 7.4 8 9c-2 1.6-3 3.5-3 5a7 7 0 0 0 7 7z', ...RJ, ...NF },
      ]),
    },
    {
      title: 'Assistance Routière',
      bg: 'linear-gradient(135deg,#d4e8f5,#104878)',
      services: ['Démarrage batterie', 'Changement de pneu', 'Ouverture de porte (lockout)'],
      icon: makeIcon([
        { d: 'M5 17H3a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h11l5 5v5h-2', ...RJ, ...NF },
        { tag: 'circle', cx: '7',  cy: '17', r: '2', ...W },
        { tag: 'circle', cx: '17', cy: '17', r: '2', ...W },
      ]),
    },
    {
      title: "Organisation d'événements",
      bg: 'linear-gradient(135deg,#fde8f5,#902070)',
      services: ['Planification complète', 'Coordination le jour'],
      icon: makeIcon([
        { d: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z', ...RJ, ...NF },
      ]),
    },
  ],

  /* ══ ROW 4 ══════════════════════════════════════════════ */
  [
    {
      title: 'Photographie',
      bg: 'linear-gradient(135deg,#e8d4d4,#702020)',
      services: ["Photographie d'événements", 'Portraits', 'Photographie de produits'],
      icon: makeIcon([
        { d: 'M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z', ...RJ, ...NF },
        { tag: 'circle', cx: '12', cy: '13', r: '4', ...W },
      ]),
    },
    {
      title: 'Vidéographie',
      bg: 'linear-gradient(135deg,#d4d4e8,#303080)',
      services: ["Vidéos d'événements", 'Vidéos promotionnelles'],
      icon: makeIcon([
        { d: 'M23 7l-7 5 7 5V7z', ...RJ, ...NF },
        { tag: 'rect', x: '1', y: '5', width: '15', height: '14', rx: '2', ry: '2', ...W, ...NF },
      ]),
    },
    {
      title: 'Musique & Animation',
      bg: 'linear-gradient(135deg,#f5e8d4,#803010)',
      services: ['DJ', 'Groupes de musique', 'Musiciens solo'],
      icon: makeIcon([
        { d: 'M9 18V5l12-2v13', ...RJ },
        { tag: 'circle', cx: '6',  cy: '18', r: '3', ...W },
        { tag: 'circle', cx: '18', cy: '16', r: '3', ...W },
      ]),
    },
    {
      title: 'Beauté & Style',
      bg: 'linear-gradient(135deg,#fde8f0,#902050)',
      services: ['Maquillage', 'Coiffure', 'Forfaits mariage'],
      icon: makeIcon([
        { d: 'M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z', ...RJ, ...NF },
      ]),
    },
  ],

  /* ══ ROW 5 ══════════════════════════════════════════════ */
  [
    {
      title: 'Services de Restauration',
      bg: 'linear-gradient(135deg,#f5f0d4,#806000)',
      services: ['Aide au service', 'Serveurs'],
      icon: makeIcon([
        { d: 'M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8zM6 1v3M10 1v3M14 1v3', ...RJ, ...NF },
      ]),
    },
    {
      title: "Décoration d'Événements",
      bg: 'linear-gradient(135deg,#e8f5d4,#308000)',
      services: ['Décoration de salle', 'Ballons & arches', 'Centres de table'],
      icon: makeIcon([
        { d: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z', ...RJ, ...NF },
      ]),
    },
    {
      title: 'Location de Matériel',
      bg: 'linear-gradient(135deg,#e8e4d4,#605030)',
      services: ['Chaises & tables', 'Vaisselle', 'Tentes & chapiteaux'],
      icon: makeIcon([
        { d: 'M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z', ...RJ, ...NF },
      ]),
    },
    {
      title: 'Réparation Ordinateurs',
      bg: 'linear-gradient(135deg,#d4e4f5,#103060)',
      services: ['Réparation ordinateur portable', 'Suppression de virus', 'Récupération de données'],
      icon: makeIcon([
        { d: 'M2 17h20M4 5h16a1 1 0 0 1 1 1v11H3V6a1 1 0 0 1 1-1z', ...RJ, ...NF },
        { d: 'M8 21h8M12 17v4', ...R },
      ]),
    },
  ],

  /* ══ ROW 6 ══════════════════════════════════════════════ */
  [
    {
      title: 'Réseau & WiFi',
      bg: 'linear-gradient(135deg,#d4f5f5,#006060)',
      services: ['Installation routeur', 'Optimisation WiFi', 'Installation réseau maison'],
      icon: makeIcon([
        { d: 'M5 12.55a11 11 0 0 1 14.08 0',  ...R },
        { d: 'M1.42 9a16 16 0 0 1 21.16 0',   ...R },
        { d: 'M8.53 16.11a6 6 0 0 1 6.95 0',  ...R },
        { tag: 'circle', cx: '12', cy: '20', r: '1', fill: S, stroke: 'none' },
      ]),
    },
    {
      title: 'Maison Connectée',
      bg: 'linear-gradient(135deg,#f5f0d4,#606000)',
      services: ['Installation caméras', 'Serrures intelligentes', 'Éclairage intelligent'],
      icon: makeIcon([
        { d: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z', ...RJ, ...NF },
        { d: 'M9 22V12h6v10', ...R },
      ]),
    },
    {
      title: 'Support Technique',
      bg: 'linear-gradient(135deg,#e8e8f5,#303060)',
      services: ["Configuration d'appareils", 'Assistance logicielle', 'Support email & comptes'],
      icon: makeIcon([
        { d: 'M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z', ...W, ...NF },
        { d: 'M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3', ...R },
        { tag: 'circle', cx: '12', cy: '17', r: '1', fill: S, stroke: 'none' },
      ]),
    },
    {
      title: 'Réparation Téléphones & Tablettes',
      bg: 'linear-gradient(135deg,#f5d4e8,#600030)',
      services: ["Remplacement d'écran", 'Remplacement batterie', 'Réparation port de charge'],
      icon: makeIcon([
        { d: 'M17 2H7a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z', ...W, ...NF },
        { d: 'M12 18h.01', ...R },
      ]),
    },
  ],

  /* ══ ROW 7 ══════════════════════════════════════════════ */
  [
    {
      title: 'Lavage auto à domicile',
      bg: 'linear-gradient(135deg,#d4e8f5,#103860)',
      services: ['Nettoyage extérieur', 'Nettoyage intérieur', 'Lavage complet (à domicile)'],
      icon: makeIcon([
        { d: 'M3 17l2-7h14l2 7H3z', ...RJ, ...NF },
        { tag: 'circle', cx: '7.5',  cy: '17', r: '2', ...W },
        { tag: 'circle', cx: '16.5', cy: '17', r: '2', ...W },
        { d: 'M5 10h14', ...R },
      ]),
    },
    {
      title: 'Car Detailing',
      bg: 'linear-gradient(135deg,#f5e8d4,#603010)',
      services: ['Detailing intérieur', 'Detailing extérieur', 'Detailing complet (à domicile)'],
      icon: makeIcon([
        { d: 'M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z', ...W, ...NF },
        { d: 'M8 13s1.5 2 4 2 4-2 4-2', ...R },
        { d: 'M9 9h.01M15 9h.01', ...R },
      ]),
    },
    {
      title: 'Diagnostic OBD mobile',
      bg: 'linear-gradient(135deg,#e8e4d4,#404010)',
      services: ['Diagnostic électronique', 'Lecture des codes défaut', 'Rapport de diagnostic (à domicile)'],
      icon: makeIcon([
        { d: 'M9 3H5a2 2 0 0 0-2 2v4m6-6h10a2 2 0 0 1 2 2v4M9 3v18m0 0h10a2 2 0 0 0 2-2V9M9 21H5a2 2 0 0 1-2-2V9m0 0h18', ...R },
      ]),
    },
    {
      title: 'Jardinage & Extérieur',
      bg: 'linear-gradient(135deg,#d4f0d4,#104810)',
      services: ['Tonte de gazon', 'Taille de haies', 'Entretien jardin'],
      icon: makeIcon([
        { d: 'M12 22V12', ...R },
        { d: 'M12 12C12 8 15 5 19 5c0 4-3 7-7 7z', ...RJ, ...NF },
        { d: 'M12 12C12 8 9 5 5 5c0 4 3 7 7 7z',   ...RJ, ...NF },
      ]),
    },
  ],
]

export default defineComponent({
  name: 'ServicesGrid',
  data() {
    return {
      searchQuery: '',
      rows: ROWS,
    }
  },
  computed: {
    filteredRows() {
      const q = this.searchQuery.trim().toLowerCase()
      if (!q) return this.rows
      return this.rows
        .map(row => row.filter(card =>
          card.title.toLowerCase().includes(q) ||
          card.services.some(s => s.toLowerCase().includes(q))
        ))
        .filter(row => row.length > 0)
    },
  },
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap');

/* ─── Section ─────────────────────────── */
.services-section {
  width: 100%;
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 16px 80px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 36px;
  font-family: 'Inter', sans-serif;
}

/* ─── Search bar ──────────────────────── */
.search-wrapper {
  position: relative;
  width: 100%;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  pointer-events: none;
}

.search-input {
  box-sizing: border-box;
  width: 100%;
  height: 65px;
  padding: 12px 20px 12px 48px;
  border: 2px solid #E5E7EB;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #62748E;
  background: #fff;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.search-input::placeholder { color: #62748E; }

.search-input:focus {
  border-color: #FC5A15;
  box-shadow: 0 0 0 4px rgba(252, 90, 21, 0.1);
}

/* ─── Grid ────────────────────────────── */
.grid {
  display: flex;
  flex-direction: column;
  gap: 23px;
}

.grid-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 23px;
}

/* ─── Card ────────────────────────────── */
.service-card {
  display: flex;
  flex-direction: column;
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,.10), 0 2px 4px -2px rgba(0,0,0,.10);
  animation: fadeUp 0.4s ease both;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.service-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 16px 40px rgba(252, 90, 21, .14);
}

/* ─── Colour band ─────────────────────── */
.card-image {
  position: relative;
  height: 192px;
  flex-shrink: 0;
}

.img-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(0deg, rgba(0,0,0,.45) 0%, rgba(0,0,0,0) 60%);
}

.img-icon-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  z-index: 1;
  width: 48px;
  height: 48px;
  background: rgba(255,255,255,0.92);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(6px);
  transition: transform 0.25s ease;
}

.service-card:hover .img-icon-badge {
  transform: scale(1.1) rotate(-6deg);
}

/* ─── Card body ───────────────────────── */
.card-body {
  display: flex;
  flex-direction: column;
  flex: 1;
  padding: 20px;
}

.card-title {
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 12px;
}

/* ─── Services list ───────────────────── */
.card-services {
  list-style: none;
  margin: 0 0 auto;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.card-services li {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.bullet-wrap {
  flex-shrink: 0;
  width: 16px;
  height: 16px;
  margin-top: 2px;
}

.bullet-wrap svg { display: block; width: 16px; height: 16px; }

/* ─── Button ──────────────────────────── */
.card-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 20px;
  width: 100%;
  height: 48px;
  padding: 0;
  border: none;
  border-radius: 14px;
  background: linear-gradient(180deg, #FC5A15 0%, #E54D0F 100%);
  color: #fff;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 400;
  letter-spacing: -0.31px;
  cursor: pointer;
  transition: filter 0.2s, transform 0.15s;
}

.card-btn:hover { filter: brightness(1.09); transform: scale(1.02); }
.card-btn svg   { width: 20px; height: 20px; flex-shrink: 0; }

/* ─── No results ──────────────────────── */
.no-results {
  text-align: center;
  color: #62748E;
  font-size: 16px;
  padding: 48px 0;
}

/* ─── Keyframes ───────────────────────── */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ─── Responsive ──────────────────────── */
@media (max-width: 1100px) { .grid-row { grid-template-columns: repeat(3, 1fr); } }
@media (max-width:  780px) { .grid-row { grid-template-columns: repeat(2, 1fr); } }
@media (max-width:  500px) {
  .grid-row     { grid-template-columns: 1fr; }
  .search-input { height: 52px; font-size: 14px; }
}
</style>
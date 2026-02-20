<template>
  <section class="hero-section">
    <div class="hero-inner">

      <div class="hero-text">
        <h1 class="hero-title">Nos Services</h1>
        <p class="hero-subtitle">
          Des artisans qualifiés et vérifiés pour tous vos travaux et dépannages à domicile
        </p>
      </div>

      <div class="cards-row">
        <div
          v-for="(stat, index) in stats"
          :key="index"
          class="stat-card"
          :style="{ animationDelay: `${index * 0.1}s` }"
        >
          <div class="icon-circle">
            <component :is="stat.iconComponent" />
          </div>
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-label">{{ stat.label }}</span>
        </div>
      </div>

    </div>
  </section>

  <!-- Services Grid Section -->
  <section class="services-section">
    <div class="services-inner">
      
      <!-- Search bar -->
      <div class="search-bar">
        <svg class="search-icon" viewBox="0 0 20 20" fill="none">
          <circle cx="9" cy="9" r="6" stroke="#62748E" stroke-width="1.667"/>
          <path d="M14 14l4 4" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
        </svg>
        <input 
          type="text" 
          v-model="searchQuery"
          placeholder="Rechercher un service (plomberie, électricité, beauté...)"
          class="search-input"
        />
      </div>

      <!-- Services grid -->
      <div class="services-grid">
        <div 
          v-for="(service, index) in filteredServices" 
          :key="index"
          class="service-card"
          :style="{ animationDelay: `${(index % 4) * 0.1}s` }"
        >
          <!-- Image with overlay -->
          <div class="service-image">
            <div class="image-overlay"></div>
            <div class="service-icon-badge">
              <component :is="service.iconComponent" />
            </div>
          </div>

          <!-- Content -->
          <div class="service-content">
            <h3 class="service-title">{{ service.title }}</h3>
            
            <div class="service-items">
              <div 
                v-for="(item, idx) in service.items" 
                :key="idx"
                class="service-item"
              >
                <svg viewBox="0 0 16 16" fill="none">
                  <circle cx="8" cy="8" r="6" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M6 8l2 2 4-4" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <span>{{ item }}</span>
              </div>
            </div>

            <button class="service-btn" @click="goToService(service.slug)">
              <span>Voir les artisans</span>
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M7 10h10M12 5l5 5-5 5" stroke="white" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </div>
        </div>
      </div>

    </div>
  </section>
</template>

<script>
import { defineComponent, h } from 'vue'

const ArtisansIcon = defineComponent({
  name: 'ArtisansIcon',
  render() {
    return h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
      h('path', { d: 'M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2', stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
      h('circle', { cx: 9, cy: 7, r: 4, stroke: 'white', 'stroke-width': 2 }),
      h('path', { d: 'M23 21v-2a4 4 0 0 0-3-3.87', stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round' }),
      h('path', { d: 'M16 3.13a4 4 0 0 1 0 7.75', stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round' }),
    ])
  },
})

const SatisfactionIcon = defineComponent({
  name: 'SatisfactionIcon',
  render() {
    return h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
      h('polygon', {
        points: '12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2',
        stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round',
      }),
    ])
  },
})

const DisponibiliteIcon = defineComponent({
  name: 'DisponibiliteIcon',
  render() {
    return h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
      h('circle', { cx: 12, cy: 12, r: 10, stroke: 'white', 'stroke-width': 2 }),
      h('polyline', { points: '12 6 12 12 16 14', stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
    ])
  },
})

const SecuriseIcon = defineComponent({
  name: 'SecuriseIcon',
  render() {
    return h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
      h('path', { d: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z', stroke: 'white', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round' }),
    ])
  },
})

export default defineComponent({
  name: 'HeroSection',
  components: { ArtisansIcon, SatisfactionIcon, DisponibiliteIcon, SecuriseIcon },
  methods: {
    goToService(slug) {
      this.$router.push(`/services/${slug}`)
    },
  },
  data() {
    return {
      searchQuery: '',
      stats: [
        { value: '500+',  label: 'Artisans',      iconComponent: ArtisansIcon },
        { value: '4.8/5', label: 'Satisfaction',  iconComponent: SatisfactionIcon },
        { value: '24/7',  label: 'Disponibilité', iconComponent: DisponibiliteIcon },
        { value: '100%',  label: 'Sécurisé',      iconComponent: SecuriseIcon },
      ],
      services: [
        {
          title: 'Plomberie',
          slug: 'plomberie',
          items: ['Réparation de fuite', 'Installation sanitaire', 'Réparation de toilette', 'Débouchage'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M8 3v16M8 12h8', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linecap': 'round' })
            ])
          })
        },
        {
          title: 'Électricité',
          slug: 'electricite',
          items: ['Installation de luminaires', 'Réparation prises & interrupteurs', 'Installation ventilateur de plafond'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M13 2L3 14h8l-1 8 10-12h-8l1-8z', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linejoin': 'round' })
            ])
          })
        },
        {
          title: 'Peinture',
          slug: 'peinture',
          items: ['Travaux de peinture intérieure'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M4 15l4-8 4 8M6 12h4M18 9v6', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linecap': 'round' }),
              h('path', { d: 'M18 6a2 2 0 1 0 0-4 2 2 0 0 0 0 4z', stroke: '#FC5A15', 'stroke-width': 2 })
            ])
          })
        },
        {
          title: 'Réparations générales',
          slug: 'reparations-generales',
          items: ['Montage TV, étagères, tringles', 'Réparation portes & serrures', 'Petites menuiseries', 'Joints & silicone'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z', stroke: '#FC5A15', 'stroke-width': 2 })
            ])
          })
        },
        {
          title: 'Déménagement',
          slug: 'demenagement',
          items: ['Déménagement local', 'Emballage & déballage', 'Transport de meubles'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linejoin': 'round' }),
              h('polyline', { points: '9 22 9 12 15 12 15 22', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linejoin': 'round' })
            ])
          })
        },
        {
          title: 'Électroménager',
          slug: 'electromenager',
          items: ['Réparation lave-linge / sèche-linge', 'Réparation réfrigérateur', 'Réparation four / cuisinière'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('rect', { x: 3, y: 3, width: 18, height: 18, rx: 2, stroke: '#FC5A15', 'stroke-width': 2 }),
              h('path', { d: 'M3 9h18M9 3v18', stroke: '#FC5A15', 'stroke-width': 2 })
            ])
          })
        },
        {
          title: 'Nettoyage',
          slug: 'nettoyage',
          items: ['Nettoyage standard', 'Nettoyage en profondeur', 'Nettoyage après déménagement'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('circle', { cx: 12, cy: 12, r: 10, stroke: '#FC5A15', 'stroke-width': 2 }),
              h('path', { d: 'M8 8l8 8M16 8l-8 8', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linecap': 'round' })
            ])
          })
        },
        {
          title: 'Chauffage, Ventilation et Climatisation',
          slug: 'chauffage-ventilation-climatisation',
          items: ['Entretien climatisation', 'Réparation climatisation', 'Entretien chauffage'],
          iconComponent: defineComponent({
            render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, [
              h('path', { d: 'M14 3v18M7 10l5-5 5 5', stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round' })
            ])
          })
        },
      ]
    }
  },
  computed: {
    filteredServices() {
      if (!this.searchQuery) return this.services
      const query = this.searchQuery.toLowerCase()
      return this.services.filter(service => 
        service.title.toLowerCase().includes(query) ||
        service.items.some(item => item.toLowerCase().includes(query))
      )
    }
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&family=Inter:wght@400;500&display=swap');

.hero-section {
  box-sizing: border-box;
  width: 100%;
  min-height: 551px;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background:
    linear-gradient(180deg, rgba(255,247,237,0) 9.21%, #ffffff 89.42%),
    linear-gradient(0deg, rgba(255,255,255,0.39), rgba(255,255,255,0.39)),
    repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(200,190,180,0.18) 49px, rgba(200,190,180,0.18) 50px),
    repeating-linear-gradient(0deg,  transparent, transparent 23px, rgba(200,190,180,0.18) 23px, rgba(200,190,180,0.18) 24px),
    #f5f0eb;
}

.hero-section::before {
  content: '';
  position: absolute;
  inset: 0;
  background: repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(200,190,180,0.12) 49px, rgba(200,190,180,0.12) 50px);
  background-size: 100px 48px;
  background-position: 0 24px;
  pointer-events: none;
}

.hero-inner {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 1280px;
  padding: 56px 16px 72px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 48px;
}

.hero-text {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  animation: fadeDown 0.6s ease both;
}

.hero-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 48px;
  line-height: 48px;
  letter-spacing: 0.35px;
  color: #314158;
  margin: 0;
  text-align: center;
}

.hero-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748e;
  margin: 0;
  text-align: center;
  max-width: 768px;
}

.cards-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 20px;
}

.stat-card {
  box-sizing: border-box;
  width: 206px;
  height: 190px;
  background: #ffffff;
  border: 1px solid #fc5a15;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  position: relative;
  overflow: hidden;
  animation: fadeUp 0.5s ease both;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.stat-card::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(252,90,21,0.06) 0%, transparent 60%);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.stat-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(252,90,21,0.15); }
.stat-card:hover::after { opacity: 1; }

.icon-circle {
  width: 48px;
  height: 48px;
  background: #fc5a15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: transform 0.25s ease;
}

.stat-card:hover .icon-circle { transform: scale(1.1) rotate(-5deg); }

.stat-value {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 30px;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
  text-align: center;
}

.stat-label {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748e;
  text-align: center;
}

@keyframes fadeDown {
  from { opacity: 0; transform: translateY(-16px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}

@media (max-width: 900px) {
  .hero-title    { font-size: 36px; }
  .hero-subtitle { font-size: 17px; }
  .stat-card     { width: 180px; height: 170px; }
}

@media (max-width: 600px) {
  .hero-title    { font-size: 28px; line-height: 36px; }
  .hero-subtitle { font-size: 15px; }
  .cards-row     { gap: 12px; }
  .stat-card     { width: 150px; height: 155px; }
  .stat-value    { font-size: 24px; }
}

/* ────────────────────────────────────────────────────────────── */
/* Services Section */
/* ────────────────────────────────────────────────────────────── */

.services-section {
  width: 100%;
  padding: 38px 16px;
  background: #fff;
}

.services-inner {
  max-width: 1280px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 38px;
}

/* Search bar */
.search-bar {
  position: relative;
  width: 100%;
  max-width: 1246px;
  margin: 0 auto;
}

.search-input {
  width: 100%;
  height: 65px;
  padding: 12px 16px 12px 48px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 19px;
  letter-spacing: -0.31px;
  color: #314158;
  background: #fff;
  border: 2px solid #E5E7EB;
  border-radius: 14px;
  outline: none;
  transition: border-color 0.2s;
}

.search-input::placeholder {
  color: #62748E;
}

.search-input:focus {
  border-color: #FC5A15;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 23px;
  width: 20px;
  height: 20px;
  pointer-events: none;
}

/* Services grid */
.services-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 23px;
  animation: fadeIn 0.6s ease;
}

.service-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);
  overflow: hidden;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  animation: fadeUp 0.5s ease both;
}

.service-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px -4px rgba(0,0,0,0.15);
}

/* Service image */
.service-image {
  position: relative;
  width: 100%;
  height: 192px;
  background: linear-gradient(135deg, #ddd 0%, #aaa 100%);
}

.image-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(0deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 100%);
}

.service-icon-badge {
  position: absolute;
  left: 16px;
  top: 16px;
  width: 48px;
  height: 48px;
  background: rgba(255,255,255,0.9);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}

.service-icon-badge svg {
  width: 24px;
  height: 24px;
}

/* Service content */
.service-content {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.service-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0;
}

.service-items {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.service-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.service-item svg {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.service-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  height: 48px;
  background: linear-gradient(180deg, #FC5A15 0%, #E54D0F 100%);
  border: none;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #fff;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
}

.service-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(252,90,21,0.3);
}

.service-btn svg {
  width: 20px;
  height: 20px;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}

/* Responsive services grid */
@media (max-width: 1100px) {
  .services-grid { grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 768px) {
  .services-grid { grid-template-columns: repeat(2, 1fr); gap: 16px; }
  .search-input { height: 56px; font-size: 14px; }
}

@media (max-width: 500px) {
  .services-grid { grid-template-columns: 1fr; }
  .service-image { height: 160px; }
}
</style>
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
          v-for="(service, index) in visibleServices"
          :key="index"
          class="service-card"
          :style="{ animationDelay: `${(index % 4) * 0.1}s` }"
        >
          <!-- Image with overlay -->
          <div
            class="service-image"
            :style="{ backgroundImage: `url('${service.image}')` }"
          >
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

      <!-- Load More -->
      <div v-if="visibleCount < filteredServices.length" class="load-more-wrapper">
        <p class="load-more-count">{{ Math.min(visibleCount, filteredServices.length) }} / {{ filteredServices.length }} services</p>
        <button class="load-more-btn" @click="loadMore">
          Voir plus de services
          <svg width="18" height="18" viewBox="0 0 20 20" fill="none">
            <path d="M10 4v12M4 10l6 6 6-6" stroke="currentColor" stroke-width="1.67" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
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
  watch: {
    searchQuery() { this.visibleCount = 12 },
  },
  methods: {
    goToService(slug) {
      if (slug) this.$router.push(`/services/${slug}`)
    },
    loadMore() {
      this.visibleCount += 12
    },
  },
  data() {
    const ic = (paths) => defineComponent({ render: () => h('svg', { width: 24, height: 24, viewBox: '0 0 24 24', fill: 'none' }, paths) })
    const p  = (d, extra = {}) => h('path', { d, stroke: '#FC5A15', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', ...extra })
    const c  = (cx, cy, r) => h('circle', { cx, cy, r, stroke: '#FC5A15', 'stroke-width': 2 })
    const r  = (x, y, w, hh, rx) => h('rect', { x, y, width: w, height: hh, rx, stroke: '#FC5A15', 'stroke-width': 2, fill: 'none' })

    return {
      searchQuery: '',
      visibleCount: 12,
      stats: [
        { value: '500+',  label: 'Artisans',      iconComponent: ArtisansIcon },
        { value: '4.8/5', label: 'Satisfaction',  iconComponent: SatisfactionIcon },
        { value: '24/7',  label: 'Disponibilité', iconComponent: DisponibiliteIcon },
        { value: '100%',  label: 'Sécurisé',      iconComponent: SecuriseIcon },
      ],
      services: [
        { title: 'Plomberie',                               slug: 'plomberie',                              image: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=600&q=80', items: ['Réparation de fuite', 'Installation sanitaire', 'Réparation de toilette', 'Débouchage'],                        iconComponent: ic([p('M8 3v16M8 12h8')]) },
        { title: 'Électricité',                             slug: 'electricite',                            image: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=600&q=80', items: ['Installation de luminaires', 'Réparation prises & interrupteurs', 'Ventilateur de plafond'],                  iconComponent: ic([p('M13 2L3 14h8l-1 8 10-12h-8l1-8z')]) },
        { title: 'Peinture',                                slug: 'peinture',                               image: 'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=600&q=80', items: ['Peinture intérieure', 'Peinture extérieure'],                                                                     iconComponent: ic([p('M4 15l4-8 4 8M6 12h4M18 9v6'), p('M18 6a2 2 0 1 0 0-4 2 2 0 0 0 0 4z', { fill: 'none' })]) },
        { title: 'Réparations générales',                   slug: 'reparations-generales',                  image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&q=80', items: ['Montage TV, étagères', 'Réparation portes & serrures', 'Petites menuiseries', 'Joints & silicone'],           iconComponent: ic([p('M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z')]) },
        { title: 'Déménagement',                            slug: 'demenagement',                           image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80', items: ['Déménagement local', 'Emballage & déballage', 'Transport de meubles'],                                            iconComponent: ic([p('M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'), h('polyline', { points: '9 22 9 12 15 12 15 22', stroke: '#FC5A15', 'stroke-width': 2 })]) },
        { title: 'Électroménager',                          slug: 'electromenager',                         image: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', items: ['Réparation lave-linge', 'Réparation réfrigérateur', 'Réparation four / cuisinière'],                              iconComponent: ic([r(3, 3, 18, 18, 2), p('M3 9h18M9 3v18')]) },
        { title: 'Nettoyage',                               slug: 'nettoyage',                              image: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600&q=80', items: ['Nettoyage standard', 'Nettoyage en profondeur', 'Nettoyage après déménagement'],                               iconComponent: ic([c(12, 12, 10), p('M8 8l8 8M16 8l-8 8')]) },
        { title: 'Chauffage, Ventilation et Climatisation', slug: 'chauffage-ventilation-climatisation',    image: 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=600&q=80', items: ['Entretien climatisation', 'Réparation climatisation', 'Entretien chauffage'],                                  iconComponent: ic([p('M14 3v18M7 10l5-5 5 5')]) },
        { title: 'Mécanicien Mobile',                       slug: null,                                     image: 'https://images.unsplash.com/photo-1599256872237-5dae43b37e58?w=600&q=80', items: ['Diagnostic de base', 'Remplacement plaquettes de frein', 'Remplacement batterie', 'Vérification alternateur'],  iconComponent: ic([p('M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z')]) },
        { title: 'Vidange Mobile',                          slug: null,                                     image: 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=600&q=80', items: ['Vidange standard', 'Vidange huile synthétique'],                                                                  iconComponent: ic([p('M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5S12.5 5 12 2.5C11.5 5 10 7.4 8 9c-2 1.6-3 3.5-3 5a7 7 0 0 0 7 7z')]) },
        { title: 'Assistance Routière',                     slug: null,                                     image: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600&q=80', items: ['Démarrage batterie', 'Changement de pneu', 'Ouverture de porte (lockout)'],                                     iconComponent: ic([p('M5 17H3a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h11l5 5v5h-2'), c(7, 17, 2), c(17, 17, 2)]) },
        { title: "Organisation d'événements",               slug: null,                                     image: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&q=80', items: ['Planification complète', 'Coordination le jour'],                                                                 iconComponent: ic([p('M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z')]) },
        { title: 'Photographie',                            slug: null,                                     image: 'https://images.unsplash.com/photo-1542038374944-65417f4e5fb7?w=600&q=80', items: ["Photographie d'événements", 'Portraits', 'Photographie de produits'],                                           iconComponent: ic([p('M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z'), c(12, 13, 4)]) },
        { title: 'Vidéographie',                            slug: null,                                     image: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=600&q=80', items: ["Vidéos d'événements", 'Vidéos promotionnelles'],                                                                  iconComponent: ic([p('M23 7l-7 5 7 5V7z'), r(1, 5, 15, 14, 2)]) },
        { title: 'Musique & Animation',                     slug: null,                                     image: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80', items: ['DJ', 'Groupes de musique', 'Musiciens solo'],                                                                      iconComponent: ic([p('M9 18V5l12-2v13'), c(6, 18, 3), c(18, 16, 3)]) },
        { title: 'Beauté & Style',                          slug: null,                                     image: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&q=80', items: ['Maquillage', 'Coiffure', 'Forfaits mariage'],                                                                      iconComponent: ic([p('M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z')]) },
        { title: 'Services de Restauration',                slug: null,                                     image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80', items: ['Aide au service', 'Serveurs'],                                                                                     iconComponent: ic([p('M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8zM6 1v3M10 1v3M14 1v3')]) },
        { title: "Décoration d'Événements",                 slug: null,                                     image: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&q=80', items: ['Décoration de salle', 'Ballons & arches', 'Centres de table'],                                                  iconComponent: ic([p('M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z')]) },
        { title: 'Location de Matériel',                    slug: null,                                     image: 'https://images.unsplash.com/photo-1549294413-26f195200c16?w=600&q=80', items: ['Chaises & tables', 'Vaisselle', 'Tentes & chapiteaux'],                                                             iconComponent: ic([p('M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z')]) },
        { title: 'Réparation Ordinateurs',                  slug: null,                                     image: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80', items: ['Réparation ordinateur portable', 'Suppression de virus', 'Récupération de données'],                             iconComponent: ic([p('M2 17h20M4 5h16a1 1 0 0 1 1 1v11H3V6a1 1 0 0 1 1-1z'), p('M8 21h8M12 17v4')]) },
        { title: 'Réseau & WiFi',                           slug: null,                                     image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=600&q=80', items: ['Installation routeur', 'Optimisation WiFi', 'Installation réseau maison'],                                        iconComponent: ic([p('M5 12.55a11 11 0 0 1 14.08 0'), p('M1.42 9a16 16 0 0 1 21.16 0'), p('M8.53 16.11a6 6 0 0 1 6.95 0'), h('circle', { cx: 12, cy: 20, r: 1, fill: '#FC5A15', stroke: 'none' })]) },
        { title: 'Maison Connectée',                        slug: null,                                     image: 'https://images.unsplash.com/photo-1558002038-1055e5a1c6ff?w=600&q=80', items: ['Installation caméras', 'Serrures intelligentes', 'Éclairage intelligent'],                                         iconComponent: ic([p('M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'), p('M9 22V12h6v10')]) },
        { title: 'Réparation Téléphones & Tablettes',       slug: null,                                     image: 'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=600&q=80', items: ["Remplacement d'écran", 'Remplacement batterie', 'Réparation port de charge'],                                  iconComponent: ic([p('M17 2H7a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z'), p('M12 18h.01')]) },
        { title: 'Lavage auto à domicile',                  slug: null,                                     image: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600&q=80', items: ['Nettoyage extérieur', 'Nettoyage intérieur', 'Lavage complet'],                                                  iconComponent: ic([p('M3 17l2-7h14l2 7H3z'), c(7.5, 17, 2), c(16.5, 17, 2), p('M5 10h14')]) },
        { title: 'Car Detailing',                           slug: null,                                     image: 'https://images.unsplash.com/photo-1502161254066-6c74afbf07aa?w=600&q=80', items: ['Detailing intérieur', 'Detailing extérieur', 'Detailing complet'],                                               iconComponent: ic([c(12, 12, 10), p("M8 13s1.5 2 4 2 4-2 4-2"), p('M9 9h.01M15 9h.01')]) },
        { title: 'Jardinage & Extérieur',                   slug: null,                                     image: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80', items: ['Tonte de gazon', 'Taille de haies', 'Entretien jardin'],                                                         iconComponent: ic([p('M12 22V12'), p('M12 12C12 8 15 5 19 5c0 4-3 7-7 7z'), p('M12 12C12 8 9 5 5 5c0 4 3 7 7 7z')]) },
        { title: 'Support Technique',                       slug: null,                                     image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&q=80', items: ["Configuration d'appareils", 'Assistance logicielle', 'Support email & comptes'],                               iconComponent: ic([c(12, 12, 10), p('M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3'), h('circle', { cx: 12, cy: 17, r: 1, fill: '#FC5A15', stroke: 'none' })]) },
        { title: 'Diagnostic OBD mobile',                   slug: null,                                     image: 'https://images.unsplash.com/photo-1635073908681-b5a3c630a54c?w=600&q=80', items: ['Diagnostic électronique', 'Lecture des codes défaut', 'Rapport de diagnostic'],                                iconComponent: ic([p('M9 3H5a2 2 0 0 0-2 2v4m6-6h10a2 2 0 0 1 2 2v4M9 3v18m0 0h10a2 2 0 0 0 2-2V9M9 21H5a2 2 0 0 1-2-2V9m0 0h18')]) },
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
    },
    visibleServices() {
      return this.filteredServices.slice(0, this.visibleCount)
    },
  },
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
  display: flex;
  flex-direction: column;
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
  background-size: cover;
  background-position: center;
  background-color: #d1d5db;
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
  flex: 1;
}

.service-btn {
  margin-top: auto;
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

.load-more-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 8px 0 16px;
}

.load-more-count {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #62748E;
  margin: 0;
}

.load-more-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 40px;
  background: white;
  border: 2px solid #FC5A15;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 500;
  color: #FC5A15;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}

.load-more-btn:hover {
  background: #FC5A15;
  color: white;
}
</style>
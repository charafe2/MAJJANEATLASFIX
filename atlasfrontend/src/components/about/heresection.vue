<template>
  <div class="about-page">

    <!-- ── HERO ──────────────────────────────────────────────────────────── -->
    <section class="hero">
      <div class="hero-inner">
        <span class="hero-tag">À propos d'AtlasFix</span>
        <h1 class="hero-title">
          AtlasFix, votre partenaire de confiance<br>
          pour les services du quotidien
        </h1>
        <p class="hero-desc">
          AtlasFix est une marketplace de services locaux qui connecte les ménages et les entreprises
          marocaines avec des artisans et prestataires de services fiables, qualifiés et de confiance. Notre
          mission est simple : <strong>vous aider à trouver rapidement le bon professionnel, au bon endroit, en
          toute sérénité.</strong>
        </p>
      </div>
    </section>

  </div>
  <Aboutvision/>
  <Aboutwhy/>
  <AboutCommunity/>
  <AboutTradition/>
</template>

<script setup>
import { useRouter } from 'vue-router'
import Aboutvision from './Aboutvision.vue'
import Aboutwhy from './Aboutwhy.vue'
import AboutCommunity from './AboutCommunity.vue'
import AboutTradition from './AboutTradition.vue'
const router = useRouter()

const stats = [
  { value: '10 000+', label: 'Clients satisfaits' },
  { value: '2 500+',  label: 'Artisans partenaires' },
  { value: '50+',     label: 'Villes couvertes' },
  { value: '4.8/5',   label: 'Note moyenne' },
]

const missionPoints = [
  'Mise en relation instantanée avec des pros qualifiés',
  'Devis transparents sans mauvaise surprise',
  'Suivi en temps réel de votre demande',
  'Service client disponible 7j/7',
]

const cards = [
  { icon: '🔧', title: 'Artisans vérifiés',   sub: 'Diplômes et identités contrôlés' },
  { icon: '⭐', title: 'Avis authentiques',    sub: 'Système de notation transparent' },
  { icon: '🛡️', title: 'Paiement sécurisé',   sub: 'Fonds libérés après validation' },
  { icon: '📍', title: 'Couverture nationale', sub: 'Toutes les grandes villes du Maroc' },
]

const values = [
  { icon: '🤝', title: 'Confiance',     desc: "Chaque artisan est vérifié et évalué par notre équipe avant d'être accepté sur la plateforme." },
  { icon: '⚡', title: 'Rapidité',      desc: 'Recevez plusieurs devis en moins de 24h et planifiez votre intervention au plus vite.' },
  { icon: '💎', title: 'Qualité',       desc: 'Nous maintenons des standards élevés grâce aux avis clients et à notre système de notation.' },
  { icon: '🌍', title: 'Accessibilité', desc: 'AtlasFix est pensé pour tous les Marocains, quelle que soit leur ville ou leur budget.' },
  { icon: '🔒', title: 'Sécurité',      desc: 'Vos données et vos paiements sont protégés par les meilleures technologies disponibles.' },
  { icon: '♻️', title: 'Impact local',  desc: "Nous soutenons les artisans locaux et contribuons à l'économie de proximité." },
]

const team = [
  { name: 'Youssef Alami',  role: 'CEO & Co-fondateur',    initials: 'YA', color: '#FC5A15' },
  { name: 'Sara Benali',    role: 'CTO & Co-fondatrice',   initials: 'SB', color: '#155DFC' },
  { name: 'Karim Ouhabi',   role: 'Directeur Opérations',  initials: 'KO', color: '#34F1AB' },
  { name: 'Nadia Chraibi',  role: 'Resp. Marketing',       initials: 'NC', color: '#F0B100' },
]
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');

.about-page {
  font-family: 'Poppins', sans-serif;
  color: #393939;
  overflow-x: hidden;
}

/* ── HERO ─────────────────────────────────────────────────── */
.hero {
  position: relative;
  width: 100%;
  min-height: 659px;
  display: flex;
  align-items: center;
  justify-content: center;

  /* Exact Figma gradient stack + blurred handyman photo */
  background:
    linear-gradient(180deg, rgba(255,255,255,0) 0%, #FFFFFF 93.31%),
    linear-gradient(111.07deg, rgba(252,90,21,0.024) 0.25%, rgba(252,90,21,0.048) 99.75%),
    linear-gradient(238.17deg, rgba(30,64,175,0.104) 11.35%, rgba(240,177,0,0.052) 88.65%),
    linear-gradient(180deg, rgba(252,90,21,0.04) 0%, rgba(255,255,255,0.04) 100%),
    url('https://images.unsplash.com/photo-1621905251189-08b45249bea5?w=1440&q=80') center/cover no-repeat;

  /* The Figma backdrop-filter on the background layer */
  backdrop-filter: blur(15.05px);
}

.hero-inner {
  position: relative;
  z-index: 1;
  text-align: center;
  max-width: 720px;
  padding: 140px 24px 100px;
  animation: fadeUp 0.7s ease both;
}

/* Orange pill label — matches screenshot exactly */
.hero-tag {
  display: inline-block;
  font-size: 22px;
  font-weight: 700;
  color: #FC5A15;
  background: rgba(252, 90, 21, 0.07);
  border: 1.5px solid rgba(252, 90, 21, 0.18);
  border-radius: 6px;
  padding: 6px 20px;
  margin-bottom: 32px;
  letter-spacing: -0.2px;
}

.hero-title {
  font-size: clamp(26px, 3.2vw, 40px);
  font-weight: 700;
  line-height: 1.25;
  color: #1a1a2e;
  margin: 0 0 24px;
}

.hero-desc {
  font-size: 15px;
  line-height: 1.8;
  color: #6b7280;
  margin: 0;
  max-width: 640px;
  margin-inline: auto;
}

.hero-desc strong {
  color: #393939;
  font-weight: 600;
}



</style>
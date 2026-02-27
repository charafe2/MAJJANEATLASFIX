<!-- src/components/ServicesSection.vue -->
<template>
  <section class="services-section">
    <div class="services-container">

      <!-- Header -->
      <div class="section-header">
        <h2 class="section-title">Services disponibles</h2>
        <p class="section-subtitle">
          Des artisans qualifiés pour tous vos besoins du quotidien.
        </p>
      </div>

      <!-- Carousel -->
      <div class="carousel-wrapper">

        <div ref="trackRef" class="carousel-track">
          <div
            v-for="(service, i) in services"
            :key="i"
            class="service-card"
          >
            <!-- Image -->
            <div class="card-image-wrap">
              <img :src="service.image" :alt="service.title" class="card-image" />
            </div>

            <!-- Icon circle sits on the seam between image and content -->
            <div class="icon-circle">
              <img :src="service.icon" :alt="service.title" />
            </div>

            <!-- Content -->
            <div class="card-content">
              <h3 class="card-title">{{ service.title }}</h3>
              <button class="card-btn">Voir détails</button>
            </div>
          </div>
        </div>

        <!-- Arrows -->
        <button class="arrow arrow-prev" @click="scroll(-1)" aria-label="Précédent">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
        </button>

        <button class="arrow arrow-next" @click="scroll(1)" aria-label="Suivant">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </button>

      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'

const services = ref([
  { title: 'Plomberie',            image: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400&q=80', icon: '/icons/plumbing.svg' },
  { title: 'Électricité',          image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80', icon: '/icons/electricity.svg' },
  { title: 'Peinture',             image: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400&q=80', icon: '/icons/paint.svg' },
  { title: 'Menuiserie',           image: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400&q=80', icon: '/icons/hammer.svg' },
  { title: 'Climatisation',        image: 'https://images.unsplash.com/photo-1631545806609-bae1b2e66987?w=400&q=80', icon: '/icons/ac.svg' },
  { title: 'Réparations générales',image: 'https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=400&q=80', icon: '/icons/wrench.svg' },
  { title: 'Carrelage',            image: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&q=80', icon: '/icons/tile.svg' },
  { title: 'Maçonnerie',           image: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&q=80', icon: '/icons/brick.svg' },
])

const trackRef = ref(null)
const CARD_W   = 260 + 24  // card width + gap

const scroll = (dir) => {
  trackRef.value?.scrollBy({ left: dir * CARD_W * 2, behavior: 'smooth' })
}
</script>

<style scoped>
/* ── Section ──────────────────────────────────────────────────────────── */
.services-section {
  background: #fff;
  padding: 80px 0;
}

.services-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 64px;
}

/* ── Header ───────────────────────────────────────────────────────────── */
.section-header {
  text-align: center;
  margin-bottom: 52px;
}

.section-title {
  font-family: 'Poppins', sans-serif;
  font-size: 40px;
  font-weight: 600;
  color: #0a0a0a;
  margin: 0 0 12px;
  letter-spacing: -0.5px;
}

.section-subtitle {
  font-family: 'Poppins', sans-serif;
  font-size: 17px;
  font-weight: 400;
  color: #4a5565;
  max-width: 520px;
  margin: 0 auto;
}

/* ── Carousel wrapper ─────────────────────────────────────────────────── */
.carousel-wrapper {
  position: relative;
  /* horizontal padding makes room for the arrows that sit outside the track */
  padding: 0 24px;
}

/* ── Track ────────────────────────────────────────────────────────────── */
.carousel-track {
  display: flex;
  gap: 24px;
  overflow-x: auto;
  scroll-behavior: smooth;
  scrollbar-width: none;
  -webkit-overflow-scrolling: touch;
  /* top padding = half the icon circle so it isn't clipped when it overflows up */
  padding-top: 10px;
  /* bottom padding for hover shadow */
  padding-bottom: 20px;
}

.carousel-track::-webkit-scrollbar { display: none; }

/* ── Card ─────────────────────────────────────────────────────────────── */
.service-card {
  position: relative;
  flex: 0 0 260px;
  width: 260px;
  border-radius: 14px;
  background: #fff;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  /* CRITICAL: overflow must be visible so the icon circle
     can poke above the top of the card content area */
  overflow: visible;
}

.service-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 14px 36px rgba(0,0,0,0.13);
}

/* ── Image wrapper — clips the image to rounded top corners ───────────── */
.card-image-wrap {
  border-radius: 14px 14px 0 0;
  overflow: hidden;   /* clip here, not on the card */
  height: 156px;
}

.card-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.5s ease;
}

.service-card:hover .card-image {
  transform: scale(1.07);
}

/* ── Icon circle ─────────────────────────────────────────────────────── */
/* Sits exactly on the image / content seam.
   Image = 156px tall, circle = 70px.
   top = 156 - 35 = 121px  (half the circle straddles the seam) */
.icon-circle {
  position: absolute;
  top: 121px;
  left: 50%;
  transform: translateX(-50%);
  width: 70px;
  height: 70px;
  border-radius: 50%;
  background: rgba(255,255,255,0.95);
  border: 2px solid #fff;
  box-shadow: 0 2px 18px rgba(0,0,0,0.14);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.icon-circle img {
  width: 34px;
  height: 34px;
  object-fit: contain;
}

/* ── Card content ─────────────────────────────────────────────────────── */
/* top padding = half circle (35px) + breathing room (20px) = 55px */
.card-content {
  padding: 55px 20px 28px;
  text-align: center;
  background: #fff;
  border-radius: 0 0 14px 14px;
}

.card-title {
  font-family: 'Open Sans', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #0b183d;
  margin: 0 0 16px;
}

/* ── Button ───────────────────────────────────────────────────────────── */
.card-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 40px;
  padding: 0 24px;
  font-family: 'Open Sans', sans-serif;
  font-size: 13px;
  font-weight: 700;
  color: #fc5a15;
  background: transparent;
  border: 2px solid #fc5a15;
  border-radius: 9px;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
  box-shadow: 0 2px 8px rgba(252,90,21,0.15);
}

.card-btn:hover {
  background: #fc5a15;
  color: #fff;
}

/* ── Arrows ───────────────────────────────────────────────────────────── */
.arrow {
  position: absolute;
  top: calc(50% - 10px);  /* rough center of card, compensating for padding */
  transform: translateY(-50%);
  width: 42px;
  height: 42px;
  border-radius: 50%;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 20;
  transition: background 0.2s, box-shadow 0.2s;
}

.arrow svg { width: 20px; height: 20px; }

.arrow-prev {
  left: -4px;
  background: #fff;
  color: #374151;
  box-shadow: 0 2px 12px rgba(0,0,0,0.12);
  border: 1px solid #e5e7eb;
}

.arrow-prev:hover {
  background: #f9fafb;
  box-shadow: 0 4px 16px rgba(0,0,0,0.16);
}

.arrow-next {
  right: -4px;
  background: #fc5a15;
  color: #fff;
  box-shadow: 0 2px 12px rgba(252,90,21,0.30);
}

.arrow-next:hover {
  background: #e04e12;
  box-shadow: 0 4px 16px rgba(252,90,21,0.40);
}

/* ── Responsive ───────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
  .services-section   { padding: 60px 0; }
  .services-container { padding: 0 40px; }
  .section-title      { font-size: 34px; }
}

@media (max-width: 768px) {
  .services-container { padding: 0 20px; }
  .carousel-wrapper   { padding: 0 12px; }
  .section-title      { font-size: 28px; }
  .section-subtitle   { font-size: 15px; }
  .service-card       { flex: 0 0 220px; width: 220px; }
  .arrow              { width: 36px; height: 36px; }
  .arrow svg          { width: 16px; height: 16px; }
}
</style>
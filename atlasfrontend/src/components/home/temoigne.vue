<!-- src/components/TestimonialsSection.vue -->
<template>
  <section class="tm-section">
    <div class="tm-wrapper">

      <h2 class="tm-title">Témoignages</h2>

      <div class="tm-carousel-area">

        <!-- Left arrow -->
        <button class="tm-arrow tm-arrow-prev" @click="prev" aria-label="Précédent">
          <svg viewBox="0 0 8 16" fill="none">
            <path d="M7 1L1 8l6 7" stroke="#D9D9D9" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>

        <!-- Cards -->
        <div class="tm-track">
          <div
            v-for="(t, i) in visible"
            :key="i"
            class="tm-card"
          >
            <!-- Top row: name + quote icon -->
            <div class="tm-card-header">
              <div class="tm-card-meta">
                <span class="tm-name">{{ t.name }}</span>
                <span class="tm-role">{{ t.role }}</span>
              </div>
              <!-- Orange quote mark -->
              <svg class="tm-quote" viewBox="0 0 35 25" fill="none">
                <path d="M0 24.5V14.9C0 6.3 5.3 1.4 15.9 0l1.4 2.8C11.6 4 8.6 7 8 12h7.5v12.5H0zm18.6 0V14.9C18.6 6.3 23.9 1.4 34.5 0l1.4 2.8C30.2 4 27.2 7 26.6 12h7.5v12.5H18.6z" fill="#FC5A15"/>
              </svg>
            </div>

            <!-- Review text -->
            <p class="tm-text">{{ t.text }}</p>
          </div>
        </div>

        <!-- Right arrow -->
        <button class="tm-arrow tm-arrow-next" @click="next" aria-label="Suivant">
          <svg viewBox="0 0 8 16" fill="none">
            <path d="M1 1l6 7-6 7" stroke="#FC5A15" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>

      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const testimonials = ref([])
const current = ref(0)

onMounted(async () => {
  try {
    const res = await fetch('/api/public/testimonials')
    const json = await res.json()
    testimonials.value = json.data ?? []
  } catch {
    // keep empty
  }
})

const visible = computed(() => {
  const total = testimonials.value.length
  if (total === 0) return []
  return [0, 1, 2].map(offset => testimonials.value[(current.value + offset) % total])
})

const prev = () => {
  current.value = (current.value - 1 + testimonials.value.length) % testimonials.value.length
}

const next = () => {
  current.value = (current.value + 1) % testimonials.value.length
}
</script>

<style scoped>
.tm-section {
  background: #ffffff;
  padding: 80px 0;
}

.tm-wrapper {
  max-width: 1246px;
  margin: 0 auto;
  padding: 0 40px;
  display: flex;
  flex-direction: column;
  gap: 54px;
}

/* Title */
.tm-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 40px;
  line-height: 1;
  text-align: center;
  letter-spacing: -0.45px;
  color: #0a0a0a;
  margin: 0;
}

/* Carousel area: arrows + track */
.tm-carousel-area {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* Arrow buttons */
.tm-arrow {
  flex-shrink: 0;
  width: 30px;
  height: 40px;
  border-radius: 100px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.2s;
}

.tm-arrow svg {
  width: 8px;
  height: 16px;
}

.tm-arrow-prev {
  border: 1px solid #D9D9D9;
}

.tm-arrow-prev:hover {
  background: #f9f9f9;
}

.tm-arrow-next {
  border: 1px solid #FC5A15;
}

.tm-arrow-next:hover {
  background: #fff5f0;
}

/* Track: 3 cards in a row */
.tm-track {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  flex: 1;
}

/* Card */
.tm-card {
  background: #ffffff;
  border-radius: 26px;
  box-shadow: 0px 2px 10.5px rgba(0, 0, 0, 0.17);
  padding: 27px;
  display: flex;
  flex-direction: column;
  gap: 27px;
}

/* Header row */
.tm-card-header {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: space-between;
}

.tm-card-meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.tm-name {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  font-size: 18px;
  line-height: 1.3;
  letter-spacing: 0.002em;
  color: #0a0a0a;
}

.tm-role {
  font-family: 'Public Sans', 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 13.7px;
  line-height: 1.5;
  color: #8A8D93;
}

.tm-quote {
  width: 35px;
  height: 25px;
  flex-shrink: 0;
}

/* Review text */
.tm-text {
  font-family: 'Public Sans', 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 13.7px;
  line-height: 1.55;
  color: #363A3D;
  margin: 0;
}

/* Responsive */
@media (max-width: 900px) {
  .tm-track {
    grid-template-columns: repeat(2, 1fr);
  }
  .tm-track .tm-card:last-child {
    display: none;
  }
}

@media (max-width: 640px) {
  .tm-section { padding: 60px 0; }
  .tm-wrapper { padding: 0 16px; gap: 40px; }
  .tm-title { font-size: 30px; }
  .tm-track {
    grid-template-columns: 1fr;
  }
  .tm-track .tm-card:not(:first-child) {
    display: none;
  }
}
</style>
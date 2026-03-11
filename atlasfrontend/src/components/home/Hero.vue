<!-- src/components/HeroSection.vue -->
<template>
    
  <section class="hs-hero">

    <!-- Background photo + overlays -->
    <div class="hs-bg">
      <img
        src="../../assets/images/Background.svg"
        alt=""
        class="hs-bg-img"
      />
      <div class="hs-bg-overlay"></div>
      <div class="hs-bg-fade"></div>
    </div>

    <!-- Main content -->
    <div class="hs-content">

      <!-- Title -->
      <h1 class="hs-title">
        La <span class="hs-orange">confiance</span> au cœur de<br/>
        chaque <span class="hs-orange">service</span>
      </h1>

      <!-- Subtitle -->
      <p class="hs-subtitle">
        Réparation, ménage, plomberie, électricité, bricolage… Trouvez et réservez les services
        dont vous avez besoin en quelques clics, facilement et en toute garantie.
      </p>

      <!-- Search bar -->
      <div class="hs-search">
        <!-- Search icon -->
        <div class="hs-search-icon">
          <svg viewBox="0 0 24 24" fill="none">
            <circle cx="11" cy="11" r="7" stroke="#99A1AF" stroke-width="1.9"/>
            <path d="M16.5 16.5L21 21" stroke="#99A1AF" stroke-width="1.9" stroke-linecap="round"/>
          </svg>
        </div>

        <!-- Service dropdown -->
        <div class="hs-search-field" ref="dropdownRef">
          <div class="hs-select-trigger" @click="dropdownOpen = !dropdownOpen">
            <span :class="selectedService ? 'hs-select-value' : 'hs-select-placeholder'">
              {{ selectedService || 'Quel service recherchez-vous ?' }}
            </span>
            <svg class="hs-caret" :class="{ open: dropdownOpen }" viewBox="0 0 24 24" fill="none">
              <path d="M6 9l6 6 6-6" stroke="#58595B" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <transition name="hs-drop">
            <ul v-if="dropdownOpen" class="hs-dropdown">
              <li
                v-for="s in services"
                :key="s"
                class="hs-dropdown-item"
                :class="{ selected: selectedService === s }"
                @click="selectService(s)"
              >{{ s }}</li>
            </ul>
          </transition>
        </div>

        <!-- Divider -->
        <div class="hs-divider"></div>

        <!-- Location input -->
        <input
          class="hs-location"
          type="text"
          placeholder="localisation"
        />

        <!-- CTA button -->
        <button class="hs-btn">
          <span class="hs-btn-text">Demandez votre service</span>
          <span class="hs-btn-pulse"></span>
        </button>
      </div>

      <!-- Trust badges -->
      <div class="hs-badges">

        <!-- Badge 1: Prestataires vérifiés -->
        <div class="hs-badge">
          <svg class="hs-badge-icon" viewBox="0 0 50 50" fill="none">
            <path d="M25 3L6 11v13c0 11.1 8.1 21.5 19 24 10.9-2.5 19-12.9 19-24V11L25 3z" fill="#FC5A15"/>
            <path d="M17 25l5 5 11-11" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <span>Prestataires vérifiés</span>
        </div>

        <!-- Badge 2: Paiements sécurisés -->
        <div class="hs-badge">
          <svg class="hs-badge-icon" viewBox="0 0 50 50" fill="none">
            <rect x="8" y="22" width="34" height="24" rx="3" fill="#FC5A15"/>
            <path d="M16 22V16a9 9 0 0 1 18 0v6" stroke="#FC5A15" stroke-width="3" stroke-linecap="round"/>
            <circle cx="25" cy="33" r="3" fill="white"/>
            <line x1="25" y1="36" x2="25" y2="40" stroke="white" stroke-width="2.5" stroke-linecap="round"/>
          </svg>
          <span>Paiements sécurisés</span>
        </div>

        <!-- Badge 3: Garantie de continuité -->
        <div class="hs-badge">
          <svg class="hs-badge-icon" viewBox="0 0 50 50" fill="none">
            <path d="M25 4a21 21 0 1 1 0 42A21 21 0 0 1 25 4z" fill="#FC5A15"/>
            <path d="M16 25l6 6 12-12" stroke="white" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <span>garantie de continuité</span>
        </div>

      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const services = [
  'Réparations générales',
  'Plomberie',
  'Électricité',
  'Peinture',
  'Électroménager',
  'Nettoyage',
  'Déménagement',
  'Climatisation',
  'Menuiserie',
  'Carrelage',
]

const selectedService = ref('')
const dropdownOpen    = ref(false)
const dropdownRef     = ref(null)

function selectService(s) {
  selectedService.value = s
  dropdownOpen.value = false
}

function onClickOutside(e) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
}

onMounted(()  => document.addEventListener('click', onClickOutside))
onUnmounted(() => document.removeEventListener('click', onClickOutside))
</script>

<style scoped>
/* ── Hero wrapper ───────────────────────────────────────────────────────── */
.hs-hero {
  position: relative;
  min-height: 826px;
  background: #ffffff;
  /* overflow removed — allows dropdown to escape the hero bounds */
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ── Background ─────────────────────────────────────────────────────────── */
.hs-bg {
  position: absolute;
  inset: 0;
  overflow: hidden; /* clip the bg image here instead */
}

.hs-bg-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.9;
}

.hs-bg-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(252, 90, 21, 0.05) 0%, rgba(252, 90, 21, 0.1) 100%);
}

.hs-bg-fade {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 50%;
  background: linear-gradient(to top, #ffffff, transparent);
  pointer-events: none;
}

/* ── Content ────────────────────────────────────────────────────────────── */
.hs-content {
  position: relative;
  z-index: 10;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 140px 40px 80px;
  max-width: 1000px;
  width: 100%;
}

/* ── Title ──────────────────────────────────────────────────────────────── */
.hs-title {
  font-family: 'Montserrat', sans-serif;
  font-weight: 600;
  font-size: 55px;
  line-height: 1.36;
  letter-spacing: -0.31px;
  color: #000000;
  margin: 0 0 32px;
  text-shadow: 0 4px 4px rgba(0, 0, 0, 0.15);
}

.hs-orange {
  color: #FC5A15;
}

/* ── Subtitle ───────────────────────────────────────────────────────────── */
.hs-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 1.75;
  color: #58595B;
  max-width: 862px;
  margin: 0 0 48px;
}

/* ── Search bar ─────────────────────────────────────────────────────────── */
.hs-search {
  position: relative;
  z-index: 50;
  display: flex;
  align-items: center;
  background: #ffffff;
  box-shadow: 0 11px 17px -3px rgba(0,0,0,0.10), 0 4px 7px -4px rgba(0,0,0,0.10);
  border-radius: 11px;
  width: 100%;
  max-width: 907px;
  height: 73px;
  padding: 0 9px 0 18px;
  gap: 0;
}

.hs-search-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
  margin-right: 10px;
}

.hs-search-icon svg {
  width: 22px;
  height: 22px;
}

/* Service dropdown wrapper */
.hs-search-field {
  position: relative;
  display: flex;
  align-items: center;
  flex: 1;
  height: 100%;
}

/* Custom trigger row */
.hs-select-trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  height: 100%;
  cursor: pointer;
  gap: 6px;
  padding-right: 4px;
  user-select: none;
}

.hs-select-placeholder {
  font-family: 'Poppins', sans-serif;
  font-size: 17px;
  color: rgba(16, 24, 40, 0.5);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.hs-select-value {
  font-family: 'Poppins', sans-serif;
  font-size: 17px;
  color: #101828;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.hs-caret {
  flex-shrink: 0;
  width: 20px;
  height: 20px;
  transition: transform 0.2s ease;
}
.hs-caret.open { transform: rotate(180deg); }

/* Dropdown panel */
.hs-dropdown {
  position: absolute;
  top: calc(100% + 8px);
  left: -18px;
  min-width: 260px;
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.12), 0 2px 8px rgba(0,0,0,0.06);
  list-style: none;
  margin: 0;
  padding: 6px 0;
  z-index: 999;
  max-height: 260px;
  overflow-y: auto;
  scrollbar-width: none;
}

.hs-dropdown::-webkit-scrollbar { display: none; }

.hs-dropdown-item {
  padding: 12px 20px;
  font-family: 'Poppins', sans-serif;
  font-size: 15px;
  color: #393939;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}
.hs-dropdown-item:hover   { background: #FFF5F0; color: #FC5A15; }
.hs-dropdown-item.selected { color: #FC5A15; font-weight: 500; }

/* Dropdown transition */
.hs-drop-enter-active,
.hs-drop-leave-active { transition: opacity 0.15s ease, transform 0.15s ease; }
.hs-drop-enter-from,
.hs-drop-leave-to     { opacity: 0; transform: translateY(-6px); }

/* Divider */
.hs-divider {
  width: 1px;
  height: 40%;
  background: #D0D5DD;
  flex-shrink: 0;
  margin: 0 14px;
}

/* Location input */
.hs-location {
  border: none;
  outline: none;
  background: transparent;
  font-family: 'Poppins', sans-serif;
  font-size: 17px;
  color: rgba(16, 24, 40, 0.5);
  width: 180px;
  flex-shrink: 0;
}

/* CTA button */
.hs-btn {
  position: relative;
  flex-shrink: 0;
  width: 282px;
  height: 55px;
  background: #FC5A15;
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 18px;
  line-height: 27px;
  letter-spacing: -0.356px;
  text-align: center;
  border: none;
  border-radius: 11.4px;
  cursor: pointer;
  white-space: nowrap;
  margin-left: 8px;
  overflow: hidden;
  transition: background 0.2s, transform 0.15s;
}

.hs-btn:hover {
  background: #e04e12;
  transform: translateY(-1px);
}

.hs-btn-text {
  position: relative;
  z-index: 1;
}

/* Ripple pulse ring */
.hs-btn-pulse {
  position: absolute;
  inset: -4px;
  border-radius: 15px;
  background: transparent;
  border: 2px solid rgba(252, 90, 21, 0.5);
  animation: btn-pulse 2s ease-out infinite;
  pointer-events: none;
}

@keyframes btn-pulse {
  0%   { transform: scale(1);    opacity: 1; }
  60%  { transform: scale(1.06); opacity: 0; }
  100% { transform: scale(1.06); opacity: 0; }
}

/* ── Trust badges ───────────────────────────────────────────────────────── */
.hs-badges {
  display: flex;
  justify-content: center;
  gap: 90px;
  margin-top: 64px;
}

.hs-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 11px;
  width: 234px;
}

.hs-badge-icon {
  width: 50px;
  height: 50px;
}

.hs-badge span {
  font-family: 'Open Sans', sans-serif;
  font-size: 18px;
  color: #58595B;
  text-align: center;
}

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
  .hs-title { font-size: 44px; }
  .hs-badges { gap: 40px; }
}

@media (max-width: 768px) {
  .hs-hero { min-height: auto; }
  .hs-content { padding: 100px 24px 60px; }
  .hs-title { font-size: 34px; }
  .hs-subtitle { font-size: 16px; }

  .hs-search {
    flex-direction: column;
    height: auto;
    padding: 16px;
    gap: 12px;
  }
  .hs-search-field { width: 100%; }
  .hs-divider { width: 100%; height: 1px; margin: 0; }
  .hs-location { width: 100%; }
  .hs-btn { width: 100%; margin-left: 0; }

  .hs-badges {
    flex-direction: column;
    align-items: center;
    gap: 32px;
  }
}
</style>
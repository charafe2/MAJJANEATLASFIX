<template>
  <div class="faq-page">

    <!-- ── HERO ─────────────────────────────────────────── -->
    <div class="hero">
      <div class="hero-inner">

        <!-- Badge -->
        <div class="hero-badge">
          <svg viewBox="0 0 20 20" fill="none">
            <path d="M17 2H3a1 1 0 0 0-1 1v11a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1z" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M10 15v3M6.5 18h7" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
          </svg>
          <span>Centre d'aide</span>
        </div>

        <!-- Title -->
        <h1 class="hero-title">Comment pouvons<br>nous vous aider&nbsp;?</h1>

        <!-- Subtitle -->
        <p class="hero-subtitle">
          Trouvez rapidement des réponses à vos questions les plus fréquentes
        </p>

        <!-- Search -->
        <div class="search-wrap">
          <svg class="search-icon" viewBox="0 0 24 24" fill="none">
            <circle cx="10" cy="10" r="7" stroke="#62748E" stroke-width="2"/>
            <path d="M17 17L21 21" stroke="#62748E" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <input
            v-model="searchQuery"
            class="search-input"
            type="text"
            placeholder="Rechercher une question..."
          />
        </div>

      </div>
    </div>

    <!-- ── CONTENT ───────────────────────────────────────── -->
    <div class="content">

      <!-- Filter tabs -->
      <div class="tabs">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          class="tab-btn"
          :class="{ active: activeTab === tab.key }"
          @click="activeTab = tab.key"
        >
          <svg v-if="tab.key === 'all'" viewBox="0 0 20 20" fill="none">
            <path d="M2 5h16M2 10h16M2 15h16" stroke="currentColor" stroke-width="1.667" stroke-linecap="round"/>
          </svg>
          <svg v-else viewBox="0 0 20 20" fill="none">
            <path d="M3 5l7-3 7 3v6c0 3.5-3 6-7 7-4-1-7-3.5-7-7V5z" stroke="currentColor" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M7 10l2.5 2.5L13 7" stroke="currentColor" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          {{ tab.label }}
        </button>
      </div>

      <!-- Two-column body -->
      <div class="body-cols">

        <!-- LEFT: FAQ accordion -->
        <div class="accordion-col">
          <div
            v-for="(item, idx) in filteredFaqs"
            :key="idx"
            class="faq-item"
            :class="{ open: openIdx === idx }"
          >
            <button class="faq-question" @click="toggle(idx)">
              <span>{{ item.q }}</span>
              <span class="faq-chevron">
                <svg viewBox="0 0 24 24" fill="none">
                  <path d="M6 9l6 6 6-6" stroke="#58595B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
            </button>
            <div class="faq-answer" v-show="openIdx === idx">
              <p>{{ item.a }}</p>
            </div>
          </div>

          <p v-if="filteredFaqs.length === 0" class="no-results">
            Aucune question trouvée pour «&nbsp;{{ searchQuery }}&nbsp;»
          </p>
        </div>

        <!-- RIGHT: sidebar -->
        <div class="sidebar">

          <!-- Orange help card -->
          <div class="help-card">
            <div class="help-card-icon">
              <svg viewBox="0 0 48 48" fill="none">
                <circle cx="24" cy="24" r="20" stroke="white" stroke-width="4"/>
                <path d="M24 16v8M24 32h.01" stroke="white" stroke-width="4" stroke-linecap="round"/>
              </svg>
            </div>
            <h3 class="help-card-title">Besoin d'aide&nbsp;?</h3>
            <p class="help-card-desc">Notre équipe est là pour vous accompagner</p>
            <button class="help-card-btn">Contacter le support</button>
          </div>

          <!-- Contact info card -->
          <div class="contact-card">
            <h4 class="contact-card-title">Nous contacter</h4>
            <div class="contact-items">

              <div class="contact-item">
                <div class="contact-icon blue">
                  <svg viewBox="0 0 20 20" fill="none">
                    <path d="M18 13.5v2.25A1.5 1.5 0 0 1 16.5 17c-6.627 0-12-5.373-12-12A1.5 1.5 0 0 1 6 3.5h2.25a.75.75 0 0 1 .75.75c0 1.013.168 1.985.48 2.893a.75.75 0 0 1-.17.79l-1.07 1.07a12.001 12.001 0 0 0 4.707 4.707l1.07-1.07a.75.75 0 0 1 .79-.17c.908.312 1.88.48 2.893.48a.75.75 0 0 1 .75.75z" stroke="#155DFC" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="contact-text">
                  <span class="contact-sub">Téléphone</span>
                  <span class="contact-val">+212 5XX-XXXXXX</span>
                </div>
              </div>

              <div class="contact-item">
                <div class="contact-icon green">
                  <svg viewBox="0 0 20 20" fill="none">
                    <rect x="2" y="4" width="16" height="13" rx="1.5" stroke="#00A63E" stroke-width="1.667"/>
                    <path d="M2 7.5l8 5 8-5" stroke="#00A63E" stroke-width="1.667" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="contact-text">
                  <span class="contact-sub">Email</span>
                  <span class="contact-val">support@atlasfix.ma</span>
                </div>
              </div>

              <div class="contact-item">
                <div class="contact-icon purple">
                  <svg viewBox="0 0 20 20" fill="none">
                    <circle cx="10" cy="10" r="8" stroke="#9810FA" stroke-width="1.667"/>
                    <path d="M10 6v4l2.5 2.5" stroke="#9810FA" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="contact-text">
                  <span class="contact-sub">Horaires</span>
                  <span class="contact-val">Lun - Ven : 9h - 18h</span>
                </div>
              </div>

            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'FAQPage',
  data() {
    return {
      searchQuery: '',
      activeTab: 'clients',
      openIdx: 0,

      tabs: [
        { key: 'all',          label: 'Tous' },
        { key: 'clients',      label: 'Pour les clients' },
        { key: 'prestataires', label: 'Pour les prestataires' },
      ],

      faqs: {
        clients: [
          {
            q: 'Comment puis-je réserver un service sur AtlasFix\u00a0?',
            a: 'AtlasFix est une marketplace de services locaux qui vous met en relation avec des prestataires qualifiés. Pour réserver, créez un compte, recherchez le service souhaité, choisissez un prestataire et confirmez votre réservation en quelques clics.',
            tab: 'clients',
          },
          {
            q: 'Quels moyens de paiement sont acceptés\u00a0?',
            a: 'Nous acceptons les paiements par carte bancaire (Visa, Mastercard), virement bancaire ainsi que le paiement en espèces directement auprès du prestataire selon les cas.',
            tab: 'clients',
          },
          {
            q: 'Puis-je annuler ou modifier une réservation\u00a0?',
            a: 'Oui, vous pouvez annuler ou modifier une réservation depuis votre espace client. Des conditions d annulation peuvent s appliquer selon le délai avant l intervention. Consultez nos CGU pour les détails.',
            tab: 'clients',
          },
          {
            q: 'Comment laisser un avis sur un prestataire\u00a0?',
            a: 'Après chaque intervention terminée, vous recevrez une notification vous invitant à laisser un avis sur le prestataire. Vous pouvez également accéder à cette option depuis l historique de vos réservations.',
            tab: 'clients',
          },
          {
            q: 'Les prestataires sont-ils vérifiés\u00a0?',
            a: 'Oui, tous les prestataires passent par un processus de vérification d identité et de qualifications avant d être autorisés à proposer leurs services sur la plateforme.',
            tab: 'clients',
          },
          {
            q: 'Que se passe-t-il en cas d incident lors d une intervention?',
            a: 'En cas d incident, contactez immédiatement notre service client. AtlasFix dispose d une assurance couvrant les interventions réalisées via la plateforme. Notre équipe vous accompagnera dans les démarches.',
            tab: 'clients',
          },
        ],
        prestataires: [
          {
            q: 'Comment m inscrire en tant que prestataire?',
            a: 'Créez un compte prestataire, complétez votre profil avec vos qualifications, vos zones d intervention et vos tarifs, puis soumettez vos documents pour validation.',
            tab: 'prestataires',
          },
          {
            q: 'Quand et comment suis-je payé\u00a0?',
            a: 'Les paiements sont effectués sous 3 jours ouvrés après la confirmation de l intervention par le client. Ils sont versés directement sur votre compte bancaire.',
            tab: 'prestataires',
          },
          {
            q: 'Puis-je définir mes propres tarifs\u00a0?',
            a: 'Oui, vous êtes libre de fixer vos propres tarifs. Nous vous recommandons de rester compétitif par rapport au marché local pour maximiser vos réservations.',
            tab: 'prestataires',
          },
          {
            q: 'Comment gérer mes disponibilités\u00a0?',
            a: 'Depuis votre tableau de bord prestataire, vous pouvez définir vos créneaux disponibles, bloquer des jours et accepter ou refuser des demandes selon votre agenda.',
            tab: 'prestataires',
          },
          {
            q: 'Quelle commission AtlasFix prélève-t-elle\u00a0?',
            a: 'AtlasFix prélève une commission de 15% sur chaque transaction réalisée via la plateforme. Cette commission couvre les frais de mise en relation, le marketing et le support client.',
            tab: 'prestataires',
          },
          {
            q: 'Comment améliorer mon classement sur la plateforme\u00a0?',
            a: 'Votre classement dépend de la qualité de vos avis, de votre taux de réponse, du respect des délais et de la complétude de votre profil. Un profil vérifié avec de bonnes évaluations apparaîtra en tête des résultats.',
            tab: 'prestataires',
          },
        ],
      },
    }
  },
  computed: {
    activeFaqs() {
      if (this.activeTab === 'all') {
        return [...this.faqs.clients, ...this.faqs.prestataires]
      }
      return this.faqs[this.activeTab] || []
    },
    filteredFaqs() {
      const q = this.searchQuery.trim().toLowerCase()
      if (!q) return this.activeFaqs
      return this.activeFaqs.filter(f =>
        f.q.toLowerCase().includes(q) || f.a.toLowerCase().includes(q)
      )
    },
  },
  methods: {
    toggle(idx) {
      this.openIdx = this.openIdx === idx ? null : idx
    },
  },
  watch: {
    activeTab() { this.openIdx = 0 },
  },
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&family=Inter:wght@400;500&display=swap');

/* ─── Page ────────────────────────────── */
.faq-page {
  width: 100%;
  font-family: 'Inter', sans-serif;
  box-sizing: border-box;
}

/* ─── Hero ────────────────────────────── */
.hero {
  width: 100%;
  background: linear-gradient(135deg, #FFF7ED 0%, #FFFFFF 50%, #EFF6FF 100%);
  padding: 80px 16px 72px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
}

.hero-inner {
  width: 100%;
  max-width: 768px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

/* Badge */
.hero-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 50px;
  padding: 0 20px;
  background: #fff;
  border: 1px solid #FFD6A7;
  border-radius: 9999px;
  box-shadow: 0 1px 3px rgba(0,0,0,.10), 0 1px 2px -1px rgba(0,0,0,.10);
  font-family: 'Poppins', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.hero-badge svg { width: 20px; height: 20px; flex-shrink: 0; }

/* Title */
.hero-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 60px;
  line-height: 71px;
  letter-spacing: 0.26px;
  color: #314158;
  text-align: center;
  margin: 0;
}

/* Subtitle */
.hero-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  text-align: center;
  margin: 0;
}

/* Search */
.search-wrap {
  position: relative;
  width: 100%;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 24px;
  height: 24px;
  pointer-events: none;
}

.search-input {
  box-sizing: border-box;
  width: 100%;
  height: 72px;
  padding: 20px 16px 20px 56px;
  background: #fff;
  border: 2px solid #E5E7EB;
  border-radius: 16px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,.10), 0 4px 6px -4px rgba(0,0,0,.10);
  font-family: 'Poppins', sans-serif;
  font-size: 18px;
  line-height: 27px;
  letter-spacing: -0.44px;
  color: #314158;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.search-input::placeholder { color: rgba(49,65,88,0.5); }
.search-input:focus {
  border-color: #FC5A15;
  box-shadow: 0 0 0 4px rgba(252,90,21,0.10);
}

/* ─── Content ─────────────────────────── */
.content {
  width: 100%;
  max-width: 1280px;
  margin: 0 auto;
  padding: 48px 16px 80px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 48px;
}

/* ─── Filter tabs ─────────────────────── */
.tabs {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 14px;
}

.tab-btn {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 8px;
  height: 50px;
  padding: 0 24px;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  cursor: pointer;
  transition: background 0.18s, color 0.18s, border-color 0.18s, box-shadow 0.18s;
  border: 1px solid #E5E7EB;
  background: #fff;
  color: #58595B;
}

.tab-btn svg { width: 20px; height: 20px; flex-shrink: 0; }

.tab-btn.active {
  background: #FC5A15;
  border-color: #FC5A15;
  color: #fff;
  box-shadow: 0 4px 7.6px rgba(0,0,0,0.15);
}

/* ─── Two-column body ─────────────────── */
.body-cols {
  display: grid;
  grid-template-columns: 1fr 395px;
  gap: 32px;
  align-items: start;
  width: 100%;
}

/* ─── Accordion ───────────────────────── */
.accordion-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.faq-item {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,.10), 0 1px 2px -1px rgba(0,0,0,.10);
  overflow: hidden;
  transition: box-shadow 0.2s;
}

.faq-item.open {
  box-shadow: 0 4px 12px rgba(252,90,21,0.10);
}

.faq-question {
  width: 100%;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 0 24px;
  height: 74px;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 18px;
  line-height: 28px;
  letter-spacing: -0.44px;
  color: #314158;
}

.faq-question span:first-child { flex: 1; }

.faq-chevron {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.25s ease;
}

.faq-chevron svg { width: 24px; height: 24px; }

.faq-item.open .faq-chevron { transform: rotate(180deg); }

.faq-answer {
  border-top: 1px solid #F3F4F6;
  padding: 16px 24px 20px;
}

.faq-answer p {
  margin: 0;
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 16px;
  line-height: 26px;
  letter-spacing: -0.31px;
  color: #62748E;
}

.no-results {
  text-align: center;
  color: #62748E;
  font-size: 16px;
  padding: 32px 0;
}

/* ─── Sidebar ─────────────────────────── */
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Help card */
.help-card {
  width: 100%;
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0,0,0,.10), 0 8px 10px -6px rgba(0,0,0,.10);
  padding: 32px 32px 32px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 0;
  position: relative;
  min-height: 268px;
}

.help-card-icon {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
}

.help-card-icon svg { width: 48px; height: 48px; }

.help-card-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #fff;
  margin: 0 0 8px;
}

.help-card-desc {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: rgba(255,255,255,0.9);
  margin: 0 0 24px;
}

.help-card-btn {
  width: 100%;
  height: 48px;
  background: #fff;
  border: none;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #FC5A15;
  cursor: pointer;
  transition: opacity 0.2s;
}

.help-card-btn:hover { opacity: 0.9; }

/* Contact card */
.contact-card {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,.10), 0 1px 2px -1px rgba(0,0,0,.10);
  padding: 25px 25px 24px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.contact-card-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 18px;
  line-height: 28px;
  letter-spacing: -0.44px;
  color: #314158;
  margin: 0;
}

.contact-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.contact-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.contact-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.contact-icon svg { width: 20px; height: 20px; }
.contact-icon.blue   { background: #DBEAFE; }
.contact-icon.green  { background: #DCFCE7; }
.contact-icon.purple { background: #F3E8FF; }

.contact-text {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.contact-sub {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.contact-val {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

/* ─── Responsive ──────────────────────── */
@media (max-width: 1000px) {
  .body-cols { grid-template-columns: 1fr; }
  .sidebar   { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
}

@media (max-width: 640px) {
  .hero-title  { font-size: 36px; line-height: 44px; }
  .tabs        { flex-wrap: wrap; justify-content: center; }
  .sidebar     { grid-template-columns: 1fr; }
  .search-input { height: 56px; font-size: 15px; }
}
</style>
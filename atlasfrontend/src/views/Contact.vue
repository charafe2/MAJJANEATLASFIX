<template>
  <section class="contact-section">

    <!-- ── Hero text ─────────────────────────────────────── -->
    <div class="contact-hero">
      <h1 class="contact-title">Contactez-nous</h1>
      <p class="contact-subtitle">
        Une question&nbsp;? Un problème&nbsp;? Notre équipe est là pour vous aider
      </p>
    </div>

    <!-- ── Main two-column layout ─────────────────────────── -->
    <div class="contact-body">

      <!-- ── LEFT COLUMN ──────────────────────────────────── -->
      <div class="left-col">

        <!-- Contact info card -->
        <div class="info-card">
          <h2 class="info-card-title">Informations de contact</h2>

          <div class="info-list">

            <!-- Téléphone -->
            <div class="info-item">
              <div class="info-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.07 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3 1.18h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.09 9a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21 16l1.01-.08z" stroke="#FC5A15" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
              </div>
              <div class="info-text">
                <span class="info-label">Téléphone</span>
                <span class="info-value">+33 1 23 45 67 89</span>
                <span class="info-sub">Lun-Ven: 9h-18h</span>
              </div>
            </div>

            <!-- Email -->
            <div class="info-item">
              <div class="info-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none"><rect x="2" y="4" width="20" height="16" rx="2" stroke="#FC5A15" stroke-width="2"/><path d="M2 9l10 6 10-6" stroke="#FC5A15" stroke-width="2" stroke-linejoin="round"/></svg>
              </div>
              <div class="info-text">
                <span class="info-label">Email</span>
                <span class="info-value">contact@handypro.fr</span>
                <span class="info-sub">Réponse sous 24h</span>
              </div>
            </div>

            <!-- Adresse -->
            <div class="info-item">
              <div class="info-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" stroke="#FC5A15" stroke-width="2" stroke-linejoin="round"/><circle cx="12" cy="9" r="2.5" stroke="#FC5A15" stroke-width="2"/></svg>
              </div>
              <div class="info-text">
                <span class="info-label info-label--bold">Adresse</span>
                <span class="info-value">123 Avenue des Artisans</span>
                <span class="info-value">75001 Paris, France</span>
              </div>
            </div>

            <!-- Horaires -->
            <div class="info-item">
              <div class="info-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="#FC5A15" stroke-width="2"/><polyline points="12 6 12 12 16 14" stroke="#FC5A15" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
              </div>
              <div class="info-text">
                <span class="info-label info-label--bold">Horaires</span>
                <span class="info-value">Lun-Ven: 9h00 - 18h00</span>
                <span class="info-value">Sam: 10h00 - 16h00</span>
                <span class="info-value">Dim: Fermé</span>
              </div>
            </div>

          </div>
        </div>

        <!-- FAQ orange card -->
        <div class="faq-card">
          <div class="faq-card-header">
            <div class="faq-icon-wrap">
              <svg viewBox="0 0 24 24" fill="none"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 11v1" stroke="white" stroke-width="2" stroke-linecap="round"/><circle cx="12" cy="8" r="1" fill="white"/></svg>
            </div>
            <h2 class="faq-title">Questions fréquentes</h2>
          </div>
          <p class="faq-desc">
            Consultez notre FAQ pour trouver des réponses rapides aux questions les plus courantes.
          </p>
          <button class="faq-btn">Voir la FAQ</button>
        </div>

      </div>

      <!-- ── RIGHT COLUMN ─────────────────────────────────── -->
      <div class="right-col">

        <!-- Contact form card -->
        <div class="form-card">
          <div class="form-header">
            <div class="form-header-icon">
              <svg viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </div>
            <div>
              <h2 class="form-title">Envoyez-nous un message</h2>
              <p class="form-subtitle">Remplissez le formulaire ci-dessous</p>
            </div>
          </div>

          <div class="form-fields">

            <!-- Row: Prénom + Nom -->
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Prénom <span class="req">*</span></label>
                <input class="form-input" type="text" placeholder="Jean" />
              </div>
              <div class="form-group">
                <label class="form-label">Nom <span class="req">*</span></label>
                <input class="form-input" type="text" placeholder="Dupont" />
              </div>
            </div>

            <!-- Row: Email + Téléphone -->
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Email <span class="req">*</span></label>
                <input class="form-input" type="email" placeholder="jean.dupont@exemple.fr" />
              </div>
              <div class="form-group">
                <label class="form-label">Téléphone</label>
                <input class="form-input" type="tel" placeholder="06 12 34 56 78" />
              </div>
            </div>

            <!-- Sujet -->
            <div class="form-group form-group--full">
              <label class="form-label">Sujet <span class="req">*</span></label>
              <select class="form-select">
                <option value="" disabled selected></option>
                <option>Demande d'information</option>
                <option>Problème technique</option>
                <option>Réclamation</option>
                <option>Partenariat</option>
                <option>Autre</option>
              </select>
            </div>

            <!-- Message -->
            <div class="form-group form-group--full">
              <label class="form-label">Message <span class="req">*</span></label>
              <textarea class="form-textarea" placeholder="Décrivez votre demande en détail..." rows="6"></textarea>
            </div>

            <!-- Submit -->
            <button class="submit-btn">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M18.3 1.7L1 8.3l7 2.7 2.7 7 7.6-16.3z" stroke="white" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M8 11l4-4" stroke="white" stroke-width="1.667" stroke-linecap="round"/>
              </svg>
              Envoyer le message
            </button>

          </div>
        </div>

        <!-- Three small badge cards -->
        <div class="badge-row">
          <div class="badge-card">
            <div class="badge-icon green">
              <svg viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="8.5" stroke="#00A63E" stroke-width="1.667"/>
                <path d="M6.5 10.5l2.5 2.5 4.5-5" stroke="#00A63E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <p class="badge-label">Réponse rapide</p>
            <p class="badge-sub">Sous 24h</p>
          </div>
          <div class="badge-card">
            <div class="badge-icon blue">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M2 13.5V4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v7.5" stroke="#155DFC" stroke-width="1.667" stroke-linecap="round"/>
                <path d="M1 14h18" stroke="#155DFC" stroke-width="1.667" stroke-linecap="round"/>
              </svg>
            </div>
            <p class="badge-label">Support dédié</p>
            <p class="badge-sub">À votre écoute</p>
          </div>
          <div class="badge-card">
            <div class="badge-icon purple">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M17 2H3a1 1 0 0 0-1 1v11a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1z" stroke="#9810FA" stroke-width="1.667"/>
                <path d="M6.5 17.5h7" stroke="#9810FA" stroke-width="1.667" stroke-linecap="round"/>
                <path d="M10 14.5v3" stroke="#9810FA" stroke-width="1.667" stroke-linecap="round"/>
              </svg>
            </div>
            <p class="badge-label">Assistance téléphonique</p>
            <p class="badge-sub">Lun-Ven 9h-18h</p>
          </div>
        </div>

      </div>
    </div>

  </section>
</template>

<script>
export default { name: 'ContactPage' }
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&family=Inter:wght@400;500&display=swap');

/* ─── Section ─────────────────────────── */
.contact-section {
  width: 100%;
  max-width: 1280px;
  margin: 0 auto;
  padding: 80px 16px 80px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 48px;
  font-family: 'Inter', sans-serif;
}

/* ─── Hero text ───────────────────────── */
.contact-hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  animation: fadeDown 0.5s ease both;
}

.contact-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 48px;
  line-height: 48px;
  letter-spacing: 0.35px;
  color: #314158;
  margin: 0;
  text-align: center;
}

.contact-subtitle {
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #62748E;
  margin: 0;
  text-align: center;
}

/* ─── Two-column body ─────────────────── */
.contact-body {
  display: grid;
  grid-template-columns: 394px 1fr;
  gap: 32px;
  align-items: start;
}

/* ─── LEFT COLUMN ─────────────────────── */
.left-col {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Info card */
.info-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,.10), 0 4px 6px -4px rgba(0,0,0,.10);
  padding: 25px 25px 24px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.info-card-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #314158;
  margin: 0;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  gap: 16px;
}

.info-icon-wrap {
  width: 48px;
  height: 48px;
  background: #FFEDD4;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.info-icon-wrap svg { width: 24px; height: 24px; }

.info-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding-top: 4px;
}

.info-label {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.info-label--bold {
  font-weight: 500;
  font-size: 18px;
  letter-spacing: -0.44px;
}

.info-value {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
}

.info-sub {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

/* FAQ orange card */
.faq-card {
  background: linear-gradient(180deg, #FC5A15 0%, #E54D0F 100%);
  border-radius: 16px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,.10), 0 4px 6px -4px rgba(0,0,0,.10);
  padding: 24px 24px 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px;
}

.faq-card-header {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.faq-icon-wrap {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
}

.faq-icon-wrap svg { width: 24px; height: 24px; }

.faq-title {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #fff;
  margin: 0;
}

.faq-desc {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: rgba(255,255,255,0.9);
  margin: 0;
}

.faq-btn {
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

.faq-btn:hover { opacity: 0.9; }

/* ─── RIGHT COLUMN ────────────────────── */
.right-col {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Form card */
.form-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 16px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,.10), 0 4px 6px -4px rgba(0,0,0,.10);
  padding: 33px 33px 24px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-header {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.form-header-icon {
  width: 48px;
  height: 48px;
  background: #FC5A15;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.form-header-icon svg { width: 24px; height: 24px; }

.form-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #314158;
  margin: 0;
}

.form-subtitle {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

.form-fields {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group--full {
  width: 100%;
}

.form-label {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.req { color: #FC5A15; }

.form-input,
.form-select {
  box-sizing: border-box;
  width: 100%;
  height: 50px;
  padding: 12px 16px;
  border: 1px solid #D1D5DC;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #0a0a0a;
  background: #fff;
  outline: none;
  appearance: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-input::placeholder,
.form-select::placeholder { color: rgba(10,10,10,0.5); }

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  border-color: #FC5A15;
  box-shadow: 0 0 0 3px rgba(252,90,21,0.10);
}

.form-textarea {
  box-sizing: border-box;
  width: 100%;
  height: 170px;
  padding: 12px 16px;
  border: 1px solid #D1D5DC;
  border-radius: 14px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #0a0a0a;
  background: #fff;
  outline: none;
  resize: vertical;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-textarea::placeholder { color: rgba(10,10,10,0.5); }

.submit-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  width: 100%;
  height: 56px;
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

.submit-btn svg { width: 20px; height: 20px; flex-shrink: 0; }
.submit-btn:hover { filter: brightness(1.08); transform: scale(1.01); }

/* ─── Badge row ───────────────────────── */
.badge-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.badge-card {
  box-sizing: border-box;
  background: #fff;
  border: 1px solid #FC5A15;
  border-radius: 14px;
  box-shadow: 3px 5px 8.7px rgba(0,0,0,0.13);
  padding: 17px 16px 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  text-align: center;
}

.badge-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 4px;
}

.badge-icon svg { width: 20px; height: 20px; }
.badge-icon.green  { background: #DCFCE7; }
.badge-icon.blue   { background: #DBEAFE; }
.badge-icon.purple { background: #F3E8FF; }

.badge-label {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #314158;
  margin: 0;
}

.badge-sub {
  font-size: 12px;
  line-height: 16px;
  color: #62748E;
  margin: 0;
}

/* ─── Keyframes ───────────────────────── */
@keyframes fadeDown {
  from { opacity: 0; transform: translateY(-12px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ─── Responsive ──────────────────────── */
@media (max-width: 960px) {
  .contact-body { grid-template-columns: 1fr; }
  .left-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
}

@media (max-width: 640px) {
  .contact-title    { font-size: 32px; }
  .contact-subtitle { font-size: 16px; }
  .left-col  { grid-template-columns: 1fr; }
  .form-row  { grid-template-columns: 1fr; }
  .badge-row { grid-template-columns: 1fr; }
}
</style>
<template>
  <div class="litiges-page">

    <!-- ── Page Header ─────────────────────────────── -->
    <div class="page-header">
      <div class="page-header-inner">
        <div class="header-icon">
          <svg viewBox="0 0 24 24" fill="none">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8L14 2z"
              stroke="white" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M14 2v6h6" stroke="white" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M8 13h8M8 17h8M8 9h2" stroke="white" stroke-width="2.667" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="header-text">
          <h1>Résolution des litiges</h1>
          <p class="subtitle">Dernière mise à jour : 18 décembre 2025</p>
        </div>
      </div>
    </div>

    <!-- ── Content ─────────────────────────────────── -->
    <div class="litiges-content">

      <!-- Notre approche -->
      <div class="info-card">
        <div class="info-card-icon">
          <svg viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2"/>
            <path d="M12 8v4M12 16h.01" stroke="white" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="info-card-body">
          <h2>Notre approche</h2>
          <p>Nous mettons en relation des clients avec des prestataires indépendants.</p>
          <p>En cas de problème, nous proposons un processus simple et équitable pour aider les deux parties à trouver une solution rapidement.</p>
        </div>
      </div>

      <!-- Délai -->
      <div class="warning-card">
        <div class="warning-card-icon">
          <svg viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2"/>
            <path d="M12 6v6l4 2" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div class="warning-card-body">
          <h2>Délai</h2>
          <p>Les litiges doivent être ouverts dans les <strong>24 heures</strong> suivant la fin de la prestation.</p>
        </div>
      </div>

      <!-- Quand ouvrir un litige -->
      <div>
        <div class="section-header">
          <div class="section-icon green">
            <svg viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2"/>
              <path d="M9 12l2 2 4-4" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <h2>Quand ouvrir un litige</h2>
        </div>
        <div class="list-card">
          <p class="list-intro">Un litige peut être ouvert lorsque :</p>
          <ul class="bullet-list">
            <li v-for="reason in openReasons" :key="reason">
              <span class="bullet-dot orange"></span>
              {{ reason }}
            </li>
          </ul>
        </div>
      </div>

      <!-- Quand un litige n'est pas accepté -->
      <div>
        <div class="section-header">
          <div class="section-icon red">
            <svg viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2"/>
              <path d="M15 9l-6 6M9 9l6 6" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <h2>Quand un litige n'est pas accepté</h2>
        </div>
        <div class="list-card">
          <ul class="bullet-list">
            <li v-for="reason in rejectedReasons" :key="reason">
              <span class="bullet-dot red"></span>
              {{ reason }}
            </li>
          </ul>
        </div>
      </div>

      <!-- Processus -->
      <div>
        <div class="section-header">
          <div class="section-icon purple">
            <!-- share/workflow icon -->
            <svg viewBox="0 0 24 24" fill="none">
              <circle cx="18" cy="5" r="3" stroke="white" stroke-width="2"/>
              <circle cx="6" cy="12" r="3" stroke="white" stroke-width="2"/>
              <circle cx="18" cy="19" r="3" stroke="white" stroke-width="2"/>
              <path d="M8.59 13.51l6.83 3.98M15.41 6.51L8.59 10.49" stroke="white" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <h2>Processus</h2>
        </div>

        <div class="process-steps">

          <!-- Step 1: Soumission -->
          <div class="step-card purple">
            <div class="step-number purple">1</div>
            <div class="step-body">
              <h3>Soumission</h3>
              <ul class="icon-list">
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8L14 2z"
                      stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M14 2v6h6M8 13h8M8 17h5" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Description courte
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8L14 2z"
                      stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M14 2v6h6M8 13h8M8 17h5" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Photos ou captures d'écran
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8L14 2z"
                      stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M14 2v6h6M8 13h8M8 17h5" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Résultat souhaité
                </li>
              </ul>
            </div>
          </div>

          <!-- Step 2: Analyse -->
          <div class="step-card blue">
            <div class="step-number blue">2</div>
            <div class="step-body">
              <h3>Analyse</h3>
              <p class="step-intro">Nous examinons :</p>
              <ul class="icon-list">
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <circle cx="11" cy="11" r="7" stroke="#62748E" stroke-width="1.667"/>
                    <path d="M21 21l-4.35-4.35" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Les messages dans l'application
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <circle cx="11" cy="11" r="7" stroke="#62748E" stroke-width="1.667"/>
                    <path d="M21 21l-4.35-4.35" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Les détails de la prestation
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <circle cx="11" cy="11" r="7" stroke="#62748E" stroke-width="1.667"/>
                    <path d="M21 21l-4.35-4.35" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  Les preuves fournies
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <circle cx="11" cy="11" r="7" stroke="#62748E" stroke-width="1.667"/>
                    <path d="M21 21l-4.35-4.35" stroke="#62748E" stroke-width="1.667" stroke-linecap="round"/>
                  </svg>
                  L'historique des deux parties
                </li> 
              </ul>
            </div>
          </div>

          <!-- Step 3: Décision -->
          <div class="step-card green">
            <div class="step-number green">3</div>
            <div class="step-body">
              <h3>Décision</h3>
              <p class="step-intro">Nous prenons une décision équitable basée sur :</p>
              <ul class="icon-list">
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M3 10l2 2 4-4M3 17l2 2 4-4M13 12h8M13 5h8M13 19h8" stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  Les preuves
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M3 10l2 2 4-4M3 17l2 2 4-4M13 12h8M13 5h8M13 19h8" stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  Les règles de la plateforme
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none">
                    <path d="M3 10l2 2 4-4M3 17l2 2 4-4M13 12h8M13 5h8M13 19h8" stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  Les considérations de sécurité
                </li>
              </ul>
              <div class="note-box">La décision est finale.</div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'LitigesPage',
  data() {
    return {
      openReasons: [
        "La prestation n'a pas été réalisée",
        "Le prestataire ne s'est pas présenté",
        'La qualité du travail est clairement insuffisante',
        'Le client refuse de payer après la prestation',
        'Il existe un désaccord sur les détails du service',
        'Il y a un problème de sécurité ou de comportement',
      ],
      rejectedReasons: [
        'Paiement en espèces',
        'Paiement en dehors de la plateforme',
        'Accord privé entre le client et le prestataire',
        'Modification du service après réservation',
        'Aucun élément de preuve fourni',
        'Litige ouvert après 24 heures',
      ],
    }
  },
}
</script>

<style scoped>
@import '../assets/css/litiges.css';

/* ─── Tablet: 768px ────────────────────────────────── */
@media (max-width: 768px) {
  .page-header {
    padding: 32px 16px 28px;
  }

  .page-header-inner {
    gap: 12px;
  }

  .header-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
  }

  .header-icon svg {
    width: 24px;
    height: 24px;
  }

  .header-text h1 {
    font-size: 26px;
    line-height: 32px;
  }

  .header-text .subtitle {
    font-size: 14px;
    line-height: 20px;
  }

  .litiges-content {
    gap: 20px;
    padding-bottom: 60px;
  }

  .info-card,
  .warning-card {
    padding: 20px 20px 20px 24px;
  }

  .info-card-body h2,
  .warning-card-body h2,
  .section-header h2 {
    font-size: 20px;
    line-height: 28px;
  }

  .list-card {
    padding: 20px;
  }

  .step-card {
    padding: 20px 20px 20px 24px;
  }

  .step-body h3 {
    font-size: 18px;
    line-height: 26px;
  }

  .process-steps {
    gap: 20px;
  }
}

/* ─── Small tablet / large mobile: 640px ───────────── */
@media (max-width: 640px) {
  .page-header {
    padding: 28px 12px 24px;
  }

  .header-text h1 {
    font-size: 22px;
    line-height: 28px;
  }

  .litiges-content {
    padding: 0 12px 50px;
    gap: 18px;
  }

  .info-card,
  .warning-card {
    flex-direction: column;
    padding: 18px 16px;
    gap: 12px;
  }

  .info-card-icon,
  .warning-card-icon {
    width: 40px;
    height: 40px;
  }

  .info-card-icon svg,
  .warning-card-icon svg {
    width: 20px;
    height: 20px;
  }

  .info-card-body,
  .warning-card-body {
    gap: 10px;
  }

  .info-card-body p,
  .warning-card-body p {
    font-size: 14px;
    line-height: 22px;
  }

  .section-header {
    margin-bottom: 16px;
    gap: 10px;
  }

  .section-icon {
    width: 40px;
    height: 40px;
  }

  .section-icon svg {
    width: 20px;
    height: 20px;
  }

  .section-header h2 {
    font-size: 18px;
    line-height: 26px;
  }

  .list-card {
    padding: 16px;
  }

  .bullet-list {
    gap: 10px;
  }

  .bullet-list li {
    font-size: 14px;
    line-height: 22px;
    gap: 14px;
  }

  .step-card {
    flex-direction: column;
    padding: 18px 16px;
    gap: 12px;
  }

  .step-number {
    width: 36px;
    height: 36px;
    font-size: 16px;
  }

  .step-body {
    gap: 12px;
  }

  .step-body h3 {
    font-size: 16px;
    line-height: 24px;
  }

  .step-body .step-intro {
    font-size: 14px;
    line-height: 22px;
  }

  .icon-list li {
    font-size: 14px;
    line-height: 22px;
    gap: 10px;
  }

  .icon-list li svg {
    width: 18px;
    height: 18px;
  }

  .note-box {
    padding: 14px;
    font-size: 14px;
    line-height: 22px;
  }

  .process-steps {
    gap: 16px;
  }
}

/* ─── Mobile: 480px ────────────────────────────────── */
@media (max-width: 480px) {
  .page-header {
    padding: 24px 10px 20px;
  }

  .page-header-inner {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .header-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
  }

  .header-icon svg {
    width: 22px;
    height: 22px;
  }

  .header-text h1 {
    font-size: 20px;
    line-height: 26px;
  }

  .header-text .subtitle {
    font-size: 13px;
    line-height: 18px;
  }

  .litiges-content {
    padding: 0 10px 40px;
    gap: 16px;
  }

  .info-card,
  .warning-card {
    padding: 16px 14px;
    border-radius: 8px;
    gap: 10px;
  }

  .info-card-body h2,
  .warning-card-body h2 {
    font-size: 17px;
    line-height: 24px;
  }

  .info-card-body p,
  .warning-card-body p {
    font-size: 13px;
    line-height: 20px;
  }

  .section-header {
    margin-bottom: 14px;
  }

  .section-header h2 {
    font-size: 17px;
    line-height: 24px;
  }

  .list-card {
    padding: 14px;
    border-radius: 8px;
  }

  .list-intro {
    font-size: 14px;
    margin-bottom: 12px;
  }

  .bullet-list li {
    font-size: 13px;
    line-height: 20px;
    gap: 12px;
  }

  .step-card {
    padding: 16px 14px;
    border-radius: 0px 8px 8px 0px;
    gap: 10px;
  }

  .step-number {
    width: 32px;
    height: 32px;
    font-size: 14px;
  }

  .step-body h3 {
    font-size: 15px;
    line-height: 22px;
  }

  .icon-list li {
    font-size: 13px;
    line-height: 20px;
  }

  .note-box {
    padding: 12px;
    font-size: 13px;
    line-height: 20px;
    border-radius: 8px;
  }
}
</style>

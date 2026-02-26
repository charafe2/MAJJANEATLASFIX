<template>
  <div class="profile-page">

    <!-- ── Loading ───────────────────────────────────────── -->
    <div v-if="loading" class="state-box">
      <div class="spinner" /><p>Chargement du profil…</p>
    </div>

    <!-- ── Error ─────────────────────────────────────────── -->
    <div v-else-if="error" class="state-box">
      <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10" stroke="#EF4444" stroke-width="1.5"/>
        <path d="M12 8v4m0 4h.01" stroke="#EF4444" stroke-width="2" stroke-linecap="round"/>
      </svg>
      <p>{{ error }}</p>
      <button class="btn-retry" @click="fetchProfile">Réessayer</button>
    </div>

    <template v-else>

      <!-- ── Header banner ──────────────────────────────── -->
      <div class="header-banner">
        <div class="header-inner">
          <button class="back-btn" @click="goBack">
            <svg viewBox="0 0 20 20" fill="none">
              <path d="M12.5 5l-5 5 5 5" stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Retour
          </button>

          <div class="header-content">
            <div class="header-text">
              <h1 class="page-title">Mon profil</h1>
              <p class="page-subtitle">Gérez vos informations personnelles</p>
            </div>
            <button class="edit-btn" @click="openEditModal">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M14.5 2.5a2.121 2.121 0 0 1 3 3L6 17l-4 1 1-4L14.5 2.5z" stroke="white" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Modifier
            </button>
          </div>
        </div>
      </div>

      <!-- ── Stats cards ────────────────────────────────── -->
      <div class="stats-row">
        <div class="stat-card">
          <svg class="stat-icon" viewBox="0 0 32 32" fill="none">
            <path d="M16 8v16M8 16h8" stroke="#FC5A15" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
            <rect x="4" y="12" width="16" height="8" stroke="#FC5A15" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <p class="stat-value">{{ artisan.total_jobs_completed ?? 0 }}</p>
          <p class="stat-label">Travaux complétés</p>
        </div>

        <div class="stat-card">
          <svg class="stat-icon" viewBox="0 0 32 32" fill="none">
            <path d="M16 4l3.09 6.26L26 11.27l-5 4.87 1.18 6.88L16 19.77l-6.18 3.25L11 16.14l-5-4.87 6.91-1.01L16 4z" fill="#F0B100" stroke="#F0B100" stroke-width="2.667"/>
          </svg>
          <p class="stat-value">{{ artisan.rating_average ?? 0 }}/5</p>
          <p class="stat-label">Note moyenne</p>
        </div>

        <div class="stat-card">
          <svg class="stat-icon" viewBox="0 0 32 32" fill="none">
            <path d="M16 21v-8M16 8h.01" stroke="#00A63E" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
            <circle cx="16" cy="16" r="10" stroke="#00A63E" stroke-width="2.667"/>
          </svg>
          <p class="stat-value">{{ artisan.total_reviews ?? 0 }}</p>
          <p class="stat-label">Avis clients</p>
        </div>

        <div class="stat-card">
          <svg class="stat-icon" viewBox="0 0 32 32" fill="none">
            <circle cx="16" cy="16" r="10" stroke="#155DFC" stroke-width="2.667"/>
            <path d="M16 8v8l4 2" stroke="#155DFC" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <p class="stat-value">{{ responseTimeDisplay }}</p>
          <p class="stat-label">Temps de réponse</p>
        </div>
      </div>

      <!-- ── Main content ────────────────────────────────── -->
      <div class="content-cols">

        <!-- LEFT COLUMN -->
        <div class="left-col">

          <!-- Profile card -->
          <div class="profile-card">
            <div class="avatar-wrap">
              <img v-if="artisan.avatar" :src="artisan.avatar" :alt="artisan.name" class="avatar avatar--img" />
              <div v-else class="avatar">{{ avatarInitials }}</div>
              <button class="avatar-edit-btn" @click="triggerAvatarInput" :disabled="savingAvatar" :title="savingAvatar ? 'Upload en cours…' : 'Changer la photo'">
                <svg v-if="!savingAvatar" viewBox="0 0 20 20" fill="none">
                  <path d="M14.5 2.5a2.121 2.121 0 0 1 3 3L6 17l-4 1 1-4L14.5 2.5z" stroke="#FC5A15" stroke-width="1.5"/>
                </svg>
                <span v-else class="avatar-spinner"></span>
              </button>
              <input ref="avatarInputRef" type="file" accept="image/jpg,image/jpeg,image/png,image/webp" class="input-hidden" @change="onAvatarChange" />
            </div>

            <h2 class="profile-name">{{ artisan.name || '—' }}</h2>
            <p class="profile-role">{{ artisan.service_category || artisan.business_name || '—' }}</p>

            <div class="profile-rating">
              <svg v-for="i in filledStars" :key="'f' + i" viewBox="0 0 20 20" fill="none">
                <path d="M10 2l2.09 4.26L18 7.27l-4 3.87.95 5.52L10 14.77l-5.05 2.65.95-5.52-4-3.87 5.91-1.01L10 2z" fill="#F0B100" stroke="#F0B100" stroke-width="1.667"/>
              </svg>
              <svg v-for="i in emptyStars" :key="'e' + i" viewBox="0 0 20 20" fill="none">
                <path d="M10 2l2.09 4.26L18 7.27l-4 3.87.95 5.52L10 14.77l-5.05 2.65.95-5.52-4-3.87 5.91-1.01L10 2z" stroke="#D1D5DC" stroke-width="1.667"/>
              </svg>
              <span class="rating-val">{{ artisan.rating_average ?? 0 }}</span>
            </div>

            <div class="profile-details">
              <div class="detail-item">
                <svg viewBox="0 0 20 20" fill="none">
                  <path d="M10 2C6.13 2 3 5.13 3 9c0 5.25 7 11 7 11s7-5.75 7-11c0-3.87-3.13-7-7-7z" stroke="#62748E" stroke-width="1.667" stroke-linejoin="round"/>
                  <circle cx="10" cy="9" r="2" stroke="#62748E" stroke-width="1.667"/>
                </svg>
                <span>{{ artisan.city || '—' }}</span>
              </div>
              <div class="detail-item">
                <svg viewBox="0 0 20 20" fill="none">
                  <path d="M18 13.5v2.25A1.5 1.5 0 0 1 16.5 17c-6.627 0-12-5.373-12-12A1.5 1.5 0 0 1 6 3.5h2.25a.75.75 0 0 1 .75.75c0 1.013.168 1.985.48 2.893a.75.75 0 0 1-.17.79l-1.07 1.07a12.001 12.001 0 0 0 4.707 4.707l1.07-1.07a.75.75 0 0 1 .79-.17c.908.312 1.88.48 2.893.48a.75.75 0 0 1 .75.75z" stroke="#62748E" stroke-width="1.667"/>
                </svg>
                <span>{{ artisan.phone || '—' }}</span>
              </div>
              <div class="detail-item">
                <svg viewBox="0 0 20 20" fill="none">
                  <rect x="2" y="4" width="16" height="13" rx="1.5" stroke="#62748E" stroke-width="1.667"/>
                  <path d="M2 7.5l8 5 8-5" stroke="#62748E" stroke-width="1.667" stroke-linejoin="round"/>
                </svg>
                <span>{{ artisan.email || '—' }}</span>
              </div>
            </div>
          </div>

          <!-- Boost service card -->
          <div class="boost-card">
            <div class="boost-header">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M10 2l-2 8h6l-2 8" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M4 10h12" stroke="#FC5A15" stroke-width="1.667"/>
              </svg>
              <h3>Booster un service</h3>
            </div>

            <!-- Free boost credits banner -->
            <div v-if="artisan.boost_credits > 0" class="boost-free-banner">
              <svg viewBox="0 0 20 20" fill="none" width="16" height="16">
                <path d="M10 2l-2 8h6l-2 8M4 10h12" stroke="#00A63E" stroke-width="1.667" stroke-linecap="round"/>
              </svg>
              <span>
                <strong>{{ artisan.boost_credits }} boost{{ artisan.boost_credits > 1 ? 's' : '' }} gratuit{{ artisan.boost_credits > 1 ? 's' : '' }} disponible{{ artisan.boost_credits > 1 ? 's' : '' }}</strong>
                — offert{{ artisan.boost_credits > 1 ? 's' : '' }} via parrainage
              </span>
            </div>

            <div class="boost-list">
              <template v-if="artisan.services && artisan.services.length">
                <div
                  v-for="svc in artisan.services"
                  :key="svc.id"
                  class="boost-item boost-item--selected"
                >
                  <div class="boost-item-left">
                    <div class="boost-icon boost-icon--active">
                      <svg viewBox="0 0 20 20" fill="none">
                        <path d="M10 2l-2 8h6l-2 8M4 10h12" stroke="white" stroke-width="1.667"/>
                      </svg>
                    </div>
                    <div class="boost-item-text">
                      <span>{{ svc.category || '—' }}</span>
                      <small v-if="svc.type" style="display:block;font-size:12px;color:#62748E;">{{ svc.type }}</small>
                    </div>
                  </div>
                  <button class="boost-edit-btn" @click="openBoostFlow(svc)">
                    <svg viewBox="0 0 20 20" fill="none">
                      <path d="M15 7l-6 6M15 13V7h-6" stroke="#62748E" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </button>
                </div>
              </template>
              <div v-else class="boost-item" style="justify-content:center;color:#62748E;font-size:14px;">
                Aucun service ajouté pour le moment
              </div>
            </div>

            <div class="boost-notice">
              <p>Cliquez sur un service pour modifier ses informations, ses disponibilités et obtenir a clés à droite du service pour modifier</p>
            </div>
          </div>

          <!-- Referral card -->
          <div class="referral-card">
            <div class="referral-icon-wrap">
              <svg viewBox="0 0 32 32" fill="none">
                <rect x="4" y="14" width="24" height="14" rx="2" stroke="white" stroke-width="2"/>
                <path d="M4 19h24" stroke="white" stroke-width="2"/>
                <path d="M16 14v14" stroke="white" stroke-width="2"/>
                <path d="M16 14c0 0-5-6.5-8-4.5S12 14 16 14z" stroke="white" stroke-width="1.8" stroke-linejoin="round" fill="none"/>
                <path d="M16 14c0 0 5-6.5 8-4.5S20 14 16 14z" stroke="white" stroke-width="1.8" stroke-linejoin="round" fill="none"/>
              </svg>
            </div>
            <h3 class="referral-title">Programme de Parrainage</h3>
            <p class="referral-desc">Partagez AtlasFix avec vos amis et gagnez un boost gratuit pour chaque inscription</p>

            <!-- Stats row — only when artisan has referrals -->
            <div v-if="showReferralActive" class="referral-stats-row">
              <div class="referral-stat-card referral-stat-card--purple">
                <span class="referral-stat-val">{{ artisan.referrals_count || 0 }}</span>
                <span class="referral-stat-label">Parrainages</span>
              </div>
              <div class="referral-stat-card referral-stat-card--green">
                <span class="referral-stat-val">{{ artisan.boost_credits || 0 }}</span>
                <span class="referral-stat-label">Boosts gagnés</span>
              </div>
            </div>

            <!-- Generate link button — always shown -->
            <button class="referral-btn" @click="showLinkModal = true">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M13 10a3 3 0 0 0-3-3H7a3 3 0 0 0 0 6h3" stroke="white" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M10 13a3 3 0 0 0 3 3h3a3 3 0 0 0 0-6h-3" stroke="white" stroke-width="1.6" stroke-linecap="round"/>
              </svg>
              Générer mon lien de parrainage
            </button>

            <!-- Use boost button — only when credits available -->
            <button v-if="showReferralActive && artisan.boost_credits > 0" class="referral-use-boost-btn" :disabled="activatingBoost" @click="activateBoost">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M11 2L4 11h6l-1 7 7-9h-6l1-7z" stroke="white" stroke-width="1.6" stroke-linejoin="round"/>
              </svg>
              {{ activatingBoost ? 'Activation...' : `Utiliser un boost (${artisan.boost_credits})` }}
            </button>

            <!-- Yellow notice -->
            <div class="referral-notice">
              <svg viewBox="0 0 16 16" fill="none">
                <circle cx="8" cy="8" r="6" fill="#D08700"/>
                <path d="M8 5.5v3M8 10.5v.5" stroke="white" stroke-width="1.4" stroke-linecap="round"/>
              </svg>
              <div>
                <strong>Gagnez 24h de boost gratuit</strong> pour chaque artisan qui s'inscrit via votre lien.
              </div>
            </div>
          </div>

          <!-- Link modal -->
          <teleport to="body">
            <div v-if="showLinkModal" class="link-modal-backdrop" @click.self="showLinkModal = false">
              <div class="link-modal">
                <div class="link-modal-header">
                  <h3 class="link-modal-title">Mon lien de parrainage</h3>
                  <button class="link-modal-close" @click="showLinkModal = false">
                    <svg viewBox="0 0 20 20" fill="none">
                      <path d="M5 5l10 10M15 5L5 15" stroke="#62748E" stroke-width="1.8" stroke-linecap="round"/>
                    </svg>
                  </button>
                </div>
                <p class="link-modal-sub">Partagez ce lien avec vos amis artisans pour gagner des boosts gratuits.</p>
                <div class="link-modal-box">
                  <span class="link-modal-url">{{ referralLink }}</span>
                </div>
                <button class="link-modal-copy-btn" @click="copyReferralLink">
                  <svg viewBox="0 0 20 20" fill="none">
                    <rect x="8" y="8" width="10" height="10" rx="1.5" stroke="white" stroke-width="1.6"/>
                    <path d="M4 12H3a1 1 0 0 1-1-1V3a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v1" stroke="white" stroke-width="1.6"/>
                  </svg>
                  Copier le lien
                </button>
              </div>
            </div>
          </teleport>

        </div>

        <!-- RIGHT COLUMN -->
        <div class="right-col">

          <!-- Tabs -->
          <div class="tabs">
            <button :class="['tab-btn', activeTab === 'info' ? 'tab-btn--active' : '']" @click="activeTab = 'info'">Informations professionnelles</button>
            <button :class="['tab-btn', activeTab === 'prefs' ? 'tab-btn--active' : '']" @click="activeTab = 'prefs'">Préférences</button>
            <button :class="['tab-btn', activeTab === 'security' ? 'tab-btn--active' : '']" @click="activeTab = 'security'">Sécurité</button>
          </div>

          <template v-if="activeTab === 'info'">

          <!-- Service selector -->
          <div class="service-selector">
            <div class="modal-select-wrap" style="flex:1">
              <select class="modal-select" style="height:63px; font-size:15px; color:#314158;">
                <option value="" disabled selected>Sélectionnez un service</option>
                <template v-if="artisan.services && artisan.services.length">
                  <option v-for="svc in artisan.services" :key="svc.id" :value="svc.id">
                    {{ svc.category }} — {{ svc.type }}
                  </option>
                </template>
                <option v-else disabled value="primary">{{ artisan.service_category || '—' }}</option>
              </select>
              <svg class="modal-chevron" viewBox="0 0 10 6" fill="none">
                <path d="M1 1l4 4 4-4" stroke="#314158" stroke-width="1.698"/>
              </svg>
            </div>
            <button class="add-service-btn" @click="openAddServiceModal">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M10 5v10M5 10h10" stroke="white" stroke-width="1.833" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Ajouter un service
            </button>
          </div>

          <!-- About section -->
          <div class="section-card">
            <h3 class="section-title">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M10 2C6.13 2 3 5.13 3 9c0 5.25 7 11 7 11s7-5.75 7-11c0-3.87-3.13-7-7-7z" stroke="#FC5A15" stroke-width="1.667" stroke-linejoin="round"/>
                <circle cx="10" cy="9" r="1.5" stroke="#FC5A15" stroke-width="1.667"/>
              </svg>
              À propos
            </h3>
            <p class="section-text">{{ artisan.bio || 'Aucune description disponible.' }}</p>
          </div>

          <!-- Service types -->
          <div class="section-card">
            <h3 class="section-title">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M10 17v-4M10 8V4" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.667"/>
              </svg>
              Type de services
            </h3>
            <div class="service-tags">
              <template v-if="artisan.services && artisan.services.length">
                <span
                  v-for="svc in artisan.services"
                  :key="svc.id"
                  class="service-tag"
                  :title="svc.description"
                >{{ svc.category }} — {{ svc.type }}</span>
              </template>
              <span v-else class="no-data">Aucun service configuré</span>
              <button class="service-tag-add" @click="openAddServiceModal" title="Ajouter un service">
                <svg viewBox="0 0 22 22" fill="none">
                  <path d="M11 5v12M5 11h12" stroke="white" stroke-width="1.833" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- Experience & Pricing -->
          <div class="info-row">
            <div class="info-card">
              <h4 class="info-card-title">
                <svg viewBox="0 0 20 20" fill="none">
                  <path d="M10 2l-2 8h6l-2 8M4 10h12" stroke="#FC5A15" stroke-width="1.667"/>
                </svg>
                Expérience
              </h4>
              <p class="info-card-value">
                {{ artisan.experience_years != null ? artisan.experience_years + ' ans' : '—' }}
              </p>
            </div>
            <div class="info-card">
              <h4 class="info-card-title">
                <svg viewBox="0 0 20 20" fill="none">
                  <path d="M10 17v-4M10 8V4" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                  <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.667"/>
                </svg>
                Tarif minimum
              </h4>
              <p class="info-card-value">—</p>
            </div>
          </div>

          <!-- Certifications -->
          <div class="section-card">
            <h3 class="section-title">
              <svg viewBox="0 0 20 20" fill="none">
                <path d="M10 17v-4M10 8V4" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.667"/>
              </svg>
              Certifications
            </h3>
            <div class="cert-list">
              <p v-if="!artisan.certifications || artisan.certifications.length === 0" class="no-data">Aucune certification ajoutée.</p>
              <template v-else>
                <div v-for="(cert, i) in artisan.certifications" :key="i" :class="['cert-item', i % 2 === 0 ? 'cert-item--green' : 'cert-item--blue']">
                  <div :class="['cert-icon', i % 2 === 0 ? 'cert-icon--green' : 'cert-icon--blue']">
                    <svg viewBox="0 0 24 24" fill="none">
                      <path d="M12 18v-4M12 10V6" :stroke="i % 2 === 0 ? '#00A63E' : '#155DFC'" stroke-width="2" stroke-linecap="round"/>
                      <circle cx="12" cy="12" r="10" :stroke="i % 2 === 0 ? '#00A63E' : '#155DFC'" stroke-width="2"/>
                    </svg>
                  </div>
                  <div>
                    <p class="cert-name">{{ cert.name }}</p>
                    <p class="cert-date">{{ cert.date }}</p>
                  </div>
                </div>
              </template>
            </div>
          </div>

          <!-- Portfolio grouped by service -->
          <div class="portfolio-card">
            <h3 class="portfolio-title">
              <svg viewBox="0 0 20 20" fill="none">
                <rect x="2" y="4" width="16" height="12" rx="1" stroke="#FC5A15" stroke-width="1.667"/>
                <circle cx="7.5" cy="9" r="1.5" stroke="#FC5A15" stroke-width="1.667"/>
                <path d="M16 13l-4-4-6 6" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Photos de mes travaux
            </h3>

            <!-- No services yet -->
            <p v-if="!artisan.services || artisan.services.length === 0" class="no-data">
              Aucun service configuré. Ajoutez un service pour voir vos photos ici.
            </p>

            <!-- One block per service -->
            <template v-else>
              <div
                v-for="svc in artisan.services"
                :key="svc.id"
                class="portfolio-service-group"
              >
                <!-- Service header -->
                <div class="portfolio-service-header">
                  <span class="portfolio-service-label">
                    <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                      <circle cx="10" cy="10" r="8" stroke="#FC5A15" stroke-width="1.667"/>
                      <path d="M10 6v4l3 2" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                    </svg>
                    {{ svc.category }}
                  </span>
                  <span class="portfolio-service-type">{{ svc.type }}</span>
                </div>

                <!-- Photos for this service -->
                <p
                  v-if="!photosForService(svc).length"
                  class="no-data portfolio-no-photos"
                >
                  Aucune photo pour ce service.
                </p>
                <div v-else class="portfolio-grid">
                  <div
                    v-for="photo in photosForService(svc)"
                    :key="photo.id"
                    class="portfolio-item"
                  >
                    <img :src="photo.url" :alt="photo.caption" class="portfolio-img" />
                    <div class="portfolio-overlay">
                      <span class="portfolio-caption">{{ photo.caption }}</span>
                    </div>
                    <!-- Delete button shown on hover -->
                    <button
                      class="portfolio-delete-btn"
                      @click.stop="deletePhoto(photo)"
                      :disabled="deletingPhotoId === photo.id"
                      title="Supprimer cette photo"
                    >
                      <svg v-if="deletingPhotoId !== photo.id" viewBox="0 0 20 20" fill="none" width="14" height="14">
                        <path d="M3 5h14M8 5V3h4v2M6 5l1 12h6l1-12" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      <span v-else class="portfolio-delete-spinner"></span>
                    </button>
                  </div>
                </div>
              </div>

              <!-- Photos not linked to any service (uploaded before services existed) -->
              <div v-if="orphanPhotos.length" class="portfolio-service-group">
                <div class="portfolio-service-header">
                  <span class="portfolio-service-label">Autres photos</span>
                </div>
                <div class="portfolio-grid">
                  <div
                    v-for="photo in orphanPhotos"
                    :key="photo.id"
                    class="portfolio-item"
                  >
                    <img :src="photo.url" :alt="photo.caption" class="portfolio-img" />
                    <div class="portfolio-overlay">
                      <span class="portfolio-caption">{{ photo.caption }}</span>
                    </div>
                    <button
                      class="portfolio-delete-btn"
                      @click.stop="deletePhoto(photo)"
                      :disabled="deletingPhotoId === photo.id"
                      title="Supprimer cette photo"
                    >
                      <svg v-if="deletingPhotoId !== photo.id" viewBox="0 0 20 20" fill="none" width="14" height="14">
                        <path d="M3 5h14M8 5V3h4v2M6 5l1 12h6l1-12" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      <span v-else class="portfolio-delete-spinner"></span>
                    </button>
                  </div>
                </div>
              </div>
            </template>
          </div>

          </template><!-- /info -->

          <!-- ── Préférences tab ── -->
          <template v-else-if="activeTab === 'prefs'">
            <div class="tab-panel">
              <h3 class="tab-panel-title">Préférences</h3>
              <div class="pref-list">

                <div class="pref-item">
                  <div class="pref-left">
                    <div class="pref-icon">
                      <svg viewBox="0 0 20 20" fill="none">
                        <path d="M10 2a6 6 0 0 0-6 6v3.5l-1.5 2.5h15L16 11.5V8a6 6 0 0 0-6-6z" stroke="#FC5A15" stroke-width="1.667" stroke-linejoin="round"/>
                        <path d="M8.5 16a1.5 1.5 0 0 0 3 0" stroke="#FC5A15" stroke-width="1.667"/>
                      </svg>
                    </div>
                    <div class="pref-text">
                      <span class="pref-title">Notifications par email</span>
                      <span class="pref-desc">Recevoir des notifications sur les nouvelles demandes</span>
                    </div>
                  </div>
                  <button :class="['toggle', emailNotifs ? 'toggle--on' : '']" @click="emailNotifs = !emailNotifs">
                    <span class="toggle-thumb"></span>
                  </button>
                </div>

                <div class="pref-item">
                  <div class="pref-left">
                    <div class="pref-icon">
                      <svg viewBox="0 0 20 20" fill="none">
                        <path d="M18 13.5v2.25A1.5 1.5 0 0 1 16.5 17c-6.627 0-12-5.373-12-12A1.5 1.5 0 0 1 6 3.5h2.25a.75.75 0 0 1 .75.75c0 1.013.168 1.985.48 2.893a.75.75 0 0 1-.17.79l-1.07 1.07a12.001 12.001 0 0 0 4.707 4.707l1.07-1.07a.75.75 0 0 1 .79-.17c.908.312 1.88.48 2.893.48a.75.75 0 0 1 .75.75z" stroke="#FC5A15" stroke-width="1.667"/>
                      </svg>
                    </div>
                    <div class="pref-text">
                      <span class="pref-title">Notifications par SMS</span>
                      <span class="pref-desc">Recevoir des SMS pour les mises à jour importantes</span>
                    </div>
                  </div>
                  <button :class="['toggle', smsNotifs ? 'toggle--on' : '']" @click="smsNotifs = !smsNotifs">
                    <span class="toggle-thumb"></span>
                  </button>
                </div>

                <div class="pref-item pref-item--col">
                  <label class="pref-label">Langue</label>
                  <div class="pref-select-wrap">
                    <select v-model="language" class="pref-select">
                      <option value="fr">Français</option>
                      <option value="en">English</option>
                      <option value="es">العربية</option>
                    </select>
                    <svg class="select-chevron" viewBox="0 0 10 6" fill="none">
                      <path d="M1 1l4 4 4-4" stroke="rgba(98,116,142,0.65)" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </div>
                </div>

              </div>
            </div>
          </template><!-- /prefs -->

          <!-- ── Sécurité tab ── -->
          <template v-else-if="activeTab === 'security'">
            <div class="tab-panel">
              <h3 class="tab-panel-title">Sécurité</h3>
              <div class="pref-list">

                <div class="pref-item">
                  <div class="pref-left">
                    <div class="pref-icon">
                      <svg viewBox="0 0 20 20" fill="none">
                        <rect x="4" y="9" width="12" height="9" rx="1.5" stroke="#FC5A15" stroke-width="1.667"/>
                        <path d="M7 9V6a3 3 0 0 1 6 0v3" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                      </svg>
                    </div>
                    <div class="pref-text">
                      <span class="pref-title">Modifier le mot de passe</span>
                      <span class="pref-desc">Changez votre mot de passe régulièrement</span>
                    </div>
                  </div>
                  <button class="sec-btn">Modifier</button>
                </div>

                <div class="pref-item">
                  <div class="pref-left">
                    <div class="pref-icon">
                      <svg viewBox="0 0 20 20" fill="none">
                        <rect x="4" y="9" width="12" height="9" rx="1.5" stroke="#FC5A15" stroke-width="1.667"/>
                        <path d="M7 9V6a3 3 0 0 1 6 0v3" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                      </svg>
                    </div>
                    <div class="pref-text">
                      <span class="pref-title">Authentification à deux facteurs</span>
                      <span class="pref-desc">Sécurisez votre compte avec la 2FA</span>
                    </div>
                  </div>
                  <button :class="['toggle', twoFa ? 'toggle--on' : '']" @click="twoFa = !twoFa">
                    <span class="toggle-thumb"></span>
                  </button>
                </div>

                <div class="pref-item">
                  <div class="pref-left">
                    <div class="pref-icon">
                      <svg viewBox="0 0 20 20" fill="none">
                        <rect x="1.5" y="4.5" width="17" height="13" rx="1.5" stroke="#FC5A15" stroke-width="1.667"/>
                        <path d="M1.5 8.5h17" stroke="#FC5A15" stroke-width="1.667"/>
                        <path d="M5 13h3" stroke="#FC5A15" stroke-width="1.667" stroke-linecap="round"/>
                      </svg>
                    </div>
                    <div class="pref-text">
                      <span class="pref-title">Moyens de paiement</span>
                      <span class="pref-desc">Gérez vos cartes bancaires</span>
                    </div>
                  </div>
                  <button class="sec-btn">Gérer</button>
                </div>

                <div class="danger-item">
                  <div class="danger-texts">
                    <span class="danger-title">Supprimer mon compte</span>
                    <span class="danger-desc">Cette action est irréversible</span>
                  </div>
                  <button class="danger-btn" @click="handleDeleteAccount">Supprimer</button>
                </div>

              </div>
            </div>
          </template><!-- /security -->

        </div>

      </div>

    </template>

    <!-- Toast -->
    <transition name="toast">
      <div v-if="toast.show" :class="['toast', 'toast--' + toast.type]">{{ toast.message }}</div>
    </transition>

    <!-- ── Edit Profile Modal ────────────────────────────────── -->
    <transition name="modal-fade">
      <div v-if="showEditModal" class="modal-overlay" @click.self="closeEditModal">
        <div class="modal-card">

          <div class="modal-scroll">
            <h2 class="modal-heading">Modifier mon profil</h2>

            <!-- Full name -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <circle cx="8" cy="5" r="3" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M2 14c0-3.314 2.686-5 6-5s6 1.686 6 5" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                </svg>
                Nom complet *
              </label>
              <input v-model="editForm.full_name" type="text" class="modal-input" placeholder="Votre nom complet" />
              <span v-if="editErrors.full_name" class="modal-error">{{ editErrors.full_name }}</span>
            </div>

            <!-- Phone -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M14 11.08v1.92A1.2 1.2 0 0 1 12.8 14c-5.28 0-9.6-4.32-9.6-9.6A1.2 1.2 0 0 1 4.4 3.2h1.92a.6.6 0 0 1 .6.6c0 .806.134 1.586.384 2.31a.6.6 0 0 1-.136.632L5.936 7.984a9.6 9.6 0 0 0 3.766 3.765l1.242-1.242a.6.6 0 0 1 .632-.136c.724.25 1.504.384 2.31.384a.6.6 0 0 1 .6.6z" stroke="#FC5A15" stroke-width="1.333"/>
                </svg>
                Téléphone
              </label>
              <input v-model="editForm.phone" type="tel" class="modal-input" placeholder="Votre numéro de téléphone" />
              <span v-if="editErrors.phone" class="modal-error">{{ editErrors.phone }}</span>
            </div>

            <!-- City -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 1.5C5.515 1.5 3.5 3.515 3.5 6c0 3.75 4.5 8.5 4.5 8.5S12.5 9.75 12.5 6C12.5 3.515 10.485 1.5 8 1.5z" stroke="#FC5A15" stroke-width="1.333"/>
                  <circle cx="8" cy="6" r="1.5" stroke="#FC5A15" stroke-width="1.333"/>
                </svg>
                Ville
              </label>
              <div class="modal-select-wrap">
                <select v-model="editForm.city" class="modal-select">
                  <option value="">Sélectionnez une ville</option>
                  <option value="Casablanca">Casablanca</option>
                  <option value="Rabat">Rabat</option>
                  <option value="Marrakech">Marrakech</option>
                  <option value="Fès">Fès</option>
                  <option value="Tanger">Tanger</option>
                  <option value="Meknès">Meknès</option>
                  <option value="Agadir">Agadir</option>
                  <option value="Oujda">Oujda</option>
                  <option value="Kenitra">Kénitra</option>
                  <option value="Tetouan">Tétouan</option>
                  <option value="Safi">Safi</option>
                  <option value="El Jadida">El Jadida</option>
                </select>
                <svg class="modal-chevron" viewBox="0 0 10 6" fill="none">
                  <path d="M1 1l4 4 4-4" stroke="#62748E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
            </div>

            <!-- Business name -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <rect x="1" y="5" width="14" height="9" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M5 5V4a3 3 0 0 1 6 0v1" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                </svg>
                Nom de l'entreprise
              </label>
              <input v-model="editForm.business_name" type="text" class="modal-input" placeholder="Nom de votre entreprise (optionnel)" />
            </div>

            <!-- Experience years -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <circle cx="8" cy="8" r="6" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M8 5v3l2 1" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                </svg>
                Années d'expérience
              </label>
              <input v-model.number="editForm.experience_years" type="number" min="0" max="60" class="modal-input" placeholder="Ex: 5" />
            </div>

            <!-- Bio -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <rect x="2" y="1.5" width="10" height="13" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M4.5 6h5M4.5 8.5h5M4.5 11h3" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                </svg>
                Description / Bio
              </label>
              <textarea v-model="editForm.bio" class="modal-textarea" placeholder="Décrivez votre expérience et vos compétences…"></textarea>
              <span class="modal-char-count">{{ (editForm.bio || '').length }} caractères</span>
            </div>

          </div>

          <div class="modal-footer">
            <button class="modal-cancel-btn" @click="closeEditModal">Annuler</button>
            <button class="modal-submit-btn" @click="saveProfile" :disabled="savingProfile">
              {{ savingProfile ? 'Enregistrement…' : 'Enregistrer' }}
            </button>
          </div>

        </div>
      </div>
    </transition>

    <!-- ── Add Service Modal ──────────────────────────────────── -->
    <transition name="modal-fade">
      <div v-if="showAddServiceModal" class="modal-overlay" @click.self="closeAddServiceModal">
        <div class="modal-card">

          <!-- Scrollable body -->
          <div class="modal-scroll">

            <!-- Section 1: Informations professionnelles -->
            <h2 class="modal-heading">Informations professionnelles</h2>

            <!-- Service principal -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 1v14M1 8h14" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                  <rect x="1" y="5" width="9" height="5" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                </svg>
                Service principal *
              </label>
              <div class="modal-select-wrap">
                <select v-model="newService.servicePrincipal" class="modal-select">
                  <option value="" disabled>Sélectionnez une service</option>
                  <option value="plomberie">Plomberie</option>
                  <option value="electricite">Électricité</option>
                  <option value="maconnerie">Maçonnerie</option>
                  <option value="peinture">Peinture</option>
                  <option value="menuiserie">Menuiserie</option>
                </select>
                <svg class="modal-chevron" viewBox="0 0 10 6" fill="none">
                  <path d="M1 1l4 4 4-4" stroke="#62748E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
            </div>

            <!-- Type de services -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 1v14M1 8h14" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                  <rect x="1" y="5" width="9" height="5" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                </svg>
                Type de services *
              </label>
              <div class="modal-select-wrap">
                <select v-model="newService.typeService" class="modal-select">
                  <option value="" disabled>Type de service</option>
                  <option value="urgence">Urgence</option>
                  <option value="renovation">Rénovation</option>
                  <option value="installation">Installation</option>
                  <option value="entretien">Entretien</option>
                </select>
                <svg class="modal-chevron" viewBox="0 0 10 6" fill="none">
                  <path d="M1 1l4 4 4-4" stroke="#62748E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
            </div>

            <!-- Copie diplôme -->
            <div class="modal-field">
              <label class="modal-label modal-label--no-icon">Copie de votre diplôme *</label>
              <label class="modal-file-input">
                <span class="modal-file-placeholder">
                  {{ newService.diplome ? newService.diplome.name : 'Scannez le diplôme' }}
                </span>
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                  <path d="M27.5 4.5h-5.25v-.75A2.25 2.25 0 0 0 20 1.5H12a2.25 2.25 0 0 0-2.25 2.25v.75H4.5A2.25 2.25 0 0 0 2.25 6.75v20.5A2.25 2.25 0 0 0 4.5 29.5h23a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 27.5 4.5z" stroke="#FC5A15" stroke-width="2"/>
                  <path d="M21 20.5l-5-5-5 5M16 15.5v9" stroke="#FC5A15" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <input type="file" accept=".pdf,.jpg,.jpeg,.png" class="modal-file-hidden" @change="onDiplomeChange" />
              </label>
            </div>

            <!-- Section 2: Portfolio et description -->
            <h2 class="modal-heading modal-heading--bold">Portfolio et description</h2>

            <!-- Description -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <rect x="2" y="1.5" width="10" height="13" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M9 1.5v2.5a1 1 0 0 0 1 1h2.5" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                  <path d="M4.5 7h5M4.5 9.5h5M4.5 12h3" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round"/>
                </svg>
                Description *
              </label>
              <textarea
                v-model="newService.description"
                class="modal-textarea"
                placeholder="Décrivez votre expérience, vos qualifications et ce qui vous distingue des autres artisans..."
                @input="onDescInput"
              ></textarea>
              <span class="modal-char-count">{{ descCharCount }} caractères</span>
            </div>

            <!-- Photos réalisations -->
            <div class="modal-field">
              <label class="modal-label">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <rect x="1" y="2" width="14" height="12" rx="1" stroke="#FC5A15" stroke-width="1.333"/>
                  <circle cx="5.5" cy="7" r="1.5" stroke="#FC5A15" stroke-width="1.333"/>
                  <path d="M14 11l-3.5-3.5-5 5" stroke="#FC5A15" stroke-width="1.333" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Photos de vos réalisations *
              </label>
              <label
                class="modal-dropzone"
                @dragover.prevent
                @drop="onPhotosDrop"
              >
                <div class="modal-dropzone-icon">
                  <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <path d="M16 4v16M8 12l8-8 8 8" stroke="#FC5A15" stroke-width="2.667" stroke-linecap="round" stroke-linejoin="round"/>
                    <rect x="2" y="20" width="28" height="10" rx="2" stroke="#FC5A15" stroke-width="2.667"/>
                  </svg>
                </div>
                <p class="modal-dropzone-title">
                  {{ newService.photos.length ? newService.photos.length + ' photo(s) sélectionnée(s)' : 'Cliquez pour télécharger ou glissez vos images' }}
                </p>
                <p class="modal-dropzone-hint">PNG, JPG jusqu'à 10MB (minimum 3 photos)</p>
                <input type="file" multiple accept="image/*" class="modal-file-hidden" @change="onPhotosChange" />
              </label>
            </div>

          </div><!-- /modal-scroll -->

          <!-- Sticky footer -->
          <div class="modal-footer">
            <label class="modal-terms">
              <input type="checkbox" v-model="newService.acceptTerms" class="modal-checkbox" />
              <span>J'accepte les <a href="#" class="modal-link">conditions générales d'utilisation</a> et la <a href="#" class="modal-link">politique de confidentialité</a></span>
            </label>
            <button class="modal-submit-btn" @click="submitNewService" :disabled="submittingService">
              {{ submittingService ? 'Envoi en cours…' : 'Ajouter' }}
            </button>
          </div>

        </div>
      </div>
    </transition>

  </div>

      <!-- BoostModal: package picker + payment for paid boosts -->
      <BoostModal
        :show="boostModalVisible"
        :service-category-id="boostTargetService ? boostTargetService.service_category_id : null"
        @close="boostModalVisible = false"
        @boosted="onBoosted"
      />
    </template>

<script>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import BoostModal from '../components/modals/BoostModal.vue'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  withCredentials: true,
})
api.interceptors.request.use(cfg => {
  const t = localStorage.getItem('token')
  if (t) cfg.headers.Authorization = `Bearer ${t}`
  return cfg
})
api.interceptors.response.use(
  r => r,
  err => {
    if (err.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default {
  name: 'ArtisanProfile',
  components: { BoostModal },

  setup() {
    const loading   = ref(true)
    const error     = ref(null)
    const artisan   = ref({})
    const toast     = ref({ show: false, message: '', type: 'success' })
    const activeTab    = ref('info')
    const emailNotifs  = ref(true)
    const smsNotifs    = ref(false)
    const language     = ref('fr')
    const twoFa        = ref(false)

    // ── Edit profile modal ─────────────────────────────────────
    const showEditModal  = ref(false)
    const savingProfile  = ref(false)
    const savingAvatar   = ref(false)
    const avatarInputRef = ref(null)
    const editErrors     = ref({})
    const editForm       = ref({
      full_name:        '',
      phone:            '',
      city:             '',
      business_name:    '',
      experience_years: '',
      bio:              '',
    })

    function openEditModal() {
      editForm.value = {
        full_name:        artisan.value.name            ?? '',
        phone:            artisan.value.phone           ?? '',
        city:             artisan.value.city            ?? '',
        business_name:    artisan.value.business_name   ?? '',
        experience_years: artisan.value.experience_years ?? '',
        bio:              artisan.value.bio             ?? '',
      }
      editErrors.value = {}
      showEditModal.value = true
    }

    function closeEditModal() {
      showEditModal.value = false
    }

    async function saveProfile() {
      editErrors.value = {}
      if (!editForm.value.full_name.trim()) {
        editErrors.value.full_name = 'Le nom complet est requis.'
        return
      }
      savingProfile.value = true
      try {
        const fd = new FormData()
        fd.append('full_name',        editForm.value.full_name)
        fd.append('phone',            editForm.value.phone)
        fd.append('city',             editForm.value.city)
        fd.append('business_name',    editForm.value.business_name)
        fd.append('bio',              editForm.value.bio)
        if (editForm.value.experience_years !== '' && editForm.value.experience_years !== null) {
          fd.append('experience_years', editForm.value.experience_years)
        }
        const res = await api.post('/me', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
        artisan.value = res.data
        closeEditModal()
        notify('Profil mis à jour avec succès !')
      } catch (e) {
        const errs = e.response?.data?.errors ?? {}
        editErrors.value = Object.fromEntries(
          Object.entries(errs).map(([k, v]) => [k, Array.isArray(v) ? v[0] : v])
        )
        if (!Object.keys(editErrors.value).length) {
          notify(e.response?.data?.message ?? 'Une erreur est survenue.', 'error')
        }
      } finally {
        savingProfile.value = false
      }
    }

    function triggerAvatarInput() {
      avatarInputRef.value?.click()
    }

    async function onAvatarChange(e) {
      const file = e.target.files[0]
      if (!file) return
      savingAvatar.value = true
      try {
        const fd = new FormData()
        fd.append('avatar', file)
        const res = await api.post('/me', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
        artisan.value = res.data
        notify('Photo de profil mise à jour !')
      } catch {
        notify('Impossible de mettre à jour la photo.', 'error')
      } finally {
        savingAvatar.value = false
        e.target.value = ''
      }
    }

    // ── Portfolio delete ───────────────────────────────────────
    const deletingPhotoId = ref(null)

    function photosForService(svc) {
      if (!artisan.value.portfolio) return []
      return artisan.value.portfolio.filter(p => p.service_category_id === svc.service_category_id)
    }

    const orphanPhotos = computed(() => {
      if (!artisan.value.portfolio) return []
      const categoryIds = new Set((artisan.value.services ?? []).map(s => s.service_category_id))
      return artisan.value.portfolio.filter(p => !categoryIds.has(p.service_category_id))
    })

    async function deletePhoto(photo) {
      if (!confirm('Supprimer cette photo ?')) return
      deletingPhotoId.value = photo.id
      try {
        await api.delete(`/artisan/portfolio/${photo.id}`)
        artisan.value.portfolio = artisan.value.portfolio.filter(p => p.id !== photo.id)
        notify('Photo supprimée.')
      } catch {
        notify('Impossible de supprimer la photo.', 'error')
      } finally {
        deletingPhotoId.value = null
      }
    }

    // ── Add Service Modal ──────────────────────────────────────
    const showAddServiceModal = ref(false)
    const newService = ref({
      servicePrincipal: '',
      typeService: '',
      diplome: null,
      description: '',
      photos: [],
      acceptTerms: false,
    })
    const descCharCount = ref(0)

    function openAddServiceModal() { showAddServiceModal.value = true }
    function closeAddServiceModal() {
      showAddServiceModal.value = false
      newService.value = { servicePrincipal: '', typeService: '', diplome: null, description: '', photos: [], acceptTerms: false }
      descCharCount.value = 0
    }
    function onDescInput(e) { descCharCount.value = e.target.value.length }
    function onDiplomeChange(e) { newService.value.diplome = e.target.files[0] ?? null }
    function onPhotosChange(e) { newService.value.photos = Array.from(e.target.files) }
    function onPhotosDrop(e) {
      e.preventDefault()
      newService.value.photos = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'))
    }
    const submittingService = ref(false)

    async function submitNewService() {
      const svc = newService.value
      if (!svc.servicePrincipal)  { notify('Veuillez sélectionner un service principal.', 'warning'); return }
      if (!svc.typeService)       { notify('Veuillez sélectionner un type de service.', 'warning'); return }
      if (!svc.description.trim()) { notify('Veuillez ajouter une description.', 'warning'); return }
      if (svc.photos.length < 1)  { notify('Veuillez ajouter au moins une photo de réalisation.', 'warning'); return }
      if (!svc.acceptTerms)       { notify('Veuillez accepter les conditions.', 'warning'); return }

      submittingService.value = true
      try {
        const fd = new FormData()
        fd.append('service_category', svc.servicePrincipal)
        fd.append('type_service',     svc.typeService)
        fd.append('description',      svc.description)
        if (svc.diplome) fd.append('diplome', svc.diplome)
        svc.photos.forEach(p => fd.append('photos[]', p))

        const res = await api.post('/artisan/service', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
        artisan.value = res.data
        closeAddServiceModal()
        notify('Service ajouté avec succès !')
      } catch (e) {
        const msg = e.response?.data?.message ?? 'Une erreur est survenue.'
        const errs = e.response?.data?.errors
        if (errs) {
          const first = Object.values(errs)[0]
          notify(Array.isArray(first) ? first[0] : first, 'error')
        } else {
          notify(msg, 'error')
        }
      } finally {
        submittingService.value = false
      }
    }

    const avatarInitials = computed(() => {
      const name = artisan.value.name ?? ''
      const parts = name.trim().split(' ').filter(Boolean)
      if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase()
      return (parts[0]?.[0] ?? 'A').toUpperCase()
    })

    const filledStars = computed(() => Math.min(5, Math.round(artisan.value.rating_average ?? 0)))
    const emptyStars  = computed(() => 5 - filledStars.value)

    const responseTimeDisplay = computed(() => {
      const min = artisan.value.response_time_avg
      if (!min) return '—'
      if (min < 60) return `${min}min`
      const h = Math.floor(min / 60)
      const m = min % 60
      return m > 0 ? `${h}h${m}` : `${h}h`
    })

    function notify(message, type = 'success') {
      toast.value = { show: true, message, type }
      setTimeout(() => (toast.value.show = false), 3200)
    }

    async function fetchProfile() {
      loading.value = true
      error.value   = null
      try {
        const res = await api.get('/me')
        artisan.value = res.data
      } catch (e) {
        error.value = e.response?.data?.message ?? e.message ?? 'Une erreur est survenue.'
      } finally {
        loading.value = false
      }
    }

    function goBack() {
      window.history.length > 1 ? window.history.back() : (window.location.href = '/')
    }

    function handleDeleteAccount() {
      if (window.confirm('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.')) {
        notify('Fonctionnalité bientôt disponible.', 'warning')
      }
    }

    const referralLink = computed(() => {
      const code = artisan.value.referral_code
      if (!code) return ''
      return `${window.location.origin}/register/artisan?ref=${code}`
    })

    // ── Referral card state ──────────────────────────────────────
    const showLinkModal = ref(false)
    const showReferralActive = computed(() => (artisan.value.referrals_count || 0) > 0)

    function copyReferralLink() {
      const link = referralLink.value
      if (!link) { notify('Lien de parrainage non disponible.', 'warning'); return }
      navigator.clipboard?.writeText(link)
        .then(() => notify('Lien copié dans le presse-papier !'))
        .catch(() => notify('Impossible de copier le lien.', 'error'))
    }

    // Boost flow
    const activatingBoost    = ref(false)
    const boostModalVisible  = ref(false)
    const boostTargetService = ref(null)

    // Called when artisan clicks the arrow button on a service
    async function openBoostFlow(svc) {
      if (activatingBoost.value) return
      if ((artisan.value.boost_credits ?? 0) > 0) {
        // Use a free credit immediately for this service
        activatingBoost.value = true
        try {
          const res = await api.post('/artisan/boost/activate', {
            service_category_id: svc.service_category_id ?? null,
          })
          notify(res.data.message ?? 'Boost activé !', 'success')
        } catch (e) {
          notify(e.response?.data?.error ?? 'Une erreur est survenue.', 'error')
        } finally {
          activatingBoost.value = false
          await fetchProfile()
        }
      } else {
        // No free credits: open paid boost modal
        boostTargetService.value = svc
        boostModalVisible.value  = true
      }
    }

    // Called from referral section "Utiliser un boost" button (no specific service)
    async function activateBoost() {
      if (activatingBoost.value) return
      activatingBoost.value = true
      try {
        const res = await api.post('/artisan/boost/activate')
        notify(res.data.message ?? 'Boost activé !', 'success')
        await fetchProfile()
      } catch (e) {
        notify(e.response?.data?.error ?? 'Une erreur est survenue.', 'error')
      } finally {
        activatingBoost.value = false
      }
    }

    function onBoosted() {
      notify('Boost activé ! Votre service est maintenant mis en avant.', 'success')
      boostModalVisible.value = false
      fetchProfile()
    }

    onMounted(fetchProfile)

    return {
      loading, error, artisan, toast, activeTab,
      emailNotifs, smsNotifs, language, twoFa,
      avatarInitials, filledStars, emptyStars, responseTimeDisplay,
      referralLink, showReferralActive, showLinkModal, activatingBoost,
      boostModalVisible, boostTargetService,
      fetchProfile, goBack, copyReferralLink, activateBoost, openBoostFlow, onBoosted, handleDeleteAccount,
      showAddServiceModal, newService, descCharCount, submittingService,
      openAddServiceModal, closeAddServiceModal,
      onDescInput, onDiplomeChange, onPhotosChange, onPhotosDrop, submitNewService,
      // portfolio
      deletingPhotoId, photosForService, orphanPhotos, deletePhoto,
      // edit profile
      showEditModal, editForm, editErrors, savingProfile,
      savingAvatar, avatarInputRef,
      openEditModal, closeEditModal, saveProfile,
      triggerAvatarInput, onAvatarChange,
    }
  },
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Inter:wght@400;500;600;700&display=swap');

/* ─── Page wrapper ────────────────────── */
.profile-page {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Inter', sans-serif;
  padding-bottom: 80px;
}

/* ─── Loading / Error states ─────────── */
.state-box {
  min-height: 380px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  color: #62748E;
  font-size: 16px;
}
.spinner {
  width: 44px; height: 44px;
  border: 3px solid #f3f4f6;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin .75s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.btn-retry {
  padding: 9px 28px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  cursor: pointer;
  font-family: inherit;
  transition: opacity .2s;
}
.btn-retry:hover { opacity: .85; }

/* ─── Header banner ───────────────────── */
.header-banner {
  width: 100%;
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
  padding: 0 80px;
  box-sizing: border-box;
}

.header-inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 25px 0;
  display: flex;
  flex-direction: column;
  gap: 9px;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  cursor: pointer;
}

.back-btn svg { width: 20px; height: 20px; }

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-text {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.page-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 30px;
  line-height: 36px;
  letter-spacing: 0.40px;
  color: #314158;
  margin: 0;
}

.page-subtitle {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

.edit-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 48px;
  padding: 0 24px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #fff;
  cursor: pointer;
  transition: opacity 0.2s;
}

.edit-btn:hover { opacity: 0.9; }
.edit-btn svg { width: 20px; height: 20px; }

/* ─── Stats row ───────────────────────── */
.stats-row {
  max-width: 1280px;
  margin: 23px auto 0;
  padding: 0 16px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  filter: drop-shadow(0 4px 4px rgba(0,0,0,0.10));
}

.stat-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px 25px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stat-icon { width: 32px; height: 32px; }

.stat-value {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 30px;
  line-height: 36px;
  letter-spacing: 0.40px;
  color: #314158;
  margin: 0;
}

.stat-label {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  margin: 0;
}

/* ─── Content columns ─────────────────── */
.content-cols {
  max-width: 1280px;
  margin: 23px auto 0;
  padding: 0 16px;
  display: grid;
  grid-template-columns: 396px 1fr;
  gap: 24px;
  align-items: start;
}

/* LEFT COLUMN */
.left-col {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

/* Profile card */
.profile-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  box-shadow: 0 4px 4px rgba(0,0,0,0.09);
  padding: 25px 25px 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.avatar-wrap {
  position: relative;
  margin-bottom: 16px;
}

.avatar {
  width: 128px;
  height: 128px;
  background: #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;
  line-height: 40px;
  letter-spacing: 0.37px;
  color: #fff;
}

.avatar--img {
  width: 128px;
  height: 128px;
  border-radius: 50%;
  object-fit: cover;
  display: block;
}

.avatar-edit-btn {
  position: absolute;
  bottom: 0;
  right: -5px;
  width: 31px;
  height: 31px;
  background: #fff;
  border: 1px solid #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.avatar-edit-btn svg { width: 14px; height: 14px; }

.profile-name {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 4px;
  text-align: center;
}

.profile-role {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0 0 16px;
  text-align: center;
}

.profile-rating {
  display: flex;
  align-items: center;
  gap: 4px;
  padding-bottom: 24px;
  border-bottom: 1px solid #F3F4F6;
  margin-bottom: 26px;
  width: 100%;
  justify-content: center;
}

.profile-rating svg { width: 20px; height: 20px; }

.rating-val {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin-left: 4px;
}

.profile-details {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.detail-item svg { width: 20px; height: 20px; flex-shrink: 0; }

/* Boost card */
.boost-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  box-shadow: 0 4px 4px rgba(0,0,0,0.10);
  padding: 25px 25px 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.boost-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.boost-header svg { width: 20px; height: 20px; }

.boost-header h3 {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0;
}

.boost-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.boost-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 80px;
  padding: 0 16px;
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 14px;
}

.boost-item--active {
  background: #fff;
}

.boost-item--selected {
  border-color: rgba(252,90,21,0.4);
}

.boost-item-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.boost-icon {
  width: 40px;
  height: 40px;
  background: #F3F4F6;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.boost-icon--active { background: #FC5A15; }
.boost-icon svg { width: 20px; height: 20px; }

.boost-item span {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.boost-item--selected span { color: #FC5A15; }

.boost-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  height: 20px;
  padding: 0 8px;
  background: linear-gradient(90deg, #FDC700 0%, #FF6900 100%);
  border-radius: 9999px;
  font-size: 12px !important;
  line-height: 16px !important;
  color: #fff !important;
  margin-left: 8px;
}

.boost-badge svg { width: 12px; height: 12px; }

.boost-edit-btn {
  width: 44px;
  height: 44px;
  background: #F3F4F6;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: opacity 0.2s;
}

.boost-edit-btn--active { background: #FEF9C2; border-color: #FEF9C2; }
.boost-edit-btn:hover { opacity: 0.8; }
.boost-edit-btn svg { width: 20px; height: 20px; }

.boost-free-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #F0FDF4;
  border: 1px solid #86EFAC;
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 13px;
  color: #15803D;
  margin-bottom: 12px;
}
.boost-free-banner svg { flex-shrink: 0; }

.boost-notice {
  padding: 17px;
  background: linear-gradient(90deg, rgba(255,247,237,0.41) 0%, rgba(255,237,212,0.41) 100%);
  border: 1px solid rgba(255,214,167,0.2);
  border-radius: 14px;
}

.boost-notice p {
  font-size: 12px;
  line-height: 16px;
  color: #58595B;
  margin: 0;
}

/* Referral card */
.referral-card {
  background: #fff;
  border: 1px solid rgba(0,71,171,0.15);
  border-radius: 14px;
  box-shadow: 0 4px 4px rgba(0,0,0,0.10);
  padding: 26px 26px 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.referral-icon-wrap {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #FC5A15 0%, rgba(252,90,21,0.74) 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.referral-icon-wrap svg { width: 32px; height: 32px; }

.referral-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  text-align: center;
  margin: 0 0 8px;
}

.referral-desc {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  text-align: center;
  margin: 0 0 16px;
}

/* Referral stats row */
.referral-stats-row {
  display: flex;
  gap: 12px;
  width: 100%;
  margin-bottom: 14px;
}

.referral-stat-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 10px;
  border-radius: 10px;
  border: 1.5px solid;
  background: #fff;
}

.referral-stat-card--purple {
  border-color: #A78BFA;
  color: #7C3AED;
}

.referral-stat-card--green {
  border-color: #6EE7B7;
  color: #059669;
}

.referral-stat-val {
  font-size: 22px;
  font-weight: 700;
  line-height: 1;
  margin-bottom: 4px;
}

.referral-stat-label {
  font-size: 11px;
  font-weight: 500;
  text-align: center;
  opacity: 0.85;
}

/* Use boost button */
.referral-use-boost-btn {
  width: 100%;
  height: 44px;
  background: linear-gradient(90deg, #059669 0%, #10B981 100%);
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  margin-bottom: 14px;
  transition: opacity 0.2s;
}

.referral-use-boost-btn:hover { opacity: 0.9; }
.referral-use-boost-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.referral-use-boost-btn svg { width: 18px; height: 18px; }

.referral-btn {
  width: 100%;
  height: 48px;
  background: linear-gradient(90deg, #FC5A15 0%, rgba(252,90,21,0.88) 100%);
  border: none;
  border-radius: 10px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,0.10), 0 4px 6px -4px rgba(0,0,0,0.10);
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  margin-bottom: 16px;
  transition: opacity 0.2s;
}

.referral-btn:hover { opacity: 0.9; }
.referral-btn svg { width: 20px; height: 20px; }

.referral-notice {
  padding: 13px;
  background: linear-gradient(90deg, #FEFCE8 0%, #FFF7ED 100%);
  border: 1px solid #FFF085;
  border-radius: 10px;
  display: flex;
  gap: 8px;
  font-size: 12px;
  line-height: 16px;
  color: #733E0A;
  width: 100%;
  box-sizing: border-box;
}

.referral-notice svg { width: 16px; height: 16px; flex-shrink: 0; margin-top: 2px; }
.referral-notice strong { font-weight: 700; }

/* Link modal */
.link-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
}

.link-modal {
  background: #fff;
  border-radius: 18px;
  padding: 28px 24px 24px;
  width: 100%;
  max-width: 420px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.link-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.link-modal-title {
  font-size: 18px;
  font-weight: 700;
  color: #314158;
  margin: 0;
}

.link-modal-close {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background 0.15s;
}

.link-modal-close:hover { background: #F3F4F6; }
.link-modal-close svg { width: 20px; height: 20px; }

.link-modal-sub {
  font-size: 13px;
  color: #62748E;
  margin: 0;
  line-height: 1.5;
}

.link-modal-box {
  background: #FFF7ED;
  border: 1.5px solid #FFEDD4;
  border-radius: 10px;
  padding: 12px 14px;
  word-break: break-all;
}

.link-modal-url {
  font-size: 13px;
  font-weight: 500;
  color: #FC5A15;
  line-height: 1.5;
}

.link-modal-copy-btn {
  width: 100%;
  height: 48px;
  background: linear-gradient(90deg, #FC5A15 0%, rgba(252,90,21,0.88) 100%);
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  transition: opacity 0.2s;
}

.link-modal-copy-btn:hover { opacity: 0.9; }
.link-modal-copy-btn svg { width: 18px; height: 18px; }

/* RIGHT COLUMN */
.right-col {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Tabs */
.tabs {
  display: flex;
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
}

.tab-btn {
  padding: 14.5px 24px 12px;
  background: none;
  border: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  cursor: pointer;
  position: relative;
  transition: color 0.2s;
}

.tab-btn--active {
  color: #FC5A15;
}

.tab-btn--active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 16px;
  right: 16px;
  height: 2px;
  background: #FC5A15;
  border-radius: 1px;
}

/* Service selector */
.service-selector {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px;
  display: flex;
  gap: 12px;
}

.service-dropdown {
  flex: 1;
  height: 63px;
  padding: 0 20px;
  background: #fff;
  border: 1px solid #99A1AF;
  border-radius: 12px;
  box-shadow: 0 0.85px 2.55px rgba(0,0,0,0.10), 0 0.85px 1.70px -0.85px rgba(0,0,0,0.10);
  display: flex;
  align-items: center;
  gap: 9px;
  cursor: pointer;
}

.service-dropdown svg:first-child { width: 32px; height: 32px; flex-shrink: 0; }
.service-dropdown span {
  flex: 1;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 16px;
  line-height: 27px;
  letter-spacing: 0.06px;
  color: #000;
}

.chevron { width: 9px; height: 5px; flex-shrink: 0; }

.add-service-btn {
  width: 276px;
  height: 63px;
  background: linear-gradient(90deg, #FC5A15 0%, rgba(252,90,21,0.81) 100%);
  border: none;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 18.58px;
  line-height: 28px;
  letter-spacing: -0.36px;
  color: #fff;
  cursor: pointer;
  transition: opacity 0.2s;
}

.add-service-btn:hover { opacity: 0.9; }
.add-service-btn svg { width: 18.58px; height: 18.58px; }

/* Section cards */
.section-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 16px;
}

.section-title svg { width: 20px; height: 20px; }

.section-text {
  font-size: 16px;
  line-height: 26px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0;
}

/* Service tags */
.service-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.service-tag {
  display: inline-flex;
  align-items: center;
  height: 42px;
  padding: 0 17px;
  background: rgba(252,90,21,0.03);
  border: 1px solid #FC5A15;
  border-radius: 10px;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #FC5A15;
}

.service-tag-add {
  width: 42px;
  height: 42px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: opacity 0.2s;
}

.service-tag-add:hover { opacity: 0.9; }
.service-tag-add svg { width: 22px; height: 22px; }

/* Info row */
.info-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 26px;
}

.info-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px 25px 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0;
}

.info-card-title svg { width: 20px; height: 20px; }

.info-card-value {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #FC5A15;
  margin: 0;
}

/* Certifications */
.cert-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cert-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 0 0 16px;
  height: 82px;
  border-radius: 10px;
}

.cert-item--green {
  background: #F0FDF4;
  border: 1px solid #B9F8CF;
}

.cert-item--blue {
  background: #EFF6FF;
  border: 1px solid #BEDBFF;
}

.cert-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.cert-icon--green { background: #DCFCE7; }
.cert-icon--blue  { background: #DBEAFE; }
.cert-icon svg { width: 24px; height: 24px; }

.cert-name {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  margin: 0 0 2px;
}

.cert-date {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  margin: 0;
}

/* Portfolio */
.portfolio-card {
  background: #fff;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  padding: 25px;
}

.portfolio-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 20px;
}

.portfolio-title svg { width: 20px; height: 20px; }

.portfolio-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.portfolio-item {
  position: relative;
  width: 100%;
  aspect-ratio: 1;
  border-radius: 14px;
  overflow: hidden;
  cursor: pointer;
}

.portfolio-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.portfolio-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(0deg, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.2) 50%, rgba(0,0,0,0) 100%);
  opacity: 0;
  transition: opacity 0.3s;
  display: flex;
  align-items: flex-end;
  padding: 12px;
}

.portfolio-item:hover .portfolio-overlay { opacity: 1; }

.portfolio-caption {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #fff;
}

/* Delete button on hover */
.portfolio-delete-btn {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: rgba(239, 68, 68, 0.85);
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s, background 0.15s;
  z-index: 10;
}
.portfolio-item:hover .portfolio-delete-btn { opacity: 1; }
.portfolio-delete-btn:hover { background: #dc2626; }
.portfolio-delete-btn:disabled { cursor: not-allowed; opacity: 0.7; }

.portfolio-delete-spinner {
  width: 10px;
  height: 10px;
  border: 2px solid rgba(255,255,255,0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

/* Service group headers */
.portfolio-service-group {
  margin-bottom: 20px;
}
.portfolio-service-group:last-child { margin-bottom: 0; }

.portfolio-service-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
  padding-bottom: 6px;
  border-bottom: 1px solid #F0F0F0;
}

.portfolio-service-label {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  font-weight: 600;
  color: #314158;
}

.portfolio-service-type {
  font-size: 12px;
  color: #62748E;
  background: #F5F5F5;
  padding: 2px 8px;
  border-radius: 10px;
}

.portfolio-no-photos {
  font-size: 13px;
  margin: 0 0 4px;
}

/* Empty / no-data */
.no-data {
  font-size: 14px;
  color: #99A1AF;
  font-style: italic;
}

/* Toast */
.toast {
  position: fixed;
  bottom: 28px;
  right: 28px;
  padding: 14px 22px;
  border-radius: 12px;
  font-size: 14px;
  color: #fff;
  z-index: 9999;
  box-shadow: 0 4px 24px rgba(0,0,0,.16);
  pointer-events: none;
}
.toast--success { background: #00A63E; }
.toast--error   { background: #EF4444; }
.toast--warning { background: #F59E0B; }
.toast-enter-active, .toast-leave-active { transition: all .3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(10px); }

/* ─── Tab panels (Préférences / Sécurité) ─── */
.tab-panel {
  background: #F9FAFB;
  border-radius: 14px;
  padding: 24px 24px 0;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.tab-panel-title {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  font-size: 20px;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0;
}

.pref-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px;
}

.pref-item {
  background: #fff;
  border-radius: 10px;
  min-height: 76px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  gap: 12px;
}

.pref-item--col {
  flex-direction: column;
  align-items: flex-start;
  min-height: auto;
  padding: 16px 16px 0;
  gap: 8px;
}

.pref-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.pref-icon {
  width: 40px;
  height: 40px;
  background: #FFEDD4;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.pref-icon svg { width: 20px; height: 20px; }

.pref-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.pref-title {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.pref-desc {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.pref-label {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

.pref-select-wrap {
  position: relative;
  width: 100%;
  padding-bottom: 16px;
}

.pref-select {
  width: 100%;
  height: 47px;
  padding: 0 40px 0 15px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  background: #fff;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  color: #62748E;
  appearance: none;
  cursor: pointer;
  outline: none;
}

.pref-select:focus { border-color: #FC5A15; }

.select-chevron {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-60%);
  width: 10px;
  height: 6px;
  pointer-events: none;
}

/* Toggle switch */
.toggle {
  position: relative;
  width: 44px;
  height: 24px;
  border-radius: 9999px;
  border: none;
  background: #E5E7EB;
  cursor: pointer;
  flex-shrink: 0;
  transition: background 0.2s;
  padding: 0;
}

.toggle--on { background: #FC5A15; }

.toggle-thumb {
  position: absolute;
  width: 20px;
  height: 20px;
  background: #fff;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: left 0.2s;
  display: block;
}

.toggle--on .toggle-thumb { left: 22px; }

/* Security action buttons */
.sec-btn {
  height: 36px;
  padding: 0 18px;
  background: #fff;
  border: 1.5px solid #FC5A15;
  border-radius: 8px;
  color: #FC5A15;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background 0.15s;
}

.sec-btn:hover { background: #FFF7ED; }

/* Danger zone */
.danger-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  background: #FEF2F2;
  border: 1px solid #FCA5A5;
  border-radius: 10px;
  gap: 16px;
}

.danger-texts {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.danger-title {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #DC2626;
  font-weight: 500;
}

.danger-desc {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #EF4444;
}

.danger-btn {
  height: 40px;
  padding: 0 20px;
  background: #EF4444;
  border: none;
  border-radius: 8px;
  color: #fff;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  flex-shrink: 0;
  transition: opacity 0.2s;
}

.danger-btn:hover { opacity: 0.9; }

/* Responsive */
@media (max-width: 1200px) {
  .content-cols { grid-template-columns: 1fr; }
  .stats-row { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .header-banner { padding: 0 20px; }
  .stats-row { padding: 0 12px; }
  .content-cols { padding: 0 12px; margin-top: 16px; }
  .tabs { overflow-x: auto; white-space: nowrap; -webkit-overflow-scrolling: touch; }
  .tab-btn { flex-shrink: 0; padding: 12px 16px 10px; font-size: 13px; }
  .page-title { font-size: 22px; line-height: 28px; }
  .page-subtitle { font-size: 13px; }
  .edit-btn { height: 40px; padding: 0 16px; font-size: 14px; }
  .stat-value { font-size: 24px; }
}

@media (max-width: 640px) {
  .header-banner { padding: 0 16px; }
  .stats-row { grid-template-columns: repeat(2, 1fr); padding: 0 12px; }
  .info-row { grid-template-columns: 1fr; }
  .portfolio-grid { grid-template-columns: repeat(2, 1fr); }
  .service-selector { flex-direction: column; }
  .add-service-btn { width: 100%; }
  .profile-card { padding: 20px 16px 24px; }
  .section-card { padding: 18px 16px; }
  .portfolio-card { padding: 18px 16px; }
  .avatar { width: 96px; height: 96px; font-size: 28px; }
  .avatar--img { width: 96px; height: 96px; }
  .artisan-name { font-size: 18px; }
  .cert-list { gap: 10px; }
  .referral-card { padding: 16px; }
  .tab-panel { padding: 16px; }
}

@media (max-width: 480px) {
  .stats-row { grid-template-columns: 1fr 1fr; gap: 10px; }
  .stat-card { padding: 16px 14px 12px; }
  .stat-value { font-size: 20px; }
  .stat-label { font-size: 12px; }
  .portfolio-grid { grid-template-columns: repeat(2, 1fr); gap: 8px; }
  .header-content { flex-direction: column; align-items: flex-start; gap: 10px; }
  .edit-btn { width: 100%; justify-content: center; }
  .page-title { font-size: 20px; }
  .service-tags { flex-wrap: wrap; gap: 8px; }
  .service-tag { font-size: 12px; padding: 4px 10px; }
}

/* ─── Shared modal helpers ───────────────────────────── */
.input-hidden { display: none; }

.modal-input {
  width: 100%;
  height: 47px;
  padding: 0 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #314158;
  outline: none;
  box-sizing: border-box;
  background: #fff;
}
.modal-input:focus { border-color: #FC5A15; }
.modal-input::placeholder { color: rgba(10,10,10,0.4); }

.modal-error {
  font-size: 13px;
  color: #EF4444;
  margin-top: -4px;
}

.modal-cancel-btn {
  height: 50px;
  padding: 0 28px;
  background: #fff;
  border: 1.5px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  color: #62748E;
  cursor: pointer;
  transition: border-color 0.2s;
}
.modal-cancel-btn:hover { border-color: #FC5A15; color: #FC5A15; }

/* Disabled state for submit */
.modal-submit-btn:disabled { opacity: 0.65; cursor: not-allowed; }

/* Avatar spinner */
.avatar-spinner {
  display: inline-block;
  width: 12px;
  height: 12px;
  border: 2px solid #FC5A15;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin .6s linear infinite;
}

/* ─── Add Service Modal ───────────────────────────────── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 24px 16px;
  box-sizing: border-box;
}

.modal-card {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -4px rgba(0,0,0,0.1);
  width: 100%;
  max-width: 864px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 32px 32px 8px;
  display: flex;
  flex-direction: column;
  gap: 26px;
}

/* headings */
.modal-heading {
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #314158;
  margin: 0;
}

.modal-heading--bold { font-weight: 600; }

/* field container */
.modal-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* label */
.modal-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.modal-label svg { flex-shrink: 0; }
.modal-label--no-icon { padding-left: 0; }

/* select */
.modal-select-wrap {
  position: relative;
}

.modal-select {
  width: 100%;
  height: 47px;
  padding: 0 40px 0 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  background: #fff;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 19px;
  letter-spacing: -0.31px;
  color: rgba(10,10,10,0.5);
  appearance: none;
  cursor: pointer;
  outline: none;
  box-sizing: border-box;
}

.modal-select:focus { border-color: #FC5A15; color: #314158; }

.modal-chevron {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 10px;
  height: 6px;
  pointer-events: none;
}

/* file input (diplôme) */
.modal-file-input {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 47px;
  padding: 0 12px 0 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  cursor: pointer;
  box-sizing: border-box;
}

.modal-file-placeholder {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 19px;
  letter-spacing: -0.31px;
  color: rgba(10,10,10,0.5);
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.modal-file-hidden { display: none; }

/* textarea */
.modal-textarea {
  width: 100%;
  height: 150px;
  padding: 12px 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Poppins', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  resize: vertical;
  outline: none;
  box-sizing: border-box;
}

.modal-textarea::placeholder { color: rgba(10,10,10,0.5); }
.modal-textarea:focus { border-color: #FC5A15; }

.modal-char-count {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

/* dropzone */
.modal-dropzone {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 34px 34px 14px;
  border: 2px solid #D1D5DC;
  border-radius: 10px;
  cursor: pointer;
  min-height: 192px;
  box-sizing: border-box;
  transition: border-color 0.2s;
}

.modal-dropzone:hover { border-color: #FC5A15; }

.modal-dropzone-icon {
  width: 64px;
  height: 64px;
  background: rgba(252,90,21,0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-dropzone-title {
  font-family: 'Poppins', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  text-align: center;
  margin: 0;
}

.modal-dropzone-hint {
  font-family: 'Poppins', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  text-align: center;
  margin: 0;
}

/* footer */
.modal-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 32px 24px;
  border-top: 1px solid #F3F4F6;
  gap: 16px;
  flex-shrink: 0;
}

.modal-terms {
  display: flex;
  align-items: center;
  gap: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  font-weight: 700;
  cursor: pointer;
  flex: 1;
}

.modal-checkbox {
  width: 16px;
  height: 16px;
  border: 1px solid #58595B;
  border-radius: 3px;
  cursor: pointer;
  flex-shrink: 0;
  accent-color: #FC5A15;
}

.modal-link {
  color: #FC5A15;
  text-decoration: none;
}

.modal-link:hover { text-decoration: underline; }

.modal-submit-btn {
  height: 50px;
  padding: 0 32px;
  background: #FC5A15;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #fff;
  cursor: pointer;
  flex-shrink: 0;
  transition: opacity 0.2s;
}

.modal-submit-btn:hover { opacity: 0.9; }

/* transition */
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.25s ease; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }

@media (max-width: 640px) {
  .modal-scroll { padding: 20px 16px 8px; }
  .modal-footer { flex-direction: column; align-items: flex-start; padding: 16px; }
  .modal-submit-btn { width: 100%; }
}
</style>

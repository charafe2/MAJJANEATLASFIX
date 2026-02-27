<template>
  <div class="page-wrapper">

    <main class="main-content">
      <!-- Page Header -->
      <div class="page-header">
        <h1 class="page-title">Tableau de bord des paiements</h1>
        <p class="page-subtitle">Gérez et suivez tous vos paiements en un seul endroit</p>
      </div>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <!-- Total Revenue Card -->
        <div class="stat-card stat-card--orange">
          <div class="stat-card__header">
            <div class="stat-icon stat-icon--white">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1.41 16.09V20h-2.67v-1.93c-1.71-.36-3.16-1.46-3.27-3.4h1.96c.1 1.05.82 1.87 2.65 1.87 1.96 0 2.4-.98 2.4-1.59 0-.83-.44-1.61-2.67-2.14-2.48-.6-4.18-1.62-4.18-3.67 0-1.72 1.39-2.84 3.11-3.21V4h2.67v1.95c1.86.45 2.79 1.86 2.85 3.39H14.3c-.05-1.11-.64-1.87-2.22-1.87-1.5 0-2.4.68-2.4 1.64 0 .84.65 1.39 2.67 1.91s4.18 1.39 4.18 3.91c-.01 1.83-1.38 2.83-3.12 3.16z" fill="white"/>
              </svg>
            </div>
            <div class="stat-badge stat-badge--white">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6h-6z" fill="white"/>
              </svg>
              <span>+12%</span>
            </div>
          </div>
          <p class="stat-label">{{user?.account_type === 'client' ? "Total depensé" : "Revenue Total"}}</p>
          <p class="stat-value">{{ formatAmount(stats.total_revenue) }} MAD</p>
          <p class="stat-period">Ce mois-ci</p>
        </div>

        <!-- Completed Payments Card -->
        <div class="stat-card stat-card--white">
          <div class="stat-card__header">
            <div class="stat-icon stat-icon--green">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="#00A63E"/>
              </svg>
            </div>
            <div class="stat-badge stat-badge--green">
              <span>{{ stats.completed_count }} paiement{{ stats.completed_count !== 1 ? 's' : '' }}</span>
            </div>
          </div>
          <p class="stat-label">Paiements complétés</p>
          <p class="stat-value stat-value--dark">{{ formatAmount(stats.completed_total) }} MAD</p>
          <div class="stat-footer stat-footer--green">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z" stroke="#00A63E" stroke-width="0.5" fill="#00A63E"/>
            </svg>
            <span>Reçus et confirmés</span>
          </div>
        </div>

        <!-- Pending Payments Card -->
        <div class="stat-card stat-card--white">
          <div class="stat-card__header">
            <div class="stat-icon stat-icon--orange-light">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z" fill="#F54900"/>
              </svg>
            </div>
            <div class="stat-badge stat-badge--orange">
              <span>{{ stats.pending_count }} paiement{{ stats.pending_count !== 1 ? 's' : '' }}</span>
            </div>
          </div>
          <p class="stat-label">Paiements en cours</p>
          <p class="stat-value stat-value--dark">{{ formatAmount(stats.pending_total) }} MAD</p>
          <div class="stat-footer stat-footer--orange">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="9" stroke="#F54900" stroke-width="2" fill="none"/>
              <path d="M12 7v5l3 3" stroke="#F54900" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span>En attente de confirmation</span>
          </div>
        </div>
      </div>

      <!-- Filters & Search Bar -->
      <div class="filter-bar">
        <div class="filter-bar__left">
          <div class="search-input-wrapper">
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" fill="#62748E"/>
            </svg>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher par client ou service..."
              class="search-input"
            />
          </div>

          <div class="filter-buttons">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" class="filter-icon">
              <path d="M4.25 5.61C6.27 8.2 10 13 10 13v6c0 .55.45 1 1 1h2c.55 0 1-.45 1-1v-6s3.72-4.8 5.74-7.39A1 1 0 0 0 18.95 4H5.04a1 1 0 0 0-.79 1.61z" fill="#62748E"/>
            </svg>
            <button
              v-for="f in filters"
              :key="f.value"
              class="filter-btn"
              :class="{ 'filter-btn--active': activeFilter === f.value }"
              @click="activeFilter = f.value"
            >
              {{ f.label }}
            </button>
          </div>
        </div>

        <button class="export-btn" @click="exportPayments">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z" fill="#FC5A15"/>
          </svg>
          <span>Exporter</span>
        </button>
      </div>

      <!-- Payments Table -->
      <div class="table-card">
        <div class="table-header">
          <h2 class="table-title">Historique des paiements</h2>
          <p class="table-count">{{ filteredPayments.length }} résultats</p>
        </div>

        <div class="table-wrapper">
          <table class="payments-table">
            <thead>
              <tr>
                <th>Client</th>
                <th>Service</th>
                <th>Montant</th>
                <th>Méthode</th>
                <th>Date</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="payment in filteredPayments" :key="payment.id" class="table-row" @click="goToDetail(payment)">
                <!-- Client -->
                <td>
                  <div class="client-cell">
                    <div class="client-avatar">{{ payment.initials }}</div>
                    <span class="client-name">{{ payment.client }}</span>
                  </div>
                </td>

                <!-- Service -->
                <td>
                  <span class="service-name">{{ payment.service }}</span>
                </td>

                <!-- Montant -->
                <td>
                  <span class="amount">{{ payment.amount }} MAD</span>
                </td>

                <!-- Méthode -->
                <td>
                  <span class="method">{{ payment.method ?? '—' }}</span>
                </td>

                <!-- Date -->
                <td>
                  <div class="date-cell">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                      <path d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z" fill="#62748E"/>
                    </svg>
                    <span>{{ payment.date }}</span>
                  </div>
                </td>

                <!-- Statut -->
                <td>
                  <span
                    class="status-badge"
                    :class="payment.status === 'completed' ? 'status-badge--completed' : 'status-badge--pending'"
                  >
                    <svg v-if="payment.status === 'completed'" width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="#008236"/>
                    </svg>
                    <svg v-else width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <circle cx="12" cy="12" r="9" stroke="#CA3500" stroke-width="2" fill="none"/>
                      <path d="M12 7v5l3 3" stroke="#CA3500" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                    {{ statusLabel(payment.status) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'          // ← was missing
import { getPaymentStats } from '../api/payments'

const router = useRouter()
const user   = ref(null)

function loadUser() {
  try {
    const raw = localStorage.getItem('user')
    user.value = raw ? JSON.parse(raw) : null
  } catch {
    user.value = null
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────
const searchQuery  = ref('')
const activeFilter = ref('all')

const filters = [
  { label: 'Tous',      value: 'all'       },
  { label: 'Complétés', value: 'completed' },
  { label: 'En cours',  value: 'pending'   },
]

// ── Data ──────────────────────────────────────────────────────────────────────
const payments = ref([])
const stats    = ref({
  total_revenue:   0,
  completed_total: 0,
  completed_count: 0,
  pending_total:   0,
  pending_count:   0,
})
const loading = ref(false)

async function loadPayments() {
  loading.value = true
  try {
    const { data } = await getPaymentStats()
    payments.value = data.payments ?? []
    stats.value    = data.stats    ?? stats.value
  } catch {
    // keep empty state on error
  } finally {
    loading.value = false
  }
}

onMounted(async () => {        // ← call BOTH functions here
  loadUser()
  await loadPayments()
})

// ── Computed ──────────────────────────────────────────────────────────────────
const filteredPayments = computed(() =>
  payments.value.filter(p => {
    const q = searchQuery.value.toLowerCase()
    const matchesSearch =
      !q ||
      p.client.toLowerCase().includes(q) ||
      p.service.toLowerCase().includes(q)
    const matchesFilter =
      activeFilter.value === 'all' || p.status === activeFilter.value
    return matchesSearch && matchesFilter
  })
)

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Format a number with space-separated thousands: 7400 → "7 400" */
function formatAmount(n) {
  return Math.round(n ?? 0)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, '\u00A0')
}

/** Map API status → display label */
function statusLabel(status) {
  return status === 'completed' ? 'Complété' : 'En cours'
}

// ── Navigation ────────────────────────────────────────────────────────────
function goToDetail(payment) {
  const base = user.value?.account_type === 'artisan' ? '/artisan/demandes' : '/client/demandes'
  const id = String(payment.id).replace(/^sr-/i, '')
  router.push(`${base}/${id}`)
}

// ── Export ────────────────────────────────────────────────────────────────────
function exportPayments() {
  const headers = ['Client', 'Service', 'Montant (MAD)', 'Méthode', 'Date', 'Statut']
  const rows    = filteredPayments.value.map(p =>
    [p.client, p.service, p.amount, p.method ?? '—', p.date, statusLabel(p.status)].join(',')
  )
  const csv  = [headers.join(','), ...rows].join('\n')
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url  = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href     = url
  link.download = 'paiements.csv'
  link.click()
  URL.revokeObjectURL(url)
}
</script>

<style scoped>
/* ── Layout ─────────────────────────────────────────────────────────────── */
.page-wrapper {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Poppins', sans-serif;
}

.main-content {
  max-width: 1248px;
  margin: 0 auto;
  padding: 48px 24px 80px;
}

/* ── Page Header ─────────────────────────────────────────────────────────── */
.page-header {
  margin-bottom: 32px;
}

.page-title {
  font-size: 30px;
  font-weight: 400;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
  margin: 0 0 8px;
}

.page-subtitle {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

/* ── Stats Grid ──────────────────────────────────────────────────────────── */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  border-radius: 16px;
  padding: 24px;
  min-height: 204px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.stat-card--orange {
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  box-shadow: 0px 10px 15px -3px rgba(0,0,0,.1), 0px 4px 6px -4px rgba(0,0,0,.1);
}

.stat-card--white {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  box-shadow: 0px 1px 3px rgba(0,0,0,.1), 0px 1px 2px -1px rgba(0,0,0,.1);
}

.stat-card__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-icon--white   { background: rgba(255,255,255,.2); }
.stat-icon--green   { background: #DCFCE7; }
.stat-icon--orange-light { background: #FFEDD4; }

.stat-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 12px;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 20px;
}

.stat-badge--white  { background: rgba(255,255,255,.2); color: #fff; }
.stat-badge--green  { background: #DCFCE7; color: #00A63E; }
.stat-badge--orange { background: #FFEDD4; color: #F54900; }

.stat-label {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  margin: 16px 0 4px;
}

.stat-card--orange .stat-label { color: rgba(255,255,255,.8); }
.stat-card--white  .stat-label { color: #62748E; }

.stat-value {
  font-size: 36px;
  font-weight: 400;
  line-height: 40px;
  letter-spacing: 0.37px;
  margin: 0;
}

.stat-card--orange .stat-value { color: #fff; }
.stat-value--dark              { color: #314158; font-size: 30px; line-height: 36px; }

.stat-period {
  font-size: 14px;
  line-height: 20px;
  color: rgba(255,255,255,.7);
  margin: 8px 0 0;
}

.stat-footer {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  margin-top: 8px;
}

.stat-footer--green  { color: #00A63E; }
.stat-footer--orange { color: #F54900; }

/* ── Filter Bar ──────────────────────────────────────────────────────────── */
.filter-bar {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  box-shadow: 0px 1px 3px rgba(0,0,0,.1), 0px 1px 2px -1px rgba(0,0,0,.1);
  border-radius: 16px;
  padding: 25px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
  gap: 16px;
}

.filter-bar__left {
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.search-input-wrapper {
  position: relative;
  width: 340px;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}

.search-input {
  width: 100%;
  box-sizing: border-box;
  padding: 12px 16px 12px 40px;
  border: 1px solid #D1D5DC;
  border-radius: 14px;
  font-family: 'Poppins', sans-serif;
  font-size: 16px;
  line-height: 24px;
  color: #314158;
  outline: none;
  transition: border-color .2s;
}

.search-input::placeholder { color: rgba(10,10,10,.5); }
.search-input:focus { border-color: #FC5A15; }

.filter-buttons {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-icon {
  flex-shrink: 0;
}

.filter-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  cursor: pointer;
  background: #F3F4F6;
  color: #62748E;
  transition: background .15s, color .15s;
}

.filter-btn--active {
  background: #FC5A15;
  color: #FFFFFF;
}

.export-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #FFFFFF;
  border: 2px solid #FC5A15;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #FC5A15;
  cursor: pointer;
  white-space: nowrap;
  transition: background .15s, color .15s;
}

.export-btn:hover {
  background: #FC5A15;
  color: #FFFFFF;
}

.export-btn:hover svg path { fill: #FFFFFF; }

/* ── Table Card ──────────────────────────────────────────────────────────── */
.table-card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  box-shadow: 0px 1px 3px rgba(0,0,0,.1), 0px 1px 2px -1px rgba(0,0,0,.1);
  border-radius: 16px;
  overflow: hidden;
}

.table-header {
  padding: 24px 24px 16px;
  border-bottom: 1px solid #E5E7EB;
}

.table-title {
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 4px;
}

.table-count {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  margin: 0;
}

.table-wrapper {
  overflow-x: auto;
}

.payments-table {
  width: 100%;
  border-collapse: collapse;
}

.payments-table thead {
  background: #F9FAFB;
}

.payments-table th {
  padding: 16px 24px;
  text-align: left;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  border-bottom: 1px solid #E5E7EB;
  white-space: nowrap;
}

.payments-table td {
  padding: 16px 24px;
  border-bottom: 1px solid #E5E7EB;
  vertical-align: middle;
}

.table-row:last-child td {
  border-bottom: none;
}

.table-row {
  cursor: pointer;
}

.table-row:hover {
  background: #FFF4EE;
}

/* ── Table Cells ─────────────────────────────────────────────────────────── */
.client-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.client-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #FC5A15 0%, #F54900 100%);
  color: #FFFFFF;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.client-name {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  white-space: nowrap;
}

.service-name {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
}

.amount {
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #314158;
  white-space: nowrap;
}

.method {
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  white-space: nowrap;
}

.date-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  white-space: nowrap;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 999px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  white-space: nowrap;
}

.status-badge--completed {
  background: #DCFCE7;
  color: #008236;
}

.status-badge--pending {
  background: #FFEDD4;
  color: #CA3500;
}

/* ── Responsive ──────────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .stat-card--orange {
    grid-column: 1 / -1;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  .stat-card--orange {
    grid-column: unset;
  }
  .filter-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  .search-input-wrapper {
    width: 100%;
  }
  .payments-table th,
  .payments-table td {
    padding: 12px 16px;
  }
}
</style>

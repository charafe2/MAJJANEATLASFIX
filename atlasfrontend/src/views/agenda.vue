<template>
  <div class="page-wrapper">
    <div class="main-content">

      <!-- ── Sub-header ───────────────────────────────────────────────────── -->
      <div class="sub-header">
        <button class="back-btn" @click="$router.back()">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M15.41 16.59L10.83 12l4.58-4.59L14 6l-6 6 6 6 1.41-1.41z" fill="#62748E"/>
          </svg>
          Retour
        </button>
        <div class="header-row">
          <div class="header-info">
            <h1 class="page-title">Mon agenda</h1>
            <p class="page-subtitle">Gérez tous vos rendez-vous en un seul endroit</p>
          </div>
          <button class="new-rdv-btn" @click="openNewRdv">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" fill="white"/>
            </svg>
            Nouveau rendez-vous
          </button>
        </div>
      </div>

      <!-- ── Two-column layout ─────────────────────────────────────────────── -->
      <div class="agenda-layout">

        <!-- ── Calendar ────────────────────────────────────────────────────── -->
        <div class="calendar-card">

          <!-- Orange gradient header -->
          <div class="cal-header">
            <button class="cal-nav-btn" @click="prevMonth" aria-label="Mois précédent">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M15.41 16.59L10.83 12l4.58-4.59L14 6l-6 6 6 6 1.41-1.41z" fill="white"/>
              </svg>
            </button>
            <span class="cal-month-title">{{ monthTitle }}</span>
            <button class="cal-nav-btn" @click="nextMonth" aria-label="Mois suivant">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z" fill="white"/>
              </svg>
            </button>
          </div>

          <!-- "Aujourd'hui" button row -->
          <div class="cal-today-row">
            <button class="today-btn" @click="goToToday">Aujourd'hui</button>
          </div>

          <!-- Calendar body -->
          <div class="cal-body">

            <!-- Weekday labels -->
            <div class="cal-weekdays">
              <div v-for="d in weekdays" :key="d" class="cal-weekday">{{ d }}</div>
            </div>

            <!-- Days grid -->
            <div class="cal-grid">
              <!-- Leading empty cells (offset before day 1) -->
              <div
                v-for="n in startOffset"
                :key="'pad-' + n"
                class="cal-cell cal-cell--empty"
              ></div>

              <!-- Day cells -->
              <div
                v-for="day in daysInMonth"
                :key="day"
                class="cal-cell"
                :class="dayCellClass(day)"
                @click="selectDay(day)"
              >
                <span class="cal-day-num">{{ day }}</span>
                <div v-if="hasAppointments(day)" class="cal-appt-wrapper">
                  <span
                    class="cal-indicator"
                    :style="{ background: appointmentColor(day) }"
                  ></span>
                </div>
              </div>
            </div>

          </div>
        </div>

        <!-- ── Appointment details panel ───────────────────────────────────── -->
        <div class="details-card">
          <h2 class="details-title">Détails des rendez-vous</h2>

          <!-- Empty state -->
          <div v-if="selectedRdvs.length === 0" class="no-rdv">
            <svg width="44" height="44" viewBox="0 0 24 24" fill="none">
              <path
                d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13zM8 10H6v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm-8 4H6v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2z"
                fill="#D1D5DC"
              />
            </svg>
            <p>Aucun rendez-vous ce jour</p>
          </div>

          <!-- Appointment cards -->
          <div v-else class="rdv-list">
            <div
              v-for="(rdv, i) in selectedRdvs"
              :key="i"
              class="rdv-card"
              :class="rdv.status === 'terminee' ? 'rdv-card--green' : 'rdv-card--orange'"
            >
              <!-- Date + time row -->
              <div class="rdv-meta">
                <div class="rdv-meta-item">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path
                      d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z"
                      :fill="rdv.status === 'terminee' ? '#00A63E' : '#FC5A15'"
                    />
                  </svg>
                  <span class="rdv-meta-text">{{ rdv.dateLabel }}</span>
                </div>
                <div class="rdv-meta-item">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path
                      d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"
                      :fill="rdv.status === 'terminee' ? '#00A63E' : '#FC5A15'"
                    />
                  </svg>
                  <span class="rdv-meta-text">{{ rdv.time }}</span>
                  <span
                    class="rdv-duration"
                    :class="rdv.status === 'terminee' ? 'rdv-duration--green' : 'rdv-duration--orange'"
                  >({{ rdv.duration }})</span>
                </div>
              </div>

              <!-- Title -->
              <h3
                class="rdv-title"
                :class="rdv.status === 'terminee' ? 'rdv-title--green' : 'rdv-title--orange'"
              >{{ rdv.title }}</h3>

              <!-- Client info -->
              <div class="rdv-info">
                <div class="rdv-info-row">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" fill="#62748E"/>
                  </svg>
                  <span>{{ rdv.client }}</span>
                </div>
                <div class="rdv-info-row">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z" fill="#62748E"/>
                  </svg>
                  <span>{{ rdv.phone }}</span>
                </div>
                <div class="rdv-info-row">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" fill="#62748E"/>
                  </svg>
                  <span>{{ rdv.city }}</span>
                </div>
              </div>

              <!-- Status badge -->
              <span
                class="rdv-badge"
                :class="rdv.status === 'terminee' ? 'rdv-badge--green' : 'rdv-badge--orange'"
              >{{ rdv.status === 'terminee' ? 'Terminée' : 'En attente' }}</span>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>

  <!-- ── Nouveau rendez-vous modal ─────────────────────────────────────────── -->
  <Teleport to="body">
    <div v-if="showNewRdvModal" class="modal-overlay" @click.self="closeNewRdv">
      <div class="modal-container">

        <!-- Orange gradient header -->
        <div class="modal-header">
          <h2 class="modal-title">Nouveau rendez-vous</h2>
          <button class="modal-close-btn" @click="closeNewRdv" aria-label="Fermer">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" fill="white"/>
            </svg>
          </button>
        </div>

        <!-- Scrollable form body -->
        <div class="modal-form">

          <!-- Nom du client -->
          <div class="mf-field">
            <label class="mf-label">Nom du client *</label>
            <input class="mf-input" type="text" placeholder="Mohammed Alami" v-model="newRdv.clientName" />
          </div>

          <!-- Téléphone -->
          <div class="mf-field">
            <label class="mf-label">Téléphone</label>
            <input class="mf-input" type="tel" placeholder="+212 6 12 34 56 78" v-model="newRdv.phone" />
          </div>

          <!-- Service -->
          <div class="mf-field">
            <label class="mf-label">Service *</label>
            <div class="mf-select-wrap">
              <select class="mf-select" v-model="newRdv.service">
                <option value="" disabled>Plombier</option>
                <option value="plombier">Plombier</option>
                <option value="electricien">Électricien</option>
                <option value="peintre">Peintre</option>
                <option value="menuisier">Menuisier</option>
              </select>
              <svg class="mf-caret" width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M7 10l5 5 5-5z" fill="#99A1AF"/>
              </svg>
            </div>
          </div>

          <!-- Type de service -->
          <div class="mf-field">
            <label class="mf-label">Type de service *</label>
            <input class="mf-input" type="text" placeholder="Réparation fuite" v-model="newRdv.serviceType" />
          </div>

          <!-- Date + Heure (side by side) -->
          <div class="mf-row">
            <div class="mf-field mf-field--half">
              <label class="mf-label">Date *</label>
              <input class="mf-input" type="date" v-model="newRdv.date" />
            </div>
            <div class="mf-field mf-field--half">
              <label class="mf-label">Heure *</label>
              <input class="mf-input" type="time" v-model="newRdv.time" />
            </div>
          </div>

          <!-- Durée estimée -->
          <div class="mf-field">
            <label class="mf-label">Durée estimée</label>
            <div class="mf-select-wrap">
              <select class="mf-select" v-model="newRdv.duration">
                <option value="">Sélectionner</option>
                <option value="30min">30 minutes</option>
                <option value="1h">1 heure</option>
                <option value="2h">2 heures</option>
                <option value="3h">3 heures</option>
              </select>
              <svg class="mf-caret" width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M7 10l5 5 5-5z" fill="#99A1AF"/>
              </svg>
            </div>
          </div>

          <!-- Type de rendez-vous -->
          <div class="mf-field">
            <label class="mf-label">Type de rendez-vous</label>
            <div class="mf-radio-group">
              <label class="mf-radio-label">
                <input class="mf-radio" type="radio" name="newRdvType" value="sur_place" v-model="newRdv.rdvType" />
                <span class="mf-radio-text">Sur place</span>
              </label>
              <label class="mf-radio-label">
                <input class="mf-radio" type="radio" name="newRdvType" value="visioconference" v-model="newRdv.rdvType" />
                <span class="mf-radio-text">Visioconférence</span>
              </label>
            </div>
          </div>

          <!-- Lieu -->
          <div class="mf-field">
            <label class="mf-label">Lieu</label>
            <input class="mf-input" type="text" placeholder="Casablanca, Maarif" v-model="newRdv.lieu" />
          </div>

          <!-- Notes -->
          <div class="mf-field">
            <label class="mf-label">Notes</label>
            <textarea class="mf-textarea" placeholder="Détails supplémentaires..." v-model="newRdv.notes"></textarea>
          </div>

        </div>

        <!-- Footer buttons -->
        <div class="modal-footer">
          <p v-if="submitError" class="mf-error">{{ submitError }}</p>
          <div class="mf-footer-btns">
            <button class="mf-btn mf-btn--cancel" @click="closeNewRdv" :disabled="submitting">Annuler</button>
            <button class="mf-btn mf-btn--submit" @click="submitNewRdv" :disabled="submitting">
              {{ submitting ? 'Enregistrement...' : 'Ajouter le rendez-vous' }}
            </button>
          </div>
        </div>

      </div>
    </div>
  </Teleport>

</template>

<script setup>
import { ref, computed, reactive, onMounted } from 'vue'
import { getAgenda, createAppointment } from '../api/agenda'

// ── Locale helpers ────────────────────────────────────────────────────────────
const monthNames = [
  '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
]
const weekdays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']

// ── Duration helper ───────────────────────────────────────────────────────────
function formatDuration(minutes) {
  if (!minutes) return '—'
  if (minutes < 60) return `${minutes} min`
  const h = Math.floor(minutes / 60)
  const m = minutes % 60
  return m === 0 ? `${h}h` : `${h}h${String(m).padStart(2, '0')}`
}

// ── Map API item → template shape ─────────────────────────────────────────────
function mapAppointment(item) {
  const d     = new Date(item.scheduled_at)
  const year  = d.getFullYear()
  const month = d.getMonth() + 1
  const day   = d.getDate()
  return {
    id:        item.id,
    type:      item.type,
    date:      { year, month, day },
    dateLabel: `${day} ${monthNames[month]}`,
    time:      d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    duration:  formatDuration(item.duration_minutes),
    title:     item.title || 'Rendez-vous',
    client:    item.contact_name  || '—',
    phone:     item.contact_phone || '—',
    city:      item.city          || '—',
    status:    item.status === 'completed' ? 'terminee' : 'enattente',
  }
}

// ── Appointments state (real data) ────────────────────────────────────────────
const appointments  = ref([])
const loadingAgenda = ref(false)
const agendaError   = ref('')

async function loadAgenda() {
  loadingAgenda.value = true
  agendaError.value   = ''
  try {
    const { data } = await getAgenda()
    appointments.value = (data.data ?? []).map(mapAppointment)
  } catch (e) {
    agendaError.value  = e.response?.data?.error || 'Impossible de charger l\'agenda.'
    appointments.value = []
  } finally {
    loadingAgenda.value = false
  }
}

// ── Calendar state ────────────────────────────────────────────────────────────
const todayDate    = new Date()
const focusedYear  = ref(todayDate.getFullYear())
const focusedMonth = ref(todayDate.getMonth() + 1)
const selectedDay  = ref(todayDate.getDate())

// ── Computed ──────────────────────────────────────────────────────────────────
const monthTitle = computed(() =>
  `${monthNames[focusedMonth.value]} ${focusedYear.value}`
)

const daysInMonth = computed(() =>
  new Date(focusedYear.value, focusedMonth.value, 0).getDate()
)

// getDay() → 0 = Sun … 6 = Sat (matches our Dim … Sam columns)
const startOffset = computed(() =>
  new Date(focusedYear.value, focusedMonth.value - 1, 1).getDay()
)

const selectedRdvs = computed(() => {
  if (!selectedDay.value) return []
  return appointments.value.filter(
    a =>
      a.date.year  === focusedYear.value  &&
      a.date.month === focusedMonth.value &&
      a.date.day   === selectedDay.value
  )
})

// ── Navigation ────────────────────────────────────────────────────────────────
function prevMonth() {
  if (focusedMonth.value === 1) { focusedMonth.value = 12; focusedYear.value-- }
  else focusedMonth.value--
  selectedDay.value = null
}

function nextMonth() {
  if (focusedMonth.value === 12) { focusedMonth.value = 1; focusedYear.value++ }
  else focusedMonth.value++
  selectedDay.value = null
}

function goToToday() {
  focusedYear.value  = todayDate.getFullYear()
  focusedMonth.value = todayDate.getMonth() + 1
  selectedDay.value  = todayDate.getDate()
}

function selectDay(day) { selectedDay.value = day }

// ── Appointment helpers ────────────────────────────────────────────────────────
function dayAppointments(day) {
  return appointments.value.filter(
    a =>
      a.date.year  === focusedYear.value  &&
      a.date.month === focusedMonth.value &&
      a.date.day   === day
  )
}

function hasAppointments(day) { return dayAppointments(day).length > 0 }

function appointmentColor(day) {
  const rdvs = dayAppointments(day)
  if (!rdvs.length) return null
  return rdvs.some(r => r.status === 'terminee') ? '#02BB05' : '#FC5A15'
}

function dayCellClass(day) {
  const isSelected = selectedDay.value === day
  const isToday    =
    todayDate.getFullYear()  === focusedYear.value  &&
    todayDate.getMonth() + 1 === focusedMonth.value &&
    todayDate.getDate()      === day
  const color   = appointmentColor(day)
  const hasAppt = !!color

  return {
    'cal-cell--selected-green':  isSelected && hasAppt && color === '#02BB05',
    'cal-cell--selected-orange': isSelected && hasAppt && color === '#FC5A15',
    'cal-cell--today':           isToday && !(isSelected && hasAppt),
  }
}

// ── New-RDV modal ─────────────────────────────────────────────────────────────
const showNewRdvModal = ref(false)
const submitting      = ref(false)
const submitError     = ref('')

const newRdv = reactive({
  clientName:  '',
  phone:       '',
  service:     '',
  serviceType: '',
  date:        '',
  time:        '',
  duration:    '',
  rdvType:     'sur_place',
  lieu:        '',
  notes:       '',
})

function resetNewRdv() {
  Object.assign(newRdv, {
    clientName: '', phone: '', service: '', serviceType: '',
    date: '', time: '', duration: '', rdvType: 'sur_place', lieu: '', notes: '',
  })
  submitError.value = ''
}

function openNewRdv()  { showNewRdvModal.value = true }
function closeNewRdv() { showNewRdvModal.value = false; resetNewRdv() }

async function submitNewRdv() {
  submitError.value = ''
  if (!newRdv.date || !newRdv.time) {
    submitError.value = 'Veuillez renseigner la date et l\'heure.'
    return
  }
  const title = newRdv.serviceType || newRdv.service || 'Rendez-vous'

  submitting.value  = true
  submitError.value = ''
  try {
    const { data } = await createAppointment({
      title,
      client_name:  newRdv.clientName  || null,
      client_phone: newRdv.phone       || null,
      date:         newRdv.date,
      time:         newRdv.time,
      duration:     newRdv.duration    || null,
      rdv_type:     newRdv.rdvType,
      city:         newRdv.lieu        || null,
      notes:        newRdv.notes       || null,
    })
    appointments.value.push(mapAppointment(data.data))
    closeNewRdv()
  } catch (e) {
    submitError.value = e.response?.data?.message || 'Impossible de créer le rendez-vous.'
  } finally {
    submitting.value = false
  }
}

// ── Init ──────────────────────────────────────────────────────────────────────
onMounted(loadAgenda)
</script>

<style scoped>
/* ── Base ────────────────────────────────────────────────────────────────── */
.page-wrapper {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFFEFC 0%, #FFFFFF 100%);
  font-family: 'Inter', 'Poppins', sans-serif;
}

.main-content {
  max-width: 1440px;
  margin: 0 auto;
}

/* ── Sub-header ──────────────────────────────────────────────────────────── */
.sub-header {
  padding: 20px 97px;
  background: #FFFFFF;
  border-bottom: 1px solid #E5E7EB;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  cursor: pointer;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  padding: 0;
  margin-bottom: 10px;
  transition: color .15s;
}

.back-btn:hover { color: #314158; }

.header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.page-title {
  font-family: 'Inter', sans-serif;
  font-size: 30px;
  font-weight: 400;
  line-height: 36px;
  letter-spacing: 0.4px;
  color: #314158;
  margin: 0 0 4px;
}

.page-subtitle {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
  margin: 0;
}

.new-rdv-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #FC5A15;
  color: #FFFFFF;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  cursor: pointer;
  white-space: nowrap;
  flex-shrink: 0;
  box-shadow: 0px 10px 15px -3px rgba(0,0,0,.1), 0px 4px 6px -4px rgba(0,0,0,.1);
  transition: opacity .15s;
}

.new-rdv-btn:hover { opacity: .88; }

/* ── Two-column layout ───────────────────────────────────────────────────── */
.agenda-layout {
  display: grid;
  grid-template-columns: 1fr 420px;
  gap: 24px;
  padding: 32px 97px 80px;
  align-items: start;
}

/* ── Calendar card ───────────────────────────────────────────────────────── */
.calendar-card {
  background: #FFFFFF;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  box-shadow: 0px 1px 8.2px rgba(0,0,0,.18);
  overflow: hidden;
}

/* ── Calendar header (orange gradient) ──────────────────────────────────── */
.cal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px 0;
  background: linear-gradient(180deg, #FC5A15 0%, #FF7A47 100%);
}

.cal-month-title {
  font-family: 'Inter', sans-serif;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: 0.07px;
  text-transform: capitalize;
  color: #FFFFFF;
}

.cal-nav-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255,255,255,.2);
  border: none;
  border-radius: 10px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background .15s;
}

.cal-nav-btn:hover { background: rgba(255,255,255,.35); }

/* "Aujourd'hui" row — still on gradient background */
.cal-today-row {
  background: linear-gradient(180deg, #FC5A15 0%, #FF7A47 100%);
  padding: 12px 24px 16px;
}

.today-btn {
  display: block;
  width: 100%;
  height: 40px;
  background: #FFFFFF;
  border: none;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #FC5A15;
  cursor: pointer;
  transition: background .15s;
}

.today-btn:hover { background: #FFF7ED; }

/* ── Calendar body ───────────────────────────────────────────────────────── */
.cal-body {
  padding: 20px 24px;
}

.cal-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  margin-bottom: 6px;
}

.cal-weekday {
  text-align: center;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
  padding: 8px 0;
}

/* ── Day grid ────────────────────────────────────────────────────────────── */
.cal-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.cal-cell {
  background: #F9FAFB;
  border: 1px solid transparent;
  border-radius: 10px;
  min-height: 88px;
  padding: 6px 6px 4px;
  display: flex;
  flex-direction: column;
  cursor: pointer;
  transition: background .12s, border-color .12s;
}

.cal-cell:hover:not(.cal-cell--empty) { background: #F3F4F6; }

.cal-cell--empty {
  background: transparent;
  border-color: transparent;
  cursor: default;
  pointer-events: none;
}

.cal-day-num {
  display: block;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #314158;
  text-align: center;
}

/* Wrapper that pushes the indicator bar to the bottom of the cell */
.cal-appt-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding-bottom: 2px;
}

.cal-indicator {
  display: block;
  height: 4px;
  border-radius: 999px;
  width: 100%;
}

/* ── Day cell states ─────────────────────────────────────────────────────── */
.cal-cell--selected-green {
  background: rgba(255, 247, 237, 0.38);
  border-color: #02BB05;
}
.cal-cell--selected-green .cal-day-num { color: #02BB05; }

.cal-cell--selected-orange {
  background: rgba(252, 90, 21, 0.04);
  border-color: #FC5A15;
}
.cal-cell--selected-orange .cal-day-num { color: #FC5A15; }

.cal-cell--today            { border-color: #FC5A15; }
.cal-cell--today .cal-day-num { color: #FC5A15; }

/* ── Details panel ───────────────────────────────────────────────────────── */
.details-card {
  background: #FFFFFF;
  border: 1px solid #F3F4F6;
  border-radius: 14px;
  box-shadow: 0px 1px 4.7px rgba(0,0,0,.16);
  padding: 25px 25px 24px;
}

.details-title {
  font-family: 'Inter', sans-serif;
  font-size: 20px;
  font-weight: 400;
  line-height: 28px;
  letter-spacing: -0.45px;
  color: #314158;
  margin: 0 0 24px;
}

/* ── Empty state ─────────────────────────────────────────────────────────── */
.no-rdv {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 48px 0;
  color: #62748E;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
}

.no-rdv p { margin: 0; }

/* ── Appointment list ────────────────────────────────────────────────────── */
.rdv-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ── Appointment card ────────────────────────────────────────────────────── */
.rdv-card {
  background: rgba(252, 90, 21, 0.01);
  border-left: 4px solid transparent;
  border-radius: 10px;
  box-shadow: 0px 1px 5.8px rgba(0,0,0,.16);
  padding: 16px 16px 16px 20px;
}

.rdv-card--green  { border-left-color: #00A63E; }
.rdv-card--orange { border-left-color: #FC5A15; }

/* Date + time meta row */
.rdv-meta {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.rdv-meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.rdv-meta-text {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #62748E;
}

.rdv-duration {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 16px;
}

.rdv-duration--green  { color: #00A63E; }
.rdv-duration--orange { color: #FC5A15; }

/* Title */
.rdv-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 400;
  line-height: 24px;
  letter-spacing: -0.31px;
  margin: 0 0 12px;
}

.rdv-title--green  { color: #00A63E; }
.rdv-title--orange { color: #FC5A15; }

/* Client info rows */
.rdv-info {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 14px;
}

.rdv-info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #62748E;
}

/* Status badge */
.rdv-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 4px;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  line-height: 16px;
}

.rdv-badge--green {
  background: rgba(0, 166, 62, 0.04);
  border: 0.4px solid #00A63E;
  color: #00A63E;
}

.rdv-badge--orange {
  background: rgba(252, 90, 21, 0.04);
  border: 0.4px solid #FC5A15;
  color: #FC5A15;
}

/* ── Modal overlay ───────────────────────────────────────────────────────── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 24px;
}

/* ── Modal container ─────────────────────────────────────────────────────── */
.modal-container {
  position: relative;
  width: 723px;
  max-width: 100%;
  max-height: 90vh;
  background: #FFFFFF;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
  overflow: hidden;
}

/* ── Orange gradient header ──────────────────────────────────────────────── */
.modal-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 24px 24px 24px;
  background: linear-gradient(180deg, #FC5A15 0%, #FF7A47 100%);
  border-radius: 14px 14px 0 0;
  flex-shrink: 0;
}

.modal-title {
  font-family: 'Inter', sans-serif;
  font-size: 24px;
  font-weight: 400;
  line-height: 32px;
  letter-spacing: 0.07px;
  color: #FFFFFF;
  margin: 0;
}

.modal-close-btn {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 10px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background .15s;
}

.modal-close-btn:hover { background: rgba(255, 255, 255, 0.35); }

/* ── Scrollable form area ────────────────────────────────────────────────── */
.modal-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 24px 40px 16px;
  overflow-y: auto;
  flex: 1;
}

/* ── Generic field wrapper ───────────────────────────────────────────────── */
.mf-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.mf-label {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 400;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #314158;
}

/* Text / tel / date / time inputs */
.mf-input {
  box-sizing: border-box;
  width: 100%;
  height: 42px;
  padding: 8px 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 19px;
  letter-spacing: -0.31px;
  color: #0A0A0A;
  outline: none;
  transition: border-color .15s;
}

.mf-input::placeholder { color: rgba(10, 10, 10, 0.5); }
.mf-input:focus { border-color: #FC5A15; }

/* Textarea */
.mf-textarea {
  box-sizing: border-box;
  width: 100%;
  height: 90px;
  padding: 8px 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  color: #0A0A0A;
  resize: none;
  outline: none;
  transition: border-color .15s;
}

.mf-textarea::placeholder { color: rgba(10, 10, 10, 0.5); }
.mf-textarea:focus { border-color: #FC5A15; }

/* Select wrapper (for custom caret) */
.mf-select-wrap {
  position: relative;
}

.mf-select {
  box-sizing: border-box;
  width: 100%;
  height: 39px;
  padding: 0 40px 0 16px;
  border: 1px solid #D1D5DC;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 19px;
  letter-spacing: -0.31px;
  color: rgba(10, 10, 10, 0.5);
  background: #FFFFFF;
  appearance: none;
  -webkit-appearance: none;
  cursor: pointer;
  outline: none;
  transition: border-color .15s;
}

.mf-select:focus { border-color: #FC5A15; color: #0A0A0A; }

.mf-caret {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}

/* Side-by-side row (Date + Heure) */
.mf-row {
  display: flex;
  gap: 16px;
}

.mf-field--half { flex: 1; }

/* Radio group */
.mf-radio-group {
  display: flex;
  flex-direction: row;
  gap: 16px;
}

.mf-radio-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.mf-radio {
  width: 13px;
  height: 13px;
  border: 1px solid #99A1AF;
  cursor: pointer;
  accent-color: #FC5A15;
  flex-shrink: 0;
}

.mf-radio-text {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 20px;
  letter-spacing: -0.15px;
  color: #314158;
}

/* ── Footer buttons ──────────────────────────────────────────────────────── */
.modal-footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 16px 40px 24px;
  flex-shrink: 0;
}

.mf-error {
  margin: 0;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  text-align: center;
}

.mf-footer-btns {
  display: flex;
  flex-direction: row;
  gap: 12px;
}

.mf-btn {
  flex: 1;
  height: 50px;
  border-radius: 10px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  line-height: 24px;
  letter-spacing: -0.31px;
  cursor: pointer;
  transition: opacity .15s;
}

.mf-btn--cancel {
  background: #FFFFFF;
  border: 1px solid #D1D5DC;
  color: #314158;
}

.mf-btn--cancel:hover { background: #F9FAFB; }

.mf-btn--submit {
  background: #FC5A15;
  border: none;
  color: #FFFFFF;
}

.mf-btn--submit:hover { opacity: .88; }

/* ── Responsive ──────────────────────────────────────────────────────────── */
@media (max-width: 1200px) {
  .sub-header    { padding: 20px 40px; }
  .agenda-layout { grid-template-columns: 1fr 360px; padding: 24px 40px 60px; }
}

@media (max-width: 900px) {
  .sub-header    { padding: 16px 24px; }
  .agenda-layout { grid-template-columns: 1fr; padding: 20px 24px 60px; }
  /* On small screens show details above calendar */
  .details-card  { order: -1; }
}

@media (max-width: 600px) {
  .header-row              { flex-direction: column; align-items: flex-start; gap: 12px; }
  .new-rdv-btn             { width: 100%; justify-content: center; }
  .cal-header,
  .cal-today-row           { padding-left: 12px; padding-right: 12px; }
  .cal-month-title         { font-size: 18px; }
  .cal-body                { padding: 12px; }
  .cal-cell                { min-height: 52px; padding: 4px 4px 2px; }
  .cal-day-num             { font-size: 11px; }
}
</style>

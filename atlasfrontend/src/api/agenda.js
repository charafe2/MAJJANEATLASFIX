import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
})

api.interceptors.request.use(cfg => {
  const token = localStorage.getItem('token')
  if (token) cfg.headers.Authorization = `Bearer ${token}`
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

/** Fetch all agenda appointments for the authenticated user. */
export const getAgenda = () =>
  api.get('/agenda')

/**
 * Create a manual appointment.
 * @param {Object} payload - { title, client_name, client_phone, date (YYYY-MM-DD),
 *                             time (HH:mm), duration ('30min'|'1h'|'2h'|'3h'),
 *                             rdv_type, city, notes }
 */
export const createAppointment = (payload) =>
  api.post('/agenda', payload)

export default api

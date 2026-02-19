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

export const getCategories = () =>
  api.get('/categories')

export const getServiceTypes = (categoryId) =>
  api.get(`/categories/${categoryId}/service-types`)

export const createServiceRequest = (formData) =>
  api.post('/client/service-requests', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })

export const getServiceRequests = (status = null) =>
  api.get('/client/service-requests', { params: status ? { status } : {} })

export const getServiceRequest = (id) =>
  api.get(`/client/service-requests/${id}`)

export const cancelServiceRequest = (id) =>
  api.patch(`/client/service-requests/${id}/cancel`)

export const acceptOffer = (requestId, offerId) =>
  api.post(`/client/service-requests/${requestId}/offers/${offerId}/accept`)

export const rejectOffer = (requestId, offerId) =>
  api.post(`/client/service-requests/${requestId}/offers/${offerId}/reject`)

// ── Artisan: Browse & respond ─────────────────────────────────────────────

export const getArtisanServiceRequests = (params = {}) =>
  api.get('/artisan/service-requests', { params })

export const submitOffer = (requestId, data) =>
  api.post(`/artisan/service-requests/${requestId}/offers`, data)

export const getClientProfile = (clientId) =>
  api.get(`/artisan/clients/${clientId}`)

export const getMyOffers = (tab = 'all') =>
  api.get('/artisan/offers', { params: { tab } })

export default api

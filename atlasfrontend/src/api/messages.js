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

// ── Conversations ──────────────────────────────────────────────────────────

export const getConversations = () =>
  api.get('/conversations')

/**
 * Get or create a conversation.
 * Client:  pass { artisan_id, service_request_id? }
 * Artisan: pass { client_id,  service_request_id? }
 */
export const getOrCreateConversation = (params) =>
  api.post('/conversations', params)

export const getConversation = (id) =>
  api.get(`/conversations/${id}`)

// ── Messages ───────────────────────────────────────────────────────────────

export const getMessages = (conversationId) =>
  api.get(`/conversations/${conversationId}/messages`)

export const sendMessageApi = (conversationId, content) =>
  api.post(`/conversations/${conversationId}/messages`, { content })

export const markAsRead = (conversationId) =>
  api.post(`/conversations/${conversationId}/read`)

export default api

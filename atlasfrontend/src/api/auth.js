import axios from 'axios'

// ── Axios instance ─────────────────────────────────────────────────────────
const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
})

// Attach Bearer token on every request if available
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Auth endpoints 
export const registerClient = (data) => api.post('/register', data)

export const registerArtisan = (formData) =>
  api.post('/register', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })

export const login = (data) => api.post('/login', data)

export const verifyCode = (data) => api.post('/verify', data)

export const resendCode = (data) => api.post('/resend-code', data)

export const forgotPassword = (data) => api.post('/forgot-password', data)

export const resetPassword = (data) => api.post('/reset-password', data)

export const logout = () => api.post('/logout')

export default api
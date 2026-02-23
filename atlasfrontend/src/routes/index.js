import { createRouter, createWebHistory } from 'vue-router'
import GoogleSuccess from '../views/GoogleSuccess.vue'
import GoogleComplete from '../views/GoogleComplete.vue'
const routes = [
  // ── Public ──────────────────────────────────────────────────────────────
  { path: '/',               component: () => import('../views/Home.vue') },
  { path: '/login',          component: () => import('../views/login.vue') },
  { path: '/register',       component: () => import('../views/register.vue') },
  { path: '/register/client',  component: () => import('../views/registerClient.vue') },
  { path: '/register/artisan', component: () => import('../views/registerArtisan.vue') },
  { path: '/forgot-password',  component: () => import('../views/ForgotPassword.vue') },
  { path: '/client/profile',           component: () => import('../components/profile/profileView.vue'), meta: { requiresAuth: true, accountType: 'client' } },
  { path: '/artisan/clients/:id',      component: () => import('../components/profile/profileView.vue'), meta: { requiresAuth: true, accountType: 'artisan' } },
  {path:'/auth/google/success',component: GoogleSuccess,},
{  path:'/register/google-complete',component: GoogleComplete,},


  // Google OAuth callback
  { path: '/auth/callback',  component: () => import('../views/GoogleCallback.vue') },

  // ── Artisan pricing: only reachable right after registration ────────────
  // Requires token (artisan just registered) + ?uid= query param.
  // Without ?uid the guard redirects to the dashboard.
  {
    path: '/register/artisan/pricing',
    component: () => import('../views/Pricing.vue'),
    meta: {accountType: 'artisan', pricingPage: true },
  },

  // ── Payment Stats ────────────────────────────────────────────────────
  {
    path: '/payments',
    component: () => import('../views/paymentstats.vue'),
    meta: { requiresAuth: true },
  },

  // ── Agenda ───────────────────────────────────────────────────────────
  {
    path: '/agenda',
    component: () => import('../views/agenda.vue'),
    meta: { requiresAuth: true },
  },

  // ── Protected ────────────────────────────────────────────────────────
  {
    path: '/client/dashboard',
    component: () => import('../views/client/Dashboard.vue'),
    meta: { requiresAuth: true, accountType: 'client' },
  },
  {
    path: '/artisan/dashboard',
    component: () => import('../views/artisan/Dashboard.vue'),
    meta: { requiresAuth: true, accountType: 'artisan' },
  },

  // ── Service request list pages ────────────────────────────────────────
  {
    path: '/client/mes-demandes',
    component: () => import('../views/client/MesDemandes.vue'),
    meta: { requiresAuth: true, accountType: 'client' },
  },
  {
    path: '/artisan/mes-demandes',
    component: () => import('../views/artisan/MesDemandesAcceptees.vue'),
    meta: { requiresAuth: true, accountType: 'artisan' },
  },

  // ── Service request detail pages ─────────────────────────────────────
  {
    path: '/client/demandes/:id',
    component: () => import('../views/DemandeDetail.vue'),
    meta: { requiresAuth: true, accountType: 'client' },
    props: { role: 'client' },
  },
  {
    path: '/artisan/demandes/:id',
    component: () => import('../views/DemandeDetail.vue'),
    meta: { requiresAuth: true, accountType: 'artisan' },
    props: { role: 'artisan' },
  },

  // ── Messaging (accessible to both clients and artisans) ──────────────
  {
    path: '/messages',
    component: () => import('../views/Messages.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/messages/:id',
    component: () => import('../views/Messages.vue'),
    meta: { requiresAuth: true },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() { return { top: 0 } },
})

// ── Navigation guard ──────────────────────────────────────────────────────
router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('token')
  const user  = JSON.parse(localStorage.getItem('user') || 'null')

  // 1. Auth-required routes
  if (to.meta.requiresAuth) {
    if (!token) { next('/login'); return }

    // Wrong account type → their own dashboard
    if (to.meta.accountType && user?.account_type !== to.meta.accountType) {
      next(user?.account_type === 'client' ? '/client/dashboard' : '/artisan/dashboard')
      return
    }

    // Pricing page guard: must arrive with ?uid= (set by RegisterArtisan on success).
    // Prevents artisans from bookmarking and revisiting the pricing page later.
    if (to.meta.pricingPage && !to.query.uid) {
      next('/artisan/dashboard')
      return
    }
  }

  // 2. Already-logged-in users skip guest pages
  //    (pricing page is excluded — it's post-register, not a guest page)
  const guestOnlyPaths = ['/login', '/register', '/register/client', '/register/artisan']
  if (token && guestOnlyPaths.includes(to.path)) {
    next(user?.account_type === 'client' ? '/client/dashboard' : '/artisan/dashboard')
    return
  }

  next()
  
}
)

export default router


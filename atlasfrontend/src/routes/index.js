import { createRouter, createWebHistory } from 'vue-router'
import GoogleSuccess from '../views/auth/GoogleSuccess.vue'
import GoogleComplete from '../views/auth/GoogleComplete.vue'

const routes = [
  // ── Root ────────────────────────────────────────────────────────────────
  { path: '/',     component: () => import('../views/Home.vue') },
  { path: '/Home', redirect: '/' },

  // ── Auth ────────────────────────────────────────────────────────────────
  { path: '/login',                    component: () => import('../views/auth/loginvue.vue') },
  { path: '/register',                 component: () => import('../views/auth/register.vue') },
  { path: '/register/client',          component: () => import('../views/auth/registerClient.vue') },
  { path: '/register/artisan',         component: () => import('../views/auth/registerArtisan.vue') },
  { path: '/register/artisan/pricing', component: () => import('../views/Pricing.vue'), meta: { accountType: 'artisan', pricingPage: true } },
  { path: '/register/google-complete', component: GoogleComplete },
  { path: '/verify',                   component: () => import('../views/auth/verify.vue') },
  { path: '/forgot-password',          component: () => import('../views/auth/forgotpassword.vue') },

  // ── Google OAuth ─────────────────────────────────────────────────────
  { path: '/auth/google/success', component: GoogleSuccess },
  { path: '/auth/callback',       component: () => import('../views/auth/GoogleSuccess.vue') },

  // ── Dashboard redirects ───────────────────────────────────────────────
  { path: '/dashboard',         redirect: '/client/profile' },
  { path: '/client/dashboard',  redirect: '/client/profile' },
  { path: '/artisan/dashboard', redirect: '/artisan/profile' },

  // ── Public pages ─────────────────────────────────────────────────────
  { path: '/Aboutus',        component: () => import('../components/about/heresection.vue') },
  { path: '/services',       component: () => import('../components/services/servicesHero.vue') },
  { path: '/services/:slug', component: () => import('../views/ServicePage.vue') },
  { path: '/contact',        component: () => import('../views/Contact.vue') },
  { path: '/faq',            component: () => import('../views/faq.vue') },

  // ── Profiles ─────────────────────────────────────────────────────────
  { path: '/client/profile',       component: () => import('../views/profile/profileView.vue'), meta: { requiresAuth: true, accountType: 'client' } },
  { path: '/artisan/profile',      component: () => import('../views/artisan/ArtisanProfile.vue'),   meta: { requiresAuth: true, accountType: 'artisan' } },
  { path: '/artisan/clients/:id',  component: () => import('../views/profile/profileView.vue'), meta: { requiresAuth: true, accountType: 'artisan' } },
  { path: '/artisans/profile/:id', component: () => import('../views/artisan/Artisanprofilevisit.vue'), meta: { requiresAuth: true } },

  // ── Messaging ────────────────────────────────────────────────────────
  { path: '/messages',     component: () => import('../views/Messages.vue'), meta: { requiresAuth: true } },
  { path: '/messages/:id', component: () => import('../views/Messages.vue'), meta: { requiresAuth: true } },

  // ── Service requests ─────────────────────────────────────────────────
  { path: '/client/mes-demandes',        component: () => import('../views/client/MesDemandes.vue'),          meta: { requiresAuth: true, accountType: 'client' } },
  { path: '/client/mes-demandes/offres', component: () => import('../views/client/DemandeOffres.vue'),        meta: { requiresAuth: true, accountType: 'client' } },
  { path: '/client/nouvelle-demande',    component: () => import('../views/client/NouvelleDemande.vue'),      meta: { requiresAuth: true, accountType: 'client' } },
  { path: '/artisan/demandes-clients',   component: () => import('../views/artisan/DemandesClients.vue'),     meta: { requiresAuth: true, accountType: 'artisan' } },
  { path: '/artisan/mes-demandes',       component: () => import('../views/artisan/MesDemandesAcceptees.vue'),meta: { requiresAuth: true, accountType: 'artisan' } },
  { path: '/client/demandes/:id',        component: () => import('../views/DemandeDetail.vue'),               meta: { requiresAuth: true, accountType: 'client' },  props: { role: 'client' } },
  { path: '/artisan/demandes/:id',       component: () => import('../views/DemandeDetail.vue'),               meta: { requiresAuth: true, accountType: 'artisan' }, props: { role: 'artisan' } },

  // ── Payments & Agenda ─────────────────────────────────────────────────
  { path: '/payments',       component: () => import('../views/paymentstats.vue'), meta: { requiresAuth: true } },
  { path: '/agenda',         component: () => import('../views/agenda.vue'),       meta: { requiresAuth: true } },
  { path: '/Artisan/agenda', redirect: '/agenda' },

  // ── Static info pages ─────────────────────────────────────────────────
  { path: '/litiges', component: () => import('../views/LitigesPage.vue') },
  { path: '/Litiges', redirect: '/litiges' },
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
})

export default router

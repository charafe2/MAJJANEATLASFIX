import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import axios from 'axios'
import App from './App.vue'

// ── Views ───────────────────────────────────────────────────────────────────
import loginvue          from './views/loginvue.vue'
import register          from './views/register.vue'
import RegC              from './views/registerClient.vue'
import pricing           from './views/Pricing.vue'
import regA              from './views/registerArtisan.vue'
import verify            from './views/verify.vue'
import home              from './views/Home.vue'
import profileC          from './components/profile/profileView.vue'
import Hero              from './components/about/heresection.vue'
import Services          from './components/services/servicesHero.vue'
import Contact           from './views/Contact.vue'
import Faq               from './views/faq.vue'
import ArtisanProfile    from './views/ArtisanProfile.vue'
import ServicePage       from './views/ServicePage.vue'
import Artisanprofilevisit from './views/Artisanprofilevisit.vue'
import Paymentstats      from './views/paymentstats.vue'
import Agenda            from './views/agenda.vue'
import MesDemandes       from './views/client/MesDemandes.vue'
import NouvelleDemande   from './views/client/NouvelleDemande.vue'
import DemandeOffres     from './views/client/DemandeOffres.vue'
import DemandesClients   from './views/artisan/DemandesClients.vue'
import MesDemandesAcceptees from './views/artisan/MesDemandesAcceptees.vue'
import Messages          from './views/Messages.vue'
import DemandeDetail     from './views/DemandeDetail.vue'
import ForgotPassword    from './views/forgotpassword.vue'
import GoogleSuccess     from './views/GoogleSuccess.vue'
import GoogleComplete    from './views/GoogleComplete.vue'
import Litige from './views/LitigesPage.vue'
// import './style.css'
import './assets/css/profile.css'

// Axios base URL
axios.defaults.baseURL = 'http://127.0.0.1:8000'

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior() { return { top: 0 } },
  routes: [

    // ── Root ────────────────────────────────────────────────────────────────
    { path: '/',    component: home },
    { path: '/Home', redirect: '/' },

    // ── Auth ────────────────────────────────────────────────────────────────
    { path: '/login',                   component: loginvue },
    { path: '/register',                component: register },
    { path: '/register/client',         component: RegC },
    { path: '/register/artisan',        component: regA },
    { path: '/register/artisan/pricing', component: pricing },
    { path: '/register/google-complete', component: GoogleComplete },
    { path: '/verify',                  component: verify },
    { path: '/forgot-password',         component: ForgotPassword },

    // ── Google OAuth ─────────────────────────────────────────────────────
    { path: '/auth/google/success', component: GoogleSuccess },
    { path: '/auth/callback',       component: GoogleSuccess },

    // ── Dashboard redirects (legacy + Google auth flow) ──────────────────
    { path: '/client/dashboard',  redirect: '/client/profile' },
    { path: '/artisan/dashboard', redirect: '/artisan/profile' },
    { path: '/dashboard',         redirect: '/client/profile' },

    // ── Public pages ─────────────────────────────────────────────────────
    { path: '/Aboutus',          component: Hero },
    { path: '/services',         component: Services },
    { path: '/services/:slug',   component: ServicePage },
    { path: '/contact',          component: Contact },
    { path: '/faq',              component: Faq },

    // ── Profiles ─────────────────────────────────────────────────────────
    { path: '/client/profile',       component: profileC },
    { path: '/artisan/profile',      component: ArtisanProfile },
    { path: '/artisan/clients/:id',  component: profileC },
    { path: '/artisans/profile/:id', component: Artisanprofilevisit },

    // ── Messaging ────────────────────────────────────────────────────────
    { path: '/messages',     component: Messages },
    { path: '/messages/:id', component: Messages },

    // ── Service requests ─────────────────────────────────────────────────
    { path: '/client/mes-demandes',          component: MesDemandes },
    { path: '/client/mes-demandes/offres',   component: DemandeOffres },
    { path: '/client/nouvelle-demande',      component: NouvelleDemande },
    { path: '/artisan/demandes-clients',  component: DemandesClients },
    { path: '/artisan/mes-demandes',      component: MesDemandesAcceptees },
    { path: '/client/demandes/:id',   component: DemandeDetail, props: { role: 'client' } },
    { path: '/artisan/demandes/:id',  component: DemandeDetail, props: { role: 'artisan' } },

    // ── Payments & Agenda ─────────────────────────────────────────────────
    { path: '/payments',       component: Paymentstats },
    { path: '/Artisan/agenda', component: Agenda },

    //Footers
        { path: '/Litiges', component: Litige },

  ],
})

const app = createApp(App)
app.use(router)
app.mount('#app')

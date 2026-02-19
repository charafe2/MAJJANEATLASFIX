import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import axios from 'axios'
import App from './App.vue'
import loginvue from './views/loginvue.vue'
import register from './views/register.vue'
import RegC from './views/registerClient.vue'
import pricing from './views/Pricing.vue'
import regA from './views/registerArtisan.vue'
import verify from './views/verify.vue'
import home from './views/Home.vue'
import profileC from './components/profile/profileView.vue'
import Hero from './components/about/heresection.vue'
import Services from './components/services/servicesHero.vue'
import Contact from './views/Contact.vue'

// import './style.css'
import './assets/css/profile.css'
import Faq from './views/faq.vue'
import ArtisanProfile from './views/ArtisanProfile.vue'
import ServicesPlombier from './views/ServicesPlombier.vue'
import Artisanprofilevisit from './views/Artisanprofilevisit.vue'
import Paymentstats from './views/paymentstats.vue'
import Agenda from './views/agenda.vue'
import MesDemandes from './views/client/MesDemandes.vue'
import NouvelleDemande from './views/client/NouvelleDemande.vue'
import DemandesClients from './views/artisan/DemandesClients.vue'
import MesDemandesAcceptees from './views/artisan/MesDemandesAcceptees.vue'

// Axios base URL
axios.defaults.baseURL = 'http://127.0.0.1:8000'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', component: loginvue },
    { path: '/register', component: register },
    { path: '/register/client', component: RegC },
 { path: '/register/artisan/pricing', component: pricing },
    { path: '/register/artisan', component: regA },
    { path: '/verify', component: verify },
    { path: '/Home', component: home },
    { path: '/client/profile', component: profileC },
    { path: '/Aboutus', component: Hero },
    { path: '/services', component: Services },
    { path: '/Contact', component: Contact },
    { path: '/faq', component: Faq },
    { path: '/artisan/profile', component: ArtisanProfile },
    { path: '/services/plombier', component: ServicesPlombier },
    { path: '/Client/Artisan/Profile', component: Artisanprofilevisit },
    { path: '/Artisan/Payments', component: Paymentstats },
    { path: '/Artisan/agenda',            component: Agenda },
    { path: '/client/mes-demandes',       component: MesDemandes },
    { path: '/client/nouvelle-demande',   component: NouvelleDemande },
    { path: '/artisan/demandes-clients',   component: DemandesClients },
    { path: '/artisan/clients/:id',        component: profileC },
    { path: '/artisan/mes-demandes',       component: MesDemandesAcceptees },


  ]
})

const app = createApp(App)
app.use(router)
app.mount('#app')
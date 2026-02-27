import { createApp } from 'vue'
import axios from 'axios'
import App from './App.vue'
import router from './routes/index.js'
import './assets/css/profile.css'

// Axios base URL
axios.defaults.baseURL = 'http://127.0.0.1:8000'

const app = createApp(App)
app.use(router)
app.mount('#app')

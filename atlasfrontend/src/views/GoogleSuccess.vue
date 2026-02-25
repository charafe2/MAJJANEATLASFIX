<template>
  <div class="callback-screen">
    <!-- shown only if something went wrong -->
    <div v-if="error" class="error-box">
      <div class="error-icon">⚠️</div>
      <h2>Échec de la connexion Google</h2>
      <p>{{ errorMessage }}</p>
      <button @click="$router.replace('/login')">Retour à la connexion</button>
    </div>

    <!-- loading spinner while we parse the URL -->
    <div v-else class="spinner-wrap">
      <div class="spinner"></div>
      <p>Connexion en cours…</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route  = useRoute()

const error        = ref(false)
const errorMessage = ref('')

const ERROR_MESSAGES = {
  google_failed: 'La connexion Google a échoué. Veuillez réessayer.',
  banned:        'Ce compte a été suspendu.',
}

onMounted(() => {
  const q = route.query

  // ── Hard error from backend ──────────────────────────────────────────────
  if (q.error) {
    error.value        = true
    // Show the raw reason from Laravel in dev so we can diagnose
    const reason = q.reason ? ` (${decodeURIComponent(q.reason)})` : ''
    errorMessage.value = (ERROR_MESSAGES[q.error] ?? 'Une erreur est survenue.') + reason
    return
  }

  // ── Existing user — backend sent a base64 payload ────────────────────────
  if (q.payload) {
    try {
      const data = JSON.parse(atob(decodeURIComponent(q.payload)))

      localStorage.setItem('token', data.token)
      localStorage.setItem('user',  JSON.stringify(data.user))

      const dest = data.user?.account_type === 'artisan'
        ? '/artisan/profile'
        : '/client/profile'

      router.replace(dest)
    } catch (e) {
      error.value        = true
      errorMessage.value = 'Impossible de lire la réponse du serveur.'
    }
    return
  }

  // ── New user — needs to complete their profile ───────────────────────────
  if (q.requires_completion === 'true') {
    router.replace({
      path: '/register/google-complete',
      query: {
        temp_key:  q.temp_key,
        full_name: q.full_name,
        email:     q.email,
      },
    })
    return
  }

  // ── Nothing useful in URL ─────────────────────────────────────────────────
  error.value        = true
  errorMessage.value = 'Réponse inattendue du serveur.'
})
</script>

<style scoped>
.callback-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Poppins', sans-serif;
  background: linear-gradient(135deg, #fff8f5 0%, #ffffff 100%);
}

.spinner-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  color: #888;
}

.spinner {
  width: 42px;
  height: 42px;
  border: 4px solid rgba(252, 90, 21, 0.15);
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.error-box {
  text-align: center;
  max-width: 360px;
  padding: 40px 32px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.08);
}

.error-icon { font-size: 40px; margin-bottom: 12px; }

.error-box h2 {
  font-size: 18px;
  font-weight: 700;
  color: #111;
  margin-bottom: 8px;
}

.error-box p {
  font-size: 14px;
  color: #666;
  margin-bottom: 24px;
}

.error-box button {
  background: #FC5A15;
  color: white;
  border: none;
  padding: 12px 28px;
  border-radius: 30px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
}
</style>
<template>
  <!-- blank — this view just runs logout logic and redirects immediately -->
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

onMounted(() => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.replace('/login')   // replace so the user can't hit Back to /logout
})
</script>
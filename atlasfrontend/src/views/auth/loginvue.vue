<template>
  <div>

    <AuthBackground>
      <login />
    </AuthBackground>
  </div>
</template>

<script setup>
import Navbar from "../../components/navbar.vue";
import AuthBackground from "../../components/auth/Authbackground.vue";
import login from "./login.vue";
import footer from "../../components/footer.vue"
</script>
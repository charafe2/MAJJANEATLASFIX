<template>
  <div class="auth-bg">
    <slot />
  </div>
</template>

<style scoped>
.auth-bg {
  min-height: calc(100vh - 70px);

  background-image:
    linear-gradient(
      rgba(255, 255, 255, 0.93),
      rgba(255, 255, 255, 0.93)
    ),
    /* url("/assets/worker-repairing-water-heater.jpg"); */
;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;

  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
<!-- ProfileTabs.vue -->
<template>
  <div class="tabs">
    <button class="active">Informations personnelles</button>
    <button>Préférences</button>
    <button>Sécurité</button>
  </div>
</template>

<style scoped>
.tabs {
  background: white;
  border-bottom: 1px solid #eee;
  display: flex;
  gap: 20px;
}

button {
  padding: 14px 18px;
  border: none;
  background: none;
  color: gray;
  cursor: pointer;
  font-size: 14px;
}

button.active {
  color: #ea580c;
  border-bottom: 2px solid #ea580c;
}
</style>

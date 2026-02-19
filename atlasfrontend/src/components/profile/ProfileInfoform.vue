<!-- ProfileInfoForm.vue -->
<template>
  <div class="card">
    <h3>Informations personnelles</h3>

    <div class="grid">
      <Input label="Prénom" value="Marie" />
      <Input label="Nom" value="Dupont" />
      <Input label="Email" value="marie.dupont@email.com" />
      <Input label="Téléphone" value="+212 6 12 34 56 78" />
      <Input label="Adresse" value="15 Al Nakhil" />
      <Input label="Ville" value="Rabat" />
      <Input label="Code postal" value="75001" />
      <Input label="Date de naissance" value="15/03/1990" />
    </div>
  </div>
</template>

<script setup>
import Input from "./ProfileInput.vue";
</script>

<style scoped>
.card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
}

h3 {
  margin-bottom: 20px;
  color: #444;
}

.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}
</style>

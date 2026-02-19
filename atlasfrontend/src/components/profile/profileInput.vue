<!-- ProfileInput.vue -->
<template>
  <div class="input-group">
    <label>{{ label }}</label>
    <input :value="value" />
  </div>
</template>

<script setup>
defineProps({
  label: String,
  value: String,
});
</script>

<style scoped>
.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

label {
  font-size: 14px;
  color: gray;
}

input {
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ddd;
}

input:focus {
  outline: none;
  border-color: #ea580c;
}
</style>

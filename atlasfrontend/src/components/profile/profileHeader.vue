<!-- ProfileHeader.vue -->
<template>
  <div class="header">
    <div class="left">
      <div class="avatar">
        <img src="https://i.pravatar.cc/150" />
        <span class="edit">✎</span>
      </div>

      <div class="info">
        <h2>Marie Dupont</h2>
        <p>📧 marie.dupont@email.com</p>
        <p>📞 +33 6 12 34 56 78</p>
        <p>📍 15 Rue de la République, Paris</p>
      </div>
    </div>

    <div class="stats">
      <div class="stat">
        <div class="icon">📄</div>
        <div class="value">12</div>
        <div class="label">Demandes</div>
      </div>

      <div class="stat">
        <div class="icon">✅</div>
        <div class="value">8</div>
        <div class="label">Projets terminés</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.header {
  background: linear-gradient(to bottom, #ea580c, #fb923c);
  color: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);

  display: flex;
  justify-content: space-between;
}

.left {
  display: flex;
  gap: 20px;
}

.avatar {
  position: relative;
}

.avatar img {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 4px solid white;
  object-fit: cover;
}

.edit {
  position: absolute;
  bottom: 0;
  right: 0;
  background: white;
  color: #ea580c;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.info h2 {
  margin-bottom: 8px;
}

.stats {
  display: flex;
  gap: 40px;
}

.stat {
  text-align: center;
}

.icon {
  background: rgba(255, 255, 255, 0.2);
  width: 45px;
  height: 45px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: auto;
  margin-bottom: 8px;
}
</style>

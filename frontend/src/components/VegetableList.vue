<script setup>
defineProps({
  grouped: Array,
  monthName: String,
  total: Number,
  loading: Boolean,
})
</script>

<template>
  <div v-if="loading" class="loading">Loading…</div>

  <template v-else-if="total === 0">
    <div class="empty-state">
      <div class="icon">🌨️</div>
      <p>Nothing to seed in {{ monthName }}. Time to plan!</p>
    </div>
  </template>

  <template v-else>
    <div class="results-header">
      Seed in <span>{{ monthName }}</span> — {{ total }} crop{{ total !== 1 ? 's' : '' }}
    </div>

    <div v-for="group in grouped" :key="group.category" class="category-section">
      <div class="category-title">{{ group.category }}</div>
      <div class="veg-grid">
        <div v-for="veg in group.items" :key="veg.id" class="veg-card">
          <span class="veg-emoji">{{ veg.emoji ?? '🌱' }}</span>
          <span>{{ veg.name }}</span>
        </div>
      </div>
    </div>
  </template>
</template>

<style scoped>
.results-header {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--green-dark);
  margin-bottom: 1.25rem;
}

.results-header span { color: var(--green-mid); }

.category-section { margin-bottom: 1.75rem; }

.category-title {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.6rem;
  padding-left: 0.25rem;
}

.veg-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.6rem;
}

.veg-card {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.7rem 0.9rem;
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  font-size: 0.9rem;
  font-weight: 500;
}

.veg-emoji { font-size: 1.2rem; flex-shrink: 0; }

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--text-muted);
}

.empty-state .icon { font-size: 3rem; margin-bottom: 0.75rem; }

.loading { text-align: center; padding: 3rem; color: var(--text-muted); }
</style>

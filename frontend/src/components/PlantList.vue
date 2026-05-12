<script setup>
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const props = defineProps({
  grouped:   Array,
  monthName: String,
  total:     Number,
  loading:   Boolean,
  gardenIds: Set,
  query:     { type: String, default: '' },
})

const emit = defineEmits(['toggle-garden'])

const router = useRouter()
const { t, te } = useI18n()

const plantName = (plant) => {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}
</script>

<template>
  <div v-if="loading" class="loading">{{ t('loading') }}</div>

  <template v-else-if="total === 0 && query">
    <div class="empty-state">
      <div class="icon">🔍</div>
      <p>{{ monthName ? t('noSearchResults', { query }) : t('noSearchResultsAll', { query }) }}</p>
    </div>
  </template>

  <template v-else-if="total === 0">
    <div class="empty-state">
      <div class="icon">🌨️</div>
      <p>{{ t('noCrops', { month: monthName }) }}</p>
    </div>
  </template>

  <template v-else>
    <div class="results-header">
      {{ monthName ? t('seedIn', { month: monthName }) : t('allPlants') }} — {{ t('cropCount', { n: total }) }}
    </div>

    <div v-for="group in grouped" :key="group.category" class="category-section">
      <div class="category-title">{{ t(`categories.${group.category}`) }}</div>
      <div class="plant-grid">
        <div
          v-for="plant in group.items"
          :key="plant.id"
          class="plant-card"
          @click="router.push(`/plant/${plant.id}`)"
        >
          <span class="plant-emoji">{{ plant.emoji ?? '🌱' }}</span>
          <span class="plant-name">{{ plantName(plant) }}</span>
          <button
            class="garden-btn"
            :class="{ added: gardenIds?.has(plant.id) }"
            :title="gardenIds?.has(plant.id) ? t('garden.removeTooltip') : t('garden.addTooltip')"
            @click.stop="emit('toggle-garden', plant.id)"
          >
            {{ gardenIds?.has(plant.id) ? '✓' : '+' }}
          </button>
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

.plant-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.6rem;
}

.plant-card {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.7rem 0.9rem;
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.plant-card:hover {
  border-color: var(--green-light);
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.plant-emoji { font-size: 1.2rem; flex-shrink: 0; }
.plant-name  { flex: 1; min-width: 0; }

.garden-btn {
  flex-shrink: 0;
  width: 1.5rem;
  height: 1.5rem;
  border-radius: 50%;
  border: 1.5px solid var(--green-pale);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.95rem;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}

@media (pointer: coarse) {
  .garden-btn {
    width: 2.5rem;
    height: 2.5rem;
    font-size: 1.1rem;
  }
}

.garden-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-mid);
}

.garden-btn.added {
  background: var(--green-mid);
  border-color: var(--green-mid);
  color: #fff;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--text-muted);
}

.empty-state .icon { font-size: 3rem; margin-bottom: 0.75rem; }

.loading { text-align: center; padding: 3rem; color: var(--text-muted); }
</style>

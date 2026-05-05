<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const route  = useRoute()
const router = useRouter()
const { t, tm, te } = useI18n()

const vegetable = ref(null)
const loading   = ref(true)
const inGarden  = ref(false)

const months = computed(() => tm('months'))

const localName = computed(() => {
  if (!vegetable.value) return ''
  const key = `vegetables.${vegetable.value.name}`
  return te(key) ? t(key) : vegetable.value.name
})

const description = computed(() => {
  if (!vegetable.value) return ''
  return t(`descriptions.${vegetable.value.name}`)
})

async function toggleGarden() {
  const method = inGarden.value ? 'DELETE' : 'PUT'
  await fetch(`/api/garden/${route.params.id}`, { method })
  inGarden.value = !inGarden.value
}

onMounted(async () => {
  const [vegRes, gardenRes] = await Promise.all([
    fetch(`/api/vegetables/${route.params.id}`),
    fetch('/api/garden'),
  ])
  if (vegRes.ok) vegetable.value = await vegRes.json()
  if (gardenRes.ok) {
    const ids = await gardenRes.json()
    inGarden.value = ids.includes(route.params.id)
  }
  loading.value = false
})
</script>

<template>
  <main>
    <button class="back-btn" @click="router.back()">{{ t('back') }}</button>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="vegetable">
      <div class="detail-card">
        <div class="detail-hero">
          <span class="detail-emoji">{{ vegetable.emoji ?? '🌱' }}</span>
          <div class="detail-hero-text">
            <h2>{{ localName }}</h2>
            <span class="category-badge">{{ t(`categories.${vegetable.category}`) }}</span>
          </div>
          <button
            class="garden-btn"
            :class="{ added: inGarden }"
            @click="toggleGarden"
          >
            {{ inGarden ? '✓ In my garden' : '+ Add to my garden' }}
          </button>
        </div>

        <p class="description">{{ description }}</p>

        <div class="months-section">
          <h3>{{ t('seedingMonths') }}</h3>
          <div class="months-grid">
            <div
              v-for="(name, i) in months"
              :key="i"
              class="month-chip"
              :class="{ active: vegetable.seedingMonths.includes(i + 1) }"
            >
              {{ name }}
            </div>
          </div>
        </div>

        <div class="months-section">
          <h3>{{ t('harvestingMonths') }}</h3>
          <div class="months-grid">
            <div
              v-for="(name, i) in months"
              :key="i"
              class="month-chip harvest"
              :class="{ active: vegetable.harvestingMonths.includes(i + 1) }"
            >
              {{ name }}
            </div>
          </div>
        </div>
      </div>
    </template>
  </main>
</template>

<style scoped>
main {
  max-width: 860px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

.back-btn {
  background: none;
  border: none;
  color: var(--green-mid);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  margin-bottom: 1.5rem;
  display: block;
}

.back-btn:hover { color: var(--green-dark); }

.detail-card {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.detail-hero {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  flex-wrap: wrap;
}

.detail-hero-text { flex: 1; }

.detail-emoji { font-size: 3.5rem; line-height: 1; }

.detail-hero h2 {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 0.35rem;
}

.category-badge {
  display: inline-block;
  padding: 0.2rem 0.65rem;
  background: var(--green-pale);
  color: var(--green-mid);
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.description {
  font-size: 1rem;
  line-height: 1.6;
  color: var(--text-muted);
  border-top: 1px solid var(--green-pale);
  padding-top: 1.5rem;
}

.months-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.months-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.75rem;
}

.months-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 0.4rem;
}

@media (max-width: 480px) {
  .months-grid { grid-template-columns: repeat(4, 1fr); }
}

.month-chip {
  padding: 0.45rem 0.25rem;
  text-align: center;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  background: var(--bg);
  color: var(--text-muted);
}

.month-chip.active {
  background: var(--green-mid);
  color: #fff;
}

.month-chip.harvest.active {
  background: #d97706;
  color: #fff;
}

.garden-btn {
  padding: 0.5rem 1rem;
  border-radius: var(--radius);
  border: 1.5px solid var(--green-pale);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
  white-space: nowrap;
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

.loading { text-align: center; padding: 3rem; color: var(--text-muted); }
</style>

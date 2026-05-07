<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import MonthSelector from '../components/MonthSelector.vue'
import VegetableList from '../components/VegetableList.vue'
import { csrfHeaders } from '../stores/auth.js'

const CATEGORY_ORDER = ['Fruiting', 'Leafy', 'Brassica', 'Root', 'Legume', 'Herb']

const { t, tm, te } = useI18n()
const route  = useRoute()
const router = useRouter()

const selectedMonth = ref(null)
const counts        = ref({})
const vegetables    = ref([])
const loading       = ref(false)
const gardenIds     = ref(new Set())
const query         = ref(route.query.q ?? '')

const months = computed(() => tm('months'))

const grouped = computed(() => {
  const q = query.value.trim().toLowerCase()
  const filtered = q
    ? vegetables.value.filter(v => {
        const key = `vegetables.${v.name}`
        const localised = te(key) ? t(key) : v.name
        return localised.toLowerCase().includes(q) || v.name.toLowerCase().includes(q)
      })
    : vegetables.value

  const g = {}
  for (const v of filtered) {
    if (!g[v.category]) g[v.category] = []
    g[v.category].push(v)
  }
  return CATEGORY_ORDER.filter(c => g[c]).map(c => ({ category: c, items: g[c] }))
})

const filteredTotal = computed(() => grouped.value.reduce((sum, g) => sum + g.items.length, 0))

async function fetchCounts() {
  const res = await fetch('/api/vegetables/counts')
  counts.value = await res.json()
}

async function fetchGarden() {
  const res = await fetch('/api/garden')
  gardenIds.value = new Set(await res.json())
}

async function toggleGarden(vegetableId) {
  const inGarden = gardenIds.value.has(vegetableId)
  const method = inGarden ? 'DELETE' : 'PUT'
  await fetch(`/api/garden/${vegetableId}`, { method, headers: csrfHeaders() })
  const next = new Set(gardenIds.value)
  inGarden ? next.delete(vegetableId) : next.add(vegetableId)
  gardenIds.value = next
}

async function fetchVegetables(month) {
  loading.value = true
  const url = month ? `/api/vegetables?month=${month}` : '/api/vegetables'
  const res = await fetch(url)
  vegetables.value = await res.json()
  loading.value = false
}

watch(selectedMonth, month => fetchVegetables(month))

watch(query, q => {
  router.replace({ query: q ? { q } : {} })
})

onMounted(() => {
  fetchCounts()
  fetchVegetables(selectedMonth.value)
  fetchGarden()
})
</script>

<template>
  <div class="home-header">
    <p>{{ t('tagline') }}</p>
  </div>
  <main>
    <MonthSelector
      :months="months"
      :counts="counts"
      :selected="selectedMonth"
      @select="selectedMonth = $event"
    />
    <div class="search-bar">
      <input
        v-model="query"
        type="search"
        :placeholder="t('search')"
        class="search-input"
      />
    </div>
    <VegetableList
      :grouped="grouped"
      :month-name="selectedMonth ? months[selectedMonth - 1] : null"
      :total="filteredTotal"
      :loading="loading"
      :garden-ids="gardenIds"
      :query="query"
      @toggle-garden="toggleGarden"
    />
  </main>
</template>

<style scoped>
.home-header {
  background: var(--green-dark);
  padding: 0 1.5rem 1rem;
  text-align: center;
}

.home-header p { color: var(--green-light); font-size: 0.95rem; }

main { max-width: 860px; margin: 0 auto; padding: 2rem 1rem 4rem; }

.search-bar { margin-bottom: 1.5rem; }

.search-input {
  width: 100%;
  padding: 0.6rem 1rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  font-size: 0.95rem;
  color: var(--text);
  outline: none;
  transition: border-color 0.15s;
}

.search-input::placeholder { color: var(--text-muted); }
.search-input:focus { border-color: var(--green-mid); }
</style>

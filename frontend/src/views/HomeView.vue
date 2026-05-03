<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import MonthSelector from '../components/MonthSelector.vue'
import VegetableList from '../components/VegetableList.vue'

const CATEGORY_ORDER = ['Fruiting', 'Leafy', 'Brassica', 'Root', 'Legume', 'Herb']

const { t, tm } = useI18n()

const selectedMonth = ref(new Date().getMonth() + 1)
const counts        = ref({})
const vegetables    = ref([])
const loading       = ref(false)

const months = computed(() => tm('months'))

const grouped = computed(() => {
  const g = {}
  for (const v of vegetables.value) {
    if (!g[v.category]) g[v.category] = []
    g[v.category].push(v)
  }
  return CATEGORY_ORDER.filter(c => g[c]).map(c => ({ category: c, items: g[c] }))
})

async function fetchCounts() {
  const res = await fetch('/api/vegetables/counts')
  counts.value = await res.json()
}

async function fetchVegetables(month) {
  loading.value = true
  const res = await fetch(`/api/vegetables?month=${month}`)
  vegetables.value = await res.json()
  loading.value = false
}

watch(selectedMonth, month => fetchVegetables(month))

onMounted(() => {
  fetchCounts()
  fetchVegetables(selectedMonth.value)
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
    <VegetableList
      :grouped="grouped"
      :month-name="months[selectedMonth - 1]"
      :total="vegetables.length"
      :loading="loading"
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
</style>

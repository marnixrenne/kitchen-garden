<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import MonthSelector from './components/MonthSelector.vue'
import VegetableList from './components/VegetableList.vue'

const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
const CATEGORY_ORDER = ['Fruiting', 'Leafy', 'Brassica', 'Root', 'Legume', 'Herb']

const selectedMonth = ref(new Date().getMonth() + 1)
const counts = ref({})
const vegetables = ref([])
const loading = ref(false)

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
  <header>
    <h1>🌱 Kitchen Garden</h1>
    <p>Select a month to see which vegetables you can seed</p>
  </header>
  <main>
    <MonthSelector
      :months="MONTHS"
      :counts="counts"
      :selected="selectedMonth"
      @select="selectedMonth = $event"
    />
    <VegetableList
      :grouped="grouped"
      :month-name="MONTHS[selectedMonth - 1]"
      :total="vegetables.length"
      :loading="loading"
    />
  </main>
</template>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --green-dark:  #1b4332;
  --green-mid:   #2d6a4f;
  --green-light: #74c69d;
  --green-pale:  #d8f3dc;
  --bg:          #f4f1eb;
  --card-bg:     #ffffff;
  --text:        #1b4332;
  --text-muted:  #52796f;
  --radius:      10px;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
}

header {
  background: var(--green-dark);
  color: #fff;
  padding: 2rem 1.5rem 1.5rem;
  text-align: center;
}

header h1 { font-size: 2rem; font-weight: 700; }
header p  { margin-top: 0.4rem; color: var(--green-light); }

main { max-width: 860px; margin: 0 auto; padding: 2rem 1rem 4rem; }
</style>

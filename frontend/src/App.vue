<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import MonthSelector from './components/MonthSelector.vue'
import VegetableList from './components/VegetableList.vue'
import LoginForm from './components/LoginForm.vue'
import { user, checkAuth, logout } from './stores/auth.js'

const CATEGORY_ORDER = ['Fruiting', 'Leafy', 'Brassica', 'Root', 'Legume', 'Herb']

const { t, tm, locale } = useI18n()

const selectedMonth = ref(new Date().getMonth() + 1)
const counts        = ref({})
const vegetables    = ref([])
const loading       = ref(false)
const authChecked   = ref(false)

const months = computed(() => tm('months'))

const grouped = computed(() => {
  const g = {}
  for (const v of vegetables.value) {
    if (!g[v.category]) g[v.category] = []
    g[v.category].push(v)
  }
  return CATEGORY_ORDER.filter(c => g[c]).map(c => ({ category: c, items: g[c] }))
})

function switchLocale(lang) {
  locale.value = lang
  localStorage.setItem('locale', lang)
}

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

watch(user, (u) => {
  if (u) {
    fetchCounts()
    fetchVegetables(selectedMonth.value)
  }
})

onMounted(async () => {
  await checkAuth()
  authChecked.value = true
  if (user.value) {
    fetchCounts()
    fetchVegetables(selectedMonth.value)
  }
})
</script>

<template>
  <template v-if="!authChecked" />

  <LoginForm v-else-if="!user" />

  <template v-else>
    <header>
      <div class="header-top">
        <h1>🌱 Kitchen Garden</h1>
        <div class="header-controls">
          <span class="display-name">{{ user.username }}</span>
          <button class="logout-btn" @click="logout">{{ t('logout') }}</button>
          <div class="lang-switcher">
            <button :class="{ active: locale === 'en' }" @click="switchLocale('en')">EN</button>
            <button :class="{ active: locale === 'nl' }" @click="switchLocale('nl')">NL</button>
          </div>
        </div>
      </div>
      <p>{{ t('tagline') }}</p>
    </header>
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
  padding: 1.5rem 1.5rem 1.25rem;
}

.header-top {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.4rem;
}

header h1 { font-size: 2rem; font-weight: 700; }
header p  { color: var(--green-light); text-align: center; }

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-left: auto;
}

.display-name {
  font-size: 0.85rem;
  color: rgba(255,255,255,0.7);
}

.logout-btn {
  padding: 0.25rem 0.7rem;
  border: 1.5px solid rgba(255,255,255,0.3);
  border-radius: 6px;
  background: transparent;
  color: rgba(255,255,255,0.8);
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.logout-btn:hover {
  border-color: rgba(255,255,255,0.8);
  color: #fff;
}

.lang-switcher {
  display: flex;
  gap: 0.25rem;
}

.lang-switcher button {
  padding: 0.25rem 0.6rem;
  border: 1.5px solid rgba(255,255,255,0.3);
  border-radius: 6px;
  background: transparent;
  color: rgba(255,255,255,0.6);
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.lang-switcher button:hover {
  border-color: rgba(255,255,255,0.7);
  color: #fff;
}

.lang-switcher button.active {
  border-color: #fff;
  color: #fff;
}

main { max-width: 860px; margin: 0 auto; padding: 2rem 1rem 4rem; }
</style>

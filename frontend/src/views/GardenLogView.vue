<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { gardenParam, activeGardenId, activeGardenName } from '../stores/garden.js'

const router = useRouter()
const { t, te, locale } = useI18n()

const allEntries = ref([])
const loading    = ref(true)
const filter     = ref('')

function formatDate(iso) {
  return new Date(iso + 'T00:00:00').toLocaleDateString(locale.value, {
    day: 'numeric', month: 'short', year: 'numeric',
  })
}

function actionLabel(action) {
  const key = `garden.loggedAction.${action}`
  return te(key) ? t(key) : action
}

const filtered = computed(() => {
  const q = filter.value.trim().toLowerCase()
  if (!q) return allEntries.value
  return allEntries.value.filter(e =>
    e.plantName.toLowerCase().includes(q) ||
    actionLabel(e.action).toLowerCase().includes(q) ||
    (e.comment ?? '').toLowerCase().includes(q)
  )
})

async function load() {
  loading.value = true
  allEntries.value = []
  const param = gardenParam()
  const [detailsRes, instancesRes, logRes] = await Promise.all([
    fetch(`/api/garden/details${param}`),
    fetch(`/api/garden/instances${param}`),
    fetch('/api/garden/plant-log'),
  ])
  if (!detailsRes.ok || !instancesRes.ok || !logRes.ok) {
    loading.value = false
    return
  }
  const details   = await detailsRes.json()
  const instances = await instancesRes.json()
  const log       = await logRes.json()

  const plantById = {}
  for (const d of details) plantById[d.id] = d

  const instMap = {}
  for (const inst of instances) {
    const plant = plantById[inst.plantId]
    if (plant) instMap[inst.id] = plant
  }

  const flat = []
  for (const [instanceId, entries] of Object.entries(log)) {
    const plant = instMap[instanceId]
    if (!plant) continue
    const plantName = te(`plants.${plant.name}`) ? t(`plants.${plant.name}`) : plant.name
    for (const e of entries) {
      flat.push({
        id: e.id,
        plantId: plant.id,
        plantName,
        emoji: plant.emoji ?? '🌱',
        action: e.action,
        date: e.date,
        comment: e.comment,
      })
    }
  }

  flat.sort((a, b) => b.date.localeCompare(a.date))
  allEntries.value = flat
  loading.value = false
}

onMounted(load)
watch(activeGardenId, load)
</script>

<template>
  <main>
    <div class="page-header">
      <h2 class="page-title">{{ activeGardenName ?? t('myGarden') }}</h2>
    </div>

    <div class="garden-tabs">
      <RouterLink class="garden-tab" to="/garden">{{ t('garden.thisWeek') }}</RouterLink>
      <RouterLink class="garden-tab" :to="{ path: '/garden', query: { tab: 'calendar' } }">{{ t('garden.calendarTab') }}</RouterLink>
      <span class="garden-tab active">{{ t('garden.logNav') }}</span>
    </div>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else>
      <div class="log-filter-wrap">
        <input
          v-model="filter"
          class="log-filter"
          :placeholder="t('garden.logSearch')"
          type="search"
        />
      </div>

      <div v-if="allEntries.length === 0" class="empty">
        {{ t('garden.logEmpty') }}
      </div>

      <div v-else-if="filtered.length === 0" class="empty">
        {{ t('garden.logNoResults', { query: filter }) }}
      </div>

      <ul v-else class="log-list">
        <li v-for="entry in filtered" :key="entry.id" class="log-entry">
          <div class="log-entry-main">
            <button
              class="log-plant-name"
              @click="router.push(`/plant/${entry.plantId}`)"
            >
              <span class="log-plant-emoji">{{ entry.emoji }}</span>
              {{ entry.plantName }}
            </button>
            <span class="log-action-badge">{{ actionLabel(entry.action) }}</span>
            <span class="log-date">{{ formatDate(entry.date) }}</span>
          </div>
          <p v-if="entry.comment" class="log-comment">{{ entry.comment }}</p>
        </li>
      </ul>
    </template>
  </main>
</template>

<style scoped>
main { max-width: 960px; margin: 0 auto; padding: 1.5rem 1rem 4rem; }

.page-header { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.25rem; flex-wrap: wrap; }
.page-title  { font-size: 1.5rem; font-weight: 700; color: var(--green-dark); flex: 1; }

.garden-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid var(--green-pale);
}

.garden-tab {
  padding: .5rem 1.1rem;
  border: none;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  background: none;
  font: inherit;
  font-size: .875rem;
  font-weight: 600;
  color: var(--text-muted);
  cursor: pointer;
  text-decoration: none;
  transition: color .15s, border-color .15s;
  white-space: nowrap;
  display: inline-block;
}

.garden-tab:hover { color: var(--green-dark); }
.garden-tab.active { color: var(--green-dark); border-bottom-color: var(--green-mid); }

.log-filter-wrap { margin-bottom: 1.25rem; }
.log-filter {
  width: 100%;
  padding: .55rem .8rem;
  border: 1px solid #d0d0d0;
  border-radius: 8px;
  font-size: .95rem;
  background: var(--card-bg, #fff);
  color: inherit;
}
.log-filter:focus { outline: none; border-color: var(--green-mid, #52b788); }

.loading {
  color: var(--text-muted, #666);
  margin-top: 2rem;
  text-align: center;
}

.empty {
  color: var(--text-muted, #666);
  font-style: italic;
  margin-top: 2rem;
  text-align: center;
}

.log-list { list-style: none; display: flex; flex-direction: column; gap: .5rem; }

.log-entry {
  background: var(--card-bg, #fff);
  border: 1px solid #e4e4e4;
  border-radius: 10px;
  padding: .75rem 1rem;
}

.log-entry-main {
  display: flex;
  align-items: center;
  gap: .6rem;
  flex-wrap: wrap;
}

.log-plant-name {
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  font-weight: 600;
  color: var(--green-dark, #1b4332);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: .35rem;
}
.log-plant-name:hover { text-decoration: underline; }
.log-plant-emoji { font-size: 1.1rem; }

.log-action-badge {
  font-size: .78rem;
  font-weight: 600;
  padding: .2rem .55rem;
  border-radius: 20px;
  background: var(--green-pale, #d8f3dc);
  color: var(--green-dark, #1b4332);
}

.log-date {
  margin-left: auto;
  font-size: .85rem;
  color: var(--text-muted, #666);
  white-space: nowrap;
}

.log-comment {
  margin-top: .45rem;
  font-size: .88rem;
  color: var(--text-muted, #666);
  padding-left: 1.6rem;
}
</style>

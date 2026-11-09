<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { moveDescription } from '../utils/zones.js'

const props = defineProps({
  plants:    { type: Array,  required: true },
  instances: { type: Array,  required: true },
  plantLog:  { type: Object, required: true },
  zoneId:    { type: String, default: null },
})
const emit = defineEmits(['edit-move'])

const query = defineModel('query', { type: String, required: true })

const router = useRouter()
const { t, te, locale } = useI18n()

function plantName(plant) {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

function actionLabel(action) {
  const key = `garden.loggedAction.${action}`
  return te(key) ? t(key) : action
}

function formatLogDate(iso) {
  return new Date(iso + 'T00:00:00').toLocaleDateString(locale.value, {
    day: 'numeric', month: 'short', year: 'numeric',
  })
}

const logEntries = computed(() => {
  const plantById = {}
  for (const p of props.plants) plantById[p.id] = p
  const flat = []
  for (const inst of props.instances) {
    if (props.zoneId && inst.zoneId !== props.zoneId) continue
    const plant = plantById[inst.plantId]
    if (!plant) continue
    const name = plantName(plant)
    for (const e of (props.plantLog[inst.id] ?? [])) {
      flat.push({ ...e, plantId: plant.id, plantName: name, emoji: plant.emoji ?? '🌱' })
    }
  }
  flat.sort((a, b) => b.date.localeCompare(a.date))
  return flat
})

const filteredLogEntries = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return logEntries.value
  return logEntries.value.filter(e =>
    e.plantName.toLowerCase().includes(q) ||
    actionLabel(e.action).toLowerCase().includes(q) ||
    (e.action === 'moved' && moveDescription(t, e).toLowerCase().includes(q)) ||
    (e.comment ?? '').toLowerCase().includes(q)
  )
})
</script>

<template>
  <div class="log-filter-wrap">
    <input
      v-model="query"
      class="log-filter"
      :placeholder="t('garden.logSearch')"
      type="search"
    />
  </div>
  <div v-if="logEntries.length === 0" class="empty">
    {{ t('garden.logEmpty') }}
  </div>
  <div v-else-if="filteredLogEntries.length === 0" class="empty">
    {{ t('garden.logNoResults', { query }) }}
  </div>
  <ul v-else class="log-list">
    <li v-for="entry in filteredLogEntries" :key="entry.id" class="log-entry-item">
      <div class="log-entry-main">
        <button class="log-plant-name" @click="router.push(`/plant/${entry.plantId}`)">
          <span class="log-plant-emoji">{{ entry.emoji }}</span>
          {{ entry.plantName }}
        </button>
        <span class="log-action-badge">{{ actionLabel(entry.action) }}</span>
        <span v-if="entry.action === 'moved'" class="log-move">{{ moveDescription(t, entry) }}</span>
        <span class="log-date">{{ formatLogDate(entry.date) }}</span>
        <button
          v-if="entry.action === 'moved'"
          class="log-edit-btn"
          :title="t('zones.editEntry')"
          @click="emit('edit-move', entry)"
        >✎</button>
      </div>
      <p v-if="entry.comment" class="log-comment">{{ entry.comment }}</p>
    </li>
  </ul>
</template>

<style scoped>
.empty {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}

.log-filter-wrap { margin-bottom: 1.25rem; }

.log-filter {
  width: 100%;
  padding: .55rem .8rem;
  border: 1px solid #d0d0d0;
  border-radius: 8px;
  font-size: .95rem;
  background: var(--card-bg);
  color: inherit;
}

.log-filter:focus { outline: none; border-color: var(--green-mid); }

.log-list { list-style: none; display: flex; flex-direction: column; gap: .5rem; }

.log-entry-item {
  background: var(--card-bg);
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
  color: var(--green-dark);
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
  background: var(--green-pale);
  color: var(--green-dark);
}

.log-date {
  margin-left: auto;
  font-size: .85rem;
  color: var(--text-muted);
  white-space: nowrap;
}

.log-comment {
  margin-top: .45rem;
  font-size: .88rem;
  color: var(--text-muted);
  padding-left: 1.6rem;
}

.log-move { font-size: .85rem; color: var(--text-muted); }

.log-edit-btn {
  border: none;
  background: none;
  cursor: pointer;
  color: var(--text-muted);
  font-size: .9rem;
  padding: 0 .2rem;
}

.log-edit-btn:hover { color: var(--green-dark); }
</style>

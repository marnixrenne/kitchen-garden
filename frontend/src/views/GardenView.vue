<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import ThisWeekCard from '../components/ThisWeekCard.vue'
import { activeGardenName, activeGardenId, gardens, setActiveGarden } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { BED_TYPES, ASPECTS, SUN_LEVELS, MAX_DIMENSION_CM, bedLabel } from '../utils/beds.js'

const router = useRouter()
const route  = useRoute()
const { t, tm, te, locale } = useI18n()

function formatDate(isoDate) {
  return new Date(isoDate + 'T00:00:00').toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
}

const plants        = ref([])
const suggestions   = ref(null)
const loading       = ref(true)
const selectedMonth = ref(null)

const instances      = ref([])   // [{id: instanceId, plantId, bedId, sunShortfall}]
const beds           = ref([])   // creation order
const plantLog       = ref({})   // keyed by instanceId
const plantPlan      = ref({})   // keyed by instanceId
const lifecycle      = ref({})   // keyed by instanceId
const expandedPlants = ref(new Set())
const activeTab      = ref(
  route.query.tab === 'calendar' ? 'calendar' :
  route.query.tab === 'log'      ? 'log'      : 'week'
)

watch(() => route.query.tab, (tab) => {
  activeTab.value = tab === 'calendar' ? 'calendar' : tab === 'log' ? 'log' : 'week'
})

function setTab(tab) {
  activeTab.value = tab
  router.replace({ path: '/garden', query: tab === 'week' ? {} : { tab } })
}

const logFilter = ref('')

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
  for (const p of plants.value) plantById[p.id] = p
  const flat = []
  for (const inst of instances.value) {
    const plant = plantById[inst.plantId]
    if (!plant) continue
    const name = plantName(plant)
    for (const e of (plantLog.value[inst.id] ?? [])) {
      flat.push({ ...e, plantId: plant.id, plantName: name, emoji: plant.emoji ?? '🌱' })
    }
  }
  flat.sort((a, b) => b.date.localeCompare(a.date))
  return flat
})

const filteredLogEntries = computed(() => {
  const q = logFilter.value.trim().toLowerCase()
  if (!q) return logEntries.value
  return logEntries.value.filter(e =>
    e.plantName.toLowerCase().includes(q) ||
    actionLabel(e.action).toLowerCase().includes(q) ||
    (e.action === 'moved' && moveDescription(e).toLowerCase().includes(q)) ||
    (e.comment ?? '').toLowerCase().includes(q)
  )
})

const instancesByPlantId = computed(() => {
  const map = {}
  for (const inst of instances.value) {
    if (!map[inst.plantId]) map[inst.plantId] = []
    map[inst.plantId].push(inst.id)
  }
  return map
})

function lcForPlant(plantId) {
  for (const iid of (instancesByPlantId.value[plantId] ?? [])) {
    if (lifecycle.value[iid]) return lifecycle.value[iid]
  }
  return null
}

function dotTooltip(entry) {
  const action = te(`garden.loggedAction.${entry.action}`) ? t(`garden.loggedAction.${entry.action}`) : entry.action
  const date   = formatDate(entry.date)
  return entry.comment ? `${action} · ${date}\n${entry.comment}` : `${action} · ${date}`
}

function planDotTooltip(entry) {
  const action = te(`garden.planAction.${entry.action}`) ? t(`garden.planAction.${entry.action}`) : entry.action
  const start  = formatDate(entry.plannedDateStart)
  const end    = formatDate(entry.plannedDateEnd)
  return entry.plannedDateStart === entry.plannedDateEnd ? `${action} · ${start}` : `${action} · ${start} – ${end}`
}

function toggleExpand(plantId) {
  const s = new Set(expandedPlants.value)
  if (s.has(plantId)) s.delete(plantId)
  else s.add(plantId)
  expandedPlants.value = s
}

function entriesForMonth(plantId, month) {
  const iids = instancesByPlantId.value[plantId] ?? []
  return iids.flatMap(iid =>
    (plantLog.value[iid] ?? []).filter(e => new Date(e.date + 'T00:00:00').getMonth() + 1 === month)
  )
}

function planEntriesForMonth(plantId, month) {
  const iids = instancesByPlantId.value[plantId] ?? []
  return iids.flatMap(iid =>
    (plantPlan.value[iid] ?? []).filter(e => {
      const startM = new Date(e.plannedDateStart + 'T00:00:00').getMonth() + 1
      const endM   = new Date(e.plannedDateEnd   + 'T00:00:00').getMonth() + 1
      return startM <= endM
        ? month >= startM && month <= endM
        : month >= startM || month <= endM
    })
  )
}

function hasExpandContent(plantId) {
  const iids = instancesByPlantId.value[plantId] ?? []
  return iids.some(iid =>
    (plantLog.value[iid]?.length ?? 0) > 0 || (plantPlan.value[iid]?.length ?? 0) > 0
  )
}

async function fetchInstances() {
  const res = await fetch(`/api/gardens/${activeGardenId.value}/instances`)
  if (res.ok) instances.value = await res.json()
}

async function fetchBeds() {
  const res = await fetch(`/api/gardens/${activeGardenId.value}/beds`)
  if (res.ok) beds.value = await res.json()
}

async function fetchPlantLog() {
  const res = await fetch(`/api/gardens/${activeGardenId.value}/plant-log`)
  if (res.ok) plantLog.value = await res.json()
}

async function fetchPlantPlan() {
  const res = await fetch(`/api/gardens/${activeGardenId.value}/plan`)
  if (res.ok) plantPlan.value = await res.json()
}

async function fetchLifecycle() {
  const res = await fetch(`/api/gardens/${activeGardenId.value}/lifecycle`)
  if (res.ok) lifecycle.value = await res.json()
}

function isPlanEntryDone(plantId, entry) {
  const iids = instancesByPlantId.value[plantId] ?? []
  return iids.some(iid =>
    (plantLog.value[iid] ?? []).some(log =>
      log.action === entry.action &&
      log.date >= entry.plannedDateStart &&
      log.date <= entry.plannedDateEnd
    )
  )
}

// ── Beds ──────────────────────────────────────────────────────────────────────

// A plant is in a garden at most once, so each plant maps to a single instance
const instanceByPlantId = computed(() => {
  const map = {}
  for (const inst of instances.value) map[inst.plantId] = inst
  return map
})

const hasSeveralBeds = computed(() => beds.value.length > 1)

// With one bed the calendar looks as it did before beds existed: a single headerless group
const calendarGroups = computed(() => {
  if (!hasSeveralBeds.value) return [{ bed: null, plants: sortedPlants.value }]
  return beds.value.map(bed => ({
    bed,
    plants: sortedPlants.value.filter(p => instanceByPlantId.value[p.id]?.bedId === bed.id),
  }))
})

function bedDetails(bed) {
  const parts = []
  if (bed.type)                  parts.push(t(`beds.type.${bed.type}`))
  if (bed.lengthCm && bed.widthCm) parts.push(t('beds.dimensionsValue', { length: bed.lengthCm, width: bed.widthCm }))
  else if (bed.lengthCm || bed.widthCm) parts.push(`${bed.lengthCm ?? bed.widthCm} cm`)
  if (bed.sunExposure)           parts.push(t(`sunRequirement.${bed.sunExposure}`))
  if (bed.aspect)                parts.push(t('beds.facing', { aspect: t(`beds.aspect.${bed.aspect}`) }))
  return parts.join(' · ')
}

function todayIso() {
  return new Date().toISOString().slice(0, 10)
}

async function errorText(res) {
  try { return (await res.json()).message || `Error ${res.status}` } catch { return `Error ${res.status}` }
}

// Create / edit bed

const bedModal = ref({ open: false })

function openBedModal(bed = null) {
  bedModal.value = {
    open: true,
    bed,
    name:        bed?.name ?? '',
    type:        bed?.type ?? '',
    lengthCm:    bed?.lengthCm ?? '',
    widthCm:     bed?.widthCm ?? '',
    sunExposure: bed?.sunExposure ?? '',
    aspect:      bed?.aspect ?? '',
    saving: false,
    error: '',
  }
}

function validDimension(value) {
  if (value === '' || value === null) return true
  const n = Number(value)
  return Number.isInteger(n) && n >= 1 && n <= MAX_DIMENSION_CM
}

// The unnamed bed a garden starts with may stay unnamed; every other bed needs a name
const bedFormError = computed(() => {
  const m = bedModal.value
  if (!m.open) return ''
  const mayStayUnnamed = m.bed && m.bed.name === null
  if (!m.name.trim() && !mayStayUnnamed) return t('beds.nameRequired')
  if (!validDimension(m.lengthCm) || !validDimension(m.widthCm)) return t('beds.dimensionsInvalid', { max: MAX_DIMENSION_CM })
  return ''
})

async function saveBed() {
  const m = bedModal.value
  if (bedFormError.value || m.saving) return
  m.saving = true
  m.error = ''
  const body = {
    name:        m.name.trim() || null,
    type:        m.type || null,
    lengthCm:    m.lengthCm === '' ? null : Number(m.lengthCm),
    widthCm:     m.widthCm === '' ? null : Number(m.widthCm),
    sunExposure: m.sunExposure || null,
    aspect:      m.aspect || null,
  }
  const res = await fetch(
    m.bed ? `/api/gardens/${activeGardenId.value}/beds/${m.bed.id}` : `/api/gardens/${activeGardenId.value}/beds`,
    { method: m.bed ? 'PUT' : 'POST', headers: { 'Content-Type': 'application/json', ...csrfHeaders() }, body: JSON.stringify(body) },
  )
  m.saving = false
  if (!res.ok) { m.error = await errorText(res); return }
  m.open = false
  // A bed's sun exposure changes the instances' sun warnings
  await Promise.all([fetchBeds(), fetchInstances()])
}

// Delete bed

const deleteBedModal = ref({ open: false })

function plantsInBed(bed) {
  return instances.value.filter(i => i.bedId === bed.id).length
}

function openDeleteBedModal(bed) {
  const others = beds.value.filter(b => b.id !== bed.id)
  deleteBedModal.value = {
    open: true,
    bed,
    plantCount: plantsInBed(bed),
    disposition: 'move',
    targetBedId: others[0]?.id ?? null,
    deleting: false,
    error: '',
  }
}

async function confirmDeleteBed() {
  const m = deleteBedModal.value
  if (m.deleting) return
  const params = m.plantCount === 0 ? ''
    : m.disposition === 'move' ? `?plants=move&targetBedId=${m.targetBedId}`
    : '?plants=delete'
  m.deleting = true
  m.error = ''
  const res = await fetch(`/api/gardens/${activeGardenId.value}/beds/${m.bed.id}${params}`, {
    method: 'DELETE',
    headers: csrfHeaders(),
  })
  m.deleting = false
  if (!res.ok) { m.error = await errorText(res); return }
  m.open = false
  if (m.plantCount > 0 && m.disposition === 'delete') await loadAll()
  else await Promise.all([fetchBeds(), fetchInstances(), fetchPlantLog()])
}

// Move a plant

const moveModal = ref({ open: false })

function openMoveModal(plant) {
  const instance = instanceByPlantId.value[plant.id]
  if (!instance) return
  moveModal.value = { open: true, plant, instance, bedId: null, date: todayIso(), comment: '', saving: false, error: '' }
}

const moveTargets = computed(() =>
  moveModal.value.open ? beds.value.filter(b => b.id !== moveModal.value.instance.bedId) : []
)

async function confirmMove() {
  const m = moveModal.value
  if (!m.bedId || m.saving) return
  m.saving = true
  m.error = ''
  const res = await fetch(`/api/gardens/${activeGardenId.value}/instances/${m.instance.id}/move`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ bedId: m.bedId, date: m.date || null, comment: m.comment.trim() || null }),
  })
  m.saving = false
  if (!res.ok) { m.error = await errorText(res); return }
  m.open = false
  await Promise.all([fetchInstances(), fetchPlantLog()])
}

// Edit a move log entry: only its date and comment can change

const entryModal = ref({ open: false })

function openEntryModal(entry) {
  entryModal.value = { open: true, entry, date: entry.date, comment: entry.comment ?? '', saving: false, error: '' }
}

async function saveEntry() {
  const m = entryModal.value
  if (!m.date || m.saving) return
  m.saving = true
  m.error = ''
  const res = await fetch(`/api/gardens/${activeGardenId.value}/plant-log/${m.entry.id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ date: m.date, comment: m.comment.trim() || null }),
  })
  m.saving = false
  if (!res.ok) { m.error = await errorText(res); return }
  m.open = false
  await fetchPlantLog()
}

function moveDescription(entry) {
  return t('beds.movedFromTo', { from: bedLabel(t, entry.fromBedName), to: bedLabel(t, entry.toBedName) })
}

const months = computed(() => tm('months'))
const sortedPlants = computed(() =>
  [...plants.value].sort((a, b) => plantName(a).localeCompare(plantName(b)))
)

function cellType(plant, month) {
  const sow     = plant.seedingMonths.includes(month)
  const harvest = plant.harvestingMonths.includes(month)
  if (sow && harvest) return 'both'
  if (sow)            return 'sow'
  if (harvest)        return 'harvest'
  return null
}

const sowingMonthSet = computed(() => {
  const s = new Set()
  for (const p of sortedPlants.value) for (const m of p.seedingMonths) s.add(m)
  return s
})
const harvestingMonthSet = computed(() => {
  const s = new Set()
  for (const p of sortedPlants.value) for (const m of p.harvestingMonths) s.add(m)
  return s
})

const toSow     = computed(() => selectedMonth.value == null ? [] :
  sortedPlants.value.filter(v => v.seedingMonths.includes(selectedMonth.value)))
const toHarvest = computed(() => selectedMonth.value == null ? [] :
  sortedPlants.value.filter(v => v.harvestingMonths.includes(selectedMonth.value)))

function selectMonth(month) {
  selectedMonth.value = selectedMonth.value === month ? null : month
}

function icalDate(year, month) {
  const next = month === 12 ? `${year + 1}0101` : `${year}${String(month + 1).padStart(2, '0')}01`
  return {
    start: `${year}${String(month).padStart(2, '0')}01`,
    end: next,
  }
}

function icalFold(line) {
  // iCal spec: fold lines at 75 octets
  const out = []
  while (line.length > 75) {
    out.push(line.slice(0, 75))
    line = ' ' + line.slice(75)
  }
  out.push(line)
  return out.join('\r\n')
}

function downloadIcal() {
  const year = new Date().getFullYear()
  const crlf = '\r\n'
  const lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    `PRODID:-//Kitchen Garden//EN`,
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
  ]

  for (let m = 1; m <= 12; m++) {
    const { start, end } = icalDate(year, m)
    const sowList     = sortedPlants.value.filter(v => v.seedingMonths.includes(m)).map(plantName)
    const harvestList = sortedPlants.value.filter(v => v.harvestingMonths.includes(m)).map(plantName)

    if (sowList.length > 0) {
      lines.push('BEGIN:VEVENT')
      lines.push(`UID:kg-sow-${year}-${m}@kitchengarden`)
      lines.push(`DTSTART;VALUE=DATE:${start}`)
      lines.push(`DTEND;VALUE=DATE:${end}`)
      lines.push(icalFold(`SUMMARY:🌱 ${t('garden.toSow')}: ${sowList.join(', ')}`))
      lines.push('END:VEVENT')
    }

    if (harvestList.length > 0) {
      lines.push('BEGIN:VEVENT')
      lines.push(`UID:kg-harvest-${year}-${m}@kitchengarden`)
      lines.push(`DTSTART;VALUE=DATE:${start}`)
      lines.push(`DTEND;VALUE=DATE:${end}`)
      lines.push(icalFold(`SUMMARY:🧺 ${t('garden.toHarvest')}: ${harvestList.join(', ')}`))
      lines.push('END:VEVENT')
    }
  }

  lines.push('END:VCALENDAR')

  const blob = new Blob([lines.join(crlf) + crlf], { type: 'text/calendar;charset=utf-8' })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement('a')
  a.href     = url
  a.download = 'kitchen-garden.ics'
  a.click()
  setTimeout(() => URL.revokeObjectURL(url), 100)
}

function plantName(plant) {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

async function onWeekRefresh() {
  await Promise.all([fetchBeds(), fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
}

// ── Rename garden ─────────────────────────────────────────────────────────────

const editModal = ref({ open: false, name: '', saving: false })

function openEditModal() {
  editModal.value.name = activeGardenName.value ?? ''
  editModal.value.open = true
}

async function confirmRenameGarden() {
  const id = activeGardenId.value
  if (!id) return
  editModal.value.saving = true
  const res = await fetch(`/api/gardens/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ name: editModal.value.name.trim() }),
  })
  editModal.value.saving = false
  if (!res.ok) return
  const updated = await res.json()
  const idx = gardens.value.findIndex(g => g.id === id)
  if (idx !== -1) gardens.value[idx] = updated
  editModal.value.open = false
}

// ── Delete garden ─────────────────────────────────────────────────────────────

const deleteModal = ref({ open: false, deleting: false })

async function confirmDeleteGarden() {
  const id = activeGardenId.value
  if (!id) return
  deleteModal.value.deleting = true
  const res = await fetch(`/api/gardens/${id}`, {
    method: 'DELETE',
    headers: csrfHeaders(),
  })
  deleteModal.value.deleting = false
  if (!res.ok) return
  deleteModal.value.open = false
  const remaining = gardens.value.filter(g => g.id !== id)
  setActiveGarden(remaining.length > 0 ? remaining[0].id : null)
  gardens.value = remaining
  router.push(remaining.length > 0 ? '/garden' : '/discover')
}

async function loadAll() {
  loading.value = true
  plants.value = []
  suggestions.value = null
  instances.value = []
  beds.value = []
  plantLog.value = {}
  plantPlan.value = {}
  lifecycle.value = {}
  expandedPlants.value = new Set()
  const [detailsRes, suggestionsRes] = await Promise.all([
    fetch(`/api/gardens/${activeGardenId.value}/details`),
    fetch(`/api/gardens/${activeGardenId.value}/suggestions`),
  ])
  if (detailsRes.ok)     plants.value      = await detailsRes.json()
  if (suggestionsRes.ok) suggestions.value = await suggestionsRes.json()
  loading.value = false
  await Promise.all([fetchBeds(), fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
}

onMounted(loadAll)
watch(activeGardenId, loadAll)
</script>

<template>
  <main>
    <div class="page-header">
      <h2 class="page-title">{{ activeGardenName ?? t('myGarden') }}</h2>
      <div class="page-header-actions">
        <button class="edit-garden-btn" @click="openEditModal" :title="t('garden.editGarden')">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
          </svg>
        </button>
        <button class="delete-garden-btn" @click="deleteModal.open = true" :title="t('garden.deleteGarden')">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="3 6 5 6 21 6"/>
            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/>
            <line x1="10" y1="11" x2="10" y2="17"/>
            <line x1="14" y1="11" x2="14" y2="17"/>
          </svg>
        </button>
      </div>
    </div>

    <div class="garden-tabs">
      <button class="garden-tab" :class="{ active: activeTab === 'week' }" @click="setTab('week')">{{ t('garden.thisWeek') }}</button>
      <button class="garden-tab" :class="{ active: activeTab === 'calendar' }" @click="setTab('calendar')">{{ t('garden.calendarTab') }}</button>
      <button class="garden-tab" :class="{ active: activeTab === 'log' }" @click="setTab('log')">{{ t('garden.logNav') }}</button>
    </div>

    <div v-if="!loading && activeTab === 'calendar'" class="bed-toolbar">
      <button v-if="!hasSeveralBeds && beds.length === 1" class="bed-settings-link" @click="openBedModal(beds[0])">
        {{ t('beds.settings') }}
      </button>
      <button class="add-bed-btn" @click="openBedModal()">+ {{ t('beds.add') }}</button>
    </div>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="activeTab === 'log'">
      <div class="log-filter-wrap">
        <input
          v-model="logFilter"
          class="log-filter"
          :placeholder="t('garden.logSearch')"
          type="search"
        />
      </div>
      <div v-if="logEntries.length === 0" class="empty">
        {{ t('garden.logEmpty') }}
      </div>
      <div v-else-if="filteredLogEntries.length === 0" class="empty">
        {{ t('garden.logNoResults', { query: logFilter }) }}
      </div>
      <ul v-else class="log-list">
        <li v-for="entry in filteredLogEntries" :key="entry.id" class="log-entry-item">
          <div class="log-entry-main">
            <button class="log-plant-name" @click="router.push(`/plant/${entry.plantId}`)">
              <span class="log-plant-emoji">{{ entry.emoji }}</span>
              {{ entry.plantName }}
            </button>
            <span class="log-action-badge">{{ actionLabel(entry.action) }}</span>
            <span v-if="entry.action === 'moved'" class="log-move">{{ moveDescription(entry) }}</span>
            <span class="log-date">{{ formatLogDate(entry.date) }}</span>
            <button
              v-if="entry.action === 'moved'"
              class="log-edit-btn"
              :title="t('beds.editEntry')"
              @click="openEntryModal(entry)"
            >✎</button>
          </div>
          <p v-if="entry.comment" class="log-comment">{{ entry.comment }}</p>
        </li>
      </ul>
    </template>

    <template v-else-if="sortedPlants.length === 0">
      <p class="empty">{{ t('garden.empty') }}</p>
    </template>

    <template v-else>
      <!-- Calendar download -->
      <div v-if="activeTab === 'calendar'" class="calendar-top-bar">
        <button v-if="sortedPlants.length > 0" class="ical-btn" @click="downloadIcal">
          📅 {{ t('garden.addToCalendar') }}
        </button>
      </div>

      <!-- Legend -->
      <div v-if="activeTab === 'calendar'" class="legend">
        <span class="legend-item"><span class="legend-swatch sow" />{{ t('garden.toSow') }}</span>
        <span class="legend-item"><span class="legend-swatch harvest" />{{ t('garden.toHarvest') }}</span>
        <span class="legend-item"><span class="legend-swatch both" />{{ t('garden.both') }}</span>
      </div>

      <!-- Calendar -->
      <div v-if="activeTab === 'calendar'" class="calendar-wrap">
        <table class="calendar">
          <thead>
            <tr>
              <th scope="col" class="plant-col-header"></th>
              <th
                v-for="(name, i) in months"
                :key="i"
                scope="col"
                class="month-header"
                :class="{
                  selected:      selectedMonth === i + 1,
                  'has-sow':     sowingMonthSet.has(i + 1),
                  'has-harvest': harvestingMonthSet.has(i + 1),
                }"
                @click="selectMonth(i + 1)"
              >
                {{ name }}
              </th>
            </tr>
          </thead>
          <tbody>
            <template v-for="group in calendarGroups" :key="group.bed?.id ?? 'all'">
            <tr v-if="group.bed" class="bed-row">
              <td colspan="13">
                <div class="bed-row-inner">
                  <span class="bed-name">{{ bedLabel(t, group.bed.name) }}</span>
                  <span v-if="bedDetails(group.bed)" class="bed-details">{{ bedDetails(group.bed) }}</span>
                  <span v-if="group.plants.length === 0" class="bed-empty">{{ t('beds.empty') }}</span>
                  <span class="bed-actions">
                    <button class="bed-icon-btn" :title="t('beds.edit')" @click="openBedModal(group.bed)">✎</button>
                    <button class="bed-icon-btn danger" :title="t('beds.delete')" @click="openDeleteBedModal(group.bed)">🗑</button>
                  </span>
                </div>
              </td>
            </tr>
            <template v-for="plant in group.plants" :key="plant.id">
              <tr class="plant-row">
                <td
                  class="plant-name"
                  role="button"
                  tabindex="0"
                  @click="router.push(`/plant/${plant.id}`)"
                  @keydown.enter="router.push(`/plant/${plant.id}`)"
                >
                  <button
                    v-if="hasExpandContent(plant.id)"
                    class="expand-btn"
                    :class="{ open: expandedPlants.has(plant.id) }"
                    @click.stop="toggleExpand(plant.id)"
                    :aria-label="expandedPlants.has(plant.id) ? 'Collapse' : 'Expand'"
                  >{{ expandedPlants.has(plant.id) ? '−' : '+' }}</button>
                  <span v-else class="expand-btn-placeholder" />
                  <span class="plant-emoji">{{ plant.emoji ?? '🌱' }}</span>
                  <span>{{ plantName(plant) }}</span>
                  <span
                    v-if="instanceByPlantId[plant.id]?.sunShortfall"
                    class="sun-warning"
                    :title="t('beds.sunWarning')"
                    :aria-label="t('beds.sunWarning')"
                  >⚠️</span>
                  <span
                    v-if="lcForPlant(plant.id)"
                    class="lifecycle-badge"
                    :class="'lc-' + lcForPlant(plant.id).state"
                  >{{ te(`garden.lifecycle.${lcForPlant(plant.id).state}`) ? t(`garden.lifecycle.${lcForPlant(plant.id).state}`) : lcForPlant(plant.id).state }}</span>
                  <button
                    v-if="hasSeveralBeds && instanceByPlantId[plant.id]"
                    class="move-btn"
                    :class="{ 'push-right': !lcForPlant(plant.id) }"
                    :title="t('beds.moveToBed')"
                    @click.stop="openMoveModal(plant)"
                  >⇄</button>
                </td>
                <td
                  v-for="m in 12"
                  :key="m"
                  class="cal-cell"
                  :class="{
                    selected: selectedMonth === m,
                    [cellType(plant, m)]: cellType(plant, m) !== null,
                  }"
                >
                  <span v-if="cellType(plant, m)" class="cell-bar" :class="cellType(plant, m)" />
                </td>
              </tr>
              <tr
                v-if="hasExpandContent(plant.id) && expandedPlants.has(plant.id)"
                class="log-expand-row"
              >
                <td class="log-expand-name-cell" />
                <td
                  v-for="m in 12"
                  :key="m"
                  class="log-expand-month-cell"
                  :class="{ selected: selectedMonth === m }"
                >
                  <span
                    v-for="entry in entriesForMonth(plant.id, m)"
                    :key="entry.id"
                    class="log-entry-dot"
                    :title="dotTooltip(entry)"
                  />
                  <span
                    v-for="entry in planEntriesForMonth(plant.id, m)"
                    :key="entry.id"
                    :class="['plan-entry-dot', `plan-dot-${entry.action}`, { 'plan-dot-done': isPlanEntryDone(plant.id, entry) }]"
                    :title="planDotTooltip(entry)"
                  />
                </td>
              </tr>
            </template>
            </template>
          </tbody>
        </table>
      </div>

      <!-- Activity panel -->
      <div v-if="activeTab === 'calendar' && selectedMonth !== null" class="activity">
        <div v-if="toSow.length === 0 && toHarvest.length === 0" class="nothing">
          {{ t('garden.nothingThisMonth') }}
        </div>
        <template v-else>
          <div v-if="toSow.length > 0" class="section">
            <h3 class="section-title sow">🌱 {{ t('garden.toSow') }}</h3>
            <div class="plant-list">
              <div
                v-for="plant in toSow"
                :key="plant.id"
                class="plant-chip"
                role="button"
                tabindex="0"
                @click="router.push(`/plant/${plant.id}`)"
                @keydown.enter="router.push(`/plant/${plant.id}`)"
              >
                <span>{{ plant.emoji ?? '🌱' }}</span>
                <span>{{ plantName(plant) }}</span>
              </div>
            </div>
          </div>
          <div v-if="toHarvest.length > 0" class="section">
            <h3 class="section-title harvest">🧺 {{ t('garden.toHarvest') }}</h3>
            <div class="plant-list">
              <div
                v-for="plant in toHarvest"
                :key="plant.id"
                class="plant-chip"
                role="button"
                tabindex="0"
                @click="router.push(`/plant/${plant.id}`)"
                @keydown.enter="router.push(`/plant/${plant.id}`)"
              >
                <span>{{ plant.emoji ?? '🌱' }}</span>
                <span>{{ plantName(plant) }}</span>
              </div>
            </div>
          </div>
        </template>
      </div>
      <!-- This week -->
      <ThisWeekCard v-if="activeTab === 'week'" class="this-week-card" @refresh="onWeekRefresh" />

      <!-- Planting suggestions -->
      <div v-if="activeTab === 'calendar' && suggestions && (suggestions.sunGroups.length > 0 || suggestions.conflicts.length > 0)" class="suggestions">
        <h3 class="suggestions-title">{{ t('garden.suggestions') }}</h3>
        <p class="suggestions-hint">{{ t('garden.suggestionsHint') }}</p>

        <div class="sun-groups">
          <div v-for="group in suggestions.sunGroups" :key="group.sunRequirement" class="sun-group">
            <div class="sun-group-header">
              <span class="sun-label">{{ t(`sunRequirement.${group.sunRequirement}`) }}</span>
            </div>
            <div class="sun-group-plants">
              <div
                v-for="v in group.plants"
                :key="v.id"
                class="sg-chip"
                role="button"
                tabindex="0"
                @click="router.push(`/plant/${v.id}`)"
                @keydown.enter="router.push(`/plant/${v.id}`)"
              >
                {{ v.emoji ?? '🌱' }} {{ plantName(v) }}
              </div>
            </div>
            <div v-if="group.goodPairs.length > 0" class="good-pairs">
              <span class="pairs-label">{{ t('garden.goodTogether') }}:</span>
              <span v-for="pair in group.goodPairs" :key="pair.a.id + pair.b.id" class="pair">
                {{ pair.a.emoji ?? '🌱' }} {{ plantName(pair.a) }} + {{ pair.b.emoji ?? '🌱' }} {{ plantName(pair.b) }}
              </span>
            </div>
          </div>
        </div>

        <div v-if="suggestions.conflicts.length > 0" class="conflicts">
          <span class="conflicts-label">⚠️ {{ t('garden.keepApart') }}:</span>
          <span v-for="pair in suggestions.conflicts" :key="pair.a.id + pair.b.id" class="conflict-pair">
            {{ pair.a.emoji ?? '🌱' }} {{ plantName(pair.a) }} ↔ {{ pair.b.emoji ?? '🌱' }} {{ plantName(pair.b) }}
          </span>
        </div>
      </div>
    </template>
  </main>

  <Teleport to="body">
    <div v-if="editModal.open" class="dg-backdrop" @click.self="editModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('garden.editGarden') }}</div>
        <div class="dg-body">
          <input
            v-model="editModal.name"
            class="eg-input"
            :placeholder="t('garden.editGardenPlaceholder')"
            maxlength="100"
            @keydown.enter="confirmRenameGarden"
            @keydown.esc="editModal.open = false"
          />
          <div class="dg-actions">
            <button class="dg-cancel" @click="editModal.open = false" :disabled="editModal.saving">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="eg-save" @click="confirmRenameGarden" :disabled="editModal.saving || !editModal.name.trim()">
              {{ t('garden.editGardenSave') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="deleteModal.open" class="dg-backdrop" @click.self="deleteModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="dg-header">{{ t('garden.deleteGarden') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ t('garden.deleteGardenConfirm', { name: activeGardenName ?? t('myGarden') }) }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" @click="deleteModal.open = false" :disabled="deleteModal.deleting">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="dg-confirm" @click="confirmDeleteGarden" :disabled="deleteModal.deleting">
              {{ t('garden.deleteGardenConfirmBtn') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="bedModal.open" class="dg-backdrop" @click.self="bedModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ bedModal.bed ? t('beds.edit') : t('beds.add') }}</div>
        <div class="dg-body">
          <label class="bf-field">
            <span class="bf-label">{{ t('beds.name') }}</span>
            <input
              v-model="bedModal.name"
              class="eg-input"
              maxlength="100"
              :placeholder="bedModal.bed && bedModal.bed.name === null ? t('beds.mainBed') : t('beds.namePlaceholder')"
            />
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('beds.typeLabel') }}</span>
            <select v-model="bedModal.type" class="eg-input">
              <option value="">{{ t('beds.notSet') }}</option>
              <option v-for="type in BED_TYPES" :key="type" :value="type">{{ t(`beds.type.${type}`) }}</option>
            </select>
          </label>
          <div class="bf-row">
            <label class="bf-field">
              <span class="bf-label">{{ t('beds.lengthCm') }}</span>
              <input v-model="bedModal.lengthCm" class="eg-input" type="number" min="1" :max="MAX_DIMENSION_CM" step="1" />
            </label>
            <label class="bf-field">
              <span class="bf-label">{{ t('beds.widthCm') }}</span>
              <input v-model="bedModal.widthCm" class="eg-input" type="number" min="1" :max="MAX_DIMENSION_CM" step="1" />
            </label>
          </div>
          <div class="bf-row">
            <label class="bf-field">
              <span class="bf-label">{{ t('beds.sunLabel') }}</span>
              <select v-model="bedModal.sunExposure" class="eg-input">
                <option value="">{{ t('beds.notSet') }}</option>
                <option v-for="sun in SUN_LEVELS" :key="sun" :value="sun">{{ t(`sunRequirement.${sun}`) }}</option>
              </select>
            </label>
            <label class="bf-field">
              <span class="bf-label">{{ t('beds.aspectLabel') }}</span>
              <select v-model="bedModal.aspect" class="eg-input">
                <option value="">{{ t('beds.notSet') }}</option>
                <option v-for="aspect in ASPECTS" :key="aspect" :value="aspect">{{ t(`beds.aspect.${aspect}`) }}</option>
              </select>
            </label>
          </div>
          <p v-if="bedFormError || bedModal.error" class="bf-error">{{ bedModal.error || bedFormError }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" @click="bedModal.open = false" :disabled="bedModal.saving">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="eg-save" @click="saveBed" :disabled="bedModal.saving || !!bedFormError">
              {{ t('garden.editGardenSave') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="deleteBedModal.open" class="dg-backdrop" @click.self="deleteBedModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="dg-header">{{ t('beds.delete') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ t('beds.deleteConfirm', { name: bedLabel(t, deleteBedModal.bed.name) }) }}</p>
          <template v-if="deleteBedModal.plantCount > 0">
            <p class="dg-warning">{{ t('beds.deleteHasPlants', deleteBedModal.plantCount) }}</p>
            <label class="bf-radio">
              <input v-model="deleteBedModal.disposition" type="radio" value="move" />
              {{ t('beds.deleteMovePlants') }}
            </label>
            <select v-if="deleteBedModal.disposition === 'move'" v-model="deleteBedModal.targetBedId" class="eg-input">
              <option
                v-for="bed in beds.filter(b => b.id !== deleteBedModal.bed.id)"
                :key="bed.id"
                :value="bed.id"
              >{{ bedLabel(t, bed.name) }}</option>
            </select>
            <label class="bf-radio">
              <input v-model="deleteBedModal.disposition" type="radio" value="delete" />
              {{ t('beds.deleteRemovePlants') }}
            </label>
          </template>
          <p v-if="deleteBedModal.error" class="bf-error">{{ deleteBedModal.error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" @click="deleteBedModal.open = false" :disabled="deleteBedModal.deleting">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="dg-confirm" @click="confirmDeleteBed" :disabled="deleteBedModal.deleting">
              {{ t('beds.deleteConfirmBtn') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="moveModal.open" class="dg-backdrop" @click.self="moveModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('beds.moveTitle', { plant: plantName(moveModal.plant) }) }}</div>
        <div class="dg-body">
          <label class="bf-field">
            <span class="bf-label">{{ t('beds.moveTo') }}</span>
            <select v-model="moveModal.bedId" class="eg-input">
              <option :value="null" disabled>{{ t('beds.chooseBed') }}</option>
              <option v-for="bed in moveTargets" :key="bed.id" :value="bed.id">{{ bedLabel(t, bed.name) }}</option>
            </select>
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.dateLabel') }}</span>
            <input v-model="moveModal.date" class="eg-input" type="date" />
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.commentLabel') }}</span>
            <input v-model="moveModal.comment" class="eg-input" :placeholder="t('garden.seedModal.commentPlaceholder')" />
          </label>
          <p v-if="moveModal.error" class="bf-error">{{ moveModal.error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" @click="moveModal.open = false" :disabled="moveModal.saving">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="eg-save" @click="confirmMove" :disabled="moveModal.saving || !moveModal.bedId">
              {{ t('beds.moveConfirm') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="entryModal.open" class="dg-backdrop" @click.self="entryModal.open = false">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('beds.editEntry') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ moveDescription(entryModal.entry) }}</p>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.dateLabel') }}</span>
            <input v-model="entryModal.date" class="eg-input" type="date" />
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.commentLabel') }}</span>
            <input v-model="entryModal.comment" class="eg-input" :placeholder="t('garden.seedModal.commentPlaceholder')" />
          </label>
          <p v-if="entryModal.error" class="bf-error">{{ entryModal.error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" @click="entryModal.open = false" :disabled="entryModal.saving">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button class="eg-save" @click="saveEntry" :disabled="entryModal.saving || !entryModal.date">
              {{ t('garden.editGardenSave') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>

</template>

<style scoped>
main {
  --harvest-color: #d97706;
  max-width: 960px;
  margin: 0 auto;
  padding: 1.5rem 1rem 4rem;
}

.page-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.25rem;
  flex-wrap: wrap;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--green-dark);
  flex: 1;
}

.page-header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.edit-garden-btn {
  padding: 0.35rem 0.6rem;
  border: none;
  border-radius: var(--radius);
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background 0.15s;
}

.edit-garden-btn:hover { background: var(--green-dark); }

.delete-garden-btn {
  padding: 0.35rem 0.6rem;
  border: none;
  border-radius: var(--radius);
  background: #dc2626;
  color: #fff;
  font-size: 0.85rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background 0.15s;
}

.delete-garden-btn:hover { background: #b91c1c; }

/* Edit / rename garden modal */
.eg-header {
  padding: 0.85rem 1.25rem;
  background: var(--green-pale);
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--green-dark);
}

.eg-input {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  font-size: 0.9rem;
  color: var(--text);
  outline: none;
  box-sizing: border-box;
  transition: border-color 0.15s;
}

.eg-input:focus { border-color: var(--green-mid); }

.eg-save {
  padding: 0.4rem 1rem;
  border: none;
  border-radius: 8px;
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}

.eg-save:hover:not(:disabled) { background: var(--green-dark); }
.eg-save:disabled { opacity: 0.5; cursor: default; }

/* Delete garden modal */
.dg-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 1rem;
}

.dg-modal {
  background: #fff;
  border-radius: 10px;
  width: 100%;
  max-width: 380px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
  overflow: hidden;
}

.dg-header {
  padding: 0.85rem 1.25rem;
  background: #fee2e2;
  font-size: 0.875rem;
  font-weight: 700;
  color: #b91c1c;
}

.dg-body {
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.dg-warning {
  font-size: 0.9rem;
  color: var(--text);
  line-height: 1.5;
}

.dg-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.dg-cancel {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  background: #fff;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.dg-cancel:hover:not(:disabled) { border-color: var(--green-mid); color: var(--green-dark); }

.dg-confirm {
  padding: 0.4rem 1rem;
  border: none;
  border-radius: 8px;
  background: #dc2626;
  color: #fff;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.15s;
}

.dg-confirm:hover:not(:disabled) { opacity: 0.85; }
.dg-confirm:disabled, .dg-cancel:disabled { opacity: 0.45; cursor: not-allowed; }

.ical-btn {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  transition: border-color 0.15s, color 0.15s;
}

.ical-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-dark);
}

.garden-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid var(--green-pale);
}

.garden-tab {
  display: inline-block;
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
}

.garden-tab:hover { color: var(--green-dark); }
.garden-tab.active { color: var(--green-dark); border-bottom-color: var(--green-mid); }

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}

.this-week-card {
  margin-top: 1.5rem;
  margin-bottom: 1.5rem;
}

/* Calendar top bar */
.calendar-top-bar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 0.75rem;
}

/* Legend */
.legend {
  display: flex;
  gap: 1.25rem;
  margin-bottom: 1rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.8rem;
  color: var(--text-muted);
  font-weight: 600;
}

.legend-swatch {
  display: inline-block;
  width: 20px;
  height: 10px;
  border-radius: 4px;
}

.legend-swatch.sow     { background: var(--green-mid); }
.legend-swatch.harvest { background: var(--harvest-color); }
.legend-swatch.both    { background: linear-gradient(90deg, var(--green-mid) 50%, var(--harvest-color) 50%); }

/* Calendar */
.calendar-wrap {
  overflow-x: auto;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  margin-bottom: 1.5rem;
  -webkit-overflow-scrolling: touch;
}

@media (max-width: 700px) {
  .calendar-wrap::after {
    content: '← scroll →';
    display: block;
    text-align: center;
    font-size: 0.75rem;
    color: var(--text-muted);
    padding: 0.4rem;
    border-top: 1px solid var(--green-pale);
  }
}

.calendar {
  border-collapse: collapse;
  width: 100%;
  min-width: 640px;
}

.plant-col-header {
  width: 160px;
  min-width: 140px;
  text-align: left;
}

.month-header {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--text-muted);
  text-align: center;
  padding: 0.6rem 0.25rem;
  cursor: pointer;
  border-bottom: 2px solid var(--green-pale);
  white-space: nowrap;
  user-select: none;
  transition: background 0.15s, color 0.15s;
  position: relative;
}

.month-header::after {
  content: '';
  display: block;
  height: 3px;
  border-radius: 2px;
  margin-top: 4px;
}

.month-header.has-sow::after    { background: var(--green-mid); }
.month-header.has-harvest::after { background: var(--harvest-color); }
.month-header.has-sow.has-harvest::after {
  background: linear-gradient(90deg, var(--green-mid) 50%, var(--harvest-color) 50%);
}

.month-header:hover  { background: var(--bg); color: var(--green-dark); }
.month-header.selected { background: var(--green-pale); color: var(--green-dark); }

.plant-row:not(:last-child) td { border-bottom: 1px solid var(--green-pale); }

.plant-name {
  padding: 0.55rem 0.75rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--green-dark);
  white-space: nowrap;
  cursor: pointer;
  border-right: 1.5px solid var(--green-pale);
  display: flex;
  align-items: center;
  gap: 0.4rem;
  transition: background 0.15s;
  text-align: left;
}

.plant-name:hover { background: var(--bg); }

.expand-btn-placeholder {
  flex-shrink: 0;
  width: 1.1rem;
  height: 1.1rem;
}

.expand-btn {
  flex-shrink: 0;
  width: 1.1rem;
  height: 1.1rem;
  padding: 0;
  border: none;
  background: none;
  color: var(--green-mid);
  font-size: 0.85rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: -0.15rem;
}


.log-expand-row td { border-top: none; }

.log-expand-name-cell {
  background: var(--bg);
}

.log-expand-month-cell {
  text-align: center;
  padding: 0.25rem 0.2rem;
  background: var(--bg);
  border-bottom: 1px solid var(--green-pale);
}

.log-expand-month-cell.selected { background: rgba(216, 243, 220, 0.3); }

.log-entry-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--green-dark);
  opacity: 0.55;
  cursor: default;
  vertical-align: middle;
}

.log-entry-dot:hover {
  opacity: 1;
}

.plan-entry-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: 1.5px solid var(--harvest-color);
  background: transparent;
  opacity: 0.6;
  cursor: default;
  vertical-align: middle;
}

.plan-entry-dot:hover {
  opacity: 1;
}

.plan-dot-germination {
  border-color: var(--green-mid);
}

.plan-dot-pruning {
  border-color: #6d28d9;
}

.plan-dot-fertilizing {
  border-color: #92400e;
}

.plan-dot-watering {
  border-color: #0369a1;
}

.plan-dot-done {
  opacity: 0.3;
}

.plant-emoji { font-size: 1rem; }

.lifecycle-badge {
  font-size: 0.65rem;
  font-weight: 700;
  padding: 0.1rem 0.4rem;
  border-radius: 20px;
  white-space: nowrap;
  margin-left: auto;
}

.lc-seeded_indoor      { background: #f0fdf4; color: #166534; }
.lc-seeded_outdoor      { background: #f0fdf4; color: #166534; }
.lc-planted            { background: #f0fdf4; color: #166534; }
.lc-germinating_indoor { background: #dcfce7; color: #15803d; }
.lc-germinating_outdoor { background: #dcfce7; color: #15803d; }
.lc-transplanted       { background: #d1fae5; color: #065f46; }
.lc-growing            { background: #bbf7d0; color: #166534; }
.lc-ready_to_harvest   { background: #fef3c7; color: #92400e; }
.lc-harvested          { background: #f3f4f6; color: #6b7280; }

.cal-cell {
  padding: 0.3rem 0.2rem;
  text-align: center;
  vertical-align: middle;
  transition: background 0.15s;
}

.cal-cell.selected { background: rgba(216, 243, 220, 0.4); }

.cell-bar {
  display: block;
  height: 10px;
  border-radius: 5px;
  margin: 0 2px;
}

.cell-bar.sow     { background: var(--green-mid); }
.cell-bar.harvest { background: var(--harvest-color); }
.cell-bar.both    { background: linear-gradient(90deg, var(--green-mid) 50%, var(--harvest-color) 50%); }

/* Activity panel */
.activity {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.nothing {
  color: var(--text-muted);
  text-align: center;
  padding: 1rem 0;
}

.section { display: flex; flex-direction: column; gap: 0.75rem; }

.section-title {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.section-title.sow     { color: var(--green-mid); }
.section-title.harvest { color: var(--harvest-color); }

.plant-list { display: flex; flex-wrap: wrap; gap: 0.5rem; }

.plant-chip {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.4rem 0.75rem;
  background: var(--bg);
  border: 1.5px solid var(--green-pale);
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}

.plant-chip:hover {
  border-color: var(--green-light);
  background: var(--green-pale);
}

/* Suggestions */
.suggestions {
  margin-top: 1.5rem;
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 1.5rem;
}

.suggestions-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 0.4rem;
}

.suggestions-hint {
  font-size: 0.82rem;
  color: var(--text-muted);
  margin-bottom: 1.25rem;
  line-height: 1.5;
}

.sun-groups { display: flex; flex-direction: column; gap: 1rem; }

.sun-group {
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  overflow: hidden;
}

.sun-group-header {
  background: var(--bg);
  padding: 0.5rem 0.9rem;
  border-bottom: 1.5px solid var(--green-pale);
}

.sun-label {
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--text-muted);
}

.sun-group-plants {
  padding: 0.75rem 0.9rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.sg-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.25rem 0.65rem;
  background: var(--green-pale);
  color: var(--green-dark);
  border-radius: 20px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.15s;
}

.sg-chip:hover { opacity: 0.75; }

.good-pairs {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.4rem;
  padding: 0.5rem 0.9rem;
  border-top: 1px solid var(--green-pale);
  background: var(--green-pale);
}

.pairs-label {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--green-dark);
  white-space: nowrap;
}

.pair {
  font-size: 0.78rem;
  color: var(--green-dark);
  background: var(--bg);
  border: 1px solid var(--green-pale);
  border-radius: 20px;
  padding: 0.15rem 0.55rem;
}

.conflicts {
  --warn-bg: #fff7ed;
  --warn-border: #fed7aa;
  --warn-text: #9a3412;
  --warn-chip: #ffedd5;
  margin-top: 1rem;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 0.9rem;
  background: var(--warn-bg);
  border: 1.5px solid var(--warn-border);
  border-radius: var(--radius);
}

.conflicts-label {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--warn-text);
  white-space: nowrap;
}

.conflict-pair {
  font-size: 0.78rem;
  color: var(--warn-text);
  background: var(--warn-chip);
  border: 1px solid var(--warn-border);
  border-radius: 20px;
  padding: 0.15rem 0.55rem;
}

/* Log tab */
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

/* Beds */
.bed-toolbar {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.bed-settings-link {
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  font-size: 0.85rem;
  color: var(--green-mid);
  text-decoration: underline;
  cursor: pointer;
}

.add-bed-btn {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  color: var(--green-dark);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.add-bed-btn:hover { border-color: var(--green-mid); }

.bed-row td {
  background: var(--green-pale);
  padding: 0.45rem 0.75rem;
  border-bottom: 1px solid var(--green-pale);
}

.bed-row-inner {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.6rem;
}

.bed-name { font-size: 0.85rem; font-weight: 700; color: var(--green-dark); }
.bed-details, .bed-empty { font-size: 0.78rem; color: var(--text-muted); }
.bed-empty { font-style: italic; }
.bed-actions { margin-left: auto; display: flex; gap: 0.25rem; }

.bed-icon-btn {
  border: none;
  background: none;
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0.1rem 0.3rem;
  border-radius: 6px;
  color: var(--green-dark);
}

.bed-icon-btn:hover { background: rgba(255,255,255,0.6); }

.sun-warning { font-size: 0.8rem; cursor: help; }

.move-btn {
  flex-shrink: 0;
  border: 1px solid var(--green-pale);
  background: var(--card-bg);
  color: var(--green-mid);
  border-radius: 6px;
  font-size: 0.75rem;
  padding: 0 0.35rem;
  cursor: pointer;
}

.move-btn.push-right { margin-left: auto; }
.move-btn:hover { border-color: var(--green-mid); }

.bf-field { display: flex; flex-direction: column; gap: 0.3rem; flex: 1; min-width: 0; }
.bf-label { font-size: 0.78rem; font-weight: 600; color: var(--text-muted); }
.bf-row { display: flex; gap: 0.75rem; }
.bf-radio { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; }
.bf-error { font-size: 0.82rem; color: #b91c1c; }

.dg-body .eg-input { background: #fff; }

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

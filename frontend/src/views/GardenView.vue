<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import ThisWeekCard from '../components/ThisWeekCard.vue'
import { gardenParam } from '../stores/garden.js'

const router = useRouter()
const { t, tm, te, locale } = useI18n()

function formatDate(isoDate) {
  return new Date(isoDate + 'T00:00:00').toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
}

const plants        = ref([])
const suggestions   = ref(null)
const loading       = ref(true)
const selectedMonth = ref(null)

const instances      = ref([])   // [{id: instanceId, plantId}]
const plantLog       = ref({})   // keyed by instanceId
const plantPlan      = ref({})   // keyed by instanceId
const lifecycle      = ref({})   // keyed by instanceId
const expandedPlants = ref(new Set())

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
  const res = await fetch(`/api/garden/instances${gardenParam()}`)
  if (res.ok) instances.value = await res.json()
}

async function fetchPlantLog() {
  const res = await fetch('/api/garden/plant-log')
  if (res.ok) plantLog.value = await res.json()
}

async function fetchPlantPlan() {
  const res = await fetch('/api/garden/plan')
  if (res.ok) plantPlan.value = await res.json()
}

async function fetchLifecycle() {
  const res = await fetch('/api/garden/lifecycle')
  if (res.ok) lifecycle.value = await res.json()
}

function isPlanEntryDone(instanceId, entry) {
  const logs = plantLog.value[instanceId] ?? []
  return logs.some(log =>
    log.action === entry.action &&
    log.date >= entry.plannedDateStart &&
    log.date <= entry.plannedDateEnd
  )
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
  await Promise.all([fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
}

onMounted(async () => {
  const [detailsRes, suggestionsRes] = await Promise.all([
    fetch(`/api/garden/details${gardenParam()}`),
    fetch(`/api/garden/suggestions${gardenParam()}`),
  ])
  if (detailsRes.ok)     plants.value      = await detailsRes.json()
  if (suggestionsRes.ok) suggestions.value = await suggestionsRes.json()
  loading.value = false
  await Promise.all([fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
})
</script>

<template>
  <main>
    <div class="page-header">
      <h2 class="page-title">{{ t('myGarden') }}</h2>
      <button
        v-if="sortedPlants.length > 0"
        class="ical-btn"
        @click="downloadIcal"
      >
        📅 {{ t('garden.addToCalendar') }}
      </button>
    </div>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="sortedPlants.length === 0">
      <p class="empty">{{ t('garden.empty') }}</p>
    </template>

    <template v-else>
      <!-- Legend -->
      <div class="legend">
        <span class="legend-item"><span class="legend-swatch sow" />{{ t('garden.toSow') }}</span>
        <span class="legend-item"><span class="legend-swatch harvest" />{{ t('garden.toHarvest') }}</span>
        <span class="legend-item"><span class="legend-swatch both" />{{ t('garden.both') }}</span>
      </div>

      <!-- Calendar -->
      <div class="calendar-wrap">
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
            <template v-for="plant in sortedPlants" :key="plant.id">
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
                    v-if="lcForPlant(plant.id)"
                    class="lifecycle-badge"
                    :class="'lc-' + lcForPlant(plant.id).state"
                  >{{ te(`garden.lifecycle.${lcForPlant(plant.id).state}`) ? t(`garden.lifecycle.${lcForPlant(plant.id).state}`) : lcForPlant(plant.id).state }}</span>
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
          </tbody>
        </table>
      </div>

      <!-- Activity panel -->
      <div v-if="selectedMonth !== null" class="activity">
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
      <ThisWeekCard class="this-week-card" @refresh="onWeekRefresh" />

      <!-- Planting suggestions -->
      <div v-if="suggestions && (suggestions.sunGroups.length > 0 || suggestions.conflicts.length > 0)" class="suggestions">
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

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}

.this-week-card {
  margin-top: 1.5rem;
  margin-bottom: 1.5rem;
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

.lc-seeded           { background: #f0fdf4; color: #166534; }
.lc-germinating      { background: #dcfce7; color: #15803d; }
.lc-growing          { background: #bbf7d0; color: #166534; }
.lc-ready_to_harvest { background: #fef3c7; color: #92400e; }
.lc-harvested        { background: #f3f4f6; color: #6b7280; }

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

</style>

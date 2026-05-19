<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'

const router = useRouter()
const { t, tm, te } = useI18n()

const plants        = ref([])
const suggestions   = ref(null)
const weekSummary   = ref(null)
const loading       = ref(true)
const selectedMonth = ref(null)

const seedModal = ref({ open: false, plant: null, date: '', comment: '', saving: false })

function todayIso() {
  return new Date().toISOString().slice(0, 10)
}

function openSeedModal(plant) {
  seedModal.value = { open: true, plant, date: todayIso(), comment: '', saving: false }
}

function closeSeedModal() {
  seedModal.value.open = false
}

async function submitSeedModal() {
  if (seedModal.value.saving) return
  seedModal.value.saving = true
  try {
    await fetch('/api/garden/plant-log', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
      body: JSON.stringify({
        plantId: seedModal.value.plant.id,
        action: 'seeding',
        date: seedModal.value.date,
        comment: seedModal.value.comment || null,
      }),
    })
    closeSeedModal()
  } finally {
    seedModal.value.saving = false
  }
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

function weekRangeLabel(s) {
  const startMonth = months.value[s.weekStartMonth - 1]
  const endMonth   = months.value[s.weekEndMonth - 1]
  const range = s.weekStartMonth === s.weekEndMonth
    ? `${s.weekStartDay}–${s.weekEndDay} ${endMonth}`
    : `${s.weekStartDay} ${startMonth}–${s.weekEndDay} ${endMonth}`
  return `${t('garden.week')} ${s.week} · ${range}`
}

function hintsFor(action) {
  const hints = []
  if (action.type !== 'harvest') {
    if (action.sowingMethod === 'indoor') hints.push(t('garden.hintIndoor'))
    else if (action.sowingMethod === 'direct') hints.push(t('garden.hintDirect'))
    else if (action.sowingMethod === 'both')   hints.push(t('garden.hintBoth'))
    if (action.germinationDaysMin) {
      hints.push(t('garden.hintGermination', { min: action.germinationDaysMin, max: action.germinationDaysMax }))
    }
  }
  if (action.type === 'harvest' || action.type === 'both') {
    hints.push(t('garden.hintHarvest'))
  }
  return hints
}

const actionHints = computed(() => {
  if (!weekSummary.value) return new Map()
  return new Map(weekSummary.value.actions.map(a => [a.plant.id, hintsFor(a)]))
})

onMounted(async () => {
  const [detailsRes, suggestionsRes, weekRes] = await Promise.all([
    fetch('/api/garden/details'),
    fetch('/api/garden/suggestions'),
    fetch('/api/garden/week'),
  ])
  if (detailsRes.ok)     plants.value      = await detailsRes.json()
  if (suggestionsRes.ok) suggestions.value = await suggestionsRes.json()
  if (weekRes.ok)        weekSummary.value = await weekRes.json()
  loading.value = false
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
            <tr
              v-for="plant in sortedPlants"
              :key="plant.id"
              class="plant-row"
            >
              <td
                class="plant-name"
                role="button"
                tabindex="0"
                @click="router.push(`/plant/${plant.id}`)"
                @keydown.enter="router.push(`/plant/${plant.id}`)"
              >
                <span class="plant-emoji">{{ plant.emoji ?? '🌱' }}</span>
                <span>{{ plantName(plant) }}</span>
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
      <div v-if="weekSummary" class="this-week">
        <div class="this-week-header">
          <span class="this-week-title">{{ t('garden.thisWeek') }}</span>
          <span class="this-week-label">{{ weekRangeLabel(weekSummary) }}</span>
        </div>
        <div v-if="weekSummary.actions.length === 0" class="this-week-empty">
          {{ t('garden.nothingThisWeek') }}
        </div>
        <div v-else class="week-actions">
          <div
            v-for="action in weekSummary.actions"
            :key="action.plant.id"
            class="week-action"
            role="button"
            tabindex="0"
            @click="router.push(`/plant/${action.plant.id}`)"
            @keydown.enter="router.push(`/plant/${action.plant.id}`)"
          >
            <span class="week-action-emoji">{{ action.plant.emoji ?? '🌱' }}</span>
            <div class="week-action-body">
              <div class="week-action-top">
                <span class="week-action-name">{{ plantName(action.plant) }}</span>
                <span class="week-action-badge" :class="action.type">
                  {{ action.type === 'sow' ? t('garden.actionSow') : action.type === 'harvest' ? t('garden.actionHarvest') : t('garden.actionBoth') }}
                </span>
                <button
                  v-if="action.type === 'sow' || action.type === 'both'"
                  class="seed-now-btn"
                  @click.stop="openSeedModal(action.plant)"
                >
                  🌱 {{ t('garden.seedNow') }}
                </button>
              </div>
              <div v-if="actionHints.get(action.plant.id)?.length" class="week-action-hints">
                {{ actionHints.get(action.plant.id).join(' · ') }}
              </div>
            </div>
          </div>
        </div>
      </div>

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

  <!-- Seed now modal -->
  <Teleport to="body">
    <div v-if="seedModal.open" class="modal-backdrop" @click.self="closeSeedModal">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-header">
          <span class="modal-title">{{ t('garden.seedModal.title') }}</span>
          <span v-if="seedModal.plant" class="modal-plant">
            {{ seedModal.plant.emoji ?? '🌱' }} {{ plantName(seedModal.plant) }}
          </span>
        </div>
        <form class="modal-body" @submit.prevent="submitSeedModal">
          <div class="form-row">
            <label class="form-label">{{ t('garden.seedModal.actionLabel') }}</label>
            <span class="form-value">{{ t('garden.seedModal.actionValue') }}</span>
          </div>
          <div class="form-row">
            <label class="form-label" for="seed-date">{{ t('garden.seedModal.dateLabel') }}</label>
            <input
              id="seed-date"
              v-model="seedModal.date"
              type="date"
              class="form-input"
              required
            />
          </div>
          <div class="form-row form-row--col">
            <label class="form-label" for="seed-comment">{{ t('garden.seedModal.commentLabel') }}</label>
            <textarea
              id="seed-comment"
              v-model="seedModal.comment"
              class="form-textarea"
              :placeholder="t('garden.seedModal.commentPlaceholder')"
              rows="3"
            />
          </div>
          <div class="modal-actions">
            <button type="button" class="modal-cancel" @click="closeSeedModal">
              {{ t('garden.seedModal.cancel') }}
            </button>
            <button type="submit" class="modal-save" :disabled="seedModal.saving">
              {{ t('garden.seedModal.save') }}
            </button>
          </div>
        </form>
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

/* This week */
.this-week {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  overflow: hidden;
  margin-top: 1.5rem;
  margin-bottom: 1.5rem;
}

.this-week-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  padding: 0.75rem 1.25rem;
  background: var(--green-pale);
  gap: 0.75rem;
}

.this-week-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--green-dark);
}

.this-week-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--green-mid);
  white-space: nowrap;
}

.this-week-empty {
  padding: 1.25rem;
  font-size: 0.875rem;
  color: var(--text-muted);
}

.week-actions {
  display: flex;
  flex-direction: column;
}

.week-action {
  display: flex;
  align-items: flex-start;
  gap: 0.85rem;
  padding: 0.85rem 1.25rem;
  cursor: pointer;
  transition: background 0.15s;
  border-top: 1px solid var(--green-pale);
}

.week-action:first-child { border-top: none; }
.week-action:hover { background: var(--bg); }

.week-action-emoji {
  font-size: 1.5rem;
  line-height: 1;
  flex-shrink: 0;
  padding-top: 0.1rem;
}

.week-action-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.week-action-top {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.week-action-name {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--green-dark);
}

.week-action-badge {
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.15rem 0.5rem;
  border-radius: 20px;
  white-space: nowrap;
}

.week-action-badge.sow     { background: var(--green-pale); color: var(--green-dark); }
.week-action-badge.harvest { background: #fef3c7; color: #92400e; }
.week-action-badge.both    { background: #ede9fe; color: #4c1d95; }

.week-action-hints {
  font-size: 0.78rem;
  color: var(--text-muted);
  line-height: 1.4;
}

.seed-now-btn {
  margin-left: auto;
  padding: 0.2rem 0.65rem;
  border: 1.5px solid var(--green-mid);
  border-radius: 20px;
  background: var(--green-pale);
  color: var(--green-dark);
  font-size: 0.72rem;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
  flex-shrink: 0;
  transition: background 0.15s, border-color 0.15s;
}

.seed-now-btn:hover {
  background: var(--green-light);
  border-color: var(--green-dark);
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
}

.plant-name:hover { background: var(--bg); }

.plant-emoji { font-size: 1rem; }

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

/* Modal */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  padding: 1rem;
}

.modal {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  width: 100%;
  max-width: 420px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
}

.modal-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 0.85rem 1.25rem;
  background: var(--green-pale);
  border-bottom: 1.5px solid var(--green-pale);
  border-radius: var(--radius) var(--radius) 0 0;
}

.modal-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--green-dark);
}

.modal-plant {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--green-mid);
  white-space: nowrap;
}

.modal-body {
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.form-row--col {
  flex-direction: column;
  align-items: stretch;
  gap: 0.35rem;
}

.form-label {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--text-muted);
  white-space: nowrap;
  min-width: 80px;
}

.form-value {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--green-dark);
}

.form-input {
  flex: 1;
  padding: 0.4rem 0.6rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  font-size: 0.875rem;
  background: var(--bg);
  color: var(--text);
}

.form-input:focus {
  outline: none;
  border-color: var(--green-mid);
}

.form-textarea {
  padding: 0.5rem 0.6rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  font-size: 0.875rem;
  font-family: inherit;
  resize: vertical;
  background: var(--bg);
  color: var(--text);
}

.form-textarea:focus {
  outline: none;
  border-color: var(--green-mid);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.6rem;
  padding-top: 0.25rem;
}

.modal-cancel {
  padding: 0.45rem 1rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.modal-cancel:hover {
  border-color: var(--green-mid);
  color: var(--green-dark);
}

.modal-save {
  padding: 0.45rem 1.1rem;
  border: none;
  border-radius: var(--radius);
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.15s;
}

.modal-save:hover:not(:disabled) { opacity: 0.85; }
.modal-save:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

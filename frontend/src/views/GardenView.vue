<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const router = useRouter()
const { t, tm, te } = useI18n()

const vegetables   = ref([])
const loading      = ref(true)
const selectedMonth = ref(null)

const months = computed(() => tm('months'))

function vegName(veg) {
  const key = `vegetables.${veg.name}`
  return te(key) ? t(key) : veg.name
}

const sortedVegetables = computed(() =>
  [...vegetables.value].sort((a, b) => vegName(a).localeCompare(vegName(b)))
)

function cellType(veg, month) {
  const sow     = veg.seedingMonths.includes(month)
  const harvest = veg.harvestingMonths.includes(month)
  if (sow && harvest) return 'both'
  if (sow)            return 'sow'
  if (harvest)        return 'harvest'
  return null
}

function hasSowing(month)     { return sortedVegetables.value.some(v => v.seedingMonths.includes(month)) }
function hasHarvesting(month) { return sortedVegetables.value.some(v => v.harvestingMonths.includes(month)) }

const toSow     = computed(() => selectedMonth.value == null ? [] :
  sortedVegetables.value.filter(v => v.seedingMonths.includes(selectedMonth.value)))
const toHarvest = computed(() => selectedMonth.value == null ? [] :
  sortedVegetables.value.filter(v => v.harvestingMonths.includes(selectedMonth.value)))

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
    const sowList     = sortedVegetables.value.filter(v => v.seedingMonths.includes(m)).map(vegName)
    const harvestList = sortedVegetables.value.filter(v => v.harvestingMonths.includes(m)).map(vegName)

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
  URL.revokeObjectURL(url)
}

onMounted(async () => {
  const res = await fetch('/api/garden/details')
  if (res.ok) vegetables.value = await res.json()
  loading.value = false
})
</script>

<template>
  <main>
    <div class="page-header">
      <h2 class="page-title">{{ t('myGarden') }}</h2>
      <button
        v-if="sortedVegetables.length > 0"
        class="ical-btn"
        @click="downloadIcal"
      >
        📅 {{ t('garden.addToCalendar') }}
      </button>
    </div>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="sortedVegetables.length === 0">
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
              <th class="veg-col-header"></th>
              <th
                v-for="(name, i) in months"
                :key="i"
                class="month-header"
                :class="{
                  selected:     selectedMonth === i + 1,
                  'has-sow':    hasSowing(i + 1),
                  'has-harvest':hasHarvesting(i + 1),
                }"
                @click="selectMonth(i + 1)"
              >
                {{ name }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="veg in sortedVegetables"
              :key="veg.id"
              class="veg-row"
            >
              <td class="veg-name" @click="router.push(`/vegetable/${veg.id}`)">
                <span class="veg-emoji">{{ veg.emoji ?? '🌱' }}</span>
                <span>{{ vegName(veg) }}</span>
              </td>
              <td
                v-for="m in 12"
                :key="m"
                class="cal-cell"
                :class="{
                  selected: selectedMonth === m,
                  [cellType(veg, m)]: cellType(veg, m) !== null,
                }"
              >
                <span v-if="cellType(veg, m)" class="cell-bar" :class="cellType(veg, m)" />
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
            <div class="veg-list">
              <div
                v-for="veg in toSow"
                :key="veg.id"
                class="veg-chip"
                @click="router.push(`/vegetable/${veg.id}`)"
              >
                <span>{{ veg.emoji ?? '🌱' }}</span>
                <span>{{ vegName(veg) }}</span>
              </div>
            </div>
          </div>
          <div v-if="toHarvest.length > 0" class="section">
            <h3 class="section-title harvest">🧺 {{ t('garden.toHarvest') }}</h3>
            <div class="veg-list">
              <div
                v-for="veg in toHarvest"
                :key="veg.id"
                class="veg-chip"
                @click="router.push(`/vegetable/${veg.id}`)"
              >
                <span>{{ veg.emoji ?? '🌱' }}</span>
                <span>{{ vegName(veg) }}</span>
              </div>
            </div>
          </div>
        </template>
      </div>
    </template>
  </main>
</template>

<style scoped>
main {
  max-width: 960px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
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
.legend-swatch.harvest { background: #d97706; }
.legend-swatch.both    { background: linear-gradient(90deg, var(--green-mid) 50%, #d97706 50%); }

/* Calendar */
.calendar-wrap {
  overflow-x: auto;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  margin-bottom: 1.5rem;
}

.calendar {
  border-collapse: collapse;
  width: 100%;
  min-width: 640px;
}

.veg-col-header {
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
.month-header.has-harvest::after { background: #d97706; }
.month-header.has-sow.has-harvest::after {
  background: linear-gradient(90deg, var(--green-mid) 50%, #d97706 50%);
}

.month-header:hover  { background: var(--bg); color: var(--green-dark); }
.month-header.selected { background: var(--green-pale); color: var(--green-dark); }

.veg-row:not(:last-child) td { border-bottom: 1px solid var(--green-pale); }

.veg-name {
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

.veg-name:hover { background: var(--bg); }

.veg-emoji { font-size: 1rem; }

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
.cell-bar.harvest { background: #d97706; }
.cell-bar.both    { background: linear-gradient(90deg, var(--green-mid) 50%, #d97706 50%); }

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
.section-title.harvest { color: #d97706; }

.veg-list { display: flex; flex-wrap: wrap; gap: 0.5rem; }

.veg-chip {
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

.veg-chip:hover {
  border-color: var(--green-light);
  background: var(--green-pale);
}
</style>

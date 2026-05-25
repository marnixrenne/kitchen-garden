<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'
import { gardenParam } from '../stores/garden.js'

const emit = defineEmits(['refresh'])
const { t, te, tm, locale } = useI18n()

const weekSummary = ref(null)
const instances   = ref([])
const plantLog    = ref({})
const plantPlan   = ref({})
const lifecycle   = ref({})
const plants      = ref([])
const loading     = ref(true)

const seedModal   = ref({ open: false, plant: null, instanceId: null, date: '', comment: '', saving: false })
const actionModal = ref({ open: false, plant: null, instanceId: null, action: '', date: '', comment: '', saving: false })

function todayIso() { return new Date().toISOString().slice(0, 10) }

function formatDate(d) {
  return new Date(d + 'T00:00:00').toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
}

function pName(plant) {
  const k = `plants.${plant.name}`
  return te(k) ? t(k) : plant.name
}

function instanceSeedDate(instanceId) {
  const entries = plantLog.value[instanceId] ?? []
  for (let i = entries.length - 1; i >= 0; i--) {
    const e = entries[i]
    if (e.action === 'seeding' || e.action === 'planting') return formatDate(e.date)
  }
  return null
}

function planDateRange(entry) {
  return entry.plannedDateStart === entry.plannedDateEnd
    ? formatDate(entry.plannedDateStart)
    : `${formatDate(entry.plannedDateStart)} – ${formatDate(entry.plannedDateEnd)}`
}

function weekRangeLabel() {
  if (!weekSummary.value) return ''
  const ws = weekSummary.value
  const months = tm('months')
  const sm = months[ws.weekStartMonth - 1]
  const em = months[ws.weekEndMonth - 1]
  const range = ws.weekStartMonth === ws.weekEndMonth
    ? `${ws.weekStartDay}–${ws.weekEndDay} ${em}`
    : `${ws.weekStartDay} ${sm} – ${ws.weekEndDay} ${em}`
  return `${t('garden.week')} ${ws.week} · ${range}`
}

const instanceById = computed(() =>
  Object.fromEntries(instances.value.map(i => [i.id, i]))
)
const plantById = computed(() =>
  Object.fromEntries(plants.value.map(p => [p.id, p]))
)
const instancesByPlantId = computed(() => {
  const map = {}
  for (const inst of instances.value) {
    if (!map[inst.plantId]) map[inst.plantId] = []
    map[inst.plantId].push(inst.id)
  }
  return map
})

const LOGGABLE   = new Set(['fertilizing', 'pruning', 'watering'])
const PLAN_TO_LC = { germination: 'germinating', harvest: 'ready_to_harvest' }

function isDone(instanceId, entry) {
  return (plantLog.value[instanceId] ?? []).some(l =>
    l.action === entry.action &&
    l.date >= entry.plannedDateStart &&
    l.date <= entry.plannedDateEnd
  )
}

function hintsFor(action) {
  const hints = []
  if (action.type !== 'harvest') {
    if (action.sowingMethod === 'indoor')      hints.push(t('garden.hintIndoor'))
    else if (action.sowingMethod === 'direct') hints.push(t('garden.hintDirect'))
    else if (action.sowingMethod === 'both')   hints.push(t('garden.hintBoth'))
    if (action.germinationDaysMin)
      hints.push(t('garden.hintGermination', { min: action.germinationDaysMin, max: action.germinationDaysMax }))
  }
  if (action.type === 'harvest' || action.type === 'both') hints.push(t('garden.hintHarvest'))
  return hints
}

const ACTION_ORDER = ['seeding', 'germination', 'harvest', 'pruning', 'fertilizing', 'watering']
const ACTION_ICON  = { seeding: '🌱', germination: '🌿', harvest: '🧺', pruning: '✂️', fertilizing: '🌻', watering: '💧' }
const GROUP_LABEL_KEY = {
  seeding:     'garden.toSow',
  germination: 'garden.planAction.germination',
  harvest:     'garden.planAction.harvest',
  pruning:     'garden.planAction.pruning',
  fertilizing: 'garden.planAction.fertilizing',
  watering:    'garden.planAction.watering',
}

const actionGroups = computed(() => {
  if (!weekSummary.value) return []
  const ws = weekSummary.value
  const year = new Date().getFullYear()
  const weekStart = new Date(year, ws.weekStartMonth - 1, ws.weekStartDay)
  const weekEnd   = new Date(year, ws.weekEndMonth   - 1, ws.weekEndDay)
  const todayStr  = todayIso()

  const buckets = Object.fromEntries(ACTION_ORDER.map(a => [a, []]))

  for (const wa of (ws.actions ?? [])) {
    if (wa.type === 'sow' || wa.type === 'both') {
      const iid = (instancesByPlantId.value[wa.plant.id] ?? [])[0] ?? null
      buckets.seeding.push({
        plant: wa.plant, instanceId: iid,
        seedDate: iid ? instanceSeedDate(iid) : null,
        dateRange: null, overdue: false, done: false,
        planEntry: null, lc: null, sowAction: wa,
      })
    }
  }

  for (const [instanceId, entries] of Object.entries(plantPlan.value)) {
    const inst  = instanceById.value[instanceId]
    if (!inst) continue
    const plant = plantById.value[inst.plantId]
    if (!plant) continue
    const lc = lifecycle.value[instanceId]
    const sd = instanceSeedDate(instanceId)

    for (const entry of entries) {
      if (LOGGABLE.has(entry.action) && entry.plannedDateEnd < todayStr && !isDone(instanceId, entry)) {
        buckets[entry.action]?.push({
          plant, instanceId, seedDate: sd,
          dateRange: planDateRange(entry),
          overdue: true, done: false,
          planEntry: entry, lc: null, sowAction: null,
        })
        continue
      }

      const start = new Date(entry.plannedDateStart + 'T00:00:00')
      const end   = new Date(entry.plannedDateEnd   + 'T00:00:00')
      if (start > weekEnd || end < weekStart) continue

      if (entry.action === 'germination' || entry.action === 'harvest') {
        if (lc?.nextState === PLAN_TO_LC[entry.action]) {
          buckets[entry.action]?.push({
            plant, instanceId, seedDate: sd,
            dateRange: planDateRange(entry),
            overdue: false, done: false,
            planEntry: entry, lc, sowAction: null,
          })
        }
      } else if (LOGGABLE.has(entry.action)) {
        buckets[entry.action]?.push({
          plant, instanceId, seedDate: sd,
          dateRange: planDateRange(entry),
          overdue: false, done: isDone(instanceId, entry),
          planEntry: entry, lc: null, sowAction: null,
        })
      }
    }
  }

  return ACTION_ORDER
    .map(a => ({
      action: a,
      icon:   ACTION_ICON[a],
      label:  te(GROUP_LABEL_KEY[a]) ? t(GROUP_LABEL_KEY[a]) : a,
      items:  buckets[a],
    }))
    .filter(g => g.items.length > 0)
})

async function fetchAll() {
  loading.value = true
  const p = gardenParam()
  const [weekRes, instRes, logRes, planRes, lcRes, detailRes] = await Promise.all([
    fetch(`/api/garden/week${p}`),
    fetch(`/api/garden/instances${p}`),
    fetch('/api/garden/plant-log'),
    fetch('/api/garden/plan'),
    fetch('/api/garden/lifecycle'),
    fetch(`/api/garden/details${p}`),
  ])
  if (weekRes.ok)   weekSummary.value = await weekRes.json()
  if (instRes.ok)   instances.value   = await instRes.json()
  if (logRes.ok)    plantLog.value     = await logRes.json()
  if (planRes.ok)   plantPlan.value    = await planRes.json()
  if (lcRes.ok)     lifecycle.value    = await lcRes.json()
  if (detailRes.ok) plants.value       = await detailRes.json()
  loading.value = false
}

async function advanceLifecycle(instanceId) {
  const res = await fetch(`/api/garden/lifecycle/${instanceId}/advance`, {
    method: 'PUT',
    headers: csrfHeaders(),
  })
  if (res.ok) {
    lifecycle.value = { ...lifecycle.value, [instanceId]: await res.json() }
    emit('refresh')
  }
}

function openSeedModal(plant, instanceId) {
  seedModal.value = { open: true, plant, instanceId, date: todayIso(), comment: '', saving: false }
}

function openActionModal(plant, action, instanceId) {
  actionModal.value = { open: true, plant, instanceId, action, date: todayIso(), comment: '', saving: false }
}

async function postAction(instanceId, action, date, comment) {
  return fetch('/api/garden/plant-log', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ instanceId, action, date, comment: comment || null }),
  })
}

async function submitSeed() {
  if (seedModal.value.saving) return
  seedModal.value.saving = true
  try {
    await postAction(seedModal.value.instanceId, 'seeding', seedModal.value.date, seedModal.value.comment)
    seedModal.value.open = false
    await fetchAll()
    emit('refresh')
  } finally {
    seedModal.value.saving = false
  }
}

async function submitAction() {
  if (actionModal.value.saving) return
  actionModal.value.saving = true
  try {
    await postAction(actionModal.value.instanceId, actionModal.value.action, actionModal.value.date, actionModal.value.comment)
    actionModal.value.open = false
    await fetchAll()
    emit('refresh')
  } finally {
    actionModal.value.saving = false
  }
}

onMounted(fetchAll)
</script>

<template>
  <div v-if="loading" class="week-loading">{{ t('loading') }}</div>

  <div v-else-if="weekSummary" class="week-card">
    <div class="week-card-header">
      <span class="week-card-title">{{ t('garden.thisWeek') }}</span>
      <span class="week-card-range">{{ weekRangeLabel() }}</span>
    </div>

    <div v-if="actionGroups.length === 0" class="week-empty">
      {{ t('garden.nothingThisWeek') }}
    </div>

    <template v-else>
      <div v-for="group in actionGroups" :key="group.action" class="week-group">
        <div class="week-group-header">
          <span class="week-group-icon">{{ group.icon }}</span>
          <span class="week-group-label">{{ group.label }}</span>
        </div>

        <!-- Seeding: no seed date or date range column -->
        <template v-if="group.action === 'seeding'">
          <div v-for="(item, i) in group.items" :key="i" class="week-item week-item--seed">
            <span class="wi-emoji">{{ item.plant.emoji ?? '🌱' }}</span>
            <div class="wi-seed-body">
              <span class="wi-name">{{ pName(item.plant) }}</span>
              <span v-if="hintsFor(item.sowAction).length" class="wi-hints">
                {{ hintsFor(item.sowAction).join(' · ') }}
              </span>
            </div>
            <button
              class="wi-btn wi-btn--seed"
              :disabled="!item.instanceId"
              @click="openSeedModal(item.plant, item.instanceId)"
            >🌱 {{ t('garden.seedNow') }}</button>
          </div>
        </template>

        <!-- All other groups: seed date + date range columns -->
        <template v-else>
          <div
            v-for="(item, i) in group.items"
            :key="i"
            class="week-item"
            :class="{ 'week-item--overdue': item.overdue }"
          >
            <span class="wi-emoji">{{ item.plant.emoji ?? '🌱' }}</span>
            <span class="wi-name">{{ pName(item.plant) }}</span>
            <span class="wi-seeddate">{{ item.seedDate ?? '—' }}</span>
            <span class="wi-date">
              <span v-if="item.overdue" class="wi-overdue">{{ t('garden.overdue') }}</span>
              <span v-if="item.dateRange" class="wi-daterange">{{ item.dateRange }}</span>
            </span>
            <div class="wi-action">
              <template v-if="item.lc">
                <button class="wi-btn wi-btn--advance" @click="advanceLifecycle(item.instanceId)">
                  {{ t('garden.advanceStage') }}
                </button>
              </template>
              <template v-else-if="item.done">
                <span class="wi-done-mark">✓</span>
              </template>
              <template v-else>
                <button class="wi-btn wi-btn--log" @click="openActionModal(item.plant, item.planEntry.action, item.instanceId)">
                  {{ t('garden.logDone') }}
                </button>
              </template>
            </div>
          </div>
        </template>
      </div>
    </template>
  </div>

  <!-- Seed modal -->
  <Teleport to="body">
    <div v-if="seedModal.open" class="modal-backdrop" @click.self="seedModal.open = false">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-header">
          <span class="modal-title">{{ t('garden.seedModal.title') }}</span>
          <span v-if="seedModal.plant" class="modal-plant">
            {{ seedModal.plant.emoji ?? '🌱' }} {{ pName(seedModal.plant) }}
          </span>
        </div>
        <form class="modal-body" @submit.prevent="submitSeed">
          <div class="form-row">
            <label class="form-label">{{ t('garden.seedModal.actionLabel') }}</label>
            <span class="form-value">{{ t('garden.seedModal.actionValue') }}</span>
          </div>
          <div class="form-row">
            <label class="form-label" for="tw-seed-date">{{ t('garden.seedModal.dateLabel') }}</label>
            <input id="tw-seed-date" v-model="seedModal.date" type="date" class="form-input" required />
          </div>
          <div class="form-row form-row--col">
            <label class="form-label" for="tw-seed-comment">{{ t('garden.seedModal.commentLabel') }}</label>
            <textarea id="tw-seed-comment" v-model="seedModal.comment" class="form-textarea" :placeholder="t('garden.seedModal.commentPlaceholder')" rows="3" />
          </div>
          <div class="modal-actions">
            <button type="button" class="modal-cancel" @click="seedModal.open = false">{{ t('garden.seedModal.cancel') }}</button>
            <button type="submit" class="modal-save" :disabled="seedModal.saving">{{ t('garden.seedModal.save') }}</button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>

  <!-- Log action modal -->
  <Teleport to="body">
    <div v-if="actionModal.open" class="modal-backdrop" @click.self="actionModal.open = false">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-header">
          <span class="modal-title">{{ t('garden.actionModal.title') }}</span>
          <span v-if="actionModal.plant" class="modal-plant">
            {{ actionModal.plant.emoji ?? '🌱' }} {{ pName(actionModal.plant) }}
          </span>
        </div>
        <form class="modal-body" @submit.prevent="submitAction">
          <div class="form-row">
            <label class="form-label">{{ t('garden.actionModal.actionLabel') }}</label>
            <span class="form-value">
              {{ te(`garden.planAction.${actionModal.action}`) ? t(`garden.planAction.${actionModal.action}`) : actionModal.action }}
            </span>
          </div>
          <div class="form-row">
            <label class="form-label" for="tw-action-date">{{ t('garden.seedModal.dateLabel') }}</label>
            <input id="tw-action-date" v-model="actionModal.date" type="date" class="form-input" required />
          </div>
          <div class="form-row form-row--col">
            <label class="form-label" for="tw-action-comment">{{ t('garden.seedModal.commentLabel') }}</label>
            <textarea id="tw-action-comment" v-model="actionModal.comment" class="form-textarea" :placeholder="t('garden.seedModal.commentPlaceholder')" rows="2" />
          </div>
          <div class="modal-actions">
            <button type="button" class="modal-cancel" @click="actionModal.open = false">{{ t('garden.seedModal.cancel') }}</button>
            <button type="submit" class="modal-save" :disabled="actionModal.saving">{{ t('garden.seedModal.save') }}</button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.week-loading {
  text-align: center;
  padding: 1.25rem;
  color: var(--text-muted);
  font-size: 0.875rem;
}

.week-card {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  overflow: hidden;
}

.week-card-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  padding: 0.75rem 1.25rem;
  background: var(--green-pale);
  gap: 0.75rem;
}

.week-card-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--green-dark);
}

.week-card-range {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--green-mid);
  white-space: nowrap;
}

.week-empty {
  padding: 1.25rem;
  font-size: 0.875rem;
  color: var(--text-muted);
}

/* Groups */
.week-group {
  border-top: 1px solid var(--green-pale);
}

.week-group:first-of-type {
  border-top: none;
}

.week-group-header {
  display: flex;
  align-items: center;
  gap: 0.55rem;
  padding: 0.45rem 1.25rem;
  background: var(--bg);
  border-bottom: 1px solid var(--green-pale);
}

.week-group-icon {
  font-size: 0.95rem;
}

.week-group-label {
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

/* Items */
.week-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 1.25rem;
  border-bottom: 1px solid var(--green-pale);
}

.week-item:last-child {
  border-bottom: none;
}

.week-item--overdue {
  border-left: 3px solid #f59e0b;
  padding-left: calc(1.25rem - 3px);
}

.wi-emoji {
  font-size: 1.1rem;
  flex-shrink: 0;
  width: 1.5rem;
  text-align: center;
}

.wi-name {
  flex: 1;
  min-width: 0;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--green-dark);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.wi-seeddate {
  font-size: 0.75rem;
  color: var(--text-muted);
  font-weight: 500;
  white-space: nowrap;
  min-width: 4.5rem;
  flex-shrink: 0;
}

.wi-date {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  min-width: 10rem;
  flex-shrink: 0;
}

.wi-overdue {
  font-size: 0.65rem;
  font-weight: 700;
  padding: 0.1rem 0.4rem;
  border-radius: 20px;
  background: #fef3c7;
  color: #92400e;
  white-space: nowrap;
  flex-shrink: 0;
}

.wi-daterange {
  font-size: 0.75rem;
  color: var(--text-muted);
  white-space: nowrap;
}

.wi-action {
  flex-shrink: 0;
  margin-left: auto;
  display: flex;
  align-items: center;
}

.wi-done-mark {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--green-mid);
  padding: 0 0.5rem;
}

/* Seeding items */
.week-item--seed {
  align-items: center;
}

.wi-seed-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.wi-hints {
  font-size: 0.75rem;
  color: var(--text-muted);
  line-height: 1.3;
}

/* Buttons */
.wi-btn {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 0.25rem 0.65rem;
  border-radius: 20px;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.15s, border-color 0.15s;
  line-height: 1.4;
}

.wi-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.wi-btn--seed {
  border: 1.5px solid var(--green-mid);
  background: var(--green-pale);
  color: var(--green-dark);
}

.wi-btn--seed:hover:not(:disabled) {
  background: var(--green-light);
  border-color: var(--green-dark);
}

.wi-btn--advance {
  border: 1.5px solid var(--green-mid);
  background: none;
  color: var(--green-dark);
}

.wi-btn--advance:hover {
  background: var(--green-pale);
}

.wi-btn--log {
  border: 1.5px solid #0369a1;
  background: none;
  color: #0369a1;
}

.wi-btn--log:hover {
  background: #e0f2fe;
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

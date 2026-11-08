<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { csrfHeaders } from '../stores/auth.js'
import { activeGardenId } from '../stores/garden.js'
import { zoneLabel } from '../utils/zones.js'
import { ACTION_ICON, ACTION_LABEL_KEY, allActions, buildActionBuckets } from '../utils/openActions.js'

const props = defineProps({ zoneId: { type: String, default: null } })
const emit = defineEmits(['refresh'])
const { t, te, tm, locale } = useI18n()
const router = useRouter()

const weekSummary = ref(null)
const zones       = ref([])
const instances   = ref([])
const plantLog    = ref({})
const plantPlan   = ref({})
const lifecycle   = ref({})
const plants      = ref([])
const loading     = ref(true)

const seedModal    = ref({ open: false, plant: null, instanceId: null, method: 'seeding_indoor', date: '', comment: '', saving: false, error: '' })
const actionModal  = ref({ open: false, plant: null, instanceId: null, action: '', date: '', comment: '', saving: false, error: '' })
const advanceModal = ref({ open: false, item: null, date: '', comment: '', saving: false, error: '' })

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
    if (e.action === 'seeding_indoor' || e.action === 'seeding_outdoor' || e.action === 'planting') return formatDate(e.date)
  }
  return null
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

const seedModalInfo = computed(() => {
  const plant = seedModal.value.plant
  if (!plant) return null
  const detail = plants.value.find(p => p.id === plant.id)
  if (!detail) return null
  return {
    spacingCm:    detail.sowingGuide?.spacingCm ?? null,
    seedDepthMm:  detail.sowingGuide?.seedDepthMm ?? null,
    goodWith:     (detail.companions ?? []).filter(c => c.relationship === 'good'),
    avoidNear:    (detail.companions ?? []).filter(c => c.relationship === 'bad'),
    sameSun:      plants.value.filter(p => p.id !== detail.id && p.sunRequirement && p.sunRequirement === detail.sunRequirement),
    sunRequirement: detail.sunRequirement,
  }
})

function hintsFor(action) {
  const hints = []
  if (action.type !== 'harvest') {
    if (action.sowingMethod === 'indoor')      hints.push(t('garden.hintIndoor'))
    else if (action.sowingMethod === 'outdoor') hints.push(t('garden.hintDirect'))
    else if (action.sowingMethod === 'both')   hints.push(t('garden.hintBoth'))
    if (action.germinationDaysMin)
      hints.push(t('garden.hintGermination', { min: action.germinationDaysMin, max: action.germinationDaysMax }))
  }
  if (action.type === 'harvest' || action.type === 'both') hints.push(t('garden.hintHarvest'))
  return hints
}

const actions = computed(() => {
  if (!weekSummary.value) return []
  return allActions(buildActionBuckets({
    weekSummary: weekSummary.value,
    instances:   instances.value,
    plantLog:    plantLog.value,
    plantPlan:   plantPlan.value,
    lifecycle:   lifecycle.value,
    plants:      plants.value,
  }, formatDate))
})

function actionLabel(action) {
  const key = ACTION_LABEL_KEY[action]
  return te(key) ? t(key) : action
}

const zoneGroups = computed(() => {
  const plantById = Object.fromEntries(plants.value.map(p => [p.id, p]))
  const actionsByInstance = {}
  for (const item of actions.value) (actionsByInstance[item.instanceId] ??= []).push(item)

  return zones.value
    .filter(zone => !props.zoneId || zone.id === props.zoneId)
    .map(zone => ({
      zone,
      rows: instances.value
        .filter(inst => inst.zoneId === zone.id && plantById[inst.plantId])
        .map(inst => {
          const rowActions = actionsByInstance[inst.id] ?? []
          return { instanceId: inst.id, plant: plantById[inst.plantId], actions: rowActions, seeded: rowActions.find(a => a.seedDate) ?? null }
        })
        .sort((x, y) => pName(x.plant).localeCompare(pName(y.plant))),
    }))
})

const openActionCount = computed(() =>
  zoneGroups.value.reduce((sum, group) =>
    sum + group.rows.reduce((n, row) => n + row.actions.filter(a => !a.done).length, 0), 0)
)

async function fetchAll() {
  loading.value = true
  const gid = activeGardenId.value
  const [zonesRes, weekRes, instRes, logRes, planRes, lcRes, detailRes] = await Promise.all([
    fetch(`/api/gardens/${gid}/zones`),
    fetch(`/api/gardens/${gid}/week`),
    fetch(`/api/gardens/${gid}/instances`),
    fetch(`/api/gardens/${gid}/plant-log`),
    fetch(`/api/gardens/${gid}/plan`),
    fetch(`/api/gardens/${gid}/lifecycle`),
    fetch(`/api/gardens/${gid}/details`),
  ])
  if (zonesRes.ok)  zones.value       = await zonesRes.json()
  if (weekRes.ok)   weekSummary.value = await weekRes.json()
  if (instRes.ok)   instances.value   = await instRes.json()
  if (logRes.ok)    plantLog.value     = await logRes.json()
  if (planRes.ok)   plantPlan.value    = await planRes.json()
  if (lcRes.ok)     lifecycle.value    = await lcRes.json()
  if (detailRes.ok) plants.value       = await detailRes.json()
  loading.value = false
}

function openAdvanceModal(item) {
  advanceModal.value = { open: true, item, date: todayIso(), comment: '', saving: false, error: '' }
}

async function submitAdvance() {
  if (advanceModal.value.saving) return
  advanceModal.value.saving = true
  advanceModal.value.error = ''
  try {
    const { item, date, comment } = advanceModal.value
    const res = await fetch(`/api/gardens/${activeGardenId.value}/lifecycle/${item.instanceId}/advance`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
      body: JSON.stringify({ date, comment: comment || null }),
    })
    if (!res.ok) { advanceModal.value.error = `Error ${res.status}`; return }
    lifecycle.value = { ...lifecycle.value, [item.instanceId]: await res.json() }
    advanceModal.value.open = false
    emit('refresh')
  } finally {
    advanceModal.value.saving = false
  }
}

function openSeedModal(plant, instanceId) {
  seedModal.value = { open: true, plant, instanceId, method: 'seeding_indoor', date: todayIso(), comment: '', saving: false, error: '' }
}

function openActionModal(plant, action, instanceId) {
  actionModal.value = { open: true, plant, instanceId, action, date: todayIso(), comment: '', saving: false, error: '' }
}

async function postAction(instanceId, action, date, comment) {
  return fetch(`/api/gardens/${activeGardenId.value}/plant-log`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ instanceId, action, date, comment: comment || null }),
  })
}

async function submitSeed() {
  if (seedModal.value.saving) return
  seedModal.value.saving = true
  seedModal.value.error = ''
  try {
    const res = await postAction(seedModal.value.instanceId, seedModal.value.method, seedModal.value.date, seedModal.value.comment)
    if (!res.ok) { seedModal.value.error = `Error ${res.status}`; return }
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
  actionModal.value.error = ''
  try {
    const res = await postAction(actionModal.value.instanceId, actionModal.value.action, actionModal.value.date, actionModal.value.comment)
    if (!res.ok) { actionModal.value.error = `Error ${res.status}`; return }
    actionModal.value.open = false
    await fetchAll()
    emit('refresh')
  } finally {
    actionModal.value.saving = false
  }
}

onMounted(fetchAll)

defineOptions({ inheritAttrs: false })
</script>

<template>
  <div v-bind="$attrs">
  <div v-if="loading" class="week-loading">{{ t('loading') }}</div>

  <div v-else-if="weekSummary" class="week-card">
    <div class="week-card-header">
      <span class="week-card-title">{{ t('garden.openActions', openActionCount, { n: openActionCount }) }}</span>
      <span class="week-card-range">{{ weekRangeLabel() }}</span>
    </div>

    <section v-for="{ zone, rows } in zoneGroups" :key="zone.id" class="week-zone">
      <h3 v-if="!zoneId" class="week-zone-name">{{ zoneLabel(t, zone.name) }}</h3>

      <p v-if="rows.length === 0" class="week-empty">{{ t('zones.empty') }}</p>

      <div v-for="row in rows" :key="row.instanceId" class="week-plant">
        <div class="week-plant-header">
          <span class="wi-emoji">{{ row.plant.emoji ?? '🌱' }}</span>
          <a class="wi-name" @click.prevent="router.push(`/plant/${row.plant.id}`)">
            {{ pName(row.plant) }}
            <span v-if="row.seeded" class="wi-seeded-on"> – {{ row.seeded.seedAction === 'planting' ? t('garden.plantedOn', { date: row.seeded.seedDate }) : t('garden.seededOn', { date: row.seeded.seedDate }) }}</span>
          </a>
          <span v-if="row.actions.length === 0" class="week-plant-none">{{ t('dashboard.nothingOpen') }}</span>
        </div>

        <div
          v-for="item in row.actions"
          :key="`${item.action}-${item.planEntry?.id ?? 'sow'}`"
          class="week-action"
        >
          <span class="week-action-icon" aria-hidden="true">{{ ACTION_ICON[item.action] }}</span>
          <div class="week-action-body">
            <span class="week-action-label">{{ actionLabel(item.action) }}</span>
            <span v-if="item.sowAction && hintsFor(item.sowAction).length" class="wi-hints">{{ hintsFor(item.sowAction).join(' · ') }}</span>
            <span v-if="item.dateRange" class="wi-daterange">{{ item.dateRange }}</span>
          </div>
          <div class="wi-action">
            <button
              v-if="item.action === 'seeding'"
              class="wi-btn wi-btn--seed"
              @click.stop="openSeedModal(item.plant, item.instanceId)"
            >🌱 {{ t('garden.seedNow') }}</button>
            <button v-else-if="item.lc" class="wi-btn wi-btn--advance" @click.stop="openAdvanceModal(item)">
              {{ t(`garden.advanceLabel.${item.lc.nextState}`, t('garden.advanceStage')) }}
            </button>
            <span v-else-if="item.done" class="wi-done-mark">✓</span>
            <button v-else class="wi-btn wi-btn--log" :title="t('garden.logDone')" @click.stop="openActionModal(item.plant, item.planEntry.action, item.instanceId)">✓</button>
          </div>
        </div>
      </div>
    </section>
  </div>
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
          <div class="form-row form-row--col">
            <label class="form-label">{{ t('garden.seedModal.methodLabel') }}</label>
            <div class="method-picker">
              <label class="method-option" :class="{ active: seedModal.method === 'seeding_indoor' }">
                <input type="radio" v-model="seedModal.method" value="seeding_indoor" />
                {{ t('garden.seedModal.methodIndoor') }}
              </label>
              <label class="method-option" :class="{ active: seedModal.method === 'seeding_outdoor' }">
                <input type="radio" v-model="seedModal.method" value="seeding_outdoor" />
                {{ t('garden.seedModal.methodOutdoor') }}
              </label>
              <label class="method-option" :class="{ active: seedModal.method === 'planting' }">
                <input type="radio" v-model="seedModal.method" value="planting" />
                {{ t('garden.seedModal.methodPlanted') }}
              </label>
            </div>
          </div>
          <div v-if="seedModalInfo" class="seed-info">
            <div v-if="seedModalInfo.spacingCm && seedModal.method !== 'seeding_indoor'" class="seed-info-row">
              <span class="seed-info-label">{{ t('garden.seedModal.spacing') }}</span>
              <span class="seed-info-value">{{ seedModalInfo.spacingCm }} cm</span>
            </div>
            <div v-if="seedModalInfo.seedDepthMm !== null && seedModal.method !== 'planting'" class="seed-info-row">
              <span class="seed-info-label">{{ t('garden.seedModal.seedDepth') }}</span>
              <span class="seed-info-value">{{ seedModalInfo.seedDepthMm }} mm</span>
            </div>
            <template v-if="seedModal.method === 'seeding_outdoor' || seedModal.method === 'planting'">
              <div v-if="seedModalInfo.goodWith.length > 0" class="seed-info-row seed-info-row--companions">
                <span class="seed-info-label">{{ t('garden.seedModal.plantNear') }}</span>
                <div class="seed-info-tags">
                  <span v-for="c in seedModalInfo.goodWith" :key="c.id" class="seed-info-tag seed-info-tag--good">
                    {{ c.emoji ?? '🌱' }} {{ pName(c) }}
                  </span>
                </div>
              </div>
              <div v-if="seedModalInfo.avoidNear.length > 0" class="seed-info-row seed-info-row--companions">
                <span class="seed-info-label">{{ t('garden.seedModal.avoidNear') }}</span>
                <div class="seed-info-tags">
                  <span v-for="c in seedModalInfo.avoidNear" :key="c.id" class="seed-info-tag seed-info-tag--bad">
                    {{ c.emoji ?? '🌱' }} {{ pName(c) }}
                  </span>
                </div>
              </div>
              <div v-if="seedModalInfo.sameSun.length > 0" class="seed-info-row seed-info-row--companions">
                <span class="seed-info-label">{{ t('garden.seedModal.sameSun') }}</span>
                <div class="seed-info-tags">
                  <span v-for="p in seedModalInfo.sameSun" :key="p.id" class="seed-info-tag seed-info-tag--sun">
                    {{ p.emoji ?? '🌱' }} {{ pName(p) }}
                  </span>
                </div>
              </div>
            </template>
          </div>
          <div class="form-row">
            <label class="form-label" for="tw-seed-date">{{ t('garden.seedModal.dateLabel') }}</label>
            <input id="tw-seed-date" v-model="seedModal.date" type="date" class="form-input" required />
          </div>
          <div class="form-row form-row--col">
            <label class="form-label" for="tw-seed-comment">{{ t('garden.seedModal.commentLabel') }}</label>
            <textarea id="tw-seed-comment" v-model="seedModal.comment" class="form-textarea" :placeholder="t('garden.seedModal.commentPlaceholder')" rows="3" />
          </div>
          <p v-if="seedModal.error" class="modal-error">{{ seedModal.error }}</p>
          <div class="modal-actions">
            <button type="button" class="modal-cancel" @click="seedModal.open = false">{{ t('garden.seedModal.cancel') }}</button>
            <button type="submit" class="modal-save" :disabled="seedModal.saving">{{ t('garden.seedModal.save') }}</button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>

  <!-- Advance lifecycle modal -->
  <Teleport to="body">
    <div v-if="advanceModal.open" class="modal-backdrop" @click.self="advanceModal.open = false">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-header">
          <span class="modal-title">{{ t('garden.advanceStage') }}</span>
          <span v-if="advanceModal.item?.plant" class="modal-plant">
            {{ advanceModal.item.plant.emoji ?? '🌱' }} {{ pName(advanceModal.item.plant) }}
          </span>
        </div>
        <form class="modal-body" @submit.prevent="submitAdvance">
          <div class="form-row">
            <label class="form-label">{{ t('garden.advanceModal.nextStateLabel') }}</label>
            <span class="form-value">
              {{ advanceModal.item?.lc ? t(`garden.advanceLabel.${advanceModal.item.lc.nextState}`, advanceModal.item.lc.nextState) : '' }}
            </span>
          </div>
          <div class="form-row">
            <label class="form-label" for="tw-advance-date">{{ t('garden.seedModal.dateLabel') }}</label>
            <input id="tw-advance-date" v-model="advanceModal.date" type="date" class="form-input" required />
          </div>
          <div class="form-row form-row--col">
            <label class="form-label" for="tw-advance-comment">{{ t('garden.seedModal.commentLabel') }}</label>
            <textarea id="tw-advance-comment" v-model="advanceModal.comment" class="form-textarea" :placeholder="t('garden.seedModal.commentPlaceholder')" rows="2" />
          </div>
          <p v-if="advanceModal.error" class="modal-error">{{ advanceModal.error }}</p>
          <div class="modal-actions">
            <button type="button" class="modal-cancel" @click="advanceModal.open = false">{{ t('garden.seedModal.cancel') }}</button>
            <button type="submit" class="modal-save" :disabled="advanceModal.saving">{{ t('garden.seedModal.save') }}</button>
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
          <p v-if="actionModal.error" class="modal-error">{{ actionModal.error }}</p>
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
.week-zone {
  border-top: 1px solid var(--green-pale);
}

.week-zone:first-of-type {
  border-top: none;
}

.week-zone-name {
  padding: 0.5rem 1.25rem;
  background: var(--bg);
  border-bottom: 1px solid var(--green-pale);
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--green-dark);
}

.week-plant {
  padding: 0.55rem 1.25rem;
  border-bottom: 1px solid var(--green-pale);
}

.week-plant:last-child {
  border-bottom: none;
}

.week-plant-header {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.week-plant-none {
  margin-left: auto;
  font-size: 0.75rem;
  color: var(--text-muted);
}

.week-action {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.3rem 0 0 1.75rem;
}

.week-action-body {
  display: flex;
  align-items: baseline;
  flex-wrap: wrap;
  gap: 0.15rem 0.6rem;
  flex: 1;
  min-width: 0;
}

.week-action-label {
  font-size: 0.85rem;
  font-weight: 600;
}

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
  cursor: pointer;
  text-decoration: none;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.wi-seeded-on {
  font-size: 0.78rem;
  font-weight: 400;
  color: var(--text-muted);
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
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  background: var(--green-mid);
  color: #fff;
  font-size: 0.875rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
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
  border: 1.5px solid var(--green-mid);
  background: none;
  color: var(--green-mid);
  width: 1.75rem;
  height: 1.75rem;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
}

.wi-btn--log:hover {
  background: var(--green-pale);
  border-color: var(--green-dark);
  color: var(--green-dark);
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

.modal-error {
  font-size: 0.8rem;
  color: #b91c1c;
  margin: 0;
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

.method-picker {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

.method-option {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.3rem 0.75rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}

.method-option input[type="radio"] { display: none; }

.method-option.active {
  border-color: var(--green-mid);
  color: var(--green-dark);
  background: var(--green-pale);
}

.method-option:hover:not(.active) {
  border-color: var(--green-light);
  color: var(--green-dark);
}

/* Seed modal info panel */
.seed-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 0.65rem 0.85rem;
  background: var(--bg);
  border: 1px solid var(--green-pale);
  border-radius: var(--radius);
}

.seed-info-row {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.seed-info-row--companions {
  flex-direction: column;
  gap: 0.25rem;
}

.seed-info-label {
  font-size: 0.73rem;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  white-space: nowrap;
  min-width: 80px;
}

.seed-info-value {
  font-size: 0.825rem;
  font-weight: 600;
  color: var(--green-dark);
}

.seed-info-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}

.seed-info-tag {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.15rem 0.55rem;
  border-radius: 20px;
  white-space: nowrap;
}

.seed-info-tag--good {
  background: #d1fae5;
  color: #065f46;
}

.seed-info-tag--bad {
  background: #fee2e2;
  color: #991b1b;
}

.seed-info-tag--sun {
  background: #fef9c3;
  color: #713f12;
}
</style>

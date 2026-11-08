<script setup>
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { RouterLink } from 'vue-router'
import ZoneGround from '../components/ZoneGround.vue'
import { gardens, gardensLoaded } from '../stores/garden.js'
import { zoneLabel } from '../utils/zones.js'
import { ACTION_ICON, ACTION_LABEL_KEY, buildActionBuckets, openActions, weekRangeLabel } from '../utils/openActions.js'

const MAX_PLANTS_PER_ZONE = 5

const { t, te, tm, locale } = useI18n()

const overviews = ref({})  // keyed by gardenId
const weekLabel = ref('')
const loading   = ref(true)

function formatDate(d) {
  return new Date(d + 'T00:00:00').toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
}

function plantName(plant) {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

function actionLabel(action) {
  const key = ACTION_LABEL_KEY[action]
  return te(key) ? t(key) : action
}

// One row per Plant, however many jobs it has this week
function plantRows(actions) {
  const rows = new Map()
  for (const { instanceId, plant, action, overdue } of actions) {
    if (!rows.has(instanceId)) rows.set(instanceId, { instanceId, plant, jobs: new Map() })
    const jobs = rows.get(instanceId).jobs
    jobs.set(action, jobs.get(action) || overdue)
  }
  return [...rows.values()]
    .map(row => ({ ...row, jobs: [...row.jobs].map(([action, overdue]) => ({ action, overdue })) }))
    .sort((a, b) => plantName(a.plant).localeCompare(plantName(b.plant)))
}

function ground(zoneInstances, plantById, rows) {
  const busy = new Set(rows.map(r => r.instanceId))
  return zoneInstances
    .filter(inst => plantById[inst.plantId])
    .map(inst => {
      const plant = plantById[inst.plantId]
      return { id: inst.id, name: plantName(plant), emoji: plant.emoji, active: busy.has(inst.id) }
    })
    .sort((a, b) => a.name.localeCompare(b.name))
}

async function loadOverview(gardenId) {
  const resources = ['week', 'instances', 'plant-log', 'plan', 'lifecycle', 'details', 'zones']
  try {
    const responses = await Promise.all(resources.map(r => fetch(`/api/gardens/${gardenId}/${r}`)))
    if (responses.some(r => !r.ok)) return { failed: true }
    const [weekSummary, instances, plantLog, plantPlan, lifecycle, plants, zones] =
      await Promise.all(responses.map(r => r.json()))

    const actions = openActions(buildActionBuckets({ weekSummary, instances, plantLog, plantPlan, lifecycle, plants }, formatDate))
    const plantById = Object.fromEntries(plants.map(p => [p.id, p]))
    return {
      failed: false,
      weekSummary,
      openCount: actions.length,
      zones: zones.map(zone => {
        const zoneInstances = instances.filter(i => i.zoneId === zone.id)
        const rows = plantRows(actions.filter(a => a.zoneId === zone.id))
        return { zone, plantCount: zoneInstances.length, rows, ground: ground(zoneInstances, plantById, rows) }
      }),
    }
  } catch {
    return { failed: true }
  }
}

let latestLoad = 0

async function load() {
  if (!gardensLoaded.value) return
  const thisLoad = ++latestLoad
  loading.value = true
  const ids = gardens.value.map(g => g.id)
  const results = await Promise.all(ids.map(loadOverview))
  if (thisLoad !== latestLoad) return
  overviews.value = Object.fromEntries(ids.map((id, i) => [id, results[i]]))
  const week = results.find(r => !r.failed)?.weekSummary
  weekLabel.value = week ? weekRangeLabel(week, t, tm) : ''
  loading.value = false
}

watch([gardens, gardensLoaded], load, { immediate: true })
</script>

<template>
  <main>
    <div class="dash-head">
      <h2 class="dash-title">{{ t('dashboard.title') }}</h2>
      <p v-if="weekLabel && !loading" class="dash-week">{{ weekLabel }}</p>
    </div>

    <div v-if="loading" class="dash-message">{{ t('loading') }}</div>

    <div v-else-if="gardens.length === 0" class="dash-message">
      <p>{{ t('dashboard.noGardens') }}</p>
      <RouterLink class="dash-explore" to="/discover">{{ t('dashboard.explore') }}</RouterLink>
    </div>

    <template v-else>
      <section v-for="garden in gardens" :key="garden.id" class="dash-garden">
        <RouterLink class="dash-garden-header" :to="`/gardens/${garden.id}`">
          <h3 class="dash-garden-name">{{ garden.name }}</h3>
          <span v-if="overviews[garden.id] && !overviews[garden.id].failed" class="dash-count" :class="{ 'dash-count--open': overviews[garden.id].openCount > 0 }">
            {{ t('garden.openActions', overviews[garden.id].openCount, { n: overviews[garden.id].openCount }) }}
          </span>
        </RouterLink>

        <p v-if="!overviews[garden.id] || overviews[garden.id].failed" class="dash-failed">{{ t('dashboard.loadFailed') }}</p>

        <div v-else class="dash-zones">
          <RouterLink
            v-for="{ zone, plantCount, rows, ground: zoneGround } in overviews[garden.id].zones"
            :key="zone.id"
            class="dash-zone"
            :to="`/gardens/${garden.id}/zones/${zone.id}`"
          >
            <div class="dash-zone-header">
              <span class="dash-zone-name">{{ zoneLabel(t, zone.name) }}</span>
              <span class="dash-zone-plants">{{ plantCount > 0 ? t('dashboard.plantCount', plantCount, { n: plantCount }) : t('zones.empty') }}</span>
            </div>

            <ZoneGround :plants="zoneGround" />

            <ul v-if="rows.length > 0" class="dash-actions">
              <li v-for="row in rows.slice(0, MAX_PLANTS_PER_ZONE)" :key="row.instanceId" class="dash-action">
                <span class="dash-action-plant">{{ plantName(row.plant) }}</span>
                <span class="dash-jobs">
                  <span v-for="job in row.jobs" :key="job.action" class="dash-job"><span aria-hidden="true">{{ ACTION_ICON[job.action] }}</span> {{ actionLabel(job.action) }}<span v-if="job.overdue" class="dash-overdue">{{ t('garden.overdue') }}</span></span>
                </span>
              </li>
              <li v-if="rows.length > MAX_PLANTS_PER_ZONE" class="dash-more">{{ t('dashboard.more', { n: rows.length - MAX_PLANTS_PER_ZONE }) }}</li>
            </ul>
            <p v-else-if="plantCount > 0" class="dash-nothing">{{ t('dashboard.nothingOpen') }}</p>
          </RouterLink>
        </div>
      </section>
    </template>
  </main>
</template>

<style scoped>
main {
  max-width: 960px;
  margin: 0 auto;
  padding: 1.75rem 1rem 4rem;
}

.dash-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.25rem 1rem;
  flex-wrap: wrap;
  margin-bottom: 2rem;
}

.dash-title {
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.01em;
  color: var(--green-dark);
}

.dash-week {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-soft);
}

.dash-message {
  text-align: center;
  padding: 3rem;
  color: var(--text-soft);
}

.dash-explore {
  display: inline-block;
  margin-top: 0.75rem;
  font-weight: 600;
  color: var(--green-dark);
}

.dash-garden + .dash-garden {
  margin-top: 3.25rem;
}

.dash-garden-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.25rem 0.75rem;
  flex-wrap: wrap;
  color: inherit;
  text-decoration: none;
}

.dash-garden-header:hover .dash-garden-name {
  text-decoration: underline;
  text-underline-offset: 0.15em;
}

.dash-garden-name {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--green-dark);
}

.dash-count {
  font-size: 0.9rem;
  color: var(--text-soft);
}

.dash-count--open {
  font-weight: 700;
  color: var(--green-dark);
}

.dash-failed {
  margin-top: 0.75rem;
  font-size: 0.9rem;
  color: var(--text-soft);
}

.dash-zones {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(380px, 100%), 1fr));
  gap: 2rem 3rem;
  margin-top: 1.25rem;
}

.dash-zone {
  display: block;
  color: inherit;
  text-decoration: none;
  border-radius: 4px;
}

.dash-zone:focus-visible,
.dash-garden-header:focus-visible {
  outline: 2px solid var(--green-mid);
  outline-offset: 6px;
}

.dash-zone-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.4rem;
}

.dash-zone-name {
  font-weight: 700;
  color: var(--green-dark);
  overflow-wrap: anywhere;
}

.dash-zone:hover .dash-zone-name {
  text-decoration: underline;
  text-underline-offset: 0.15em;
}

.dash-zone-plants {
  font-size: 0.8rem;
  color: var(--text-soft);
  white-space: nowrap;
}

.dash-actions {
  list-style: none;
  margin: 0.6rem 0 0;
  padding: 0;
}

.dash-action {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.15rem 1rem;
  flex-wrap: wrap;
  padding: 0.2rem 0;
  font-size: 0.9rem;
}

.dash-action-plant {
  font-weight: 600;
}

.dash-jobs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.1rem 0.85rem;
}

.dash-job {
  font-size: 0.85rem;
  color: var(--text-soft);
  white-space: nowrap;
}

.dash-overdue {
  margin-left: 0.35rem;
  padding: 0.1rem 0.4rem;
  border-radius: 20px;
  background: #fef3c7;
  color: #92400e;
  font-size: 0.75rem;
  font-weight: 700;
}

.dash-more {
  padding-top: 0.2rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--green-mid);
}

.dash-nothing {
  margin-top: 0.6rem;
  font-size: 0.85rem;
  color: var(--text-soft);
}
</style>

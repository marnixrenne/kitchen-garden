<script setup>
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { RouterLink } from 'vue-router'
import { gardens, gardensLoaded } from '../stores/garden.js'
import { zoneLabel } from '../utils/zones.js'
import { ACTION_ICON, ACTION_LABEL_KEY, buildActionBuckets, openActions } from '../utils/openActions.js'

const MAX_ACTIONS_PER_ZONE = 5

const { t, te, locale } = useI18n()

const overviews = ref({})  // keyed by gardenId
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

async function loadOverview(gardenId) {
  const resources = ['week', 'instances', 'plant-log', 'plan', 'lifecycle', 'details', 'zones']
  try {
    const responses = await Promise.all(resources.map(r => fetch(`/api/gardens/${gardenId}/${r}`)))
    if (responses.some(r => !r.ok)) return { failed: true }
    const [weekSummary, instances, plantLog, plantPlan, lifecycle, plants, zones] =
      await Promise.all(responses.map(r => r.json()))

    const actions = openActions(buildActionBuckets({ weekSummary, instances, plantLog, plantPlan, lifecycle, plants }, formatDate))
    return {
      failed: false,
      openCount: actions.length,
      zones: zones.map(zone => ({
        zone,
        plantCount: instances.filter(i => i.zoneId === zone.id).length,
        actions: actions.filter(a => a.zoneId === zone.id),
      })),
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
  loading.value = false
}

watch([gardens, gardensLoaded], load, { immediate: true })
</script>

<template>
  <main>
    <h2 class="dash-title">{{ t('dashboard.title') }}</h2>

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
            v-for="{ zone, plantCount, actions } in overviews[garden.id].zones"
            :key="zone.id"
            class="dash-zone"
            :to="`/gardens/${garden.id}/zones/${zone.id}`"
          >
            <div class="dash-zone-header">
              <span class="dash-zone-name">{{ zoneLabel(t, zone.name) }}</span>
              <span class="dash-zone-plants">{{ plantCount > 0 ? t('dashboard.plantCount', plantCount, { n: plantCount }) : t('zones.empty') }}</span>
            </div>

            <ul v-if="actions.length > 0" class="dash-actions">
              <li v-for="item in actions.slice(0, MAX_ACTIONS_PER_ZONE)" :key="`${item.action}-${item.instanceId}-${item.planEntry?.id ?? 'sow'}`" class="dash-action">
                <span aria-hidden="true">{{ ACTION_ICON[item.action] }}</span>
                <span class="dash-action-plant">{{ plantName(item.plant) }}</span>
                <span class="dash-action-label">{{ actionLabel(item.action) }}</span>
              </li>
              <li v-if="actions.length > MAX_ACTIONS_PER_ZONE" class="dash-more">{{ t('dashboard.more', { n: actions.length - MAX_ACTIONS_PER_ZONE }) }}</li>
            </ul>
            <p v-else class="dash-nothing">{{ t('dashboard.nothingOpen') }}</p>
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
  padding: 1.5rem 1rem 4rem;
}

.dash-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 1.25rem;
}

.dash-message {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}

.dash-explore {
  display: inline-block;
  margin-top: 0.75rem;
  font-weight: 600;
  color: var(--green-dark);
}

.dash-garden {
  margin-bottom: 2rem;
}

.dash-garden-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 0.75rem 1.25rem;
  background: var(--green-pale);
  border-radius: var(--radius);
  text-decoration: none;
  flex-wrap: wrap;
}

.dash-garden-header:hover .dash-garden-name {
  text-decoration: underline;
}

.dash-garden-name {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--green-dark);
}

.dash-count {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
}

.dash-count--open {
  color: var(--green-dark);
}

.dash-failed {
  padding: 1rem 1.25rem;
  font-size: 0.85rem;
  color: var(--text-muted);
}

.dash-zones {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(260px, 100%), 1fr));
  gap: 0.75rem;
  margin-top: 0.75rem;
}

.dash-zone {
  display: block;
  padding: 0.85rem 1rem;
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  color: inherit;
  text-decoration: none;
  transition: border-color 0.15s;
}

.dash-zone:hover,
.dash-zone:focus-visible {
  border-color: var(--green-mid);
}

.dash-zone-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.dash-zone-name {
  font-weight: 700;
  color: var(--green-dark);
  overflow-wrap: anywhere;
}

.dash-zone-plants {
  font-size: 0.75rem;
  color: var(--text-muted);
  white-space: nowrap;
}

.dash-actions {
  list-style: none;
  margin: 0;
  padding: 0;
}

.dash-action {
  display: flex;
  align-items: baseline;
  gap: 0.4rem;
  padding: 0.15rem 0;
  font-size: 0.85rem;
}

.dash-action-plant {
  font-weight: 600;
}

.dash-action-label {
  margin-left: auto;
  font-size: 0.75rem;
  color: var(--text-muted);
  white-space: nowrap;
}

.dash-more {
  padding-top: 0.25rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--green-mid);
}

.dash-nothing {
  font-size: 0.8rem;
  color: var(--text-muted);
}
</style>

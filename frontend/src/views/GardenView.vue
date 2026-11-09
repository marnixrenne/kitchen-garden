<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter, useRoute, RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import ThisWeekCard from '../components/ThisWeekCard.vue'
import GardenCalendarTab from '../components/GardenCalendarTab.vue'
import GardenLogTab from '../components/GardenLogTab.vue'
import AddPlantsModal from '../components/AddPlantsModal.vue'
import ZoneFormModal from '../components/ZoneFormModal.vue'
import DeleteZoneModal from '../components/DeleteZoneModal.vue'
import MovePlantModal from '../components/MovePlantModal.vue'
import MoveEntryModal from '../components/MoveEntryModal.vue'
import RenameGardenModal from '../components/RenameGardenModal.vue'
import DeleteGardenModal from '../components/DeleteGardenModal.vue'
import { activeGardenName, activeGardenId, gardens, setActiveGarden } from '../stores/garden.js'
import { zoneLabel, moveDescription } from '../utils/zones.js'

const router = useRouter()
const route  = useRoute()
const { t, te } = useI18n()

// Set when this page shows a single Zone rather than the whole Garden
const zoneId = computed(() => route.params.zoneId ?? null)

const plants        = ref([])
const suggestions   = ref(null)
const loading       = ref(true)
const selectedMonth = ref(null)

const instances      = ref([])   // [{id: instanceId, plantId, zoneId, sunShortfall}]
const zones           = ref([])   // creation order
const plantLog       = ref({})   // keyed by instanceId
const plantPlan      = ref({})   // keyed by instanceId
const lifecycle      = ref({})   // keyed by instanceId
const expandedPlantings = ref(new Set())
const activeTab      = ref(
  route.query.tab === 'calendar' ? 'calendar' :
  route.query.tab === 'log'      ? 'log'      : 'week'
)

watch(() => route.query.tab, (tab) => {
  activeTab.value = tab === 'calendar' ? 'calendar' : tab === 'log' ? 'log' : 'week'
})

function setTab(tab) {
  activeTab.value = tab
  router.replace({ path: route.path, query: tab === 'week' ? {} : { tab } })
}

const logFilter = ref('')

// Reads part of the active Garden; a reply arriving after a switch to another Garden is dropped
async function readGarden(resource, apply) {
  const gardenId = activeGardenId.value
  const res = await fetch(`/api/gardens/${gardenId}/${resource}`)
  if (!res.ok) return
  const data = await res.json()
  if (gardenId === activeGardenId.value) apply(data, gardenId)
}

const fetchInstances = () => readGarden('instances', data => { instances.value = data })
const fetchPlantLog  = () => readGarden('plant-log', data => { plantLog.value = data })
const fetchPlantPlan = () => readGarden('plan',      data => { plantPlan.value = data })
const fetchLifecycle = () => readGarden('lifecycle', data => { lifecycle.value = data })
const fetchPlants    = () => readGarden('details',   data => { plants.value = data })

const fetchZones = () => readGarden('zones', (data, gardenId) => {
  zones.value = data
  if (zoneId.value && !data.some(z => z.id === zoneId.value)) {
    router.replace({ path: `/gardens/${gardenId}`, query: route.query })
  }
})

const focusedZone = computed(() => zones.value.find(z => z.id === zoneId.value) ?? null)

const hasPlants = computed(() =>
  plants.value.some(p => !zoneId.value || instances.value.some(i => i.plantId === p.id && i.zoneId === zoneId.value))
)

// Popups: each is open while its value is set

const zoneForm       = ref(null)  // { zone }; zone is null for a new one
const zoneToDelete   = ref(null)
const plantMove      = ref(null)  // { plant, instance }
const moveEntry      = ref(null)
const renamingGarden = ref(false)
const deletingGarden = ref(false)

function openZoneModal(zone = null) {
  zoneForm.value = { zone }
}

function plantsInZone(zone) {
  return instances.value.filter(i => i.zoneId === zone.id).length
}

async function onZoneSaved() {
  zoneForm.value = null
  // A zone's sun exposure changes the instances' sun warnings
  await Promise.all([fetchZones(), fetchInstances()])
}

async function onZoneDeleted(plantsRemoved) {
  zoneToDelete.value = null
  if (plantsRemoved) await loadAll()
  else await Promise.all([fetchZones(), fetchInstances(), fetchPlantLog()])
}

async function onPlantMoved() {
  plantMove.value = null
  await Promise.all([fetchInstances(), fetchPlantLog()])
}

async function onMoveEntrySaved() {
  moveEntry.value = null
  await fetchPlantLog()
}

function plantName(plant) {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

// Add plants

const addPlantsOpen = ref(false)
const weekCard = ref(null)

async function onPlantAdded() {
  await fetchPlants()
  await fetchInstances()
  weekCard.value?.reload?.()
}

function editZoneFromAddPlants() {
  addPlantsOpen.value = false
  openZoneModal(focusedZone.value)
}

async function onWeekRefresh() {
  await Promise.all([fetchZones(), fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
}

async function loadAll() {
  const gardenId = activeGardenId.value
  loading.value = true
  plants.value = []
  suggestions.value = null
  instances.value = []
  zones.value = []
  plantLog.value = {}
  plantPlan.value = {}
  lifecycle.value = {}
  expandedPlantings.value = new Set()
  try {
    await Promise.all([fetchPlants(), readGarden('suggestions', data => { suggestions.value = data })])
  } finally {
    if (gardenId === activeGardenId.value) loading.value = false
  }
  if (gardenId !== activeGardenId.value) return
  await Promise.all([fetchZones(), fetchInstances(), fetchPlantLog(), fetchPlantPlan(), fetchLifecycle()])
}

onMounted(loadAll)
watch(activeGardenId, id => { if (id) loadAll() })

// An address for a Garden the user doesn't have (deleted, or from another account)
watch(gardens, (list) => {
  const id = route.params.gardenId
  if (!id || list.length === 0 || list.some(g => g.id === id)) return
  setActiveGarden(list[0].id)
  router.replace('/')
}, { immediate: true })
</script>

<template>
  <main>
    <nav class="breadcrumb">
      <RouterLink to="/">{{ t('dashboard.title') }}</RouterLink>
      <template v-if="zoneId">
        <span aria-hidden="true">›</span>
        <RouterLink :to="`/gardens/${activeGardenId}`">{{ activeGardenName ?? t('myGarden') }}</RouterLink>
      </template>
    </nav>

    <div class="page-header">
      <h2 class="page-title" :class="{ 'page-title--zone': zoneId }">{{ focusedZone ? zoneLabel(t, focusedZone.name) : (activeGardenName ?? t('myGarden')) }}</h2>
      <button v-if="focusedZone" class="zone-settings-link" @click="openZoneModal(focusedZone)">{{ t('zones.settings') }}</button>
      <button v-if="focusedZone" class="add-plants-btn" @click="addPlantsOpen = true">+ {{ t('addPlants.button') }}</button>
      <div v-if="!zoneId" class="page-header-actions">
        <button class="add-zone-btn" @click="openZoneModal()">+ {{ t('zones.add') }}</button>
        <button class="edit-garden-btn" @click="renamingGarden = true" :title="t('garden.editGarden')">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
          </svg>
        </button>
        <button class="delete-garden-btn" @click="deletingGarden = true" :title="t('garden.deleteGarden')">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="3 6 5 6 21 6"/>
            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/>
            <line x1="10" y1="11" x2="10" y2="17"/>
            <line x1="14" y1="11" x2="14" y2="17"/>
          </svg>
        </button>
      </div>
    </div>

    <AddPlantsModal
      v-if="addPlantsOpen && focusedZone"
      :zone="focusedZone"
      @close="addPlantsOpen = false"
      @added="onPlantAdded"
      @edit-zone="editZoneFromAddPlants"
    />

    <div class="garden-tabs">
      <button class="garden-tab" :class="{ active: activeTab === 'week' }" @click="setTab('week')">{{ t('garden.thisWeek') }}</button>
      <button class="garden-tab" :class="{ active: activeTab === 'calendar' }" @click="setTab('calendar')">{{ t('garden.calendarTab') }}</button>
      <button class="garden-tab" :class="{ active: activeTab === 'log' }" @click="setTab('log')">{{ t('garden.logNav') }}</button>
    </div>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <GardenLogTab
      v-else-if="activeTab === 'log'"
      v-model:query="logFilter"
      :plants="plants"
      :instances="instances"
      :plant-log="plantLog"
      :zone-id="zoneId"
      @edit-move="moveEntry = $event"
    />

    <p v-else-if="!hasPlants" class="empty">{{ t('garden.empty') }}</p>

    <ThisWeekCard
      v-else-if="activeTab === 'week'"
      ref="weekCard"
      class="this-week-card"
      :zones="zones"
      :zone-id="zoneId"
      @refresh="onWeekRefresh"
      @edit-zone="openZoneModal"
    />

    <GardenCalendarTab
      v-else
      v-model:selected-month="selectedMonth"
      v-model:expanded-plantings="expandedPlantings"
      :plants="plants"
      :instances="instances"
      :zones="zones"
      :plant-log="plantLog"
      :plant-plan="plantPlan"
      :lifecycle="lifecycle"
      :suggestions="suggestions"
      :zone-id="zoneId"
      @edit-zone="openZoneModal"
      @delete-zone="zoneToDelete = $event"
      @move-plant="plantMove = $event"
    />
  </main>

  <RenameGardenModal v-if="renamingGarden" @close="renamingGarden = false" />
  <DeleteGardenModal v-if="deletingGarden" @close="deletingGarden = false" />
  <ZoneFormModal v-if="zoneForm" :zone="zoneForm.zone" @close="zoneForm = null" @saved="onZoneSaved" />
  <DeleteZoneModal
    v-if="zoneToDelete"
    :zone="zoneToDelete"
    :zones="zones"
    :plant-count="plantsInZone(zoneToDelete)"
    @close="zoneToDelete = null"
    @deleted="onZoneDeleted"
  />
  <MovePlantModal
    v-if="plantMove"
    :plant-name="plantName(plantMove.plant)"
    :instance="plantMove.instance"
    :zones="zones"
    @close="plantMove = null"
    @moved="onPlantMoved"
  />
  <MoveEntryModal
    v-if="moveEntry"
    :entry="moveEntry"
    :description="moveDescription(t, moveEntry)"
    @close="moveEntry = null"
    @saved="onMoveEntrySaved"
  />
</template>

<style scoped>
main {
  --harvest-color: #d97706;
  max-width: 960px;
  margin: 0 auto;
  padding: 1.5rem 1rem 4rem;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.5rem;
  font-size: 0.8rem;
  color: var(--text-muted);
}

.breadcrumb a {
  color: var(--green-mid);
  font-weight: 600;
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.page-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.25rem;
  flex-wrap: wrap;
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.01em;
  color: var(--green-dark);
  flex: 1;
}

.page-title--zone {
  flex: 0 1 auto;
}

.page-header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.edit-garden-btn {
  padding: 0.35rem 0.6rem;
  background: none;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  color: var(--text-soft);
  cursor: pointer;
  display: flex;
  align-items: center;
}

.edit-garden-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-dark);
}

.delete-garden-btn {
  padding: 0.35rem 0.6rem;
  background: none;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  color: var(--text-soft);
  cursor: pointer;
  display: flex;
  align-items: center;
}

.delete-garden-btn:hover {
  border-color: #b91c1c;
  color: #b91c1c;
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

.zone-settings-link {
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  font-size: 0.85rem;
  color: var(--green-mid);
  text-decoration: underline;
  cursor: pointer;
}

.add-zone-btn,
.add-plants-btn {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  color: var(--green-dark);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.add-zone-btn:hover,
.add-plants-btn:hover { border-color: var(--green-mid); }

.add-plants-btn { margin-left: auto; }
</style>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'
import { activeGardenId } from '../stores/garden.js'
import { addPlantUrl } from '../stores/zonePicker.js'
import { zoneLabel } from '../utils/zones.js'

const MAX_SEARCH_RESULTS = 30

const props = defineProps({
  zone: { type: Object, required: true },
})
const emit = defineEmits(['close', 'added', 'edit-zone'])

const { t, te } = useI18n()

const options    = ref([])
const loading    = ref(true)
const loadFailed = ref(false)
const addFailed  = ref(false)
const addingId   = ref(null)
const query      = ref('')

function plantName(plant) {
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

const recommended = computed(() => options.value.filter(o => o.recommended))

const searchResults = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return []
  return options.value
    .filter(o => plantName(o).toLowerCase().includes(q))
    .sort((a, b) => plantName(a).localeCompare(plantName(b)))
    .slice(0, MAX_SEARCH_RESULTS)
})

function names(plants) {
  return plants.map(plantName).join(', ')
}

function reasons(option) {
  const list = []
  if (option.goodWith.length) list.push(t('addPlants.goodWith', { plants: names(option.goodWith) }))
  if (option.pestControl) {
    const { predator, pest, plant } = option.pestControl
    list.push(t(`addPlants.pestControl.${predator}`, { pest: t(`addPlants.pests.${pest}`), plant: plantName(plant) }))
  }
  if (option.pollinatorsFor.length) list.push(t('addPlants.pollinators', { plants: names(option.pollinatorsFor) }))
  if (option.sunMatch) list.push(t(`addPlants.suits.${option.sunMatch}`))
  return list
}

function alsoIn(option) {
  return t('addPlants.alsoIn', { zones: option.alsoIn.map(name => zoneLabel(t, name)).join(', ') })
}

async function load() {
  try {
    const res = await fetch(`/api/gardens/${activeGardenId.value}/zones/${props.zone.id}/plant-options`)
    if (!res.ok) { loadFailed.value = true; return }
    options.value = await res.json()
    loadFailed.value = false
  } catch {
    loadFailed.value = true
  } finally {
    loading.value = false
  }
}

async function add(option) {
  if (addingId.value) return
  addingId.value = option.id
  addFailed.value = false
  try {
    const res = await fetch(addPlantUrl(option.id, props.zone.id), { method: 'POST', headers: csrfHeaders() })
    if (!res.ok) { addFailed.value = true; return }
    await load()
    emit('added')
  } catch {
    addFailed.value = true
  } finally {
    addingId.value = null
  }
}

onMounted(load)
</script>

<template>
  <Teleport to="body">
    <div class="ap-backdrop" @click.self="emit('close')">
      <div class="ap-modal" role="dialog" aria-modal="true" :aria-label="t('addPlants.title', { zone: zoneLabel(t, zone.name) })">
        <div class="ap-header">{{ t('addPlants.title', { zone: zoneLabel(t, zone.name) }) }}</div>

        <div class="ap-body">
          <p v-if="loading" class="ap-message">{{ t('loading') }}</p>
          <p v-else-if="loadFailed" class="ap-error" role="alert">{{ t('addPlants.loadFailed') }}</p>

          <template v-else>
            <p v-if="addFailed" class="ap-error" role="alert">{{ t('addPlants.addFailed') }}</p>

            <section>
              <h3 class="ap-title">{{ t('addPlants.recommended') }}</h3>
              <p v-if="!zone.sunExposure" class="ap-prompt">
                {{ t('addPlants.setSunPrompt') }}
                <button class="ap-link" @click="emit('edit-zone')">{{ t('zones.settings') }}</button>
              </p>
              <p v-if="recommended.length === 0" class="ap-message">{{ t('addPlants.noRecommendations') }}</p>
              <ul v-else class="ap-list ap-recommended">
                <li v-for="option in recommended" :key="option.id" class="ap-row">
                  <span class="ap-emoji" aria-hidden="true">{{ option.emoji ?? '🌱' }}</span>
                  <div class="ap-info">
                    <span class="ap-name">{{ plantName(option) }}</span>
                    <span class="ap-reasons">
                      <span v-for="reason in reasons(option)" :key="reason" class="ap-reason">{{ reason }}</span>
                    </span>
                    <span v-if="option.alsoIn.length" class="ap-note">{{ alsoIn(option) }}</span>
                  </div>
                  <button class="ap-add" :disabled="addingId !== null" @click="add(option)">{{ t('addPlants.add') }}</button>
                </li>
              </ul>
            </section>

            <section class="ap-search">
              <label class="ap-title" for="ap-search-input">{{ t('addPlants.search') }}</label>
              <input id="ap-search-input" v-model="query" class="ap-input" type="search" :placeholder="t('addPlants.searchPlaceholder')" />
              <p v-if="query.trim() && searchResults.length === 0" class="ap-message">{{ t('addPlants.noResults') }}</p>
              <ul v-if="searchResults.length" class="ap-list ap-results">
                <li v-for="option in searchResults" :key="option.id" class="ap-row">
                  <span class="ap-emoji" aria-hidden="true">{{ option.emoji ?? '🌱' }}</span>
                  <div class="ap-info">
                    <span class="ap-name">{{ plantName(option) }}</span>
                    <span v-if="option.inThisZone" class="ap-note">{{ t('addPlants.alreadyHere') }}</span>
                    <span v-else-if="option.alsoIn.length" class="ap-note">{{ alsoIn(option) }}</span>
                    <span v-if="option.sunShortfall" class="ap-warning">{{ t('zones.sunWarning') }}</span>
                    <span v-if="option.badWith.length" class="ap-warning">{{ t('addPlants.badWith', { plants: names(option.badWith) }) }}</span>
                  </div>
                  <button class="ap-add" :disabled="addingId !== null" @click="add(option)">
                    {{ option.inThisZone ? t('addPlants.addAnother') : t('addPlants.add') }}
                  </button>
                </li>
              </ul>
            </section>
          </template>

          <div class="ap-actions">
            <button class="ap-done" @click="emit('close')">{{ t('addPlants.done') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.ap-backdrop {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.35);
  z-index: 200;
}

.ap-modal {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 520px;
  max-height: calc(100vh - 2rem);
  border-radius: 10px;
  background: #fff;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
  overflow: hidden;
}

.ap-header {
  padding: 0.85rem 1.25rem;
  background: var(--green-pale);
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--green-dark);
}

.ap-body {
  padding: 1rem 1.25rem;
  overflow-y: auto;
}

.ap-title {
  display: block;
  margin-bottom: 0.4rem;
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--green-dark);
}

.ap-search {
  margin-top: 1.1rem;
}

.ap-input {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  font-size: 0.9rem;
  color: var(--text);
  outline: none;
  box-sizing: border-box;
}

.ap-input:focus {
  border-color: var(--green-mid);
}

.ap-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.ap-results {
  margin-top: 0.5rem;
}

.ap-row {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.4rem 0;
}

.ap-emoji {
  flex-shrink: 0;
  font-size: 1.3rem;
}

.ap-info {
  display: flex;
  flex: 1;
  flex-direction: column;
  min-width: 0;
}

.ap-name {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--green-dark);
}

.ap-reasons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.15rem 0.6rem;
}

.ap-reason,
.ap-note {
  font-size: 0.78rem;
  color: var(--text-soft);
}

.ap-warning {
  font-size: 0.78rem;
  color: #92400e;
}

.ap-add {
  flex-shrink: 0;
  padding: 0.3rem 0.8rem;
  border: 1.5px solid var(--green-mid);
  border-radius: 8px;
  background: none;
  color: var(--green-dark);
  font-size: 0.82rem;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
}

.ap-add:hover:not(:disabled) {
  background: var(--green-pale);
}

.ap-add:disabled {
  opacity: 0.5;
  cursor: default;
}

.ap-message,
.ap-prompt {
  font-size: 0.85rem;
  color: var(--text-soft);
}

.ap-prompt {
  margin-bottom: 0.4rem;
}

.ap-link {
  padding: 0;
  border: none;
  background: none;
  font: inherit;
  color: var(--green-mid);
  text-decoration: underline;
  cursor: pointer;
}

.ap-error {
  margin-bottom: 0.6rem;
  font-size: 0.85rem;
  color: #b91c1c;
}

.ap-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 1rem;
}

.ap-done {
  padding: 0.4rem 1rem;
  border: none;
  border-radius: 8px;
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}
</style>

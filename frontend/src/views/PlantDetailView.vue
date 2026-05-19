<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'

const route  = useRoute()
const router = useRouter()
const { t, tm, te } = useI18n()

const plant     = ref(null)
const loading   = ref(true)
const inGarden  = ref(false)
const gardenIds = ref(new Set())

const months = computed(() => tm('months'))

const localName = computed(() => {
  if (!plant.value) return ''
  const key = `plants.${plant.value.name}`
  return te(key) ? t(key) : plant.value.name
})

const description = computed(() => {
  if (!plant.value) return ''
  return t(`descriptions.${plant.value.name}`)
})

const goodCompanions = computed(() => plant.value?.companions.filter(c => c.relationship === 'good') ?? [])
const badCompanions  = computed(() => plant.value?.companions.filter(c => c.relationship === 'bad')  ?? [])

const pollinators = computed(() => plant.value?.insects.filter(i => i.type === 'pollinator') ?? [])
const beneficials = computed(() => plant.value?.insects.filter(i => i.type === 'beneficial') ?? [])
const pests       = computed(() => plant.value?.insects.filter(i => i.type === 'pest')       ?? [])

function monthType(m) {
  const sow     = plant.value.seedingMonths.includes(m)
  const harvest = plant.value.harvestingMonths.includes(m)
  if (sow && harvest) return 'both'
  if (sow)            return 'sow'
  if (harvest)        return 'harvest'
  return null
}

const pruningTipText = computed(() => {
  if (!plant.value?.pruningType) return ''
  const key = `pruning.tips.${plant.value.name}`
  return te(key) ? t(key) : (plant.value.pruningTip ?? '')
})

const fertilizerTipText = computed(() => {
  if (!plant.value?.fertilizerType) return ''
  const key = `fertilizer.tips.${plant.value.name}`
  return te(key) ? t(key) : (plant.value.fertilizerTip ?? '')
})

async function toggleGarden() {
  const method = inGarden.value ? 'DELETE' : 'PUT'
  await fetch(`/api/garden/${route.params.id}`, { method, headers: csrfHeaders() })
  inGarden.value = !inGarden.value
}

async function toggleCompanionGarden(id) {
  const inG = gardenIds.value.has(id)
  await fetch(`/api/garden/${id}`, { method: inG ? 'DELETE' : 'PUT', headers: csrfHeaders() })
  const next = new Set(gardenIds.value)
  inG ? next.delete(id) : next.add(id)
  gardenIds.value = next
}

async function loadPlant(id) {
  loading.value = true
  plant.value = null
  const [plantRes, gardenRes] = await Promise.all([
    fetch(`/api/plants/${id}`),
    fetch('/api/garden'),
  ])
  if (plantRes.ok) plant.value = await plantRes.json()
  if (gardenRes.ok) {
    const ids = await gardenRes.json()
    inGarden.value = ids.includes(id)
    gardenIds.value = new Set(ids)
  }
  loading.value = false
}

onMounted(() => loadPlant(route.params.id))
watch(() => route.params.id, (id) => { if (id) loadPlant(id) })
</script>

<template>
  <main>
    <button class="back-btn" @click="router.back()">{{ t('back') }}</button>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="plant">
      <div class="detail-card">
        <div class="detail-hero">
          <span class="detail-emoji">{{ plant.emoji ?? '🌱' }}</span>
          <div class="detail-hero-text">
            <h2>{{ localName }}</h2>
            <p v-if="plant.latinName" class="latin-name">{{ plant.latinName }}</p>
            <div class="badges">
              <span class="category-badge">{{ t(`categories.${plant.category}`) }}</span>
              <span v-if="plant.sunRequirement" class="sun-badge">
                {{ t(`sunRequirement.${plant.sunRequirement}`) }}
              </span>
            </div>
          </div>
          <button
            class="garden-btn"
            :class="{ added: inGarden }"
            @click="toggleGarden"
          >
            {{ inGarden ? t('garden.added') : t('garden.add') }}
          </button>
        </div>

        <img
          v-if="plant.imageUrl"
          :src="plant.imageUrl"
          :alt="localName"
          class="detail-image"
        />

        <p class="description">{{ description }}</p>

        <div v-if="plant.sowingGuide || plant.heightMinCm != null" class="sowing-section">
          <h3>{{ t('sowing.title') }}</h3>
          <div class="sowing-grid">
            <div v-if="plant.heightMinCm != null" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.height') }}</span>
              <span class="sowing-value">
                {{ plant.heightMinCm }}–{{ plant.heightMaxCm }} cm
              </span>
            </div>
            <div v-if="plant.sowingGuide?.method" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.method.label') }}</span>
              <span class="sowing-value">{{ t(`sowing.method.${plant.sowingGuide.method}`) }}</span>
            </div>
            <div v-if="plant.sowingGuide?.frostTolerance" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.frost.label') }}</span>
              <span class="sowing-value" :class="`frost-${plant.sowingGuide.frostTolerance}`">
                {{ t(`sowing.frost.${plant.sowingGuide.frostTolerance}`) }}
              </span>
            </div>
            <div v-if="plant.sowingGuide?.seedDepthMm" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.depth') }}</span>
              <span class="sowing-value">{{ plant.sowingGuide.seedDepthMm }} mm</span>
            </div>
            <div v-if="plant.sowingGuide?.spacingCm" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.spacing') }}</span>
              <span class="sowing-value">{{ plant.sowingGuide.spacingCm }} cm</span>
            </div>
            <div v-if="plant.sowingGuide?.germinationDaysMin" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.germination') }}</span>
              <span class="sowing-value">
                {{ plant.sowingGuide.germinationDaysMin }}–{{ plant.sowingGuide.germinationDaysMax }}
                {{ t('sowing.days') }}
              </span>
            </div>
            <div v-if="plant.sowingGuide?.daysToMaturityMin" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.maturity') }}</span>
              <span class="sowing-value">
                {{ plant.sowingGuide.daysToMaturityMin }}–{{ plant.sowingGuide.daysToMaturityMax }}
                {{ t('sowing.days') }}
              </span>
            </div>
          </div>
        </div>

        <div v-if="plant.pruningType" class="pruning-section">
          <h3>{{ t('pruning.title') }}</h3>
          <span class="pruning-badge">{{ t(`pruning.type.${plant.pruningType}`) }}</span>
          <p class="pruning-tip">{{ pruningTipText }}</p>
        </div>

        <div v-if="plant.fertilizerType" class="fertilizer-section">
          <h3>{{ t('fertilizer.title') }}</h3>
          <span class="fertilizer-badge" :class="`fertilizer-${plant.fertilizerType}`">
            {{ t(`fertilizer.type.${plant.fertilizerType}`) }}
          </span>
          <p class="fertilizer-tip">{{ fertilizerTipText }}</p>
        </div>

        <div class="months-section">
          <h3>{{ t('growingCalendar') }}</h3>
          <div class="months-legend">
            <span class="legend-item"><span class="legend-swatch sow" />{{ t('garden.toSow') }}</span>
            <span class="legend-item"><span class="legend-swatch harvest" />{{ t('garden.toHarvest') }}</span>
            <span class="legend-item"><span class="legend-swatch both" />{{ t('garden.both') }}</span>
          </div>
          <div class="calendar-wrap">
            <table class="month-calendar">
              <thead>
                <tr>
                  <th v-for="(name, i) in months" :key="i" class="month-col">{{ name }}</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td v-for="m in 12" :key="m" class="month-cell">
                    <span v-if="monthType(m)" class="cell-bar" :class="monthType(m)" />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-if="plant.companions.length > 0" class="companions-section">
          <h3>{{ t('companions.title') }}</h3>
          <div v-if="goodCompanions.length > 0" class="companion-group">
            <p class="companion-label good">{{ t('companions.good') }}</p>
            <div class="companion-list">
              <div
                v-for="c in goodCompanions"
                :key="c.id"
                class="companion-chip good"
                @click="router.push(`/plant/${c.id}`)"
              >
                {{ c.emoji ?? '🌱' }} {{ te(`plants.${c.name}`) ? t(`plants.${c.name}`) : c.name }}
                <button
                  class="companion-garden-btn"
                  :class="{ added: gardenIds.has(c.id) }"
                  :title="gardenIds.has(c.id) ? t('garden.removeTooltip') : t('garden.addTooltip')"
                  @click.stop="toggleCompanionGarden(c.id)"
                >
                  {{ gardenIds.has(c.id) ? '✓' : '+' }}
                </button>
              </div>
            </div>
          </div>
          <div v-if="badCompanions.length > 0" class="companion-group">
            <p class="companion-label bad">{{ t('companions.bad') }}</p>
            <div class="companion-list">
              <RouterLink
                v-for="c in badCompanions"
                :key="c.id"
                :to="`/plant/${c.id}`"
                class="companion-chip bad"
              >
                {{ c.emoji ?? '🌱' }} {{ te(`plants.${c.name}`) ? t(`plants.${c.name}`) : c.name }}
              </RouterLink>
            </div>
          </div>
        </div>

        <div v-if="plant.insects.length > 0" class="insects-section">
          <h3>{{ t('insects.title') }}</h3>
          <div v-if="pollinators.length > 0" class="insect-group">
            <p class="insect-label pollinator">{{ t('insects.pollinator') }}</p>
            <div class="insect-list">
              <span v-for="i in pollinators" :key="i.name" class="insect-chip pollinator">
                {{ t(`insects.names.${i.name}`) }}
              </span>
            </div>
          </div>
          <div v-if="beneficials.length > 0" class="insect-group">
            <p class="insect-label beneficial">{{ t('insects.beneficial') }}</p>
            <div class="insect-list">
              <span v-for="i in beneficials" :key="i.name" class="insect-chip beneficial">
                {{ t(`insects.names.${i.name}`) }}
              </span>
            </div>
          </div>
          <div v-if="pests.length > 0" class="insect-group">
            <p class="insect-label pest">{{ t('insects.pest') }}</p>
            <div class="insect-list">
              <span v-for="i in pests" :key="i.name" class="insect-chip pest">
                {{ t(`insects.names.${i.name}`) }}
              </span>
            </div>
          </div>
        </div>

        <div v-if="plant.countries.length > 0" class="countries-section">
          <h3>{{ t('countries') }}</h3>
          <div class="country-list">
            <span
              v-for="country in plant.countries"
              :key="country.code"
              class="country-chip"
            >
              {{ te(`countryNames.${country.code}`) ? t(`countryNames.${country.code}`) : country.name }}
            </span>
          </div>
        </div>
      </div>
    </template>
  </main>
</template>

<style scoped>
main {
  max-width: 860px;
  margin: 0 auto;
  padding: 1.5rem 1rem 4rem;
}

.back-btn {
  background: none;
  border: none;
  color: var(--green-mid);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  margin-bottom: 1.5rem;
  display: block;
}

.back-btn:hover { color: var(--green-dark); }

.detail-card {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

@media (max-width: 480px) {
  .detail-card { padding: 1.25rem; }
  .detail-hero h2 { font-size: 1.4rem; }
  .detail-emoji { font-size: 2.75rem; }
}

.detail-hero {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  flex-wrap: wrap;
}

.detail-hero-text { flex: 1; }

.detail-emoji { font-size: 3.5rem; line-height: 1; }

.detail-hero h2 {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 0.35rem;
}

.latin-name {
  font-size: 0.85rem;
  font-style: italic;
  color: var(--text-muted);
  margin: 0.1rem 0 0.2rem;
}

.badges { display: flex; flex-wrap: wrap; gap: 0.4rem; margin-top: 0.35rem; }

.category-badge, .sun-badge {
  display: inline-block;
  padding: 0.2rem 0.65rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.category-badge {
  background: var(--green-pale);
  color: var(--green-mid);
}

.sun-badge {
  background: #fef9c3;
  color: #854d0e;
}

.detail-image {
  width: 100%;
  max-height: 320px;
  object-fit: cover;
  border-radius: calc(var(--radius) - 4px);
  border: 1px solid var(--green-pale);
}

.description {
  font-size: 1rem;
  line-height: 1.6;
  color: var(--text-muted);
  border-top: 1px solid var(--green-pale);
  padding-top: 1.5rem;
}

.sowing-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.sowing-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.75rem;
}

.sowing-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.65rem 1rem;
}

@media (max-width: 480px) {
  .sowing-grid { grid-template-columns: 1fr; }
}

.sowing-stat {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.sowing-label {
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-muted);
}

.sowing-value {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--green-dark);
}

.frost-tender      { color: #b45309; }
.frost-half_hardy  { color: #0369a1; }
.frost-hardy       { color: #0369a1; }
.frost-very_hardy  { color: #1d4ed8; }

.months-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.months-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.65rem;
}

.months-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem 1.25rem;
  margin-bottom: 0.85rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.8rem;
  color: var(--text-muted);
}

.legend-swatch {
  display: inline-block;
  width: 24px;
  height: 8px;
  border-radius: 4px;
  flex-shrink: 0;
}

.legend-swatch.sow     { background: var(--green-mid); }
.legend-swatch.harvest { background: #d97706; }
.legend-swatch.both    { background: linear-gradient(90deg, var(--green-mid) 50%, #d97706 50%); }

.calendar-wrap {
  overflow-x: auto;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  -webkit-overflow-scrolling: touch;
}

.month-calendar {
  border-collapse: collapse;
  width: 100%;
  min-width: 480px;
}

.month-col {
  font-size: 0.7rem;
  font-weight: 700;
  color: var(--text-muted);
  text-align: center;
  padding: 0.5rem 0.25rem;
  border-bottom: 2px solid var(--green-pale);
  white-space: nowrap;
  width: calc(100% / 12);
}

.month-cell {
  padding: 0.5rem 0.2rem;
  text-align: center;
  vertical-align: middle;
}

.cell-bar {
  display: block;
  height: 10px;
  border-radius: 5px;
  margin: 0 2px;
}

.cell-bar.sow     { background: var(--green-mid); }
.cell-bar.harvest { background: #d97706; }
.cell-bar.both    { background: linear-gradient(90deg, var(--green-mid) 50%, #d97706 50%); }

.insects-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.insects-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 1rem;
}

.insect-group { margin-bottom: 1rem; }
.insect-group:last-child { margin-bottom: 0; }

.insect-label {
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.insect-label.pollinator { color: #065f46; }
.insect-label.beneficial { color: #1e40af; }
.insect-label.pest       { color: #991b1b; }

.insect-list { display: flex; flex-wrap: wrap; gap: 0.4rem; }

.insect-chip {
  display: inline-block;
  padding: 0.25rem 0.65rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.insect-chip.pollinator {
  background: #d1fae5;
  color: #065f46;
  border: 1.5px solid #6ee7b7;
}

.insect-chip.beneficial {
  background: #dbeafe;
  color: #1e40af;
  border: 1.5px solid #93c5fd;
}

.insect-chip.pest {
  background: #fee2e2;
  color: #991b1b;
  border: 1.5px solid #fca5a5;
}

.countries-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.countries-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.75rem;
}

.country-list { display: flex; flex-wrap: wrap; gap: 0.4rem; }

.country-chip {
  padding: 0.25rem 0.65rem;
  background: var(--bg);
  border: 1.5px solid var(--green-pale);
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--text-muted);
}

.garden-btn {
  padding: 0.5rem 1rem;
  border-radius: var(--radius);
  border: 1.5px solid var(--green-pale);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
  white-space: nowrap;
}

.garden-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-mid);
}

.garden-btn.added {
  background: var(--green-mid);
  border-color: var(--green-mid);
  color: #fff;
}

.loading { text-align: center; padding: 3rem; color: var(--text-muted); }

.pruning-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.pruning-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.65rem;
}

.pruning-badge {
  display: inline-block;
  padding: 0.2rem 0.65rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  background: #fef3c7;
  color: #92400e;
  margin-bottom: 0.65rem;
}

.pruning-tip {
  font-size: 0.9rem;
  line-height: 1.6;
  color: var(--text-muted);
  margin: 0;
}

.fertilizer-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.fertilizer-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 0.65rem;
}

.fertilizer-badge {
  display: inline-block;
  padding: 0.2rem 0.65rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 0.65rem;
}

.fertilizer-heavy_feeder  { background: #dcfce7; color: #166534; }
.fertilizer-moderate_feeder { background: #d1fae5; color: #065f46; }
.fertilizer-light_feeder  { background: #f0fdf4; color: #15803d; }
.fertilizer-none          { background: #f3f4f6; color: #6b7280; }

.fertilizer-tip {
  font-size: 0.9rem;
  line-height: 1.6;
  color: var(--text-muted);
  margin: 0;
}

.companions-section { border-top: 1px solid var(--green-pale); padding-top: 1.5rem; }

.companions-section h3 {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  margin-bottom: 1rem;
}

.companion-group { margin-bottom: 1rem; }
.companion-group:last-child { margin-bottom: 0; }

.companion-label {
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.companion-label.good { color: #065f46; }
.companion-label.bad  { color: #991b1b; }

.companion-list { display: flex; flex-wrap: wrap; gap: 0.4rem; }

.companion-garden-btn {
  flex-shrink: 0;
  width: 1.5rem;
  height: 1.5rem;
  border-radius: 50%;
  border: 1.5px solid var(--green-pale);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.95rem;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}

.companion-garden-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-mid);
}

.companion-garden-btn.added {
  background: var(--green-mid);
  border-color: var(--green-mid);
  color: #fff;
}

@media (pointer: coarse) {
  .companion-garden-btn { width: 2.5rem; height: 2.5rem; font-size: 1.1rem; }
}

.companion-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.25rem 0.4rem 0.25rem 0.65rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: opacity 0.15s;
}

.companion-chip:hover { opacity: 0.8; }

.companion-chip.good {
  background: #d1fae5;
  color: #065f46;
  border: 1.5px solid #6ee7b7;
}

.companion-chip.bad {
  background: #fee2e2;
  color: #991b1b;
  border: 1.5px solid #fca5a5;
}
</style>

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

const pruningTipText = computed(() => {
  if (!plant.value?.pruningType) return ''
  const key = `pruning.tips.${plant.value.name}`
  return te(key) ? t(key) : (plant.value.pruningTip ?? '')
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

        <div v-if="plant.sowingGuide" class="sowing-section">
          <h3>{{ t('sowing.title') }}</h3>
          <div class="sowing-grid">
            <div v-if="plant.sowingGuide.method" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.method.label') }}</span>
              <span class="sowing-value">{{ t(`sowing.method.${plant.sowingGuide.method}`) }}</span>
            </div>
            <div v-if="plant.sowingGuide.frostTolerance" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.frost.label') }}</span>
              <span class="sowing-value" :class="`frost-${plant.sowingGuide.frostTolerance}`">
                {{ t(`sowing.frost.${plant.sowingGuide.frostTolerance}`) }}
              </span>
            </div>
            <div v-if="plant.sowingGuide.seedDepthMm" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.depth') }}</span>
              <span class="sowing-value">{{ plant.sowingGuide.seedDepthMm }} mm</span>
            </div>
            <div v-if="plant.sowingGuide.spacingCm" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.spacing') }}</span>
              <span class="sowing-value">{{ plant.sowingGuide.spacingCm }} cm</span>
            </div>
            <div v-if="plant.sowingGuide.germinationDaysMin" class="sowing-stat">
              <span class="sowing-label">{{ t('sowing.germination') }}</span>
              <span class="sowing-value">
                {{ plant.sowingGuide.germinationDaysMin }}–{{ plant.sowingGuide.germinationDaysMax }}
                {{ t('sowing.days') }}
              </span>
            </div>
            <div v-if="plant.sowingGuide.daysToMaturityMin" class="sowing-stat">
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

        <div class="months-section">
          <h3>{{ t('seedingMonths') }}</h3>
          <div class="months-grid">
            <div
              v-for="(name, i) in months"
              :key="i"
              class="month-chip"
              :class="{ active: plant.seedingMonths.includes(i + 1) }"
            >
              {{ name }}
            </div>
          </div>
        </div>

        <div class="months-section">
          <h3>{{ t('harvestingMonths') }}</h3>
          <div class="months-grid">
            <div
              v-for="(name, i) in months"
              :key="i"
              class="month-chip harvest"
              :class="{ active: plant.harvestingMonths.includes(i + 1) }"
            >
              {{ name }}
            </div>
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
  margin-bottom: 0.75rem;
}

.months-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 0.4rem;
}

@media (max-width: 480px) {
  .months-grid { grid-template-columns: repeat(4, 1fr); }
}

@media (max-width: 360px) {
  .months-grid { grid-template-columns: repeat(3, 1fr); }
}

.month-chip {
  padding: 0.45rem 0.25rem;
  text-align: center;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  background: var(--bg);
  color: var(--text-muted);
}

.month-chip.active {
  background: var(--green-mid);
  color: #fff;
}

.month-chip.harvest.active {
  background: #d97706;
  color: #fff;
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

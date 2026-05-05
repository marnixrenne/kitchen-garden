<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const router = useRouter()
const { t, tm, te } = useI18n()

const vegetables = ref([])
const loading     = ref(true)
const selectedMonth = ref(null)

const months = computed(() => tm('months'))

function vegName(veg) {
  const key = `vegetables.${veg.name}`
  return te(key) ? t(key) : veg.name
}

function hasSowing(month)    { return vegetables.value.some(v => v.seedingMonths.includes(month)) }
function hasHarvesting(month) { return vegetables.value.some(v => v.harvestingMonths.includes(month)) }
function hasActivity(month)   { return hasSowing(month) || hasHarvesting(month) }

const toSow     = computed(() => selectedMonth.value == null ? [] :
  vegetables.value.filter(v => v.seedingMonths.includes(selectedMonth.value)))
const toHarvest = computed(() => selectedMonth.value == null ? [] :
  vegetables.value.filter(v => v.harvestingMonths.includes(selectedMonth.value)))

function selectMonth(month) {
  selectedMonth.value = selectedMonth.value === month ? null : month
}

onMounted(async () => {
  const res = await fetch('/api/garden/details')
  if (res.ok) vegetables.value = await res.json()
  loading.value = false
})
</script>

<template>
  <main>
    <h2 class="page-title">{{ t('myGarden') }}</h2>

    <div v-if="loading" class="loading">{{ t('loading') }}</div>

    <template v-else-if="vegetables.length === 0">
      <p class="empty">{{ t('garden.empty') }}</p>
    </template>

    <template v-else>
      <div class="months-grid">
        <button
          v-for="(name, i) in months"
          :key="i"
          class="month-btn"
          :class="{
            active:    selectedMonth === i + 1,
            'has-sow': hasSowing(i + 1),
            'has-harvest': hasHarvesting(i + 1),
          }"
          @click="selectMonth(i + 1)"
        >
          {{ name }}
          <span class="dots">
            <span v-if="hasSowing(i + 1)"    class="dot sow" />
            <span v-if="hasHarvesting(i + 1)" class="dot harvest" />
          </span>
        </button>
      </div>

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
  max-width: 860px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 1.5rem;
}

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}

.months-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 0.5rem;
  margin-bottom: 2rem;
}

@media (max-width: 480px) {
  .months-grid { grid-template-columns: repeat(4, 1fr); }
}

.month-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.3rem;
  padding: 0.6rem 0.25rem 0.4rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}

.month-btn:hover {
  border-color: var(--green-light);
  color: var(--green-dark);
}

.month-btn.has-sow   { border-color: var(--green-mid); }
.month-btn.has-harvest { border-color: #d97706; }
.month-btn.has-sow.has-harvest { border-color: var(--green-mid); }

.month-btn.active {
  background: var(--green-dark);
  border-color: var(--green-dark);
  color: #fff;
}

.dots {
  display: flex;
  gap: 3px;
  height: 6px;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.dot.sow     { background: var(--green-mid); }
.dot.harvest { background: #d97706; }

.month-btn.active .dot.sow     { background: rgba(255,255,255,0.7); }
.month-btn.active .dot.harvest { background: rgba(255,255,255,0.9); }

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

.veg-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

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

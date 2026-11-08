import { describe, it, expect, vi, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import PlantDetailView from '../PlantDetailView.vue'

// ---------------------------------------------------------------------------
// Minimal i18n setup
// ---------------------------------------------------------------------------
const i18n = createI18n({
  legacy: false,
  locale: 'en',
  messages: {
    en: {
      back: 'Back',
      loading: 'Loading…',
      months: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
      seedingMonths: 'Seeding months',
      harvestingMonths: 'Harvesting months',
      categories: { Fruiting: 'Fruiting', Flower: 'Flowers', Herb: 'Herbs', Brassica: 'Brassica' },
      sunRequirement: { full_sun: 'Full sun', partial_shade: 'Partial shade' },
      companions: { title: 'Companions', good: 'Good companions', bad: 'Bad companions' },
      garden: { add: 'Add', added: 'Added', addTooltip: 'Add to garden', removeTooltip: 'Remove from garden', toSow: 'To sow', toHarvest: 'To harvest', both: 'Both' },
      countries: 'Countries',
      countryNames: {},
      plants: {},
      descriptions: {},
      pruning: { title: 'Pruning', type: {}, tips: {} },
      fertilizer: { title: 'Fertilizer', type: {}, tips: {} },
      insects: { title: 'Insects', pollinator: 'Pollinators', beneficial: 'Beneficial', pest: 'Pests', names: {} },
      lifespan: { annual: 'Annual', biennial: 'Biennial', perennial: 'Perennial' },
      growingCalendar: 'Growing calendar',
      sowing: {
        title: 'Sowing guide',
        method: { label: 'Method', indoor: 'Indoor', direct: 'Direct', both: 'Both' },
        frost: { label: 'Frost tolerance' },
        depth: 'Seed depth',
        spacing: 'Spacing',
        germination: 'Germination',
        maturity: 'Days to maturity',
        days: 'days',
      },
    },
  },
})

// ---------------------------------------------------------------------------
// Fixture plants
// ---------------------------------------------------------------------------
const TOMATO = {
  id: 'aaaaaaaa-0000-0000-0000-000000000001',
  name: 'Tomato',
  category: 'Fruiting',
  emoji: '🍅',
  imageUrl: null,
  lifespan: 'annual',
  sunRequirement: 'full_sun',
  pruningType: null,
  fertilizerType: null,
  sowingGuide: null,
  seedingMonths: [3, 4],
  harvestingMonths: [7, 8, 9],
  countries: [],
  companions: [
    { id: 'bbbbbbbb-0000-0000-0000-000000000002', name: 'Basil', emoji: '🌿', relationship: 'good' },
  ],
  insects: [],
}

const NASTURTIUM = {
  id: 'cccccccc-0000-0000-0000-000000000003',
  name: 'Nasturtium',
  category: 'Flower',
  emoji: '🌸',
  imageUrl: null,
  lifespan: 'annual',
  sunRequirement: 'partial_shade',
  pruningType: null,
  fertilizerType: null,
  sowingGuide: null,
  seedingMonths: [4, 5],
  harvestingMonths: [6, 7, 8, 9],
  countries: [],
  companions: [
    { id: TOMATO.id, name: 'Tomato', emoji: '🍅', relationship: 'good' },
  ],
  insects: [],
}

const PLANTS = {
  [TOMATO.id]: TOMATO,
  [NASTURTIUM.id]: NASTURTIUM,
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function makeFetch(gardenIds = []) {
  return vi.fn(async (url, options) => {
    if (url.match(/^\/api\/gardens\/[^/]+\/instances$/)) {
      return { ok: true, json: async () => gardenIds.map(plantId => ({ plantId })) }
    }
    if (url.match(/^\/api\/gardens\//)) {
      return { ok: true, json: async () => ({}) }
    }
    const match = url.match(/^\/api\/plants\/(.+)$/)
    if (match) {
      const plant = PLANTS[match[1]]
      if (plant) return { ok: true, json: async () => plant }
    }
    return { ok: false, json: async () => ({}) }
  })
}

function makeRouter() {
  return createRouter({
    history: createMemoryHistory(),
    routes: [{ path: '/plant/:id', component: PlantDetailView }],
  })
}

async function mountAt(router, plantId, gardenIds = []) {
  global.fetch = makeFetch(gardenIds)
  await router.push(`/plant/${plantId}`)
  const wrapper = mount(PlantDetailView, {
    global: { plugins: [router, i18n] },
  })
  await flushPromises()
  return wrapper
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
describe('PlantDetailView', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('loads plant data on mount and displays the name', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id)

    expect(wrapper.text()).toContain('Tomato')
  })

  it('shows companion plant chips', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id)

    expect(wrapper.text()).toContain('Basil')
  })

  it('reloads data when route param changes (navigating via companion chip)', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id)

    expect(wrapper.text()).toContain('Tomato')

    // Simulate clicking a companion chip: navigate to another plant
    await router.push(`/plant/${NASTURTIUM.id}`)
    await flushPromises()

    // Component should now show the new plant
    expect(wrapper.text()).toContain('Nasturtium')
    expect(wrapper.text()).not.toContain('Basil') // Tomato's companion
    expect(wrapper.text()).toContain('Tomato')    // Nasturtium's companion
  })

  it('adding a companion creates a planting and shows the new count', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, [])
    expect(wrapper.find('.garden-count').exists()).toBe(false)

    await wrapper.find('.companion-garden-btn').trigger('click')
    await flushPromises()

    const [url, options] = global.fetch.mock.calls.find(([, o]) => o?.method === 'POST')
    expect(url).toContain(`/plants/${TOMATO.companions[0].id}`)
    expect(options.method).toBe('POST')
    expect(wrapper.find('.garden-count').text()).toBe('1×')
  })

  it('adds another planting of a companion already in the garden, never removing it', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, [TOMATO.companions[0].id])
    expect(wrapper.find('.companion-garden-btn').text()).toBe('+')
    expect(wrapper.find('.garden-count').text()).toBe('1×')

    await wrapper.find('.companion-garden-btn').trigger('click')
    await flushPromises()

    expect(global.fetch.mock.calls.some(([, o]) => o?.method === 'DELETE')).toBe(false)
    expect(wrapper.find('.garden-count').text()).toBe('2×')
  })

  it('companion button click does not also navigate to the companion', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, [])

    await wrapper.find('.companion-garden-btn').trigger('click')
    await flushPromises()

    expect(router.currentRoute.value.params.id).toBe(TOMATO.id)
  })
})

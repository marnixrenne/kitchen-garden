import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import VegetableDetailView from '../VegetableDetailView.vue'

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
      garden: { add: 'Add', added: 'Added', addTooltip: 'Add to garden', removeTooltip: 'Remove from garden' },
      countries: 'Countries',
      countryNames: {},
      vegetables: {},
      descriptions: {},
      pruning: { title: 'Pruning', type: {}, tips: {} },
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
// Fixture vegetables
// ---------------------------------------------------------------------------
const TOMATO = {
  id: 'aaaaaaaa-0000-0000-0000-000000000001',
  name: 'Tomato',
  category: 'Fruiting',
  emoji: '🍅',
  imageUrl: null,
  sunRequirement: 'full_sun',
  pruningType: null,
  pruningTip: null,
  sowingGuide: null,
  seedingMonths: [3, 4],
  harvestingMonths: [7, 8, 9],
  countries: [],
  companions: [
    { id: 'bbbbbbbb-0000-0000-0000-000000000002', name: 'Basil', emoji: '🌿', relationship: 'good' },
  ],
}

const NASTURTIUM = {
  id: 'cccccccc-0000-0000-0000-000000000003',
  name: 'Nasturtium',
  category: 'Flower',
  emoji: '🌸',
  imageUrl: null,
  sunRequirement: 'partial_shade',
  pruningType: null,
  pruningTip: null,
  sowingGuide: null,
  seedingMonths: [4, 5],
  harvestingMonths: [6, 7, 8, 9],
  countries: [],
  companions: [
    { id: TOMATO.id, name: 'Tomato', emoji: '🍅', relationship: 'good' },
  ],
}

const VEGETABLES = {
  [TOMATO.id]: TOMATO,
  [NASTURTIUM.id]: NASTURTIUM,
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function makeFetch(gardenIds = []) {
  return vi.fn(async (url, options) => {
    if (url === '/api/garden' && (!options || options.method === undefined)) {
      return { ok: true, json: async () => gardenIds }
    }
    if (url.startsWith('/api/garden/')) {
      // PUT / DELETE: upsert or remove — just succeed
      return { ok: true, json: async () => ({}) }
    }
    const match = url.match(/^\/api\/vegetables\/(.+)$/)
    if (match) {
      const veg = VEGETABLES[match[1]]
      if (veg) return { ok: true, json: async () => veg }
    }
    return { ok: false, json: async () => ({}) }
  })
}

function makeRouter() {
  return createRouter({
    history: createMemoryHistory(),
    routes: [{ path: '/vegetable/:id', component: VegetableDetailView }],
  })
}

async function mountAt(router, vegetableId, gardenIds = []) {
  global.fetch = makeFetch(gardenIds)
  // Navigate first so route.params.id is set when the component mounts
  await router.push(`/vegetable/${vegetableId}`)
  const wrapper = mount(VegetableDetailView, {
    global: { plugins: [router, i18n] },
  })
  await flushPromises()
  return wrapper
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
describe('VegetableDetailView', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('loads vegetable data on mount and displays the name', async () => {
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

    // Simulate clicking a companion chip: navigate to another vegetable
    await router.push(`/vegetable/${NASTURTIUM.id}`)
    await flushPromises()

    // Component should now show the new vegetable
    expect(wrapper.text()).toContain('Nasturtium')
    expect(wrapper.text()).not.toContain('Basil') // Tomato's companion
    expect(wrapper.text()).toContain('Tomato')    // Nasturtium's companion
  })

  it('companion garden button toggles from + to ✓ when clicked', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, []) // garden is empty

    // Find the + button next to Basil
    const addBtn = wrapper.find('.companion-garden-btn')
    expect(addBtn.text()).toBe('+')

    await addBtn.trigger('click')
    await flushPromises()

    // Button should now show ✓
    expect(addBtn.text()).toBe('✓')
  })

  it('companion garden button shows ✓ when companion is already in garden', async () => {
    const router = makeRouter()
    // Basil (TOMATO's companion) is already in the garden
    const wrapper = await mountAt(router, TOMATO.id, [TOMATO.companions[0].id])

    const addBtn = wrapper.find('.companion-garden-btn')
    expect(addBtn.text()).toBe('✓')
  })

  it('companion garden button toggles back to + when removing from garden', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, [TOMATO.companions[0].id])

    const addBtn = wrapper.find('.companion-garden-btn')
    expect(addBtn.text()).toBe('✓')

    await addBtn.trigger('click')
    await flushPromises()

    expect(addBtn.text()).toBe('+')
  })

  it('companion chip click does not also trigger the garden toggle', async () => {
    const router = makeRouter()
    const wrapper = await mountAt(router, TOMATO.id, [])

    // Click the button (inner): should NOT trigger navigation
    const addBtn = wrapper.find('.companion-garden-btn')
    await addBtn.trigger('click')
    await flushPromises()

    // Still on Tomato's page
    expect(router.currentRoute.value.params.id).toBe(TOMATO.id)
    // Button toggled
    expect(addBtn.text()).toBe('✓')
  })
})

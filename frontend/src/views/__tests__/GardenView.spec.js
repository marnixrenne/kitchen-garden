import { describe, it, expect, vi, afterEach, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import GardenView from '../GardenView.vue'
import BedPickerModal from '../../components/BedPickerModal.vue'
import { setActiveGarden } from '../../stores/garden.js'
import { chooseBed } from '../../stores/bedPicker.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------
const GARDEN = 'garden-1'

const MAIN_BED  = { id: 'bed-main',  name: null,    type: null, lengthCm: null, widthCm: null, sunExposure: null,    aspect: null }
const HERBS_BED = { id: 'bed-herbs', name: 'Herbs', type: 'raised', lengthCm: 200, widthCm: 100, sunExposure: 'shade', aspect: 'N' }

function plant(id, name, sunRequirement) {
  return { id, name, emoji: null, sunRequirement, seedingMonths: [3], harvestingMonths: [8] }
}

const TOMATO = plant('p-tomato', 'Tomato', 'full_sun')
const BASIL  = plant('p-basil',  'Basil',  'full_sun')

function makeFetch({ beds, instances, plants = [TOMATO, BASIL], extra = {} }) {
  const routes = {
    [`/api/gardens/${GARDEN}/details`]:     plants,
    [`/api/gardens/${GARDEN}/suggestions`]: { sunGroups: [], conflicts: [] },
    [`/api/gardens/${GARDEN}/beds`]:        beds,
    [`/api/gardens/${GARDEN}/instances`]:   instances,
    [`/api/gardens/${GARDEN}/plant-log`]:   {},
    [`/api/gardens/${GARDEN}/plan`]:        {},
    [`/api/gardens/${GARDEN}/lifecycle`]:   {},
    ...extra,
  }
  return vi.fn(async (url) => {
    if (url in routes) return { ok: true, json: async () => routes[url] }
    return { ok: false, json: async () => ({}) }
  })
}

async function mountGarden(fetchConfig) {
  global.fetch = makeFetch(fetchConfig)
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [{ path: '/garden', component: GardenView }, { path: '/plant/:id', component: { template: '<div />' } }],
  })
  await router.push('/garden?tab=calendar')
  const wrapper = mount(GardenView, {
    global: { plugins: [router, i18n], stubs: { ThisWeekCard: true, Teleport: true } },
  })
  await flushPromises()
  return wrapper
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
describe('GardenView beds', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  it('with a single bed shows no bed headers or move action, only a bed settings link', async () => {
    const wrapper = await mountGarden({
      beds: [MAIN_BED],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, bedId: MAIN_BED.id, sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  bedId: MAIN_BED.id, sunShortfall: false },
      ],
    })

    expect(wrapper.findAll('.bed-row')).toHaveLength(0)
    expect(wrapper.findAll('.move-btn')).toHaveLength(0)
    expect(wrapper.find('.bed-settings-link').text()).toBe('Bed settings')
    expect(wrapper.findAll('.plant-row')).toHaveLength(2)
  })

  it('with several beds groups plants under bed headers in creation order', async () => {
    const wrapper = await mountGarden({
      beds: [MAIN_BED, HERBS_BED],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, bedId: MAIN_BED.id,  sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  bedId: HERBS_BED.id, sunShortfall: true },
      ],
    })

    const rows = wrapper.findAll('tbody tr').map(r =>
      r.classes('bed-row') ? `bed:${r.find('.bed-name').text()}` : r.classes('plant-row') ? `plant:${r.find('.plant-name').text()}` : null
    ).filter(Boolean)
    expect(rows[0]).toBe('bed:Main bed')
    expect(rows[1]).toMatch(/^plant:.*Tomato/)
    expect(rows[2]).toBe('bed:Herbs')
    expect(rows[3]).toMatch(/^plant:.*Basil/)
    expect(wrapper.find('.bed-details').text()).toContain('Raised bed')
    expect(wrapper.findAll('.move-btn')).toHaveLength(2)
    expect(wrapper.find('.bed-settings-link').exists()).toBe(false)
  })

  it('shows a sun warning only on plants whose bed gets too little sun', async () => {
    const wrapper = await mountGarden({
      beds: [MAIN_BED, HERBS_BED],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, bedId: MAIN_BED.id,  sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  bedId: HERBS_BED.id, sunShortfall: true },
      ],
    })

    const warnings = wrapper.findAll('.plant-row').filter(r => r.find('.sun-warning').exists())
    expect(warnings).toHaveLength(1)
    expect(warnings[0].text()).toContain('Basil')
  })

  it('shows a logged move with its source and destination bed', async () => {
    global.fetch = makeFetch({
      beds: [MAIN_BED, HERBS_BED],
      instances: [{ id: 'i-basil', plantId: BASIL.id, bedId: HERBS_BED.id, sunShortfall: false }],
      extra: {
        [`/api/gardens/${GARDEN}/plant-log`]: {
          'i-basil': [{ id: 'e1', action: 'moved', date: '2025-05-02', comment: null, fromBedId: null, toBedId: HERBS_BED.id, fromBedName: null, toBedName: 'Herbs' }],
        },
      },
    })
    const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/garden', component: GardenView }] })
    await router.push('/garden?tab=log')
    const wrapper = mount(GardenView, { global: { plugins: [router, i18n], stubs: { ThisWeekCard: true, Teleport: true } } })
    await flushPromises()

    expect(wrapper.find('.log-move').text()).toBe('Main bed → Herbs')
    expect(wrapper.find('.log-edit-btn').exists()).toBe(true)
  })
})

describe('bed picker', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  function mountPicker(beds) {
    global.fetch = makeFetch({
      beds,
      instances: [],
      extra: { [`/api/plants/${TOMATO.id}`]: TOMATO },
    })
    return mount(BedPickerModal, { global: { plugins: [i18n], stubs: { Teleport: true } } })
  }

  it('skips the question when the garden has a single bed', async () => {
    mountPicker([MAIN_BED])

    await expect(chooseBed(TOMATO.id)).resolves.toBeUndefined()
  })

  it('requires an explicit choice with nothing preselected and warns about too little sun', async () => {
    const wrapper = mountPicker([MAIN_BED, HERBS_BED])

    const choice = chooseBed(TOMATO.id)
    await flushPromises()

    expect(wrapper.findAll('input[type=radio]').some(r => r.element.checked)).toBe(false)
    expect(wrapper.find('.bp-confirm').attributes('disabled')).toBeDefined()
    const options = wrapper.findAll('.bp-option')
    expect(options[0].find('.bp-warning').exists()).toBe(false) // sun unknown
    expect(options[1].find('.bp-warning').exists()).toBe(true)  // shade bed, full sun plant

    await options[1].find('input').setValue(true)
    await wrapper.find('.bp-confirm').trigger('click')

    await expect(choice).resolves.toBe(HERBS_BED.id)
  })

  it('resolves with null when cancelled', async () => {
    const wrapper = mountPicker([MAIN_BED, HERBS_BED])

    const choice = chooseBed(TOMATO.id)
    await flushPromises()
    await wrapper.find('.bp-cancel').trigger('click')

    await expect(choice).resolves.toBeNull()
  })
})

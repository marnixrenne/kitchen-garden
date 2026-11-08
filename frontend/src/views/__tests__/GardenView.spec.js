import { describe, it, expect, vi, afterEach, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import GardenView from '../GardenView.vue'
import ThisWeekCard from '../../components/ThisWeekCard.vue'
import ZonePickerModal from '../../components/ZonePickerModal.vue'
import { gardens, setActiveGarden } from '../../stores/garden.js'
import { chooseZone } from '../../stores/zonePicker.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------
const GARDEN = 'garden-1'

const MAIN_ZONE  = { id: 'zone-main',  name: null,    type: null, lengthCm: null, widthCm: null, sunExposure: null,    aspect: null }
const HERBS_ZONE = { id: 'zone-herbs', name: 'Herbs', type: 'raised', lengthCm: 200, widthCm: 100, sunExposure: 'shade', aspect: 'N' }

function plant(id, name, sunRequirement) {
  return { id, name, emoji: null, sunRequirement, seedingMonths: [3], harvestingMonths: [8] }
}

const TOMATO = plant('p-tomato', 'Tomato', 'full_sun')
const BASIL  = plant('p-basil',  'Basil',  'full_sun')

function makeFetch({ zones, instances, plants = [TOMATO, BASIL], extra = {} }) {
  const routes = {
    [`/api/gardens/${GARDEN}/details`]:     plants,
    [`/api/gardens/${GARDEN}/suggestions`]: { sunGroups: [], conflicts: [] },
    [`/api/gardens/${GARDEN}/zones`]:        zones,
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
    routes: [{ path: '/', component: { template: '<div />' } }, { path: '/garden', component: GardenView }, { path: '/plant/:id', component: { template: '<div />' } }],
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
describe('GardenView zones', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  it('with a single zone shows no zone headers or move action', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, zoneId: MAIN_ZONE.id, sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  zoneId: MAIN_ZONE.id, sunShortfall: false },
      ],
    })

    expect(wrapper.findAll('.zone-row')).toHaveLength(0)
    expect(wrapper.findAll('.move-btn')).toHaveLength(0)
    expect(wrapper.findAll('.plant-row')).toHaveLength(2)
  })

  it('with several zones groups plants under zone headers in creation order', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  zoneId: HERBS_ZONE.id, sunShortfall: true },
      ],
    })

    const rows = wrapper.findAll('tbody tr').map(r =>
      r.classes('zone-row') ? `zone:${r.find('.zone-name').text()}` : r.classes('plant-row') ? `plant:${r.find('.plant-name').text()}` : null
    ).filter(Boolean)
    expect(rows[0]).toBe('zone:Main zone')
    expect(rows[1]).toMatch(/^plant:.*Tomato/)
    expect(rows[2]).toBe('zone:Herbs')
    expect(rows[3]).toMatch(/^plant:.*Basil/)
    expect(wrapper.find('.zone-details').text()).toContain('Raised bed')
    expect(wrapper.findAll('.move-btn')).toHaveLength(2)
  })

  it('shows one calendar row per planting, telling plantings of one plant in a zone apart', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [
        { id: 'i-a', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-b', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-c', plantId: TOMATO.id, zoneId: HERBS_ZONE.id, sunShortfall: false },
      ],
      extra: { [`/api/gardens/${GARDEN}/plant-log`]: { 'i-a': [{ id: 'e1', action: 'planting', date: '2025-05-02', comment: null }] } },
    })

    const rows = wrapper.findAll('.plant-row')
    expect(rows).toHaveLength(3)
    expect(wrapper.findAll('.planting-tag').map(tag => tag.text())).toEqual(expect.arrayContaining([expect.stringContaining('May'), en.garden.notSownYet]))
    expect(wrapper.findAll('.planting-tag')).toHaveLength(2)
  })

  it('moves the planting whose row was used', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [
        { id: 'i-a', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-b', plantId: TOMATO.id, zoneId: HERBS_ZONE.id, sunShortfall: false },
      ],
    })

    await wrapper.findAll('.move-btn')[1].trigger('click')

    const options = wrapper.findAll('[role="dialog"] option').map(o => o.attributes('value'))
    expect(options).toContain(MAIN_ZONE.id)
    expect(options).not.toContain(HERBS_ZONE.id)
  })

  it('lists a plant once in the month summary however many plantings it has', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [
        { id: 'i-a', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-b', plantId: TOMATO.id, zoneId: HERBS_ZONE.id, sunShortfall: false },
      ],
    })

    await wrapper.findAll('.month-header')[2].trigger('click')

    expect(wrapper.find('.activity').text().match(/Tomato/g)).toHaveLength(1)
  })

  it('shows a sun warning only on plants whose zone gets too little sun', async () => {
    const wrapper = await mountGarden({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [
        { id: 'i-tomato', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
        { id: 'i-basil',  plantId: BASIL.id,  zoneId: HERBS_ZONE.id, sunShortfall: true },
      ],
    })

    const warnings = wrapper.findAll('.plant-row').filter(r => r.find('.sun-warning').exists())
    expect(warnings).toHaveLength(1)
    expect(warnings[0].text()).toContain('Basil')
  })

  it('shows a logged move with its source and destination zone', async () => {
    global.fetch = makeFetch({
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: [{ id: 'i-basil', plantId: BASIL.id, zoneId: HERBS_ZONE.id, sunShortfall: false }],
      extra: {
        [`/api/gardens/${GARDEN}/plant-log`]: {
          'i-basil': [{ id: 'e1', action: 'moved', date: '2025-05-02', comment: null, fromZoneId: null, toZoneId: HERBS_ZONE.id, fromZoneName: null, toZoneName: 'Herbs' }],
        },
      },
    })
    const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/garden', component: GardenView }] })
    await router.push('/garden?tab=log')
    const wrapper = mount(GardenView, { global: { plugins: [router, i18n], stubs: { ThisWeekCard: true, Teleport: true } } })
    await flushPromises()

    expect(wrapper.find('.log-move').text()).toBe('Main zone → Herbs')
    expect(wrapper.find('.log-edit-btn').exists()).toBe(true)
  })
})

describe('zone picker', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  function mountPicker(zones) {
    global.fetch = makeFetch({
      zones,
      instances: [],
      extra: { [`/api/plants/${TOMATO.id}`]: TOMATO },
    })
    return mount(ZonePickerModal, { global: { plugins: [i18n], stubs: { Teleport: true } } })
  }

  it('skips the question when the garden has a single zone', async () => {
    mountPicker([MAIN_ZONE])

    await expect(chooseZone(TOMATO.id)).resolves.toBeUndefined()
  })

  it('requires an explicit choice with nothing preselected and warns about too little sun', async () => {
    const wrapper = mountPicker([MAIN_ZONE, HERBS_ZONE])

    const choice = chooseZone(TOMATO.id)
    await flushPromises()

    expect(wrapper.findAll('input[type=radio]').some(r => r.element.checked)).toBe(false)
    expect(wrapper.find('.bp-confirm').attributes('disabled')).toBeDefined()
    const options = wrapper.findAll('.bp-option')
    expect(options[0].find('.bp-warning').exists()).toBe(false) // sun unknown
    expect(options[1].find('.bp-warning').exists()).toBe(true)  // shade zone, full sun plant

    await options[1].find('input').setValue(true)
    await wrapper.find('.bp-confirm').trigger('click')

    await expect(choice).resolves.toBe(HERBS_ZONE.id)
  })

  it('resolves with null when cancelled', async () => {
    const wrapper = mountPicker([MAIN_ZONE, HERBS_ZONE])

    const choice = chooseZone(TOMATO.id)
    await flushPromises()
    await wrapper.find('.bp-cancel').trigger('click')

    await expect(choice).resolves.toBeNull()
  })
})

describe('GardenView scoped to one zone', () => {
  const INSTANCES = [
    { id: 'i-tomato', plantId: TOMATO.id, zoneId: MAIN_ZONE.id,  sunShortfall: false },
    { id: 'i-basil',  plantId: BASIL.id,  zoneId: HERBS_ZONE.id, sunShortfall: false },
  ]

  async function mountAt(path, fetchConfig) {
    global.fetch = makeFetch(fetchConfig)
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', component: { template: '<div />' } },
        { path: '/gardens/:gardenId', component: { template: '<div />' } },
        { path: '/gardens/:gardenId/zones/:zoneId', component: { template: '<div />' } },
      ],
    })
    await router.push(path)
    const wrapper = mount(GardenView, {
      global: { plugins: [router, i18n], stubs: { ThisWeekCard: true, Teleport: true } },
    })
    await flushPromises()
    return { wrapper, router }
  }

  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  it('shows only the plants of that zone in the calendar, titled with the zone', async () => {
    const { wrapper } = await mountAt(`/gardens/${GARDEN}/zones/${HERBS_ZONE.id}?tab=calendar`, { zones: [MAIN_ZONE, HERBS_ZONE], instances: INSTANCES })

    expect(wrapper.find('.page-title').text()).toBe('Herbs')
    const rows = wrapper.findAll('.plant-row')
    expect(rows).toHaveLength(1)
    expect(rows[0].text()).toContain('Basil')
    expect(wrapper.find('.zone-toolbar').exists()).toBe(false)
  })

  it('shows only log entries of plants in that zone', async () => {
    const entry = (id) => ({ id, action: 'watering', date: '2025-05-02', comment: null })
    const { wrapper } = await mountAt(`/gardens/${GARDEN}/zones/${HERBS_ZONE.id}?tab=log`, {
      zones: [MAIN_ZONE, HERBS_ZONE],
      instances: INSTANCES,
      extra: { [`/api/gardens/${GARDEN}/plant-log`]: { 'i-tomato': [entry('e1')], 'i-basil': [entry('e2')] } },
    })

    expect(wrapper.text()).toContain('Basil')
    expect(wrapper.text()).not.toContain('Tomato')
  })

  it('passes the zone to the this-week card', async () => {
    const { wrapper } = await mountAt(`/gardens/${GARDEN}/zones/${HERBS_ZONE.id}`, { zones: [MAIN_ZONE, HERBS_ZONE], instances: INSTANCES })

    expect(wrapper.findComponent(ThisWeekCard).props('zoneId')).toBe(HERBS_ZONE.id)
  })

  it('adds a zone from the this-week tab and hands it to the card', async () => {
    const zones = [MAIN_ZONE]
    const { wrapper } = await mountAt(`/gardens/${GARDEN}`, { zones, instances: [] })

    await wrapper.find('.add-zone-btn').trigger('click')
    await wrapper.find('.bf-field input').setValue('Herbs')
    zones.push(HERBS_ZONE)  // what the next fetch of the zones returns
    await wrapper.find('.eg-save').trigger('click')
    await flushPromises()

    const [url] = global.fetch.mock.calls.find(([, options]) => options?.method === 'POST')
    expect(url).toBe(`/api/gardens/${GARDEN}/zones`)
    expect(wrapper.findComponent(ThisWeekCard).props('zones').map(z => z.id)).toEqual([MAIN_ZONE.id, HERBS_ZONE.id])
  })

  it('offers adding a zone above the tabs on every tab, but not on a zone page', async () => {
    const config = { zones: [MAIN_ZONE, HERBS_ZONE], instances: INSTANCES }

    for (const query of ['', '?tab=calendar', '?tab=log']) {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}${query}`, config)
      expect(wrapper.find('.page-header .add-zone-btn').exists()).toBe(true)
    }
    expect((await mountAt(`/gardens/${GARDEN}/zones/${HERBS_ZONE.id}`, config)).wrapper.find('.add-zone-btn').exists()).toBe(false)
  })

  it('opens the settings of the zone the this-week card asks for', async () => {
    const { wrapper } = await mountAt(`/gardens/${GARDEN}`, { zones: [MAIN_ZONE, HERBS_ZONE], instances: INSTANCES })

    wrapper.findComponent(ThisWeekCard).vm.$emit('edit-zone', HERBS_ZONE)
    await flushPromises()

    expect(wrapper.find('.eg-header').text()).toBe('Edit zone')
    expect(wrapper.find('.bf-field input').element.value).toBe('Herbs')
  })

  it('has a settings link next to the zone name on a zone page', async () => {
    const { wrapper } = await mountAt(`/gardens/${GARDEN}/zones/${HERBS_ZONE.id}`, { zones: [MAIN_ZONE, HERBS_ZONE], instances: INSTANCES })

    await wrapper.find('.page-title + .zone-settings-link').trigger('click')

    expect(wrapper.find('.bf-field input').element.value).toBe('Herbs')
  })

  it('has no zone settings link on the garden page header', async () => {
    const { wrapper } = await mountAt(`/gardens/${GARDEN}`, { zones: [MAIN_ZONE], instances: INSTANCES })

    expect(wrapper.find('.zone-settings-link').exists()).toBe(false)
  })

  describe('renaming the garden', () => {
    const config = { zones: [MAIN_ZONE], instances: [] }

    async function submitRename(wrapper) {
      await wrapper.find('.edit-garden-btn').trigger('click')
      await wrapper.find('.eg-input').setValue('New name')
      await wrapper.find('.eg-save').trigger('click')
      await flushPromises()
    }

    it('closes the popup when the name is saved', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, {
        ...config,
        extra: { [`/api/gardens/${GARDEN}`]: { id: GARDEN, name: 'New name' } },
      })

      await submitRename(wrapper)

      expect(wrapper.find('.eg-input').exists()).toBe(false)
    })

    it('keeps the popup open with an error when the server rejects the save', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, config)

      await submitRename(wrapper)

      expect(wrapper.find('.eg-input').element.value).toBe('New name')
      expect(wrapper.find('.bf-error').text()).toBe(en.garden.editGardenFailed)
    })

    it('shows an error and allows retrying when the request cannot be sent', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, config)
      global.fetch = vi.fn().mockRejectedValue(new Error('offline'))

      await submitRename(wrapper)

      expect(wrapper.find('.bf-error').text()).toBe(en.garden.editGardenFailed)
      expect(wrapper.find('.eg-save').attributes('disabled')).toBeUndefined()
    })

    it('clears the error when the popup is reopened', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, config)
      await submitRename(wrapper)

      await wrapper.find('.dg-cancel').trigger('click')
      await wrapper.find('.edit-garden-btn').trigger('click')

      expect(wrapper.find('.bf-error').exists()).toBe(false)
    })
  })

  describe('deleting the garden', () => {
    const config = { zones: [MAIN_ZONE], instances: [] }

    afterEach(() => { gardens.value = [] })

    async function submitDelete(wrapper) {
      await wrapper.find('.delete-garden-btn').trigger('click')
      await wrapper.find('.dg-confirm').trigger('click')
      await flushPromises()
    }

    it('closes the popup and returns to the dashboard when the garden is deleted', async () => {
      gardens.value = [{ id: GARDEN, name: 'Backyard' }, { id: 'garden-2', name: 'Balcony' }]
      const { wrapper, router } = await mountAt(`/gardens/${GARDEN}`, {
        ...config,
        extra: { [`/api/gardens/${GARDEN}`]: {} },
      })

      await submitDelete(wrapper)

      expect(wrapper.find('.dg-confirm').exists()).toBe(false)
      expect(router.currentRoute.value.path).toBe('/')
    })

    it('keeps the popup open with an error when the server rejects the delete', async () => {
      gardens.value = [{ id: GARDEN, name: 'Backyard' }]
      const { wrapper, router } = await mountAt(`/gardens/${GARDEN}`, config)

      await submitDelete(wrapper)

      expect(wrapper.find('.bf-error').text()).toBe(en.garden.deleteGardenFailed)
      expect(gardens.value).toHaveLength(1)
      expect(router.currentRoute.value.path).toBe(`/gardens/${GARDEN}`)
    })

    it('shows an error and allows retrying when the request cannot be sent', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, config)
      global.fetch = vi.fn().mockRejectedValue(new Error('offline'))

      await submitDelete(wrapper)

      expect(wrapper.find('.bf-error').text()).toBe(en.garden.deleteGardenFailed)
      expect(wrapper.find('.dg-confirm').attributes('disabled')).toBeUndefined()
    })

    it('clears the error when the popup is reopened', async () => {
      const { wrapper } = await mountAt(`/gardens/${GARDEN}`, config)
      await submitDelete(wrapper)

      await wrapper.find('.dg-cancel').trigger('click')
      await wrapper.find('.delete-garden-btn').trigger('click')

      expect(wrapper.find('.bf-error').exists()).toBe(false)
    })
  })

  it('falls back to the garden when the zone no longer exists', async () => {
    const { router } = await mountAt(`/gardens/${GARDEN}/zones/gone`, { zones: [MAIN_ZONE], instances: [] })

    expect(router.currentRoute.value.path).toBe(`/gardens/${GARDEN}`)
  })
})

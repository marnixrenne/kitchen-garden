import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises, enableAutoUnmount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import ThisWeekCard from '../ThisWeekCard.vue'
import { setActiveGarden } from '../../stores/garden.js'

enableAutoUnmount(afterEach)

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

const GARDEN = 'garden-1'
const WEEK = { week: 24, weekStartDay: 8, weekStartMonth: 6, weekEndDay: 14, weekEndMonth: 6, actions: [] }

const BEANS  = { id: 'p-beans',  name: 'Bean',   emoji: null }
const TOMATO = { id: 'p-tomato', name: 'Tomato', emoji: null }
const BASIL  = { id: 'p-basil',  name: 'Basil',  emoji: null }

const VEG   = { id: 'zone-veg',   name: 'Veg' }
const HERBS = { id: 'zone-herbs', name: 'Herbs' }
const EMPTY = { id: 'zone-empty', name: 'Empty' }

const INSTANCES = [
  { id: 'i-tomato', plantId: TOMATO.id, zoneId: VEG.id },
  { id: 'i-beans',  plantId: BEANS.id,  zoneId: VEG.id },
  { id: 'i-basil',  plantId: BASIL.id,  zoneId: HERBS.id },
]

const SEEDED = { 'i-tomato': { nextState: null }, 'i-beans': { nextState: null }, 'i-basil': { nextState: null } }

function planned(action, start) {
  return { id: `${action}-${start}`, action, plannedDateStart: start, plannedDateEnd: start, seedDate: '2026-05-01', seedAction: 'seeding_indoor' }
}

async function mountCard({ zoneId = null, plan = {}, log = {}, week = WEEK, instances = INSTANCES, lifecycle = SEEDED } = {}) {
  const routes = {
    [`/api/gardens/${GARDEN}/week`]:      week,
    [`/api/gardens/${GARDEN}/instances`]: instances,
    [`/api/gardens/${GARDEN}/plant-log`]: log,
    [`/api/gardens/${GARDEN}/plan`]:      plan,
    [`/api/gardens/${GARDEN}/lifecycle`]: lifecycle,
    [`/api/gardens/${GARDEN}/details`]:   [TOMATO, BEANS, BASIL],
  }
  global.fetch = vi.fn(async (url) =>
    url in routes ? { ok: true, json: async () => routes[url] } : { ok: false, json: async () => ({}) }
  )
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/:p(.*)*', component: { template: '<div />' } }] })
  const wrapper = mount(ThisWeekCard, {
    props: { zoneId, zones: [VEG, HERBS, EMPTY] },
    global: { plugins: [router, i18n], stubs: { Teleport: true } },
  })
  await flushPromises()
  return wrapper
}

const zoneNames = w => w.findAll('.week-zone-name').map(z => z.text())
const plantRows = w => w.findAll('.week-plant')

describe('ThisWeekCard', () => {
  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2026, 5, 10))
    setActiveGarden(GARDEN)
  })
  afterEach(() => { vi.useRealTimers(); vi.restoreAllMocks() })

  it('on the garden page lists every zone but only the plants with an action this week', async () => {
    const wrapper = await mountCard({ plan: { 'i-tomato': [planned('watering', '2026-06-10')] } })

    expect(zoneNames(wrapper)).toEqual(['Veg', 'Herbs', 'Empty'])
    const [veg, herbs, empty] = wrapper.findAll('.week-zone')
    expect(veg.findAll('.week-plant')).toHaveLength(1)
    expect(veg.find('.week-plant').text()).toContain('Tomato')
    expect(veg.text()).not.toContain('Bean')
    expect(herbs.find('.week-empty').text()).toBe('Nothing to do this week')
    expect(empty.find('.week-empty').text()).toBe('No plants yet')
  })

  it('shows a zone added while the card is open', async () => {
    const wrapper = await mountCard()

    await wrapper.setProps({ zones: [VEG, HERBS, EMPTY, { id: 'zone-new', name: 'New' }] })

    expect(zoneNames(wrapper)).toEqual(['Veg', 'Herbs', 'Empty', 'New'])
  })

  it('asks to edit a zone from the settings link next to its name', async () => {
    const wrapper = await mountCard()

    await wrapper.findAll('.week-zone-header')[1].find('.week-zone-settings').trigger('click')

    expect(wrapper.emitted('edit-zone')).toEqual([[HERBS]])
  })

  it('draws all of a zone\'s plants on its ground, fading those with no open job', async () => {
    const wrapper = await mountCard({ plan: { 'i-tomato': [planned('watering', '2026-06-10')] } })

    const plants = wrapper.findAll('.week-zone')[0].findAll('.ground-plant')
    expect(plants.map(p => p.attributes('title'))).toEqual(['Bean', 'Tomato'])
    expect(plants.map(p => p.classes('ground-plant--resting'))).toEqual([true, false])
  })

  it('links each zone on the garden page to its own page', async () => {
    const wrapper = await mountCard()

    expect(wrapper.find('.week-zone-name a').attributes('href')).toBe(`/gardens/${GARDEN}/zones/${VEG.id}`)
  })

  it('on a zone page lists all its plants, with actions under their own plant', async () => {
    const wrapper = await mountCard({
      zoneId: VEG.id,
      plan: { 'i-tomato': [planned('watering', '2026-06-10'), planned('pruning', '2026-06-11')] },
    })

    const [beans, tomato] = plantRows(wrapper)
    expect(tomato.findAll('.week-action-label').map(a => a.text())).toEqual([en.garden.job.pruning, en.garden.job.watering])
    expect(tomato.find('.week-plant-none').exists()).toBe(false)
    expect(beans.findAll('.week-action')).toHaveLength(0)
    expect(beans.find('.week-plant-none').text()).toBe('Nothing to do this week')
  })

  it('says so when a zone page has no plants', async () => {
    const wrapper = await mountCard({ zoneId: EMPTY.id })

    expect(wrapper.find('.week-empty').text()).toBe('No plants yet')
  })

  it('labels only the jobs whose planned dates have passed as overdue', async () => {
    const wrapper = await mountCard({
      zoneId: VEG.id,
      plan: { 'i-tomato': [planned('watering', '2026-06-09'), planned('pruning', '2026-06-12')] },
    })

    const rows = wrapper.findAll('.week-action')
    const byLabel = Object.fromEntries(rows.map(r => [r.find('.week-action-label').text(), r]))
    expect(byLabel[en.garden.job.watering].find('.wi-overdue').text()).toBe(en.garden.overdue)
    expect(byLabel[en.garden.job.pruning].find('.wi-overdue').exists()).toBe(false)
  })

  describe('several plantings of one plant', () => {
    const TWINS = [
      { id: 'i-early', plantId: TOMATO.id, zoneId: VEG.id },
      { id: 'i-late',  plantId: TOMATO.id, zoneId: VEG.id },
    ]

    it('tells them apart by sowing date, and says when one is not sown yet', async () => {
      const wrapper = await mountCard({
        zoneId: VEG.id,
        instances: TWINS,
        log: { 'i-early': [{ action: 'seeding_outdoor', date: '2026-05-01' }] },
      })

      const tags = plantRows(wrapper).map(r => r.find('.wi-seeded-on').text())
      expect(tags).toEqual(expect.arrayContaining(['Seeded May 1', en.garden.notSownYet]))
    })

    it('does not label a single unsown planting', async () => {
      const wrapper = await mountCard({ zoneId: VEG.id })

      expect(wrapper.find('.wi-seeded-on').exists()).toBe(false)
    })

    it('gives each unsown planting its own sow job', async () => {
      const wrapper = await mountCard({
        zoneId: VEG.id,
        instances: TWINS,
        lifecycle: {},
        week: { ...WEEK, actions: [{ type: 'sow', plant: TOMATO }] },
      })

      expect(wrapper.findAll('.wi-btn--seed')).toHaveLength(2)
    })
  })

  describe('removing a planting', () => {
    it('is only offered on a zone page', async () => {
      expect((await mountCard()).find('.week-plant-remove').exists()).toBe(false)
      expect((await mountCard({ zoneId: VEG.id })).find('.week-plant-remove').exists()).toBe(true)
    })

    it('asks for confirmation before deleting', async () => {
      const wrapper = await mountCard({ zoneId: VEG.id })

      await wrapper.find('.week-plant-remove').trigger('click')

      expect(global.fetch.mock.calls.some(([, o]) => o?.method === 'DELETE')).toBe(false)
      expect(wrapper.find('[role="dialog"]').text()).toContain('Bean')
    })

    it('deletes that planting when confirmed, and tells the page to refresh', async () => {
      const wrapper = await mountCard({ zoneId: VEG.id })
      const realFetch = global.fetch
      global.fetch = vi.fn(async (url, options) => options?.method === 'DELETE' ? { ok: true } : realFetch(url, options))

      await wrapper.find('.week-plant-remove').trigger('click')
      await wrapper.find('form.modal-body').trigger('submit')
      await flushPromises()

      const [url] = global.fetch.mock.calls.find(([, o]) => o?.method === 'DELETE')
      expect(url).toBe(`/api/gardens/${GARDEN}/instances/i-beans`)
      expect(wrapper.emitted('refresh')).toHaveLength(1)
      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
    })

    it('keeps the popup open with an error when the delete fails', async () => {
      const wrapper = await mountCard({ zoneId: VEG.id })
      const realFetch = global.fetch
      global.fetch = vi.fn(async (url, options) => options?.method === 'DELETE' ? { ok: false } : realFetch(url, options))

      await wrapper.find('.week-plant-remove').trigger('click')
      await wrapper.find('form.modal-body').trigger('submit')
      await flushPromises()

      expect(wrapper.find('.modal-error').text()).toBe(en.garden.removePlantingFailed)
    })
  })

  it('leaves out actions planned for another week', async () => {
    const wrapper = await mountCard({ plan: { 'i-tomato': [planned('watering', '2026-06-20')] } })

    expect(wrapper.findAll('.week-action')).toHaveLength(0)
  })

  it('marks a logged action as done and does not count it as open', async () => {
    const wrapper = await mountCard({
      plan: { 'i-tomato': [planned('watering', '2026-06-10'), planned('pruning', '2026-06-11')] },
      log:  { 'i-tomato': [{ action: 'watering', date: '2026-06-10' }] },
    })

    expect(wrapper.findAll('.wi-done-mark')).toHaveLength(1)
    expect(wrapper.find('.week-card-title').text()).toBe('1 open action')
  })

  it('opens the log dialog for an action on that plant', async () => {
    const wrapper = await mountCard({ plan: { 'i-tomato': [planned('watering', '2026-06-10')] } })

    await wrapper.find('.wi-btn--log').trigger('click')

    expect(wrapper.find('[role="dialog"]').text()).toContain('Tomato')
  })

  it('shows only the given zone, without a zone heading, and counts only its actions', async () => {
    const wrapper = await mountCard({
      zoneId: HERBS.id,
      plan: { 'i-tomato': [planned('watering', '2026-06-10')], 'i-basil': [planned('pruning', '2026-06-10')] },
    })

    expect(zoneNames(wrapper)).toEqual([])
    expect(plantRows(wrapper)).toHaveLength(1)
    expect(plantRows(wrapper)[0].text()).toContain('Basil')
    expect(wrapper.find('.week-card-title').text()).toBe('1 open action')
  })

  it('defaults the date of a job to the local day just after midnight', async () => {
    vi.setSystemTime(new Date(2026, 5, 10, 0, 30))
    const wrapper = await mountCard({ plan: { 'i-tomato': [planned('watering', '2026-06-10')] } })

    await wrapper.find('.wi-btn--log').trigger('click')

    expect(wrapper.find('#tw-action-date').element.value).toBe('2026-06-10')
  })

  describe('when the connection drops while saving', () => {
    const SOW_WEEK = { ...WEEK, actions: [{ type: 'sow', plant: TOMATO }] }

    it.each([
      ['logging a job', '.wi-btn--log', { plan: { 'i-tomato': [planned('watering', '2026-06-10')] } }],
      ['sowing', '.wi-btn--seed', { week: SOW_WEEK, lifecycle: {} }],
      ['advancing a stage', '.wi-btn--advance', { plan: { 'i-tomato': [planned('germination', '2026-06-10')] }, lifecycle: { 'i-tomato': { nextState: 'germinating_indoor' } } }],
    ])('%s shows an error and can be tried again', async (_, button, config) => {
      const wrapper = await mountCard(config)
      await wrapper.find(button).trigger('click')
      const read = global.fetch
      global.fetch = vi.fn((url, init) => init?.method ? Promise.reject(new Error('offline')) : read(url, init))

      await wrapper.find('.modal-body').trigger('submit')
      await flushPromises()

      expect(wrapper.find('.modal-error').text()).toBe(en.garden.connectionFailed)
      expect(wrapper.find('.modal-save').attributes('disabled')).toBeUndefined()
    })
  })

  describe('switching gardens', () => {
    function replyPerGarden(perGarden) {
      global.fetch = vi.fn(async (url) => {
        const [, id, resource] = url.match(/^\/api\/gardens\/([^/]+)\/(.+)$/)
        await perGarden[id].hold
        const data = { week: WEEK, instances: INSTANCES, 'plant-log': {}, plan: perGarden[id].plan, lifecycle: SEEDED, details: [TOMATO, BEANS, BASIL] }[resource]
        return { ok: true, json: async () => data }
      })
    }
    const tomatoJob = { 'i-tomato': [planned('watering', '2026-06-10')] }
    const basilJob  = { 'i-basil':  [planned('watering', '2026-06-10')] }

    it('shows the jobs of the garden switched to', async () => {
      const wrapper = await mountCard({ plan: tomatoJob })
      replyPerGarden({ other: { plan: basilJob } })

      setActiveGarden('other')
      await flushPromises()

      expect(plantRows(wrapper).map(r => r.find('.wi-name').text())).toEqual(['Basil'])
    })

    it('ignores a slow reply from the garden switched away from', async () => {
      const wrapper = await mountCard({ plan: {} })
      let release
      replyPerGarden({ slow: { plan: tomatoJob, hold: new Promise(r => { release = r }) }, fast: { plan: basilJob } })

      setActiveGarden('slow')
      await flushPromises()
      setActiveGarden('fast')
      await flushPromises()
      release()
      await flushPromises()

      expect(plantRows(wrapper).map(r => r.find('.wi-name').text())).toEqual(['Basil'])
    })
  })
})

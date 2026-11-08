import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import ThisWeekCard from '../ThisWeekCard.vue'
import { setActiveGarden } from '../../stores/garden.js'

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

function planned(action, start) {
  return { id: `${action}-${start}`, action, plannedDateStart: start, plannedDateEnd: start, seedDate: '2026-05-01', seedAction: 'seeding_indoor' }
}

async function mountCard({ zoneId = null, plan = {}, log = {}, week = WEEK } = {}) {
  const routes = {
    [`/api/gardens/${GARDEN}/zones`]:     [VEG, HERBS, EMPTY],
    [`/api/gardens/${GARDEN}/week`]:      week,
    [`/api/gardens/${GARDEN}/instances`]: INSTANCES,
    [`/api/gardens/${GARDEN}/plant-log`]: log,
    [`/api/gardens/${GARDEN}/plan`]:      plan,
    [`/api/gardens/${GARDEN}/lifecycle`]: { 'i-tomato': { nextState: null }, 'i-beans': { nextState: null }, 'i-basil': { nextState: null } },
    [`/api/gardens/${GARDEN}/details`]:   [TOMATO, BEANS, BASIL],
  }
  global.fetch = vi.fn(async (url) =>
    url in routes ? { ok: true, json: async () => routes[url] } : { ok: false, json: async () => ({}) }
  )
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/:p(.*)*', component: { template: '<div />' } }] })
  const wrapper = mount(ThisWeekCard, {
    props: { zoneId },
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

  it('lists every zone with its plants in name order', async () => {
    const wrapper = await mountCard()

    expect(zoneNames(wrapper)).toEqual(['Veg', 'Herbs', 'Empty'])
    const [veg, herbs, empty] = wrapper.findAll('.week-zone')
    expect(veg.findAll('.wi-name').map(n => n.text())).toEqual(['Bean', 'Tomato'])
    expect(herbs.findAll('.wi-name').map(n => n.text())).toEqual(['Basil'])
    expect(empty.find('.week-empty').text()).toBe('No plants yet')
  })

  it('shows this week\'s actions under their own plant', async () => {
    const wrapper = await mountCard({
      plan: { 'i-tomato': [planned('watering', '2026-06-10'), planned('pruning', '2026-06-11')] },
    })

    const [beans, tomato] = plantRows(wrapper)
    expect(tomato.findAll('.week-action-label').map(a => a.text())).toEqual([en.garden.planAction.pruning, en.garden.planAction.watering])
    expect(tomato.find('.week-plant-none').exists()).toBe(false)
    expect(beans.findAll('.week-action')).toHaveLength(0)
    expect(beans.find('.week-plant-none').text()).toBe('Nothing to do this week')
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
})

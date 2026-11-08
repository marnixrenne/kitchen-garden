import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import DashboardView from '../DashboardView.vue'
import { gardens, gardensLoaded } from '../../stores/garden.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

const TOMATO = { id: 'p-tomato', name: 'Tomato' }
const WEEK = { weekStartDay: 8, weekStartMonth: 6, weekEndDay: 14, weekEndMonth: 6, actions: [] }

const MAIN  = { id: 'zone-main',  name: null }
const HERBS = { id: 'zone-herbs', name: 'Herbs' }

function watering(start) {
  return { id: `plan-${start}`, action: 'watering', plannedDateStart: start, plannedDateEnd: start, seedDate: '2026-05-01', seedAction: 'seeding_indoor' }
}

function gardenRoutes(id, { zones, instances, plan = {} }) {
  return {
    [`/api/gardens/${id}/week`]:      WEEK,
    [`/api/gardens/${id}/instances`]: instances,
    [`/api/gardens/${id}/plant-log`]: {},
    [`/api/gardens/${id}/plan`]:      plan,
    [`/api/gardens/${id}/lifecycle`]: {},
    [`/api/gardens/${id}/details`]:   [TOMATO],
    [`/api/gardens/${id}/zones`]:     zones,
  }
}

async function mountDashboard(gardenList, routes) {
  gardens.value = gardenList
  gardensLoaded.value = true
  global.fetch = vi.fn(async (url) =>
    url in routes ? { ok: true, json: async () => routes[url] } : { ok: false, json: async () => ({}) }
  )
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [{ path: '/:pathMatch(.*)*', component: { template: '<div />' } }],
  })
  const wrapper = mount(DashboardView, { global: { plugins: [router, i18n] } })
  await flushPromises()
  return wrapper
}

describe('DashboardView', () => {
  beforeEach(() => { vi.useFakeTimers({ toFake: ['Date'] }); vi.setSystemTime(new Date(2026, 5, 10)) })
  afterEach(() => { vi.useRealTimers(); vi.restoreAllMocks(); gardens.value = []; gardensLoaded.value = false })

  it('shows every garden with its zones and the open actions per zone', async () => {
    const wrapper = await mountDashboard(
      [{ id: 'g1', name: 'Backyard' }, { id: 'g2', name: 'Balcony' }],
      {
        ...gardenRoutes('g1', {
          zones: [MAIN, HERBS],
          instances: [{ id: 'i1', plantId: TOMATO.id, zoneId: HERBS.id }],
          plan: { i1: [watering('2026-06-10')] },
        }),
        ...gardenRoutes('g2', { zones: [MAIN], instances: [] }),
      },
    )

    const sections = wrapper.findAll('.dash-garden')
    expect(sections.map(s => s.find('.dash-garden-name').text())).toEqual(['Backyard', 'Balcony'])
    expect(sections[0].find('.dash-count').text()).toBe('1 open action')

    const [main, herbs] = sections[0].findAll('.dash-zone')
    expect(main.find('.dash-zone-name').text()).toBe('Main zone')
    expect(main.find('.dash-nothing').exists()).toBe(true)
    expect(herbs.find('.dash-zone-name').text()).toBe('Herbs')
    expect(herbs.find('.dash-action-plant').text()).toBe('Tomato')
  })

  it('links a garden and a zone to their detail views', async () => {
    const wrapper = await mountDashboard(
      [{ id: 'g1', name: 'Backyard' }],
      gardenRoutes('g1', { zones: [HERBS], instances: [] }),
    )

    expect(wrapper.find('.dash-garden-header').attributes('href')).toBe('/gardens/g1')
    expect(wrapper.find('.dash-zone').attributes('href')).toBe('/gardens/g1/zones/zone-herbs')
  })

  it('caps the actions listed on a zone and says how many are left', async () => {
    const dates = ['2026-06-08', '2026-06-09', '2026-06-10', '2026-06-11', '2026-06-12', '2026-06-13', '2026-06-14']
    const wrapper = await mountDashboard(
      [{ id: 'g1', name: 'Backyard' }],
      gardenRoutes('g1', {
        zones: [HERBS],
        instances: [{ id: 'i1', plantId: TOMATO.id, zoneId: HERBS.id }],
        plan: { i1: dates.map(watering) },
      }),
    )

    expect(wrapper.findAll('.dash-action')).toHaveLength(5)
    expect(wrapper.find('.dash-more').text()).toBe('+2 more')
  })

  it('reports a garden that failed to load rather than showing it as having nothing to do', async () => {
    const wrapper = await mountDashboard([{ id: 'g1', name: 'Backyard' }], {})

    expect(wrapper.find('.dash-failed').exists()).toBe(true)
    expect(wrapper.find('.dash-count').exists()).toBe(false)
  })

  it('points to the catalogue when there are no gardens', async () => {
    const wrapper = await mountDashboard([], {})

    expect(wrapper.find('.dash-explore').attributes('href')).toBe('/discover')
  })
})

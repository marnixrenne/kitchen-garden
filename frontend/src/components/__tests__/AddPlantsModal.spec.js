import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import AddPlantsModal from '../AddPlantsModal.vue'
import { setActiveGarden } from '../../stores/garden.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en }, missingWarn: false, fallbackWarn: false })

const GARDEN = 'garden-1'
const ZONE = { id: 'zone-1', name: 'Moestuin', sunExposure: 'full_sun' }
const OPTIONS_URL = `/api/gardens/${GARDEN}/zones/${ZONE.id}/plant-options`

function option(overrides) {
  return {
    id: 'p1', name: 'Carrot', emoji: null, recommended: false, sunMatch: null,
    sunShortfall: false, goodWith: [], badWith: [], pestControl: null, pollinatorsFor: [], inThisZone: 0, alsoIn: [], ...overrides,
  }
}

const BASIL = option({ id: 'p-basil', name: 'Basil', recommended: true, sunMatch: 'full_sun', goodWith: [{ id: 'p-t', name: 'Tomato', emoji: null }], pestControl: { predator: 'ladybird', pest: 'aphid', plant: { id: 'p-t', name: 'Tomato', emoji: null } }, pollinatorsFor: [{ id: 'p-t', name: 'Tomato', emoji: null }], alsoIn: ['Kas', null] })
const PEA   = option({ id: 'p-pea', name: 'Pea', recommended: true })
const TOMATO = option({ id: 'p-t', name: 'Tomato', inThisZone: 2 })
const DILL  = option({ id: 'p-dill', name: 'Dill', sunShortfall: true, badWith: [{ id: 'p-t', name: 'Tomato', emoji: null }] })

async function mountModal({ options = [BASIL, PEA, TOMATO, DILL], zone = ZONE, fetchImpl } = {}) {
  global.fetch = fetchImpl ?? vi.fn(async (url, init) => {
    if (init?.method === 'POST') return { ok: true, status: 201, json: async () => ({}) }
    if (url === OPTIONS_URL) return { ok: true, json: async () => options }
    return { ok: false, json: async () => ({}) }
  })
  const wrapper = mount(AddPlantsModal, {
    props: { zone },
    global: { plugins: [i18n], stubs: { Teleport: true } },
  })
  await flushPromises()
  return wrapper
}

const search = async (wrapper, text) => wrapper.find('#ap-search-input').setValue(text)

describe('AddPlantsModal', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => vi.restoreAllMocks())

  it('lists the recommendations in the order given, with their reasons', async () => {
    const wrapper = await mountModal()

    const rows = wrapper.findAll('.ap-recommended .ap-row')
    expect(rows.map(r => r.find('.ap-name').text())).toEqual(['Basil', 'Pea'])
    expect(rows[0].findAll('.ap-reason').map(r => r.text())).toEqual(['Good with Tomato', 'Attracts ladybirds, which eat aphids on Tomato', 'Brings pollinators for Tomato', 'Suits full sun'])
  })

  it('notes the other zones a recommendation grows in, naming an unnamed one', async () => {
    const wrapper = await mountModal()

    expect(wrapper.find('.ap-recommended .ap-note').text()).toBe('Also in Kas, Main zone')
  })

  it('shows no search results until something is typed', async () => {
    const wrapper = await mountModal()

    expect(wrapper.findAll('.ap-results .ap-row')).toHaveLength(0)

    await search(wrapper, 'dil')

    expect(wrapper.findAll('.ap-results .ap-row').map(r => r.find('.ap-name').text())).toEqual(['Dill'])
  })

  it('warns in search about too little sun and bad companions, and still allows adding', async () => {
    const wrapper = await mountModal()

    await search(wrapper, 'dill')

    const row = wrapper.find('.ap-results .ap-row')
    expect(row.findAll('.ap-warning').map(w => w.text())).toEqual([en.zones.sunWarning, 'Bad companion for Tomato'])
    expect(row.find('.ap-add').attributes('disabled')).toBeUndefined()
  })

  it('offers adding another for a plant already in the zone', async () => {
    const wrapper = await mountModal()

    await search(wrapper, 'tomato')

    const row = wrapper.find('.ap-results .ap-row')
    expect(row.find('.ap-note').text()).toBe('Already here')
    expect(row.find('.ap-add').text()).toBe('Add another')
  })

  it('adds to this zone, reloads the options, stays open and tells the page', async () => {
    const wrapper = await mountModal()

    await wrapper.find('.ap-recommended .ap-add').trigger('click')
    await flushPromises()

    const [url] = global.fetch.mock.calls.find(([, init]) => init?.method === 'POST')
    expect(url).toBe(`/api/gardens/${GARDEN}/plants/${BASIL.id}?zoneId=${ZONE.id}`)
    expect(global.fetch.mock.calls.filter(([u]) => u === OPTIONS_URL)).toHaveLength(2)
    expect(wrapper.emitted('added')).toHaveLength(1)
    expect(wrapper.emitted('close')).toBeUndefined()
  })

  it('ignores a second click while a plant is being added', async () => {
    let finishPost
    const fetchImpl = vi.fn((url, init) => {
      if (init?.method === 'POST') return new Promise(resolve => { finishPost = () => resolve({ ok: true, json: async () => ({}) }) })
      return Promise.resolve({ ok: true, json: async () => [BASIL, PEA] })
    })
    const wrapper = await mountModal({ fetchImpl })
    const add = () => wrapper.find('.ap-recommended .ap-add')

    await add().trigger('click')
    await add().trigger('click')

    expect(fetchImpl.mock.calls.filter(([, init]) => init?.method === 'POST')).toHaveLength(1)
    expect(add().attributes('disabled')).toBeDefined()
    finishPost()
    await flushPromises()
    expect(add().attributes('disabled')).toBeUndefined()
  })

  it('shows an error and stays usable when adding fails', async () => {
    const fetchImpl = vi.fn(async (url, init) => init?.method === 'POST'
      ? { ok: false, json: async () => ({}) }
      : { ok: true, json: async () => [BASIL] })
    const wrapper = await mountModal({ fetchImpl })

    await wrapper.find('.ap-recommended .ap-add').trigger('click')
    await flushPromises()

    expect(wrapper.find('.ap-error').text()).toBe(en.addPlants.addFailed)
    expect(wrapper.emitted('added')).toBeUndefined()
    expect(wrapper.find('.ap-recommended .ap-add').attributes('disabled')).toBeUndefined()
  })

  it('shows an error when the options cannot be loaded', async () => {
    const wrapper = await mountModal({ fetchImpl: vi.fn().mockRejectedValue(new Error('offline')) })

    expect(wrapper.find('.ap-error').text()).toBe(en.addPlants.loadFailed)
  })

  it('prompts to set the sun exposure of an empty zone without one', async () => {
    const wrapper = await mountModal({ zone: { ...ZONE, sunExposure: null }, options: [BASIL] })

    await wrapper.find('.ap-link').trigger('click')

    expect(wrapper.find('.ap-prompt').exists()).toBe(true)
    expect(wrapper.emitted('edit-zone')).toHaveLength(1)
  })

  it('prompts to set the sun exposure of a planted zone without one too', async () => {
    const wrapper = await mountModal({ zone: { ...ZONE, sunExposure: null }, options: [BASIL, TOMATO] })

    expect(wrapper.find('.ap-prompt').exists()).toBe(true)
  })

  it('does not prompt once the sun exposure is set', async () => {
    const wrapper = await mountModal()

    expect(wrapper.find('.ap-prompt').exists()).toBe(false)
  })

  it('says so when there is nothing to recommend, and search still works', async () => {
    const wrapper = await mountModal({ options: [TOMATO, DILL] })

    expect(wrapper.find('.ap-recommended').exists()).toBe(false)
    expect(wrapper.find('.ap-message').text()).toBe(en.addPlants.noRecommendations)
    await search(wrapper, 'dill')
    expect(wrapper.findAll('.ap-results .ap-row')).toHaveLength(1)
  })

  it('closes from the done button', async () => {
    const wrapper = await mountModal()

    await wrapper.find('.ap-done').trigger('click')

    expect(wrapper.emitted('close')).toHaveLength(1)
  })
})

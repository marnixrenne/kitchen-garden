import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import HomeView from '../HomeView.vue'
import { setActiveGarden, gardensLoaded, newGardenModal } from '../../stores/garden.js'
import { addPlantFailed } from '../../stores/zonePicker.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

const GARDEN = 'garden-1'
const BEETROOT = { id: 'p-beet', name: 'Beetroot', category: 'Root', emoji: null, imageUrl: null }

async function mountExplore(instances = []) {
  global.fetch = vi.fn(async (url, options) => {
    if (options?.method === 'POST') return { ok: true, status: 201, json: async () => ({}) }
    if (url === '/api/plants' || url.startsWith('/api/plants?')) return { ok: true, json: async () => [BEETROOT] }
    if (url === '/api/plants/counts') return { ok: true, json: async () => ({}) }
    if (url === `/api/gardens/${GARDEN}/instances`) return { ok: true, json: async () => instances }
    if (url === `/api/gardens/${GARDEN}/zones`) return { ok: true, json: async () => [{ id: 'z1', name: null }] }
    return { ok: false, json: async () => ({}) }
  })
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/:p(.*)*', component: { template: '<div />' } }] })
  await router.push('/discover')
  const wrapper = mount(HomeView, { global: { plugins: [router, i18n] } })
  await flushPromises()
  return wrapper
}

describe('HomeView adding to the garden', () => {
  beforeEach(() => setActiveGarden(GARDEN))
  afterEach(() => {
    vi.restoreAllMocks()
    gardensLoaded.value = false
    newGardenModal.value.open = false
    addPlantFailed.value = false
  })

  it('counts up with every planting added, without ever removing one', async () => {
    const wrapper = await mountExplore()
    expect(wrapper.find('.garden-count').exists()).toBe(false)

    await wrapper.find('.garden-btn').trigger('click')
    await flushPromises()
    expect(wrapper.find('.garden-count').text()).toBe('1×')

    await wrapper.find('.garden-btn').trigger('click')
    await flushPromises()
    expect(wrapper.find('.garden-count').text()).toBe('2×')

    expect(global.fetch.mock.calls.filter(([, o]) => o?.method === 'POST')).toHaveLength(2)
    expect(global.fetch.mock.calls.some(([, o]) => o?.method === 'DELETE')).toBe(false)
  })

  it('adds one planting when the button is clicked twice in quick succession', async () => {
    const wrapper = await mountExplore()
    const add = wrapper.find('.garden-btn')

    add.trigger('click')
    add.trigger('click')
    await flushPromises()

    expect(global.fetch.mock.calls.filter(([, o]) => o?.method === 'POST')).toHaveLength(1)
    expect(wrapper.find('.garden-count').text()).toBe('1×')
  })

  it('asks for a first garden instead of adding when there is none', async () => {
    gardensLoaded.value = true
    const wrapper = await mountExplore()
    setActiveGarden(null)

    await wrapper.find('.garden-btn').trigger('click')
    await flushPromises()

    expect(newGardenModal.value.open).toBe(true)
    expect(global.fetch.mock.calls.filter(([, o]) => o?.method === 'POST')).toHaveLength(0)
    expect(global.fetch.mock.calls.some(([u]) => u.includes('/gardens/null'))).toBe(false)
  })

  it.each([
    ['the server refuses', () => Promise.resolve({ ok: false, status: 500, json: async () => ({}) })],
    ['the connection drops', () => Promise.reject(new Error('offline'))],
  ])('reports a failed add when %s, without counting it', async (_, post) => {
    const wrapper = await mountExplore()
    const read = global.fetch
    global.fetch = vi.fn((url, options) => options?.method === 'POST' ? post() : read(url, options))

    await wrapper.find('.garden-btn').trigger('click')
    await flushPromises()

    expect(addPlantFailed.value).toBe(true)
    expect(wrapper.find('.garden-count').exists()).toBe(false)
  })

  it('clears a reported failure on the next add', async () => {
    const wrapper = await mountExplore()
    addPlantFailed.value = true

    await wrapper.find('.garden-btn').trigger('click')
    await flushPromises()

    expect(addPlantFailed.value).toBe(false)
  })

  it('starts from the plantings already in the garden', async () => {
    const wrapper = await mountExplore([{ plantId: BEETROOT.id }, { plantId: BEETROOT.id }])

    expect(wrapper.find('.garden-count').text()).toBe('2×')
  })
})

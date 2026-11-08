import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import HomeView from '../HomeView.vue'
import { setActiveGarden } from '../../stores/garden.js'

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
  afterEach(() => vi.restoreAllMocks())

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

  it('starts from the plantings already in the garden', async () => {
    const wrapper = await mountExplore([{ plantId: BEETROOT.id }, { plantId: BEETROOT.id }])

    expect(wrapper.find('.garden-count').text()).toBe('2×')
  })
})

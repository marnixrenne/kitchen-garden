import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../i18n/en.js'
import App from '../App.vue'
import { user } from '../stores/auth.js'
import { gardens, gardensLoaded, activeGardenId, setActiveGarden, openNewGardenModal } from '../stores/garden.js'
import { addPlantFailed } from '../stores/zonePicker.js'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

async function mountApp(list) {
  global.fetch = vi.fn(async (url) => ({ ok: true, json: async () => (url === '/api/gardens' ? [...list] : {}) }))
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/:p(.*)*', component: { template: '<div />' } }] })
  user.value = { username: 'a', roles: [] }
  const wrapper = mount(App, { global: { plugins: [router, i18n], stubs: { Teleport: true } } })
  await flushPromises()
  return { wrapper, router }
}

describe('App', () => {
  beforeEach(() => setActiveGarden(null))
  afterEach(() => {
    vi.restoreAllMocks()
    user.value = null
    gardens.value = []
    gardensLoaded.value = false
    addPlantFailed.value = false
    setActiveGarden(null)
  })

  it('highlights the active garden in the menu', async () => {
    setActiveGarden('g2')
    const { wrapper } = await mountApp([{ id: 'g1', name: 'Backyard' }, { id: 'g2', name: 'Balcony' }])

    await wrapper.find('.nav-garden-caret-btn').trigger('click')

    expect(wrapper.findAll('.nav-garden-item--active').map(b => b.text())).toEqual(['Balcony'])
  })

  it('creates a garden from the new garden popup', async () => {
    const list = []
    const { wrapper } = await mountApp(list)
    const read = global.fetch
    global.fetch = vi.fn(async (url, options) => {
      if (options?.method !== 'POST') return read(url, options)
      list.push({ id: 'g1', name: 'Tuin' })
      return { ok: true, status: 201, json: async () => list[0] }
    })

    openNewGardenModal()
    await flushPromises()
    await wrapper.find('.ng-input').setValue('Tuin')
    await wrapper.find('form.ng-body').trigger('submit')
    await flushPromises()

    expect(wrapper.find('.ng-modal').exists()).toBe(false)
    expect(activeGardenId.value).toBe('g1')
  })

  it('shows an error in the new garden popup when the connection drops', async () => {
    const { wrapper } = await mountApp([])
    const read = global.fetch
    global.fetch = vi.fn((url, options) => options?.method === 'POST' ? Promise.reject(new Error('offline')) : read(url, options))

    openNewGardenModal()
    await flushPromises()
    await wrapper.find('.ng-input').setValue('Tuin')
    await wrapper.find('form.ng-body').trigger('submit')
    await flushPromises()

    expect(wrapper.find('.ng-error').text()).toBe(en.garden.connectionFailed)
    expect(wrapper.find('.ng-save').attributes('disabled')).toBeUndefined()
  })

  describe('a failed add', () => {
    it('is shown until dismissed', async () => {
      const { wrapper } = await mountApp([])

      addPlantFailed.value = true
      await flushPromises()
      expect(wrapper.find('.add-failed').text()).toContain(en.addPlants.addFailed)

      await wrapper.find('.add-failed button').trigger('click')
      expect(wrapper.find('.add-failed').exists()).toBe(false)
    })

    it('disappears when moving to another page', async () => {
      const { wrapper, router } = await mountApp([])
      addPlantFailed.value = true
      await flushPromises()

      await router.push('/elsewhere')
      await flushPromises()

      expect(wrapper.find('.add-failed').exists()).toBe(false)
    })
  })
})

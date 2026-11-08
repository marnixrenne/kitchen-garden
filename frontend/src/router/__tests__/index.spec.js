import { describe, it, expect, vi, beforeAll, beforeEach, afterAll } from 'vitest'
import router from '../index.js'
import { user } from '../../stores/auth.js'
import { activeGardenId, setActiveGarden } from '../../stores/garden.js'

const signedIn = { username: 'gardener', roles: ['ROLE_USER'] }
const admin    = { username: 'root',     roles: ['ROLE_ADMIN'] }

async function pathAfter(location) {
  await router.push(location)
  return router.currentRoute.value.path
}

describe('routes', () => {
  beforeAll(async () => {
    global.fetch = vi.fn(async () => ({ ok: false, json: async () => ({}) }))
    await router.push('/signup')  // settles the one-time auth check before tests set the user
  })
  beforeEach(() => { user.value = signedIn; setActiveGarden('g1') })
  afterAll(() => { user.value = null; setActiveGarden(null) })

  it('sends a signed-in user from the login page to the dashboard', async () => {
    expect(await pathAfter('/login')).toBe('/')
  })

  it('redirects /garden to the active garden and keeps the tab', async () => {
    await router.push('/garden?tab=log')

    expect(router.currentRoute.value.path).toBe('/gardens/g1')
    expect(router.currentRoute.value.query.tab).toBe('log')
  })

  it('redirects /garden to the dashboard when no garden is active', async () => {
    setActiveGarden(null)

    expect(await pathAfter('/garden')).toBe('/')
  })

  it('makes the garden in the address the active garden', async () => {
    expect(await pathAfter('/gardens/g2/zones/z1')).toBe('/gardens/g2/zones/z1')
    expect(activeGardenId.value).toBe('g2')
  })

  it('keeps guests out of a garden address', async () => {
    user.value = null

    expect(await pathAfter('/gardens/g2')).toBe('/login')
  })

  it('leaves guests on the root address, where they see the landing page', async () => {
    user.value = null

    expect(await pathAfter('/')).toBe('/')
  })

  it('sends admins from the dashboard to the admin page', async () => {
    await router.push('/signup')  // a navigation to the current page would skip the guards
    user.value = admin

    expect(await pathAfter('/')).toBe('/admin')
  })
})

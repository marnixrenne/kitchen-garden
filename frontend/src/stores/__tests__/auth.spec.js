import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { user, watchForExpiredSession } from '../auth.js'

const replying = status => vi.fn(async () => ({ ok: status < 400, status }))

describe('an expired session', () => {
  const realFetch = globalThis.fetch
  let onExpired

  function install(status) {
    globalThis.fetch = replying(status)
    onExpired = vi.fn()
    watchForExpiredSession(onExpired)
  }

  beforeEach(() => { user.value = { username: 'a', roles: [] } })
  afterEach(() => { globalThis.fetch = realFetch; user.value = null })

  it('signs the user out once, however many requests are refused', async () => {
    install(401)

    await Promise.all([fetch('/api/gardens'), fetch('/api/preferences')])

    expect(user.value).toBeNull()
    expect(onExpired).toHaveBeenCalledTimes(1)
  })

  it('still hands the reply to the caller', async () => {
    install(401)

    expect((await fetch('/api/gardens')).status).toBe(401)
  })

  it('leaves other replies alone', async () => {
    install(403)

    await fetch('/api/gardens')

    expect(user.value).not.toBeNull()
    expect(onExpired).not.toHaveBeenCalled()
  })

  it('does not count a refused login or auth check', async () => {
    install(401)

    await fetch('/api/auth/login', { method: 'POST' })

    expect(user.value).not.toBeNull()
    expect(onExpired).not.toHaveBeenCalled()
  })

  it('does nothing for a guest', async () => {
    install(401)
    user.value = null

    await fetch('/api/gardens')

    expect(onExpired).not.toHaveBeenCalled()
  })
})

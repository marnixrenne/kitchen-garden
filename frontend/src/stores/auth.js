import { ref } from 'vue'

export const user = ref(null)

export async function checkAuth() {
  const res = await fetch('/api/auth/me')
  user.value = res.ok ? await res.json() : null
}

export async function login(username, password) {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ username, password }),
  })
  if (res.ok) {
    user.value = await res.json()
    return true
  }
  return false
}

export async function logout() {
  await fetch('/api/auth/logout', { method: 'POST' })
  user.value = null
}

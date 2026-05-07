import { ref } from 'vue'

export const user = ref(null)

function getCsrfToken() {
  const cookie = document.cookie.split(';')
    .map(c => c.trim())
    .find(c => c.startsWith('XSRF-TOKEN='))
  return cookie ? decodeURIComponent(cookie.split('=').slice(1).join('=')) : null
}

export function csrfHeaders() {
  const token = getCsrfToken()
  return token ? { 'X-XSRF-TOKEN': token } : {}
}

export async function checkAuth() {
  const res = await fetch('/api/auth/me')
  user.value = res.ok ? await res.json() : null
}

export async function login(username, password) {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', ...csrfHeaders() },
    body: new URLSearchParams({ username, password }),
  })
  if (res.ok) {
    user.value = await res.json()
    return true
  }
  return false
}

export async function logout() {
  await fetch('/api/auth/logout', { method: 'POST', headers: csrfHeaders() })
  user.value = null
}

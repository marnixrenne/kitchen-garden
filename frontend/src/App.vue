<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter, RouterView, RouterLink } from 'vue-router'
import { user, logout, csrfHeaders } from './stores/auth.js'
import { activeGardenId, activeGardenName, gardens, setActiveGarden } from './stores/garden.js'

const { t, locale } = useI18n()
const router = useRouter()

const localeFlag = { en: '🇬🇧', nl: '🇳🇱', es: '🇪🇸' }

// ── Preferences ──────────────────────────────────────────────────────────────

watch(user, async (u) => {
  if (!u) return
  const res = await fetch('/api/preferences')
  if (!res.ok) return
  const prefs = await res.json()
  if (prefs.locale) {
    locale.value = prefs.locale
    localStorage.setItem('locale', prefs.locale)
  }
}, { immediate: true })

async function handleLogout() {
  await logout()
  setActiveGarden(null)
  router.push('/')
}

// ── Gardens list ─────────────────────────────────────────────────────────────

async function fetchGardens() {
  const res = await fetch('/api/garden/gardens')
  if (res.ok) {
    gardens.value = await res.json()
    if (gardens.value.length > 0 && !activeGardenId.value) {
      setActiveGarden(gardens.value[0].id)
    }
  }
}

watch(user, (u) => { if (u) fetchGardens() }, { immediate: true })

const activeGardenDisplayName = computed(() =>
  activeGardenName.value ?? t('myGarden')
)

// ── Garden dropdown ───────────────────────────────────────────────────────────

const dropdownOpen = ref(false)

function toggleDropdown() { dropdownOpen.value = !dropdownOpen.value }

function selectGarden(garden) {
  setActiveGarden(garden.id)
  dropdownOpen.value = false
  router.push('/garden')
}

function handleDocClick() { dropdownOpen.value = false }
onMounted(()  => document.addEventListener('click', handleDocClick))
onUnmounted(() => document.removeEventListener('click', handleDocClick))

// ── New garden modal ──────────────────────────────────────────────────────────

const newGardenModal = ref({ open: false, name: '', saving: false, error: '' })

function openNewGardenModal() {
  newGardenModal.value = { open: true, name: '', saving: false, error: '' }
}

async function submitNewGarden() {
  const name = newGardenModal.value.name.trim()
  if (!name) return
  newGardenModal.value.saving = true
  newGardenModal.value.error = ''
  try {
    const res = await fetch('/api/garden/gardens', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
      body: JSON.stringify({ name }),
    })
    if (!res.ok) {
      newGardenModal.value.error = `Error ${res.status}`
      return
    }
    const created = await res.json()
    await fetchGardens()
    setActiveGarden(created.id)
    newGardenModal.value.open = false
    router.push('/garden')
  } finally {
    newGardenModal.value.saving = false
  }
}
</script>

<template>
  <header v-if="user">
    <div class="header-top">
      <h1>🌱 Kitchen Garden</h1>
      <nav class="header-nav">
        <template v-if="!user?.roles?.includes('ROLE_ADMIN')">
          <RouterLink to="/home">{{ t('home') }}</RouterLink>

          <!-- Single garden: plain link -->
          <RouterLink v-if="gardens.length <= 1" to="/garden">{{ t('myGarden') }}</RouterLink>

          <!-- Multiple gardens: split button -->
          <div v-else class="nav-garden-dropdown" @click.stop>
            <div class="nav-garden-split" :class="{ 'router-link-active': $route.path === '/garden' }">
              <RouterLink class="nav-garden-label" to="/garden">{{ activeGardenDisplayName }}</RouterLink>
              <button class="nav-garden-caret-btn" @click="toggleDropdown" :title="t('garden.selectGarden')">▾</button>
            </div>
            <div v-if="dropdownOpen" class="nav-garden-menu">
              <button
                v-for="g in gardens"
                :key="g.id"
                class="nav-garden-item"
                :class="{ 'nav-garden-item--active': g.id === activeGardenId }"
                @click="selectGarden(g)"
              >{{ g.name }}</button>
            </div>
          </div>

          <button class="new-garden-btn" :title="t('garden.newGarden')" @click="openNewGardenModal">+</button>
        </template>
        <RouterLink v-if="user?.roles?.includes('ROLE_ADMIN')" to="/admin">Admin</RouterLink>
      </nav>
      <div class="header-controls">
        <span class="display-name">{{ user.username }}</span>
        <RouterLink class="settings-btn" to="/settings" :title="t('settings.title')">⚙ {{ localeFlag[locale] }}</RouterLink>
        <button class="logout-btn" @click="handleLogout">{{ t('logout') }}</button>
      </div>
    </div>
  </header>
  <RouterView />

  <Teleport to="body">
    <div v-if="newGardenModal.open" class="ng-backdrop" @click.self="newGardenModal.open = false">
      <div class="ng-modal" role="dialog" aria-modal="true">
        <div class="ng-header">{{ t('garden.newGarden') }}</div>
        <form class="ng-body" @submit.prevent="submitNewGarden">
          <input
            v-model="newGardenModal.name"
            class="ng-input"
            :placeholder="t('garden.newGardenPlaceholder')"
            required
            autofocus
          />
          <p v-if="newGardenModal.error" class="ng-error">{{ newGardenModal.error }}</p>
          <div class="ng-actions">
            <button type="button" class="ng-cancel" @click="newGardenModal.open = false">{{ t('garden.seedModal.cancel') }}</button>
            <button type="submit" class="ng-save" :disabled="newGardenModal.saving || !newGardenModal.name.trim()">
              {{ t('garden.seedModal.save') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --green-dark:  #1b4332;
  --green-mid:   #2d6a4f;
  --green-light: #74c69d;
  --green-pale:  #d8f3dc;
  --bg:          #f4f1eb;
  --card-bg:     #ffffff;
  --text:        #1b4332;
  --text-muted:  #52796f;
  --radius:      10px;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
}

header {
  background: var(--green-dark);
  color: #fff;
  padding: 0.75rem 1.5rem;
}

.header-top {
  display: flex;
  align-items: center;
  gap: 1rem;
  max-width: 860px;
  margin: 0 auto;
  flex-wrap: wrap;
}

header h1 { font-size: 1.5rem; font-weight: 700; flex-shrink: 0; }

.header-nav {
  display: flex;
  gap: 0.25rem;
  margin-left: 1.5rem;
}

.header-nav a {
  padding: 0.35rem 0.7rem;
  border-radius: 6px;
  color: rgba(255,255,255,0.7);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
  transition: background 0.15s, color 0.15s;
}

.header-nav a:hover { color: #fff; background: rgba(255,255,255,0.1); }
.header-nav a.router-link-active { color: #fff; background: rgba(255,255,255,0.15); }

/* Garden dropdown */
.nav-garden-dropdown {
  position: relative;
}

.nav-garden-split {
  display: flex;
  align-items: stretch;
  border-radius: 6px;
  overflow: hidden;
  transition: background 0.15s;
}

.nav-garden-split.router-link-active {
  background: rgba(255,255,255,0.15);
}

.nav-garden-label {
  padding: 0.35rem 0.55rem 0.35rem 0.7rem;
  color: rgba(255,255,255,0.7);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
  transition: color 0.15s;
  display: flex;
  align-items: center;
}

.nav-garden-label:hover { color: #fff; }
.nav-garden-split.router-link-active .nav-garden-label { color: #fff; }

.nav-garden-caret-btn {
  padding: 0.35rem 0.5rem;
  border: none;
  border-left: 1px solid rgba(255,255,255,0.2);
  background: transparent;
  color: rgba(255,255,255,0.5);
  font-size: 0.6rem;
  line-height: 1;
  cursor: pointer;
  transition: color 0.15s, background 0.15s;
  display: flex;
  align-items: center;
}

.nav-garden-caret-btn:hover {
  color: #fff;
  background: rgba(255,255,255,0.1);
}

.nav-garden-split:not(.router-link-active):hover {
  background: rgba(255,255,255,0.08);
}

.nav-garden-menu {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  min-width: 160px;
  background: var(--green-dark);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 8px;
  padding: 0.3rem 0;
  z-index: 150;
  box-shadow: 0 4px 16px rgba(0,0,0,0.25);
}

.nav-garden-item {
  display: block;
  width: 100%;
  padding: 0.45rem 0.9rem;
  background: none;
  border: none;
  color: rgba(255,255,255,0.75);
  font-size: 0.85rem;
  font-weight: 500;
  text-align: left;
  cursor: pointer;
  transition: background 0.1s, color 0.1s;
}

.nav-garden-item:hover { background: rgba(255,255,255,0.1); color: #fff; }
.nav-garden-item--active { color: #fff; font-weight: 700; }

.new-garden-btn {
  padding: 0.25rem 0.55rem;
  border-radius: 6px;
  border: 1.5px solid rgba(255,255,255,0.35);
  background: transparent;
  color: rgba(255,255,255,0.7);
  font-size: 1rem;
  font-weight: 700;
  line-height: 1;
  cursor: pointer;
  transition: background 0.15s, color 0.15s, border-color 0.15s;
}

.new-garden-btn:hover {
  background: rgba(255,255,255,0.1);
  border-color: rgba(255,255,255,0.6);
  color: #fff;
}

/* New garden modal */
.ng-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 1rem;
}

.ng-modal {
  background: #fff;
  border-radius: 10px;
  width: 100%;
  max-width: 360px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
  overflow: hidden;
}

.ng-header {
  padding: 0.85rem 1.25rem;
  background: var(--green-pale);
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--green-dark);
}

.ng-body {
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.ng-input {
  width: 100%;
  padding: 0.45rem 0.65rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  font-size: 0.9rem;
  background: var(--bg);
  color: var(--text);
  outline: none;
}

.ng-input:focus { border-color: var(--green-mid); }

.ng-error {
  font-size: 0.8rem;
  color: #b91c1c;
  margin-top: -0.5rem;
}

.ng-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.ng-cancel {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  background: #fff;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.ng-cancel:hover { border-color: var(--green-mid); color: var(--green-dark); }

.ng-save {
  padding: 0.4rem 1rem;
  border: none;
  border-radius: 8px;
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.15s;
}

.ng-save:hover:not(:disabled) { opacity: 0.85; }
.ng-save:disabled { opacity: 0.45; cursor: not-allowed; }

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-left: auto;
}

.display-name {
  font-size: 0.85rem;
  color: rgba(255,255,255,0.7);
}

.settings-btn {
  padding: 0.35rem 0.7rem;
  border: 1.5px solid rgba(255,255,255,0.3);
  border-radius: 6px;
  color: rgba(255,255,255,0.7);
  text-decoration: none;
  font-size: 0.75rem;
  font-weight: 600;
  transition: border-color 0.15s, color 0.15s;
}

.settings-btn:hover { border-color: rgba(255,255,255,0.7); color: #fff; }
.settings-btn.router-link-active { border-color: #fff; color: #fff; }

.logout-btn {
  padding: 0.35rem 0.7rem;
  border: 1.5px solid rgba(255,255,255,0.3);
  border-radius: 6px;
  background: transparent;
  color: rgba(255,255,255,0.8);
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.logout-btn:hover { border-color: rgba(255,255,255,0.8); color: #fff; }

@media (max-width: 540px) {
  .header-top { gap: 0.5rem; padding-bottom: 0.25rem; }
  .header-nav { margin-left: 0; width: 100%; order: 3; padding-bottom: 0.25rem; }
  .header-controls { margin-left: auto; }
  .display-name { display: none; }
}
</style>

<script setup>
import { watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter, RouterView, RouterLink } from 'vue-router'
import { user, logout } from './stores/auth.js'

const { t, locale } = useI18n()
const router = useRouter()

const localeFlag = { en: '🇬🇧', nl: '🇳🇱' }

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
  router.push('/')
}
</script>

<template>
  <header v-if="user">
    <div class="header-top">
      <h1>🌱 Kitchen Garden</h1>
      <nav class="header-nav">
        <template v-if="!user?.roles?.includes('ROLE_ADMIN')">
          <RouterLink to="/home">{{ t('home') }}</RouterLink>
          <RouterLink to="/garden">{{ t('myGarden') }}</RouterLink>
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

@media (max-width: 540px) {
  .header-top { gap: 0.5rem; padding-bottom: 0.25rem; }
  .header-nav { margin-left: 0; width: 100%; order: 3; padding-bottom: 0.25rem; }
  .header-controls { margin-left: auto; }
  .display-name { display: none; }
}
</style>

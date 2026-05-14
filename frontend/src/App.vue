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
@import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,600;0,9..144,700;1,9..144,400&family=Nunito:wght@400;500;600;700&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --green-dark:  #3d2b1f;
  --green-mid:   #c26b3a;
  --green-light: #e8a87c;
  --green-pale:  #dfc4a4;
  --bg:          #fdf6ec;
  --card-bg:     #ffffff;
  --text:        #3d2b1f;
  --text-muted:  #7a5a45;
  --radius:      16px;
}

body {
  font-family: 'Nunito', sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
}

header {
  background: #fff;
  border-bottom: 1.5px dashed var(--green-pale);
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

header h1 {
  font-family: 'Fraunces', serif;
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--green-dark);
  flex-shrink: 0;
}

.header-nav {
  display: flex;
  gap: 0.25rem;
  margin-left: 1.5rem;
}

.header-nav a {
  padding: 0.35rem 0.7rem;
  border-radius: 999px;
  color: var(--text-muted);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 700;
  transition: background 0.15s, color 0.15s;
}

.header-nav a:hover { color: var(--green-dark); background: var(--bg); }
.header-nav a.router-link-active { color: var(--green-mid); background: #fff3ec; }

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-left: auto;
}

.display-name {
  font-size: 0.85rem;
  color: var(--text-muted);
}

.settings-btn {
  padding: 0.35rem 0.7rem;
  border: 1.5px dashed var(--green-pale);
  border-radius: 999px;
  color: var(--text-muted);
  text-decoration: none;
  font-size: 0.75rem;
  font-weight: 700;
  transition: border-color 0.15s, color 0.15s, border-style 0.15s;
}

.settings-btn:hover,
.settings-btn.router-link-active { border-color: var(--green-mid); color: var(--green-mid); border-style: solid; }

.logout-btn {
  padding: 0.35rem 0.7rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 999px;
  background: transparent;
  color: var(--text-muted);
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}

.logout-btn:hover { border-color: var(--green-mid); color: var(--green-mid); background: #fff3ec; }

@media (max-width: 540px) {
  .header-top { gap: 0.5rem; padding-bottom: 0.25rem; }
  .header-nav { margin-left: 0; width: 100%; order: 3; padding-bottom: 0.25rem; }
  .header-controls { margin-left: auto; }
  .display-name { display: none; }
}
</style>

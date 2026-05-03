<script setup>
import { ref, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { RouterView } from 'vue-router'
import LoginForm from './components/LoginForm.vue'
import { user, checkAuth, logout } from './stores/auth.js'

const { t, locale } = useI18n()
const authChecked = ref(false)

function switchLocale(lang) {
  locale.value = lang
  localStorage.setItem('locale', lang)
}

onMounted(async () => {
  await checkAuth()
  authChecked.value = true
})
</script>

<template>
  <template v-if="!authChecked" />

  <LoginForm v-else-if="!user" />

  <template v-else>
    <header>
      <div class="header-top">
        <h1>🌱 Kitchen Garden</h1>
        <div class="header-controls">
          <span class="display-name">{{ user.username }}</span>
          <button class="logout-btn" @click="logout">{{ t('logout') }}</button>
          <div class="lang-switcher">
            <button :class="{ active: locale === 'en' }" @click="switchLocale('en')">EN</button>
            <button :class="{ active: locale === 'nl' }" @click="switchLocale('nl')">NL</button>
          </div>
        </div>
      </div>
    </header>
    <RouterView />
  </template>
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
  padding: 1rem 1.5rem;
}

.header-top {
  display: flex;
  align-items: center;
  gap: 1rem;
  max-width: 860px;
  margin: 0 auto;
}

header h1 { font-size: 1.5rem; font-weight: 700; }

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
  padding: 0.25rem 0.7rem;
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

.lang-switcher { display: flex; gap: 0.25rem; }

.lang-switcher button {
  padding: 0.25rem 0.6rem;
  border: 1.5px solid rgba(255,255,255,0.3);
  border-radius: 6px;
  background: transparent;
  color: rgba(255,255,255,0.6);
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.lang-switcher button:hover { border-color: rgba(255,255,255,0.7); color: #fff; }
.lang-switcher button.active { border-color: #fff; color: #fff; }
</style>

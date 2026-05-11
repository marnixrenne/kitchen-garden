<script setup>
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { user } from '../stores/auth.js'

const { t, locale } = useI18n()
const router = useRouter()

async function switchLocale(lang) {
  locale.value = lang
  localStorage.setItem('locale', lang)
  await fetch('/api/preferences/locale', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ value: lang }),
  })
}
</script>

<template>
  <main>
    <button class="back-btn" @click="router.back()">{{ t('back') }}</button>

    <div class="settings-card">
      <h2>{{ t('settings.title') }}</h2>

      <div class="setting-row">
        <span class="setting-label">{{ t('settings.username') }}</span>
        <span class="setting-value">{{ user?.username }}</span>
      </div>

      <div class="setting-row">
        <span class="setting-label">{{ t('settings.language') }}</span>
        <div class="lang-options">
          <button
            :class="['lang-btn', { active: locale === 'en' }]"
            @click="switchLocale('en')"
          >
            🇬🇧 English
          </button>
          <button
            :class="['lang-btn', { active: locale === 'nl' }]"
            @click="switchLocale('nl')"
          >
            🇳🇱 Nederlands
          </button>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
main {
  max-width: 560px;
  margin: 0 auto;
  padding: 1.5rem 1rem 4rem;
}

.back-btn {
  background: none;
  border: none;
  color: var(--green-mid);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  margin-bottom: 1.5rem;
  display: block;
}

.back-btn:hover { color: var(--green-dark); }

.settings-card {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.settings-card h2 {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--green-dark);
}

.setting-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding-top: 1.25rem;
  border-top: 1px solid var(--green-pale);
  flex-wrap: wrap;
}

.setting-label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.setting-value {
  font-size: 0.95rem;
  color: var(--text);
  font-weight: 500;
}

.lang-options {
  display: flex;
  gap: 0.5rem;
}

.lang-btn {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  background: transparent;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}

.lang-btn:hover {
  border-color: var(--green-mid);
  color: var(--green-mid);
}

.lang-btn.active {
  background: var(--green-mid);
  border-color: var(--green-mid);
  color: #fff;
}
</style>

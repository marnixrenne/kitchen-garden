import { createI18n } from 'vue-i18n'
import en from './en.js'
import nl from './nl.js'

function initialLocale() {
  const saved = localStorage.getItem('locale')
  if (saved) return saved
  const lang = navigator.language?.split('-')?.[0]?.toLowerCase()
  return lang === 'nl' ? 'nl' : 'en'
}

export default createI18n({
  legacy: false,
  locale: initialLocale(),
  fallbackLocale: 'en',
  messages: { en, nl },
})

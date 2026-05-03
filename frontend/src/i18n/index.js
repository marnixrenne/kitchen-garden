import { createI18n } from 'vue-i18n'
import en from './en.js'
import nl from './nl.js'

const savedLocale = localStorage.getItem('locale') ?? 'en'

export default createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages: { en, nl },
})

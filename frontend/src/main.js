import { createApp } from 'vue'
import App from './App.vue'
import i18n from './i18n/index.js'
import router from './router/index.js'
import { watchForExpiredSession } from './stores/auth.js'
import { clearGardens } from './stores/garden.js'

watchForExpiredSession(() => {
  clearGardens()
  router.push({ path: '/login', query: { expired: '1' } })
})

createApp(App).use(i18n).use(router).mount('#app')

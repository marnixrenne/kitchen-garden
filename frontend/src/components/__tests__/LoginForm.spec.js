import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createI18n } from 'vue-i18n'
import en from '../../i18n/en.js'
import LoginForm from '../LoginForm.vue'

const i18n = createI18n({ legacy: false, locale: 'en', messages: { en } })

async function mountAt(path) {
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/:p(.*)*', component: { template: '<div />' } }] })
  await router.push(path)
  return mount(LoginForm, { global: { plugins: [router, i18n] } })
}

describe('LoginForm', () => {
  it('explains why the user is back at the login page after a session expired', async () => {
    expect((await mountAt('/login?expired=1')).find('.expired').text()).toBe(en.login.sessionExpired)
  })

  it('says nothing on a normal visit', async () => {
    expect((await mountAt('/login')).find('.expired').exists()).toBe(false)
  })
})

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'

const router = useRouter()
const { t } = useI18n()

const email   = ref('')
const loading = ref(false)
const error   = ref('')
const sent    = ref(false)

async function submit() {
  error.value   = ''
  loading.value = true
  try {
    const res = await fetch('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
      body: JSON.stringify({ email: email.value }),
    })
    if (res.ok) {
      sent.value = true
    } else {
      const data = await res.json()
      error.value = data.error ?? 'Something went wrong'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="card">
      <div class="icon">🌱</div>
      <h1>{{ t('signup.title') }}</h1>

      <template v-if="sent">
        <p class="success">{{ t('signup.successMessage', { email }) }}</p>
        <button class="back-link" @click="router.push('/login')">{{ t('signup.backToSignIn') }}</button>
      </template>

      <template v-else>
        <p class="subtitle">{{ t('signup.subtitle') }}</p>

        <form @submit.prevent="submit">
          <div class="field">
            <label for="email">{{ t('signup.emailLabel') }}</label>
            <input
              id="email"
              v-model="email"
              type="email"
              autocomplete="email"
              :placeholder="t('signup.emailPlaceholder')"
              required
            />
          </div>

          <p v-if="error" class="error">{{ error }}</p>

          <button type="submit" :disabled="loading">
            {{ loading ? t('signup.sending') : t('signup.submit') }}
          </button>
        </form>

        <p class="footer-link">
          {{ t('signup.alreadyHaveAccount') }}
          <button class="inline-link" @click="router.push('/login')">{{ t('signup.signIn') }}</button>
        </p>
      </template>
    </div>
  </div>
</template>

<style scoped>
.page {
  min-height: 100vh;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  background: var(--bg);
  padding: 2rem 1rem;
}

@media (min-height: 600px) {
  .page { align-items: center; }
}

.card {
  width: 100%;
  max-width: 380px;
  padding: 2.5rem 2rem;
  background: var(--card-bg);
  border: 2px solid var(--green-pale);
  border-radius: 20px;
  box-shadow: 5px 5px 0 var(--green-pale);
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
}

@media (max-width: 480px) {
  .card { padding: 1.75rem 1.25rem; }
}

.icon { font-size: 2.5rem; text-align: center; }

h1 {
  text-align: center;
  font-size: 1.4rem;
  font-weight: 700;
  font-family: 'Fraunces', serif;
  color: var(--green-dark);
}

.subtitle {
  font-size: 0.9rem;
  color: var(--text-muted);
  text-align: center;
  line-height: 1.5;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-muted);
}

input {
  padding: 0.6rem 0.8rem;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  font-size: 0.95rem;
  color: var(--text);
  outline: none;
  transition: border-color 0.15s;
}

input:focus { border-color: var(--green-mid); }

.error {
  font-size: 0.85rem;
  color: #c0392b;
  text-align: center;
}

button[type="submit"] {
  width: 100%;
  padding: 0.75rem;
  background: var(--green-mid);
  color: #fff;
  border: none;
  border-radius: 999px;
  font-family: 'Nunito', sans-serif;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 3px 3px 0 #a85530;
  transition: transform 0.1s, box-shadow 0.1s, background 0.15s;
}

button[type="submit"]:hover:not(:disabled) {
  background: #a85530;
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0 #8a3e1e;
}
button[type="submit"]:disabled { opacity: 0.6; cursor: not-allowed; box-shadow: none; }

.success {
  font-size: 0.95rem;
  color: var(--green-mid);
  text-align: center;
  line-height: 1.55;
}

.back-link {
  background: none;
  border: 1.5px dashed var(--green-pale);
  border-radius: 999px;
  padding: 0.6rem;
  width: 100%;
  color: var(--green-mid);
  font-family: 'Nunito', sans-serif;
  font-size: 0.9rem;
  font-weight: 700;
  cursor: pointer;
  transition: border-color 0.15s, border-style 0.15s;
}

.back-link:hover { border-color: var(--green-mid); border-style: solid; }

.footer-link {
  text-align: center;
  font-size: 0.85rem;
  color: var(--text-muted);
}

.inline-link {
  background: none;
  border: none;
  color: var(--green-mid);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
  text-decoration: underline;
}
</style>

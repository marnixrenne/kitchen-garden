<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { login } from '../stores/auth.js'

const { t } = useI18n()
const router = useRouter()

const username = ref('')
const password = ref('')
const error    = ref(false)
const loading  = ref(false)

async function submit() {
  error.value   = false
  loading.value = true
  try {
    const ok = await login(username.value, password.value)
    if (ok) {
      router.push('/home')
    } else {
      error.value = true
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-wrapper">
    <form class="login-card" @submit.prevent="submit">
      <div class="login-icon">🌱</div>
      <h1>Kitchen Garden</h1>

      <div class="field">
        <label for="username">{{ t('login.username') }}</label>
        <input
          id="username"
          v-model="username"
          type="text"
          autocomplete="username"
          required
        />
      </div>

      <div class="field">
        <label for="password">{{ t('login.password') }}</label>
        <input
          id="password"
          v-model="password"
          type="password"
          autocomplete="current-password"
          required
        />
      </div>

      <p v-if="error" class="error">{{ t('login.error') }}</p>

      <button type="submit" :disabled="loading">
        {{ t('login.submit') }}
      </button>
    </form>
  </div>
</template>

<style scoped>
.login-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
  padding: 1rem;
}

.login-card {
  width: 100%;
  max-width: 360px;
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
  .login-card { padding: 1.75rem 1.25rem; }
}

.login-icon {
  font-size: 2.5rem;
  text-align: center;
}

h1 {
  text-align: center;
  font-size: 1.4rem;
  font-weight: 700;
  font-family: 'Fraunces', serif;
  color: var(--green-dark);
  margin-bottom: 0.25rem;
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

input:focus {
  border-color: var(--green-mid);
}

.error {
  font-size: 0.85rem;
  color: #c0392b;
  text-align: center;
}

button {
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

button:hover:not(:disabled) {
  background: #a85530;
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0 #8a3e1e;
}
button:disabled { opacity: 0.6; cursor: not-allowed; box-shadow: none; }
</style>

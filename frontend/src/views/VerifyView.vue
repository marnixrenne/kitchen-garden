<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { csrfHeaders } from '../stores/auth.js'

const route  = useRoute()
const router = useRouter()
const { t } = useI18n()

const status   = ref('loading')   // 'loading' | 'valid' | 'invalid' | 'done'
const email    = ref('')
const password = ref('')
const confirm  = ref('')
const error    = ref('')
const loading  = ref(false)

onMounted(async () => {
  const token = route.query.token
  if (!token) { status.value = 'invalid'; return }

  const res = await fetch(`/api/auth/verify/${encodeURIComponent(token)}`)
  if (res.ok) {
    const data = await res.json()
    email.value  = data.email
    status.value = 'valid'
  } else {
    status.value = 'invalid'
  }
})

async function submit() {
  error.value = ''
  if (password.value !== confirm.value) {
    error.value = t('verify.passwordMismatch')
    return
  }
  loading.value = true
  try {
    const res = await fetch('/api/auth/complete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
      body: JSON.stringify({
        token:    route.query.token,
        password: password.value,
      }),
    })
    const data = await res.json()
    if (res.ok) {
      status.value = 'done'
    } else {
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

      <!-- Loading -->
      <template v-if="status === 'loading'">
        <p class="center muted">{{ t('verify.verifying') }}</p>
      </template>

      <!-- Invalid / expired token -->
      <template v-else-if="status === 'invalid'">
        <h1>{{ t('verify.invalidTitle') }}</h1>
        <p class="subtitle">{{ t('verify.invalidSubtitle') }}</p>
        <button class="btn-outline" @click="router.push('/signup')">{{ t('verify.backToSignUp') }}</button>
      </template>

      <!-- Account created -->
      <template v-else-if="status === 'done'">
        <h1>{{ t('verify.doneTitle') }}</h1>
        <p class="success">{{ t('verify.doneSuccess', { email }) }}</p>
        <button class="btn-primary" @click="router.push('/login')">{{ t('verify.goToSignIn') }}</button>
      </template>

      <!-- Set username + password -->
      <template v-else>
        <h1>{{ t('verify.setPasswordTitle') }}</h1>
        <p class="subtitle">{{ t('verify.creatingFor', { email }) }}</p>

        <form @submit.prevent="submit">
          <input type="email" :value="email" autocomplete="username" style="display:none" />
          <div class="field">
            <label for="password">{{ t('verify.passwordLabel') }}</label>
            <input
              id="password"
              v-model="password"
              type="password"
              autocomplete="new-password"
              required
            />
          </div>

          <div class="field">
            <label for="confirm">{{ t('verify.confirmLabel') }}</label>
            <input
              id="confirm"
              v-model="confirm"
              type="password"
              autocomplete="new-password"
              required
            />
          </div>

          <p v-if="error" class="error">{{ error }}</p>

          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? t('verify.submitting') : t('verify.submit') }}
          </button>
        </form>
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

.center { text-align: center; }
.muted  { color: var(--text-muted); }

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

.success {
  font-size: 0.95rem;
  color: var(--green-mid);
  text-align: center;
  line-height: 1.55;
}

.btn-primary {
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

.btn-primary:hover:not(:disabled) {
  background: #a85530;
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0 #8a3e1e;
}
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; box-shadow: none; }

.btn-outline {
  width: 100%;
  padding: 0.75rem;
  background: none;
  border: 1.5px dashed var(--green-pale);
  border-radius: 999px;
  color: var(--green-mid);
  font-family: 'Nunito', sans-serif;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: border-color 0.15s, border-style 0.15s;
}

.btn-outline:hover { border-color: var(--green-mid); border-style: solid; }
</style>

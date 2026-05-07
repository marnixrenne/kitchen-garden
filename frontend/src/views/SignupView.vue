<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { csrfHeaders } from '../stores/auth.js'

const router = useRouter()

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
      <h1>Create account</h1>

      <template v-if="sent">
        <p class="success">
          Check your inbox — we've sent a verification link to <strong>{{ email }}</strong>.
        </p>
        <button class="back-link" @click="router.push('/login')">Back to sign in</button>
      </template>

      <template v-else>
        <p class="subtitle">Enter your email address and we'll send you a link to get started.</p>

        <form @submit.prevent="submit">
          <div class="field">
            <label for="email">Email address</label>
            <input
              id="email"
              v-model="email"
              type="email"
              autocomplete="email"
              placeholder="you@example.com"
              required
            />
          </div>

          <p v-if="error" class="error">{{ error }}</p>

          <button type="submit" :disabled="loading">
            {{ loading ? 'Sending…' : 'Send verification link' }}
          </button>
        </form>

        <p class="footer-link">
          Already have an account?
          <button class="inline-link" @click="router.push('/login')">Sign in</button>
        </p>
      </template>
    </div>
  </div>
</template>

<style scoped>
.page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
  padding: 1rem;
}

.card {
  width: 100%;
  max-width: 380px;
  padding: 2.5rem 2rem;
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
}

.icon { font-size: 2.5rem; text-align: center; }

h1 {
  text-align: center;
  font-size: 1.4rem;
  font-weight: 700;
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
  border-radius: var(--radius);
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}

button[type="submit"]:hover:not(:disabled) { background: var(--green-dark); }
button[type="submit"]:disabled { opacity: 0.6; cursor: not-allowed; }

.success {
  font-size: 0.95rem;
  color: var(--green-mid);
  text-align: center;
  line-height: 1.55;
}

.back-link {
  background: none;
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 0.6rem;
  width: 100%;
  color: var(--green-mid);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s;
}

.back-link:hover { border-color: var(--green-mid); }

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

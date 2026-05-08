<script setup>
import { ref, onMounted } from 'vue'

function formatDate(ts) {
  if (!ts) return '—'
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(ts))
}

const users   = ref([])
const loading = ref(true)
const error   = ref(null)

async function fetchUsers() {
  loading.value = true
  error.value   = null
  try {
    const res = await fetch('/api/admin/users')
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    users.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(fetchUsers)
</script>

<template>
  <main>
    <div class="admin-header">
      <h2>Users</h2>
      <button class="refresh-btn" @click="fetchUsers" :disabled="loading">Refresh</button>
    </div>

    <div v-if="loading" class="state-msg">Loading…</div>
    <div v-else-if="error" class="state-msg error">Failed to load users: {{ error }}</div>
    <div v-else-if="users.length === 0" class="state-msg">No users found.</div>
    <table v-else class="users-table">
      <thead>
        <tr>
          <th>Username</th>
          <th>Status</th>
          <th>Last login</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="u in users" :key="u.username">
          <td class="username">{{ u.username }}</td>
          <td>
            <span :class="['status-badge', u.online ? 'online' : 'offline']">
              {{ u.online ? 'Online' : 'Offline' }}
            </span>
          </td>
          <td class="last-login">{{ formatDate(u.lastLogin) }}</td>
        </tr>
      </tbody>
    </table>
  </main>
</template>

<style scoped>
main {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
}

.admin-header h2 {
  font-size: 1.4rem;
  color: var(--green-dark);
}

.refresh-btn {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-mid);
  border-radius: var(--radius);
  background: transparent;
  color: var(--green-mid);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.refresh-btn:hover:not(:disabled) {
  background: var(--green-mid);
  color: #fff;
}

.refresh-btn:disabled { opacity: 0.5; cursor: default; }

.state-msg {
  text-align: center;
  color: var(--text-muted);
  padding: 2rem 0;
}

.state-msg.error { color: #c0392b; }

.users-table {
  width: 100%;
  border-collapse: collapse;
  background: var(--card-bg);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.users-table th,
.users-table td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid var(--green-pale);
}

.users-table th {
  background: var(--green-pale);
  color: var(--green-dark);
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.users-table tbody tr:last-child td { border-bottom: none; }

.username   { font-size: 0.9rem; color: var(--text); }
.last-login { font-size: 0.85rem; color: var(--text-muted); }

.status-badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-badge.online  { background: #d1fae5; color: #065f46; }
.status-badge.offline { background: #f3f4f6; color: #6b7280; }
</style>

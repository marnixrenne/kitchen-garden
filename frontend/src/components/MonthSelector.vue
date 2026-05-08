<script setup>
import { useI18n } from 'vue-i18n'

defineProps({
  months: Array,
  counts: Object,
  selected: Number,
})

defineEmits(['select'])

const { t } = useI18n()
</script>

<template>
  <div class="month-grid">
    <button
      v-for="(name, i) in months"
      :key="i"
      class="month-btn"
      :class="{ active: selected === i + 1 }"
      @click="$emit('select', selected === i + 1 ? null : i + 1)"
    >
      {{ name }}
      <span class="count">
        {{ counts[i + 1] ? t('cropCount', { n: counts[i + 1] }) : '—' }}
      </span>
    </button>
  </div>
</template>

<style scoped>
.month-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 0.5rem;
  margin-bottom: 2.5rem;
}

@media (max-width: 540px) {
  .month-grid { grid-template-columns: repeat(4, 1fr); }
}

@media (max-width: 360px) {
  .month-grid { grid-template-columns: repeat(3, 1fr); }
}

.month-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 0.7rem 0.25rem 0.5rem;
  border: 2px solid var(--green-pale);
  border-radius: var(--radius);
  background: var(--card-bg);
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-muted);
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}

.month-btn:hover {
  border-color: var(--green-light);
  color: var(--green-mid);
}

.month-btn.active {
  background: var(--green-mid);
  border-color: var(--green-mid);
  color: #fff;
}

.count {
  font-size: 0.7rem;
  font-weight: 400;
  opacity: 0.75;
}

.month-btn.active .count { opacity: 0.85; }
</style>

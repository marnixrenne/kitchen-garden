<script setup>
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { zonePicker, closeZonePicker } from '../stores/zonePicker.js'
import { zoneLabel, isSunShortfall } from '../utils/zones.js'

const { t, te } = useI18n()

const selected = ref(null)
watch(() => zonePicker.value.open, () => { selected.value = null })

function plantName(plant) {
  if (!plant) return ''
  const key = `plants.${plant.name}`
  return te(key) ? t(key) : plant.name
}

function shortfall(zone) {
  return isSunShortfall(zone.sunExposure, zonePicker.value.plant?.sunRequirement)
}
</script>

<template>
  <Teleport to="body">
    <div v-if="zonePicker.open" class="bp-backdrop" @click.self="closeZonePicker(null)">
      <div class="bp-modal" role="dialog" aria-modal="true">
        <div class="bp-header">{{ t('zones.pickTitle', { plant: plantName(zonePicker.plant) }) }}</div>
        <div class="bp-body">
          <label v-for="zone in zonePicker.zones" :key="zone.id" class="bp-option" :class="{ chosen: selected === zone.id }">
            <input v-model="selected" type="radio" name="zone" :value="zone.id" />
            <span class="bp-name">{{ zoneLabel(t, zone.name) }}</span>
            <span v-if="zone.sunExposure" class="bp-sun">{{ t(`sunRequirement.${zone.sunExposure}`) }}</span>
            <span v-if="shortfall(zone)" class="bp-warning">⚠️ {{ t('zones.sunWarning') }}</span>
          </label>
          <div class="bp-actions">
            <button class="bp-cancel" @click="closeZonePicker(null)">{{ t('garden.seedModal.cancel') }}</button>
            <button class="bp-confirm" :disabled="!selected" @click="closeZonePicker(selected)">{{ t('zones.pickConfirm') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.bp-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 1rem;
}

.bp-modal {
  background: #fff;
  border-radius: 10px;
  width: 100%;
  max-width: 380px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
  overflow: hidden;
}

.bp-header {
  padding: 0.85rem 1.25rem;
  background: var(--green-pale);
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--green-dark);
}

.bp-body {
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.bp-option {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
}

.bp-option.chosen { border-color: var(--green-mid); }
.bp-name { font-weight: 600; color: var(--green-dark); }
.bp-sun { font-size: 0.78rem; color: var(--text-muted); }
.bp-warning { flex-basis: 100%; font-size: 0.78rem; color: #9a3412; }

.bp-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.75rem;
}

.bp-cancel {
  padding: 0.4rem 0.9rem;
  border: 1.5px solid var(--green-pale);
  border-radius: 8px;
  background: #fff;
  color: var(--text-muted);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.bp-confirm {
  padding: 0.4rem 1rem;
  border: none;
  border-radius: 8px;
  background: var(--green-mid);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.bp-confirm:disabled { opacity: 0.5; cursor: default; }
</style>

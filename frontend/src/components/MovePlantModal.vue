<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { activeGardenId } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { zoneLabel } from '../utils/zones.js'
import { todayIso } from '../utils/dates.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

const props = defineProps({
  plantName: { type: String, required: true },
  instance:  { type: Object, required: true },
  zones:     { type: Array,  required: true },
})
const emit = defineEmits(['close', 'moved'])

const { t } = useI18n()
const { busy, error, submit } = usePopupSubmit()

const targets = computed(() => props.zones.filter(z => z.id !== props.instance.zoneId))
const zoneId  = ref(null)
const date    = ref(todayIso())
const comment = ref('')

async function confirm() {
  if (!zoneId.value) return
  const res = await submit(() => fetch(`/api/gardens/${activeGardenId.value}/instances/${props.instance.id}/move`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ zoneId: zoneId.value, date: date.value || null, comment: comment.value.trim() || null }),
  }))
  if (res) emit('moved')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('zones.moveTitle', { plant: plantName }) }}</div>
        <div class="dg-body">
          <label class="bf-field">
            <span class="bf-label">{{ t('zones.moveTo') }}</span>
            <select v-model="zoneId" class="eg-input">
              <option :value="null" disabled>{{ t('zones.chooseZone') }}</option>
              <option v-for="zone in targets" :key="zone.id" :value="zone.id">{{ zoneLabel(t, zone.name) }}</option>
            </select>
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.dateLabel') }}</span>
            <input v-model="date" class="eg-input" type="date" />
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('garden.seedModal.commentLabel') }}</span>
            <input v-model="comment" class="eg-input" maxlength="1000" :placeholder="t('garden.seedModal.commentPlaceholder')" />
          </label>
          <p v-if="error" class="bf-error">{{ error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" :disabled="busy" @click="emit('close')">{{ t('garden.seedModal.cancel') }}</button>
            <button class="eg-save" :disabled="busy || !zoneId" @click="confirm">{{ t('zones.moveConfirm') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

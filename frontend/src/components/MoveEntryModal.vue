<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { activeGardenId } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

// Only the date and comment of a Move can change
const props = defineProps({
  entry:       { type: Object, required: true },
  description: { type: String, required: true },
})
const emit = defineEmits(['close', 'saved'])

const { t } = useI18n()
const { busy, error, submit } = usePopupSubmit()

const date    = ref(props.entry.date)
const comment = ref(props.entry.comment ?? '')

async function save() {
  if (!date.value) return
  const res = await submit(() => fetch(`/api/gardens/${activeGardenId.value}/plant-log/${props.entry.id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ date: date.value, comment: comment.value.trim() || null }),
  }))
  if (res) emit('saved')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('zones.editEntry') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ description }}</p>
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
            <button class="eg-save" :disabled="busy || !date" @click="save">{{ t('garden.editGardenSave') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

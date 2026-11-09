<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { activeGardenId, activeGardenName, gardens } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

const emit = defineEmits(['close'])

const { t } = useI18n()
const { busy, error, submit } = usePopupSubmit('garden.editGardenFailed')

const name = ref(activeGardenName.value ?? '')

async function save() {
  const id = activeGardenId.value
  if (!id || !name.value.trim()) return
  const res = await submit(() => fetch(`/api/gardens/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify({ name: name.value.trim() }),
  }))
  if (!res) return
  const updated = await res.json()
  const index = gardens.value.findIndex(g => g.id === id)
  if (index !== -1) gardens.value[index] = updated
  emit('close')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ t('garden.editGarden') }}</div>
        <div class="dg-body">
          <input
            v-model="name"
            class="eg-input"
            :placeholder="t('garden.editGardenPlaceholder')"
            maxlength="100"
            @keydown.enter="save"
            @keydown.esc="emit('close')"
          />
          <p v-if="error" class="bf-error" role="alert">{{ error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" :disabled="busy" @click="emit('close')">{{ t('garden.seedModal.cancel') }}</button>
            <button class="eg-save" :disabled="busy || !name.trim()" @click="save">{{ t('garden.editGardenSave') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

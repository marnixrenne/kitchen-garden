<script setup>
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { activeGardenId, activeGardenName, gardens, setActiveGarden } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

const emit = defineEmits(['close'])

const { t } = useI18n()
const router = useRouter()
const { busy, error, submit } = usePopupSubmit('garden.deleteGardenFailed')

async function confirm() {
  const id = activeGardenId.value
  if (!id) return
  const res = await submit(() => fetch(`/api/gardens/${id}`, { method: 'DELETE', headers: csrfHeaders() }))
  if (!res) return
  emit('close')
  const remaining = gardens.value.filter(g => g.id !== id)
  setActiveGarden(remaining.length > 0 ? remaining[0].id : null)
  gardens.value = remaining
  router.push(remaining.length > 0 ? '/' : '/discover')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="dg-header">{{ t('garden.deleteGarden') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ t('garden.deleteGardenConfirm', { name: activeGardenName ?? t('myGarden') }) }}</p>
          <p v-if="error" class="bf-error" role="alert">{{ error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" :disabled="busy" @click="emit('close')">{{ t('garden.seedModal.cancel') }}</button>
            <button class="dg-confirm" :disabled="busy" @click="confirm">{{ t('garden.deleteGardenConfirmBtn') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

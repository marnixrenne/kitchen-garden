<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { activeGardenId } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { zoneLabel } from '../utils/zones.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

const props = defineProps({
  zone:       { type: Object, required: true },
  zones:      { type: Array,  required: true },
  plantCount: { type: Number, required: true },
})
// 'deleted' says whether the zone's plants were removed along with it
const emit = defineEmits(['close', 'deleted'])

const { t } = useI18n()
const { busy, error, submit } = usePopupSubmit()

const otherZones   = computed(() => props.zones.filter(z => z.id !== props.zone.id))
const disposition  = ref('move')
const targetZoneId = ref(otherZones.value[0]?.id ?? null)

async function confirm() {
  const params = props.plantCount === 0 ? ''
    : disposition.value === 'move' ? `?plants=move&targetZoneId=${targetZoneId.value}`
    : '?plants=delete'
  const res = await submit(() => fetch(`/api/gardens/${activeGardenId.value}/zones/${props.zone.id}${params}`, {
    method: 'DELETE',
    headers: csrfHeaders(),
  }))
  if (res) emit('deleted', props.plantCount > 0 && disposition.value === 'delete')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="dg-header">{{ t('zones.delete') }}</div>
        <div class="dg-body">
          <p class="dg-warning">{{ t('zones.deleteConfirm', { name: zoneLabel(t, zone.name) }) }}</p>
          <template v-if="plantCount > 0">
            <p class="dg-warning">{{ t('zones.deleteHasPlants', plantCount) }}</p>
            <label class="bf-radio">
              <input v-model="disposition" type="radio" value="move" />
              {{ t('zones.deleteMovePlants') }}
            </label>
            <select v-if="disposition === 'move'" v-model="targetZoneId" class="eg-input">
              <option v-for="other in otherZones" :key="other.id" :value="other.id">{{ zoneLabel(t, other.name) }}</option>
            </select>
            <label class="bf-radio">
              <input v-model="disposition" type="radio" value="delete" />
              {{ t('zones.deleteRemovePlants') }}
            </label>
          </template>
          <p v-if="error" class="bf-error">{{ error }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" :disabled="busy" @click="emit('close')">{{ t('garden.seedModal.cancel') }}</button>
            <button class="dg-confirm" :disabled="busy" @click="confirm">{{ t('zones.deleteConfirmBtn') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

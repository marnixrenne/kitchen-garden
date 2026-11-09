<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { activeGardenId } from '../stores/garden.js'
import { csrfHeaders } from '../stores/auth.js'
import { ZONE_TYPES, ASPECTS, SUN_LEVELS, MAX_DIMENSION_CM } from '../utils/zones.js'
import { usePopupSubmit } from '../utils/popupSubmit.js'

// Without a zone this popup adds a new one
const props = defineProps({
  zone: { type: Object, default: null },
})
const emit = defineEmits(['close', 'saved'])

const { t } = useI18n()
const { busy, error, submit } = usePopupSubmit()

const form = ref({
  name:        props.zone?.name ?? '',
  type:        props.zone?.type ?? '',
  lengthCm:    props.zone?.lengthCm ?? '',
  widthCm:     props.zone?.widthCm ?? '',
  sunExposure: props.zone?.sunExposure ?? '',
  aspect:      props.zone?.aspect ?? '',
})

function validDimension(value) {
  if (value === '' || value === null) return true
  const n = Number(value)
  return Number.isInteger(n) && n >= 1 && n <= MAX_DIMENSION_CM
}

// The unnamed zone a garden starts with may stay unnamed; every other zone needs a name
const formError = computed(() => {
  const f = form.value
  const mayStayUnnamed = props.zone && props.zone.name === null
  if (!f.name.trim() && !mayStayUnnamed) return t('zones.nameRequired')
  if (!validDimension(f.lengthCm) || !validDimension(f.widthCm)) return t('zones.dimensionsInvalid', { max: MAX_DIMENSION_CM })
  return ''
})

async function save() {
  if (formError.value) return
  const f = form.value
  const body = {
    name:        f.name.trim() || null,
    type:        f.type || null,
    lengthCm:    f.lengthCm === '' ? null : Number(f.lengthCm),
    widthCm:     f.widthCm === '' ? null : Number(f.widthCm),
    sunExposure: f.sunExposure || null,
    aspect:      f.aspect || null,
  }
  const zones = `/api/gardens/${activeGardenId.value}/zones`
  const res = await submit(() => fetch(props.zone ? `${zones}/${props.zone.id}` : zones, {
    method: props.zone ? 'PUT' : 'POST',
    headers: { 'Content-Type': 'application/json', ...csrfHeaders() },
    body: JSON.stringify(body),
  }))
  if (res) emit('saved')
}
</script>

<template>
  <Teleport to="body">
    <div class="dg-backdrop" @click.self="emit('close')">
      <div class="dg-modal" role="dialog" aria-modal="true">
        <div class="eg-header">{{ zone ? t('zones.edit') : t('zones.add') }}</div>
        <div class="dg-body">
          <label class="bf-field">
            <span class="bf-label">{{ t('zones.name') }}</span>
            <input
              v-model="form.name"
              class="eg-input"
              maxlength="100"
              :placeholder="zone && zone.name === null ? t('zones.mainZone') : t('zones.namePlaceholder')"
            />
          </label>
          <label class="bf-field">
            <span class="bf-label">{{ t('zones.typeLabel') }}</span>
            <select v-model="form.type" class="eg-input">
              <option value="">{{ t('zones.notSet') }}</option>
              <option v-for="type in ZONE_TYPES" :key="type" :value="type">{{ t(`zones.type.${type}`) }}</option>
            </select>
          </label>
          <div class="bf-row">
            <label class="bf-field">
              <span class="bf-label">{{ t('zones.lengthCm') }}</span>
              <input v-model="form.lengthCm" class="eg-input" type="number" min="1" :max="MAX_DIMENSION_CM" step="1" />
            </label>
            <label class="bf-field">
              <span class="bf-label">{{ t('zones.widthCm') }}</span>
              <input v-model="form.widthCm" class="eg-input" type="number" min="1" :max="MAX_DIMENSION_CM" step="1" />
            </label>
          </div>
          <div class="bf-row">
            <label class="bf-field">
              <span class="bf-label">{{ t('zones.sunLabel') }}</span>
              <select v-model="form.sunExposure" class="eg-input">
                <option value="">{{ t('zones.notSet') }}</option>
                <option v-for="sun in SUN_LEVELS" :key="sun" :value="sun">{{ t(`sunRequirement.${sun}`) }}</option>
              </select>
            </label>
            <label class="bf-field">
              <span class="bf-label">{{ t('zones.aspectLabel') }}</span>
              <select v-model="form.aspect" class="eg-input">
                <option value="">{{ t('zones.notSet') }}</option>
                <option v-for="aspect in ASPECTS" :key="aspect" :value="aspect">{{ t(`zones.aspect.${aspect}`) }}</option>
              </select>
            </label>
          </div>
          <p v-if="formError || error" class="bf-error">{{ error || formError }}</p>
          <div class="dg-actions">
            <button class="dg-cancel" :disabled="busy" @click="emit('close')">{{ t('garden.seedModal.cancel') }}</button>
            <button class="eg-save" :disabled="busy || !!formError" @click="save">{{ t('garden.editGardenSave') }}</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped src="./gardenPopup.css"></style>

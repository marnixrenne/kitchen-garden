import { ref } from 'vue'
import { activeGardenId } from './garden.js'

const closed = { open: false, zones: [], plant: null, resolve: null }

export const zonePicker = ref({ ...closed })

// Asks which zone a plant goes in. Resolves with:
//   undefined — the garden has a single zone, so the backend places the plant there
//   null      — the user cancelled
//   a zone id  — the zone the user picked
export async function chooseZone(plantId) {
  const res  = await fetch(`/api/gardens/${activeGardenId.value}/zones`)
  const body = res.ok ? await res.json() : []
  const zones = Array.isArray(body) ? body : []
  if (zones.length <= 1) return undefined

  const plantRes = await fetch(`/api/plants/${plantId}`)
  const plant = plantRes.ok ? await plantRes.json() : null
  return new Promise(resolve => {
    zonePicker.value = { open: true, zones, plant, resolve }
  })
}

export function closeZonePicker(zoneId) {
  const { resolve } = zonePicker.value
  zonePicker.value = { ...closed }
  resolve?.(zoneId)
}

export function addPlantUrl(plantId, zoneId) {
  const base = `/api/gardens/${activeGardenId.value}/plants/${plantId}`
  return zoneId ? `${base}?zoneId=${zoneId}` : base
}

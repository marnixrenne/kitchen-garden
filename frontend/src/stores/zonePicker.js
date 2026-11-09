import { ref } from 'vue'
import { csrfHeaders } from './auth.js'
import { activeGardenId, gardensLoaded, openNewGardenModal } from './garden.js'

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
  closeZonePicker(null)
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

const beingAdded = new Set()

// Adds a planting to the active garden, asking which zone when there is a choice.
// Resolves with whether a planting was created. Without a garden it asks for a
// first one instead; a repeat click on a plant still being added is ignored.
export async function addToActiveGarden(plantId) {
  if (!activeGardenId.value) {
    if (gardensLoaded.value) openNewGardenModal()
    return false
  }
  if (beingAdded.has(plantId)) return false
  beingAdded.add(plantId)
  try {
    const zoneId = await chooseZone(plantId)
    if (zoneId === null) return false
    const res = await fetch(addPlantUrl(plantId, zoneId), { method: 'POST', headers: csrfHeaders() })
    return res.ok
  } finally {
    beingAdded.delete(plantId)
  }
}

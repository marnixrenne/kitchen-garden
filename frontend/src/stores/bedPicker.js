import { ref } from 'vue'
import { activeGardenId } from './garden.js'

const closed = { open: false, beds: [], plant: null, resolve: null }

export const bedPicker = ref({ ...closed })

// Asks which bed a plant goes in. Resolves with:
//   undefined — the garden has a single bed, so the backend places the plant there
//   null      — the user cancelled
//   a bed id  — the bed the user picked
export async function chooseBed(plantId) {
  const res  = await fetch(`/api/gardens/${activeGardenId.value}/beds`)
  const body = res.ok ? await res.json() : []
  const beds = Array.isArray(body) ? body : []
  if (beds.length <= 1) return undefined

  const plantRes = await fetch(`/api/plants/${plantId}`)
  const plant = plantRes.ok ? await plantRes.json() : null
  return new Promise(resolve => {
    bedPicker.value = { open: true, beds, plant, resolve }
  })
}

export function closeBedPicker(bedId) {
  const { resolve } = bedPicker.value
  bedPicker.value = { ...closed }
  resolve?.(bedId)
}

export function addPlantUrl(plantId, bedId) {
  const base = `/api/gardens/${activeGardenId.value}/plants/${plantId}`
  return bedId ? `${base}?bedId=${bedId}` : base
}

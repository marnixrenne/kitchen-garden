import { ref, computed } from 'vue'

export const activeGardenId = ref(localStorage.getItem('activeGardenId') || null)
export const gardens = ref([])
export const gardensLoaded = ref(false)
export const gardensFailed = ref(false)
export const newGardenModal = ref({ open: false, name: '', saving: false, error: '' })

export const activeGardenName = computed(() =>
  gardens.value.find(g => g.id === activeGardenId.value)?.name ?? null
)

export function setActiveGarden(id) {
  activeGardenId.value = id
  if (id) localStorage.setItem('activeGardenId', id)
  else localStorage.removeItem('activeGardenId')
}

export async function fetchGardens() {
  try {
    const res = await fetch('/api/gardens')
    if (!res.ok) { gardensFailed.value = true; return }
    gardens.value = await res.json()
    if (gardens.value.length > 0 && !activeGardenId.value) {
      setActiveGarden(gardens.value[0].id)
    }
    gardensFailed.value = false
    gardensLoaded.value = true
  } catch {
    gardensFailed.value = true
  }
}

export function clearGardens() {
  gardens.value = []
  gardensLoaded.value = false
  gardensFailed.value = false
  setActiveGarden(null)
}

export function openNewGardenModal() {
  newGardenModal.value = { open: true, name: '', saving: false, error: '' }
}

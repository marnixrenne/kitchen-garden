import { ref, computed } from 'vue'

export const activeGardenId = ref(localStorage.getItem('activeGardenId') || null)
export const gardens = ref([])
export const gardensLoaded = ref(false)
export const newGardenModal = ref({ open: false, name: '', saving: false, error: '' })

export const activeGardenName = computed(() =>
  gardens.value.find(g => g.id === activeGardenId.value)?.name ?? null
)

export function setActiveGarden(id) {
  activeGardenId.value = id
  if (id) localStorage.setItem('activeGardenId', id)
  else localStorage.removeItem('activeGardenId')
}

export function openNewGardenModal() {
  newGardenModal.value = { open: true, name: '', saving: false, error: '' }
}

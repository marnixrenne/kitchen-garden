import { ref, computed } from 'vue'

export const activeGardenId = ref(localStorage.getItem('activeGardenId') || null)
export const gardens = ref([])

export const activeGardenName = computed(() =>
  gardens.value.find(g => g.id === activeGardenId.value)?.name ?? null
)

export function setActiveGarden(id) {
  activeGardenId.value = id
  if (id) localStorage.setItem('activeGardenId', id)
  else localStorage.removeItem('activeGardenId')
}

export function gardenParam() {
  return activeGardenId.value ? `?gardenId=${activeGardenId.value}` : ''
}

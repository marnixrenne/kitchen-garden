import { ref } from 'vue'

export const activeGardenId = ref(localStorage.getItem('activeGardenId') || null)

export function setActiveGarden(id) {
  activeGardenId.value = id
  if (id) localStorage.setItem('activeGardenId', id)
  else localStorage.removeItem('activeGardenId')
}

export function gardenParam() {
  return activeGardenId.value ? `?gardenId=${activeGardenId.value}` : ''
}

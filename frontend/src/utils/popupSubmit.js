import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

// Sends what a popup asks for, tracking whether it is busy and what went wrong.
// submit resolves with the response, or null after a failure: the popup then
// stays open showing the error, ready to try again. With failureKey every failure
// shows that message; otherwise a refusal shows the server's reason.
export function usePopupSubmit(failureKey = null) {
  const { t } = useI18n()
  const busy  = ref(false)
  const error = ref('')

  async function refusalText(res) {
    if (failureKey) return t(failureKey)
    try { return (await res.json()).message || `Error ${res.status}` } catch { return `Error ${res.status}` }
  }

  async function submit(send) {
    if (busy.value) return null
    busy.value = true
    error.value = ''
    try {
      const res = await send()
      if (res.ok) return res
      error.value = await refusalText(res)
    } catch {
      error.value = t(failureKey ?? 'garden.connectionFailed')
    } finally {
      busy.value = false
    }
    return null
  }

  return { busy, error, submit }
}

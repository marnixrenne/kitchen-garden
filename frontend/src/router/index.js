import { h } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import LandingView         from '../views/LandingView.vue'
import HomeView            from '../views/HomeView.vue'
import DashboardView       from '../views/DashboardView.vue'
import GardenView          from '../views/GardenView.vue'
import PlantDetailView from '../views/PlantDetailView.vue'
import LoginForm           from '../components/LoginForm.vue'
import SignupView          from '../views/SignupView.vue'
import VerifyView          from '../views/VerifyView.vue'
import AdminView           from '../views/AdminView.vue'
import SettingsView        from '../views/SettingsView.vue'
import { user, checkAuth } from '../stores/auth.js'
import { activeGardenId, setActiveGarden } from '../stores/garden.js'

let authInitialized = false

// The same address greets guests and signed-in users differently
const RootView = { render: () => h(user.value ? DashboardView : LandingView) }

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/',               component: RootView,            meta: { public: true, noAdmin: true } },
    { path: '/login',          component: LoginForm,           meta: { public: true, guestOnly: true } },
    { path: '/signup',         component: SignupView,          meta: { public: true } },
    { path: '/verify',         component: VerifyView,          meta: { public: true } },
    { path: '/discover',       component: HomeView,            meta: { requiresAuth: true, noAdmin: true } },
    { path: '/garden',         redirect: (to) => activeGardenId.value ? { path: `/gardens/${activeGardenId.value}`, query: to.query } : '/' },
    { path: '/gardens/:gardenId',              component: GardenView, meta: { requiresAuth: true, noAdmin: true } },
    { path: '/gardens/:gardenId/zones/:zoneId', component: GardenView, meta: { requiresAuth: true, noAdmin: true } },
    { path: '/garden/log',    redirect: { path: '/garden', query: { tab: 'log' } } },
    { path: '/plant/:id',      component: PlantDetailView,     meta: { requiresAuth: true } },
    { path: '/admin',          component: AdminView,           meta: { requiresAuth: true, requiresAdmin: true } },
    { path: '/settings',       component: SettingsView,        meta: { requiresAuth: true } },
  ],
})

router.beforeEach(async (to) => {
  if (!authInitialized) {
    try { await checkAuth() } catch { /* backend unreachable — treat as unauthenticated */ }
    authInitialized = true
  }

  const isAdmin = user.value?.roles?.includes('ROLE_ADMIN')

  if (to.meta.requiresAuth && !user.value) return '/login'
  if (to.meta.guestOnly && user.value)     return isAdmin ? '/admin' : '/'
  if (to.meta.requiresAdmin && !isAdmin)   return '/'
  if (to.meta.noAdmin && isAdmin)          return '/admin'

  if (to.params.gardenId) setActiveGarden(to.params.gardenId)
})

export default router

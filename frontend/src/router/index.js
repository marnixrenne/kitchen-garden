import { createRouter, createWebHistory } from 'vue-router'
import LandingView        from '../views/LandingView.vue'
import HomeView           from '../views/HomeView.vue'
import VegetableDetailView from '../views/VegetableDetailView.vue'
import LoginForm          from '../components/LoginForm.vue'
import { user, checkAuth } from '../stores/auth.js'

let authInitialized = false

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/',               component: LandingView,         meta: { public: true } },
    { path: '/login',          component: LoginForm,           meta: { public: true } },
    { path: '/home',           component: HomeView,            meta: { requiresAuth: true } },
    { path: '/vegetable/:id',  component: VegetableDetailView, meta: { requiresAuth: true } },
  ],
})

router.beforeEach(async (to) => {
  if (!authInitialized) {
    await checkAuth()
    authInitialized = true
  }

  if (to.meta.requiresAuth && !user.value) return '/login'
  if (to.meta.public && user.value)        return '/home'
})

export default router

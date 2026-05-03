import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import VegetableDetailView from '../views/VegetableDetailView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/',               component: HomeView },
    { path: '/vegetable/:id',  component: VegetableDetailView },
  ],
})

export default router

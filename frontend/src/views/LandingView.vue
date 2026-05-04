<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="landing">
    <nav class="landing-nav">
      <button class="sign-in-btn" @click="router.push('/login')">Sign in</button>
      <button class="sign-up-btn" @click="router.push('/signup')">Sign up</button>
    </nav>

    <main class="landing-main">
      <div class="hero">
        <div class="hero-icon">🌱</div>
        <h1>Kitchen Garden</h1>
        <p class="tagline">
          Know exactly what to seed and when. A simple guide to planning
          your vegetable garden through the seasons.
        </p>
        <button class="cta-btn" @click="router.push('/login')">Get started</button>
      </div>

      <div class="features">
        <div class="feature">
          <div class="feature-icon">📅</div>
          <h2>Month by month</h2>
          <p>Select any month and instantly see which vegetables you can start seeding.</p>
        </div>
        <div class="feature">
          <div class="feature-icon">🥦</div>
          <h2>24 vegetables</h2>
          <p>From tomatoes to fennel — covering fruiting, leafy, root, brassica, legume and herb varieties.</p>
        </div>
        <div class="feature">
          <div class="feature-icon">🌍</div>
          <h2>English &amp; Dutch</h2>
          <p>Fully available in both English and Dutch, tailored to a temperate European climate.</p>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.landing {
  min-height: 100vh;
  background: var(--bg);
  display: flex;
  flex-direction: column;
}

.landing-nav {
  padding: 1.25rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.5rem;
}

.sign-in-btn,
.sign-up-btn {
  padding: 0.45rem 1.1rem;
  border-radius: var(--radius);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.sign-in-btn {
  background: transparent;
  border: 1.5px solid var(--green-mid);
  color: var(--green-mid);
}

.sign-in-btn:hover {
  background: var(--green-mid);
  color: #fff;
}

.sign-up-btn {
  background: var(--green-mid);
  border: 1.5px solid var(--green-mid);
  color: #fff;
}

.sign-up-btn:hover { background: var(--green-dark); border-color: var(--green-dark); }

.landing-main {
  flex: 1;
  max-width: 860px;
  margin: 0 auto;
  padding: 3rem 1.5rem 5rem;
  width: 100%;
}

.hero {
  text-align: center;
  padding: 2rem 0 4rem;
}

.hero-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.hero h1 {
  font-size: 2.75rem;
  font-weight: 800;
  color: var(--green-dark);
  margin-bottom: 1rem;
}

.tagline {
  font-size: 1.1rem;
  color: var(--text-muted);
  line-height: 1.65;
  max-width: 500px;
  margin: 0 auto 2rem;
}

.cta-btn {
  padding: 0.8rem 2rem;
  background: var(--green-mid);
  color: #fff;
  border: none;
  border-radius: var(--radius);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}

.cta-btn:hover { background: var(--green-dark); }

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.25rem;
}

.feature {
  background: var(--card-bg);
  border: 1.5px solid var(--green-pale);
  border-radius: var(--radius);
  padding: 1.75rem 1.5rem;
}

.feature-icon {
  font-size: 2rem;
  margin-bottom: 0.75rem;
}

.feature h2 {
  font-size: 1rem;
  font-weight: 700;
  color: var(--green-dark);
  margin-bottom: 0.5rem;
}

.feature p {
  font-size: 0.9rem;
  color: var(--text-muted);
  line-height: 1.55;
}
</style>

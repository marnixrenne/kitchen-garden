<script setup>
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const router = useRouter()
const { t } = useI18n()
</script>

<template>
  <div class="landing">
    <nav class="landing-nav">
      <div class="brand">🌱 Kitchen Garden</div>
      <div class="nav-links">
        <button class="sign-in-btn" @click="router.push('/login')">{{ t('landing.signIn') }}</button>
        <button class="sign-up-btn" @click="router.push('/signup')">{{ t('landing.signUp') }}</button>
      </div>
    </nav>

    <main class="landing-main">
      <div class="hero-card">
        <div class="hero-deco">🌻</div>
        <h1>{{ t('landing.heroTitle') }}</h1>
        <p class="tagline">{{ t('landing.tagline') }}</p>
        <button class="cta-btn" @click="router.push('/signup')">{{ t('landing.cta') }}</button>
      </div>

      <div class="features">
        <div class="feature">
          <div class="feature-icon">📅</div>
          <h2>{{ t('landing.feature1Title') }}</h2>
          <p>{{ t('landing.feature1Desc') }}</p>
        </div>
        <div class="feature">
          <div class="feature-icon">🥦</div>
          <h2>{{ t('landing.feature2Title') }}</h2>
          <p>{{ t('landing.feature2Desc') }}</p>
        </div>
        <div class="feature">
          <div class="feature-icon">🌍</div>
          <h2>{{ t('landing.feature3Title') }}</h2>
          <p>{{ t('landing.feature3Desc') }}</p>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,600;0,9..144,700;1,9..144,400&family=Nunito:wght@400;500;600;700&display=swap');

.landing {
  min-height: 100vh;
  background: #fdf6ec;
  background-image:
    radial-gradient(ellipse at 15% 10%, #fce9cc 0%, transparent 45%),
    radial-gradient(ellipse at 85% 90%, #f5dfc5 0%, transparent 45%);
  display: flex;
  flex-direction: column;
  font-family: 'Nunito', sans-serif;
  color: #3d2b1f;
}

/* ── Nav ── */
.landing-nav {
  padding: 1.25rem 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1.5px dashed #dfc4a4;
}

.brand {
  font-family: 'Fraunces', serif;
  font-size: 1.1rem;
  font-weight: 600;
  color: #3d2b1f;
}

.nav-links { display: flex; gap: 0.6rem; }

.sign-in-btn {
  padding: 0.45rem 1.1rem;
  background: none;
  border: 1.5px dashed #c26b3a;
  border-radius: 999px;
  color: #c26b3a;
  font-family: 'Nunito', sans-serif;
  font-size: 0.875rem;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, color 0.15s, border-style 0.15s;
}

.sign-in-btn:hover {
  background: #c26b3a;
  color: #fff;
  border-style: solid;
}

.sign-up-btn {
  padding: 0.45rem 1.1rem;
  background: #c26b3a;
  border: 1.5px solid #c26b3a;
  border-radius: 999px;
  color: #fff;
  font-family: 'Nunito', sans-serif;
  font-size: 0.875rem;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

.sign-up-btn:hover { background: #a85530; border-color: #a85530; }

/* ── Main ── */
.landing-main {
  flex: 1;
  max-width: 820px;
  margin: 0 auto;
  padding: 2.5rem 1.5rem 5rem;
  width: 100%;
}

/* ── Hero card ── */
.hero-card {
  background: #fff;
  border: 2px solid #dfc4a4;
  border-radius: 24px;
  padding: 3.5rem 3rem 3rem;
  margin-bottom: 1.75rem;
  position: relative;
  overflow: hidden;
  box-shadow: 5px 5px 0 #dfc4a4;
}

.hero-deco {
  font-size: 6rem;
  position: absolute;
  top: 1.25rem;
  right: 2rem;
  line-height: 1;
  opacity: 0.65;
  pointer-events: none;
  filter: drop-shadow(2px 3px 6px rgba(194, 107, 58, 0.2));
}

.hero-card h1 {
  font-family: 'Fraunces', serif;
  font-size: clamp(2rem, 4vw, 2.9rem);
  font-weight: 700;
  line-height: 1.15;
  color: #3d2b1f;
  max-width: 480px;
  margin-bottom: 1rem;
}

.tagline {
  font-size: 1rem;
  color: #7a5a45;
  line-height: 1.7;
  max-width: 440px;
  margin-bottom: 2rem;
}

.cta-btn {
  padding: 0.8rem 2rem;
  background: #c26b3a;
  color: #fff;
  border: none;
  border-radius: 999px;
  font-family: 'Nunito', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 3px 3px 0 #a85530;
  transition: transform 0.1s, box-shadow 0.1s, background 0.15s;
}

.cta-btn:hover {
  background: #a85530;
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0 #8a3e1e;
}

.cta-btn:active {
  transform: translate(3px, 3px);
  box-shadow: none;
}

/* ── Feature cards ── */
.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.25rem;
}

.feature {
  background: #fff;
  border: 2px solid #dfc4a4;
  border-radius: 20px;
  padding: 1.75rem 1.5rem;
  box-shadow: 4px 4px 0 #dfc4a4;
}

.feature-icon {
  font-size: 2rem;
  margin-bottom: 0.75rem;
  line-height: 1;
}

.feature h2 {
  font-family: 'Fraunces', serif;
  font-size: 1rem;
  font-weight: 600;
  color: #3d2b1f;
  margin-bottom: 0.45rem;
}

.feature p {
  font-size: 0.875rem;
  color: #7a5a45;
  line-height: 1.6;
}

@media (max-width: 500px) {
  .landing-nav { padding: 1rem 1.25rem; }
  .hero-card { padding: 2.5rem 1.5rem 2rem; }
  .hero-deco { font-size: 4rem; top: 1rem; right: 1rem; }
}
</style>

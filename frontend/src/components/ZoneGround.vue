<script setup>
// A Zone drawn as a row of its Plants on a line of soil. Plants with a job this week
// are in full colour, the rest are faded. The names are listed elsewhere on the page.
defineProps({
  plants: { type: Array, required: true },  // [{ id, name, emoji, active }]
})
</script>

<template>
  <div class="ground" aria-hidden="true">
    <span
      v-for="plant in plants"
      :key="plant.id"
      class="ground-plant"
      :class="{ 'ground-plant--resting': !plant.active }"
      :title="plant.name"
    >{{ plant.emoji ?? '🌱' }}</span>
  </div>
</template>

<style scoped>
.ground {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 0.2rem 0.4rem;
  min-height: 2.25rem;
  padding-bottom: 0.15rem;
  border-bottom: 3px solid var(--soil);
  font-size: 1.5rem;
  line-height: 1.2;
}

.ground:empty {
  min-height: 0.75rem;
}

.ground-plant--resting {
  filter: grayscale(1);
  opacity: 0.4;
}
</style>

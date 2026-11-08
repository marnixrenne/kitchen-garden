const SOWING_ACTIONS = new Set(['seeding_indoor', 'seeding_outdoor', 'planting'])

// The most recent sowing or planting in a Plant instance's log, or null if it has none yet.
export function latestSowing(entries = []) {
  return entries
    .filter(e => SOWING_ACTIONS.has(e.action))
    .reduce((latest, e) => (!latest || e.date > latest.date ? e : latest), null)
}

export function plantCounts(instances) {
  const counts = {}
  for (const { plantId } of instances) counts[plantId] = (counts[plantId] ?? 0) + 1
  return counts
}

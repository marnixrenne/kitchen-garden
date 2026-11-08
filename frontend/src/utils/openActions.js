export const ACTION_ORDER = ['seeding', 'germination', 'harvest', 'pruning', 'fertilizing', 'watering']

export const ACTION_ICON = { seeding: '🌱', germination: '🌿', harvest: '🧺', pruning: '✂️', fertilizing: '🌻', watering: '💧' }

export const ACTION_LABEL_KEY = Object.fromEntries(ACTION_ORDER.map(a => [a, `garden.job.${a}`]))

const LOGGABLE = new Set(['fertilizing', 'pruning', 'watering'])

function isDone(plantLog, instanceId, entry) {
  return (plantLog[instanceId] ?? []).some(l =>
    l.action === entry.action &&
    l.date >= entry.plannedDateStart &&
    l.date <= entry.plannedDateEnd
  )
}

function planDateRange(entry, formatDate) {
  return entry.plannedDateStart === entry.plannedDateEnd
    ? formatDate(entry.plannedDateStart)
    : `${formatDate(entry.plannedDateStart)} – ${formatDate(entry.plannedDateEnd)}`
}

// Everything a Garden has to do in the current week, keyed by action in ACTION_ORDER.
// Each item carries the zoneId of its Plant instance.
export function buildActionBuckets({ weekSummary, instances, plantLog, plantPlan, lifecycle, plants }, formatDate) {
  const year = new Date().getFullYear()
  const weekStart = new Date(year, weekSummary.weekStartMonth - 1, weekSummary.weekStartDay)
  let   weekEnd   = new Date(year, weekSummary.weekEndMonth   - 1, weekSummary.weekEndDay)
  if (weekEnd < weekStart) weekEnd = new Date(year + 1, weekSummary.weekEndMonth - 1, weekSummary.weekEndDay)

  const instanceById = Object.fromEntries(instances.map(i => [i.id, i]))
  const plantById    = Object.fromEntries(plants.map(p => [p.id, p]))
  const instanceIdsByPlant = {}
  for (const inst of instances) (instanceIdsByPlant[inst.plantId] ??= []).push(inst.id)

  const buckets = Object.fromEntries(ACTION_ORDER.map(a => [a, []]))

  for (const wa of (weekSummary.actions ?? [])) {
    if (wa.type === 'sow' || wa.type === 'both') {
      const iid = (instanceIdsByPlant[wa.plant.id] ?? []).find(id => !lifecycle[id]) ?? null
      if (!iid) continue  // all instances already seeded
      buckets.seeding.push({
        plant: wa.plant, instanceId: iid, zoneId: instanceById[iid]?.zoneId ?? null,
        seedDate: null,
        dateRange: null, done: false,
        planEntry: null, lc: null, sowAction: wa,
      })
    }
  }

  const shownGermination = new Set()
  const shownHarvest     = new Set()

  for (const [instanceId, entries] of Object.entries(plantPlan)) {
    const inst  = instanceById[instanceId]
    if (!inst) continue
    const plant = plantById[inst.plantId]
    if (!plant) continue
    const lc = lifecycle[instanceId]
    const common = { plant, instanceId, zoneId: inst.zoneId }

    for (const entry of entries) {
      const start = new Date(entry.plannedDateStart + 'T00:00:00')
      const end   = new Date(entry.plannedDateEnd   + 'T00:00:00')
      if (start > weekEnd || end < weekStart) continue

      const seedDate   = formatDate(entry.seedDate)
      const seedAction = entry.seedAction

      if (entry.action === 'germination') {
        if (!shownGermination.has(instanceId) && (!lc || lc.nextState === 'germinating_indoor' || lc.nextState === 'germinating_outdoor')) {
          shownGermination.add(instanceId)
          buckets.germination.push({
            ...common, seedDate, seedAction,
            dateRange: planDateRange(entry, formatDate),
            done: false,
            planEntry: entry, lc: lc ?? null, sowAction: null,
          })
        }
      } else if (entry.action === 'harvest') {
        if (!shownHarvest.has(instanceId) && lc?.nextState === 'ready_to_harvest') {
          shownHarvest.add(instanceId)
          buckets.harvest.push({
            ...common, seedDate, seedAction,
            dateRange: planDateRange(entry, formatDate),
            done: false,
            planEntry: entry, lc, sowAction: null,
          })
        }
      } else if (LOGGABLE.has(entry.action)) {
        buckets[entry.action]?.push({
          ...common, seedDate, seedAction,
          dateRange: planDateRange(entry, formatDate),
          done: isDone(plantLog, instanceId, entry),
          planEntry: entry, lc: null, sowAction: null,
        })
      }
    }
  }

  return buckets
}

// Every item of the buckets as one list, in ACTION_ORDER, each tagged with its action.
export function allActions(buckets) {
  return ACTION_ORDER.flatMap(action => buckets[action].map(item => ({ ...item, action })))
}

export function openActions(buckets) {
  return allActions(buckets).filter(item => !item.done)
}

export function weekRangeLabel(week, t, tm) {
  const months = tm('months')
  const startMonth = months[week.weekStartMonth - 1]
  const endMonth   = months[week.weekEndMonth - 1]
  const range = week.weekStartMonth === week.weekEndMonth
    ? `${week.weekStartDay}–${week.weekEndDay} ${endMonth}`
    : `${week.weekStartDay} ${startMonth} – ${week.weekEndDay} ${endMonth}`
  return `${t('garden.week')} ${week.week}, ${range}`
}

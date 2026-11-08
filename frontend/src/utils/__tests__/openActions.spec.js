import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { buildActionBuckets, openActions } from '../openActions.js'

const formatDate = d => d

const TOMATO = { id: 'p-tomato', name: 'Tomato' }
const BASIL  = { id: 'p-basil',  name: 'Basil' }

const WEEK = { weekStartDay: 8, weekStartMonth: 6, weekEndDay: 14, weekEndMonth: 6, actions: [] }

function water(start, end = start) {
  return { id: `plan-${start}`, action: 'watering', plannedDateStart: start, plannedDateEnd: end, seedDate: '2026-05-01', seedAction: 'seeding_indoor' }
}

function data(overrides) {
  return {
    weekSummary: WEEK,
    instances: [
      { id: 'i-tomato', plantId: TOMATO.id, zoneId: 'zone-a' },
      { id: 'i-basil',  plantId: BASIL.id,  zoneId: 'zone-b' },
    ],
    plantLog: {},
    plantPlan: {},
    lifecycle: {},
    plants: [TOMATO, BASIL],
    ...overrides,
  }
}

describe('open actions', () => {
  beforeEach(() => { vi.useFakeTimers(); vi.setSystemTime(new Date(2026, 5, 10)) })
  afterEach(() => vi.useRealTimers())

  it('tags a planned action with the zone of its plant instance', () => {
    const open = openActions(buildActionBuckets(data({ plantPlan: { 'i-basil': [water('2026-06-10')] } }), formatDate))

    expect(open).toHaveLength(1)
    expect(open[0]).toMatchObject({ action: 'watering', zoneId: 'zone-b', plant: BASIL })
  })

  it('tags a sowing action with the zone of the unseeded instance', () => {
    const weekSummary = { ...WEEK, actions: [{ type: 'sow', plant: TOMATO }] }

    const open = openActions(buildActionBuckets(data({ weekSummary }), formatDate))

    expect(open).toHaveLength(1)
    expect(open[0]).toMatchObject({ action: 'seeding', zoneId: 'zone-a' })
  })

  it('gives every unsown planting its own sowing action', () => {
    const weekSummary = { ...WEEK, actions: [{ type: 'sow', plant: TOMATO }] }
    const instances = [
      { id: 'i-a', plantId: TOMATO.id, zoneId: 'zone-a' },
      { id: 'i-b', plantId: TOMATO.id, zoneId: 'zone-b' },
      { id: 'i-sown', plantId: TOMATO.id, zoneId: 'zone-c' },
    ]

    const open = openActions(buildActionBuckets(data({ weekSummary, instances, lifecycle: { 'i-sown': {} } }), formatDate))

    expect(open.map(a => a.instanceId)).toEqual(['i-a', 'i-b'])
  })

  it('leaves out an action already logged within its planned dates', () => {
    const open = openActions(buildActionBuckets(data({
      plantPlan: { 'i-tomato': [water('2026-06-09', '2026-06-12')] },
      plantLog:  { 'i-tomato': [{ action: 'watering', date: '2026-06-10' }] },
    }), formatDate))

    expect(open).toHaveLength(0)
  })

  describe('overdue', () => {
    const overdueOf = (plantPlan, plantLog = {}) =>
      buildActionBuckets(data({ plantPlan, plantLog }), formatDate).watering[0].overdue

    it('marks an open action whose planned dates have passed', () => {
      expect(overdueOf({ 'i-tomato': [water('2026-06-08', '2026-06-09')] })).toBe(true)
    })

    it('does not mark an action planned to end today', () => {
      expect(overdueOf({ 'i-tomato': [water('2026-06-08', '2026-06-10')] })).toBe(false)
    })

    it('does not mark an action that was logged in time', () => {
      expect(overdueOf(
        { 'i-tomato': [water('2026-06-08', '2026-06-09')] },
        { 'i-tomato': [{ action: 'watering', date: '2026-06-09' }] },
      )).toBe(false)
    })

    it('compares with the local date, not UTC', () => {
      vi.setSystemTime(new Date(2026, 5, 10, 0, 30))

      expect(overdueOf({ 'i-tomato': [water('2026-06-08', '2026-06-10')] })).toBe(false)
    })
  })

  it('leaves out an action planned outside the current week', () => {
    const open = openActions(buildActionBuckets(data({ plantPlan: { 'i-tomato': [water('2026-06-20')] } }), formatDate))

    expect(open).toHaveLength(0)
  })
})

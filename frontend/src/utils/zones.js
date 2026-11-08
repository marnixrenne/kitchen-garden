// Sun scale shared by a plant's sun requirement and a zone's sun exposure, from least to most sun.
export const SUN_LEVELS = ['shade', 'partial_shade', 'full_sun']

export const ZONE_TYPES = ['in_ground', 'raised', 'container', 'greenhouse']

export const ASPECTS = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']

export const MAX_DIMENSION_CM = 10000

// True only when both are known and the zone gets less sun than the plant needs.
export function isSunShortfall(zoneExposure, plantRequirement) {
  if (!zoneExposure || !plantRequirement) return false
  return SUN_LEVELS.indexOf(zoneExposure) < SUN_LEVELS.indexOf(plantRequirement)
}

// The zone a garden starts with has no name until the user gives it one.
export function zoneLabel(t, name) {
  return name ?? t('zones.mainZone')
}

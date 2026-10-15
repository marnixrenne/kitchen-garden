// Sun scale shared by a plant's sun requirement and a bed's sun exposure, from least to most sun.
export const SUN_LEVELS = ['shade', 'partial_shade', 'full_sun']

export const BED_TYPES = ['in_ground', 'raised', 'container', 'greenhouse']

export const ASPECTS = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']

export const MAX_DIMENSION_CM = 10000

// True only when both are known and the bed gets less sun than the plant needs.
export function isSunShortfall(bedExposure, plantRequirement) {
  if (!bedExposure || !plantRequirement) return false
  return SUN_LEVELS.indexOf(bedExposure) < SUN_LEVELS.indexOf(plantRequirement)
}

// The bed a garden starts with has no name until the user gives it one.
export function bedLabel(t, name) {
  return name ?? t('beds.mainBed')
}

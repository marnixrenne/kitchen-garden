package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantId

data class SimpleVeg(val id: PlantId, val name: String, val emoji: String?)
data class VegPair(val a: SimpleVeg, val b: SimpleVeg)
data class SunGroup(val sunRequirement: String, val plants: List<SimpleVeg>, val goodPairs: List<VegPair>)
data class PlantingSuggestions(val sunGroups: List<SunGroup>, val conflicts: List<VegPair>)

package org.marnixrenne.kitchengarden.garden

import java.util.UUID

data class SimpleVeg(val id: UUID, val name: String, val emoji: String?)
data class VegPair(val a: SimpleVeg, val b: SimpleVeg)
data class SunGroup(val sunRequirement: String, val plants: List<SimpleVeg>, val goodPairs: List<VegPair>)
data class PlantingSuggestions(val sunGroups: List<SunGroup>, val conflicts: List<VegPair>)

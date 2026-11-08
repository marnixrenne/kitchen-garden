package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.InsectAttraction
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.plants.domain.SunExposure

data class RecommendationCandidate(
    val plant: SimpleVeg,
    val category: String,
    val sunRequirement: SunExposure?,
    val availableInCountry: Boolean,
    val insects: List<InsectAttraction>,
)

/** A companion relationship between two Plants, in no particular direction. */
data class CompanionLink(val a: PlantId, val b: PlantId, val good: Boolean)

/** An insect a Plant attracts that preys on a pest of a Plant already in the Zone. */
data class PestControl(val predator: String, val pest: String, val plant: SimpleVeg)

/** A Plant as seen from one Zone: whether it is a Recommendation there, and what speaks for or against it. */
data class PlantOption(
    val id: PlantId,
    val name: String,
    val emoji: String?,
    val recommended: Boolean,
    /** The Zone's Sun exposure, when it is exactly what this Plant needs. */
    val sunMatch: SunExposure?,
    val sunShortfall: Boolean,
    val goodWith: List<SimpleVeg>,
    val badWith: List<SimpleVeg>,
    val pestControl: PestControl?,
    val pollinatorsFor: List<SimpleVeg>,
    val inThisZone: Int,
    /** Names of the other Zones this Plant grows in; null for an unnamed Zone. */
    val alsoIn: List<String?>,
) {
    val insectBenefits: Int get() = (if (pestControl != null) 1 else 0) + (if (pollinatorsFor.isNotEmpty()) 1 else 0)
    val hasReason: Boolean get() = goodWith.isNotEmpty() || insectBenefits > 0 || sunMatch != null
}

object PlantRecommender {
    const val MAX_RECOMMENDATIONS = 8

    private val CATEGORY_ORDER = listOf("Fruiting", "Leafy", "Brassica", "Root", "Legume", "Herb", "Flower")

    /** Categories that don't belong in a garden bed: seaweeds, and fruit that is mostly trees and shrubs. */
    private val NEVER_RECOMMENDED = setOf("Sea", "Fruit")

    /** Categories that set fruit or pods, and so benefit from pollinators. */
    private val NEEDS_POLLINATION = setOf("Fruiting", "Legume")

    /** Which pests each predator tackles, most useful match first. */
    private val PREY = linkedMapOf(
        "ladybird" to listOf("aphid", "blackfly", "whitefly"),
        "lacewing" to listOf("aphid", "blackfly", "whitefly"),
        "parasitic_wasp" to listOf("aphid", "cabbage_white"),
    )

    /** Every candidate as a [PlantOption]: Recommendations first in rank order, then the rest by name. */
    fun options(
        zone: Zone,
        zones: List<Zone>,
        instances: List<PlantInstance>,
        candidates: List<RecommendationCandidate>,
        companions: List<CompanionLink>,
    ): List<PlantOption> {
        val exposure = zone.sunExposure
        val plantedHere = instances.filter { it.zoneId == zone.id }.map { it.plantId }.toSet()
        val candidateById = candidates.associateBy { it.plant.id }
        val zoneNames = zones.associate { it.id to it.name }
        val neighbours = plantedHere.mapNotNull { candidateById[it] }.sortedBy { it.plant.name }

        fun linked(plantId: PlantId, good: Boolean): List<SimpleVeg> = companions
            .filter { it.good == good }
            .mapNotNull { if (it.a == plantId) it.b else if (it.b == plantId) it.a else null }
            .filter { it in plantedHere }
            .distinct()
            .mapNotNull { candidateById[it]?.plant }
            .sortedBy { it.name }

        val scored = candidates.map { candidate ->
            val id = candidate.plant.id
            candidate to PlantOption(
                id = id,
                name = candidate.plant.name,
                emoji = candidate.plant.emoji,
                recommended = false,
                sunMatch = exposure?.takeIf { it == candidate.sunRequirement },
                sunShortfall = SunExposure.isShortfall(exposure, candidate.sunRequirement),
                goodWith = linked(id, good = true),
                badWith = linked(id, good = false),
                pestControl = pestControl(candidate, neighbours),
                pollinatorsFor = pollinatorsFor(candidate, neighbours),
                inThisZone = instances.count { it.plantId == id && it.zoneId == zone.id },
                alsoIn = instances
                    .filter { it.plantId == id && it.zoneId != zone.id }
                    .map { it.zoneId }
                    .distinct()
                    .map { zoneNames[it] },
            )
        }

        val ranked = scored
            .filter { (candidate, option) ->
                candidate.category !in NEVER_RECOMMENDED && candidate.availableInCountry &&
                    option.inThisZone == 0 && !option.sunShortfall && option.badWith.isEmpty() && option.hasReason
            }
            .groupBy { (_, option) -> Triple(-option.goodWith.size, -option.insectBenefits, option.sunMatch == null) }
            .entries
            .sortedWith(compareBy({ it.key.first }, { it.key.second }, { it.key.third }))
            .flatMap { spreadAcrossCategories(it.value) }
            .take(MAX_RECOMMENDATIONS)
            .map { it.copy(recommended = true) }

        val recommendedIds = ranked.map { it.id }.toSet()
        return ranked + scored.map { it.second }.filter { it.id !in recommendedIds }.sortedBy { it.name }
    }

    private fun pestControl(candidate: RecommendationCandidate, neighbours: List<RecommendationCandidate>): PestControl? {
        val attracted = candidate.insects.filter { it.type == "beneficial" }.map { it.name }.toSet()
        for ((predator, prey) in PREY) {
            if (predator !in attracted) continue
            for (pest in prey) {
                val victim = neighbours.firstOrNull { n -> n.insects.any { it.type == "pest" && it.name == pest } }
                if (victim != null) return PestControl(predator, pest, victim.plant)
            }
        }
        return null
    }

    private fun pollinatorsFor(candidate: RecommendationCandidate, neighbours: List<RecommendationCandidate>): List<SimpleVeg> {
        if (candidate.insects.none { it.type == "pollinator" }) return emptyList()
        return neighbours.filter { it.category in NEEDS_POLLINATION }.map { it.plant }
    }

    /** Takes one Plant per category in turn, alphabetically within each, so ties don't fill the list with one kind. */
    private fun spreadAcrossCategories(tied: List<Pair<RecommendationCandidate, PlantOption>>): List<PlantOption> {
        val queues = tied
            .groupBy { (candidate, _) -> candidate.category }
            .entries
            .sortedBy { (category, _) -> CATEGORY_ORDER.indexOf(category).takeIf { it >= 0 } ?: CATEGORY_ORDER.size }
            .map { (_, members) -> ArrayDeque(members.map { it.second }.sortedBy { it.name }) }

        val spread = mutableListOf<PlantOption>()
        while (spread.size < tied.size) {
            queues.forEach { queue -> queue.removeFirstOrNull()?.let { spread += it } }
        }
        return spread
    }
}

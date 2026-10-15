package org.marnixrenne.kitchengarden.plants.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue

enum class PlantLifespan(@JsonValue val key: String) {
    ANNUAL("annual"),
    BIENNIAL("biennial"),
    PERENNIAL("perennial");

    companion object {
        fun from(key: String): PlantLifespan = entries.first { it.key == key }
    }
}

enum class CompanionRelationship(@JsonValue val key: String) {
    GOOD("good"),
    BAD("bad");

    companion object {
        fun from(key: String): CompanionRelationship = entries.first { it.key == key }
    }
}

enum class SowingMethod(@JsonValue val key: String) {
    INDOOR("indoor"),
    OUTDOOR("outdoor"),
    BOTH("both");

    companion object {
        fun from(key: String): SowingMethod = entries.first { it.key == key }
    }
}

/** How much direct sun a plant needs (Sun requirement) or a bed receives (Sun exposure). Declared from least to most sun. */
enum class SunExposure(@JsonValue val key: String) {
    SHADE("shade"),
    PARTIAL_SHADE("partial_shade"),
    FULL_SUN("full_sun");

    fun isSufficientFor(requirement: SunExposure): Boolean = this >= requirement

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): SunExposure = entries.first { it.key == key }

        /** True only when both are known and the bed gets less sun than the plant needs. */
        fun isShortfall(exposure: SunExposure?, requirement: SunExposure?): Boolean =
            exposure != null && requirement != null && !exposure.isSufficientFor(requirement)
    }
}

data class Country(val code: String, val name: String)

data class CompanionPlant(val id: PlantId, val name: String, val emoji: String?, val relationship: CompanionRelationship)

data class InsectAttraction(val name: String, val type: String)

data class SowingGuide(
    val method: SowingMethod?,
    val seedDepthMm: Int?,
    val spacingCm: Int?,
    val germinationDaysMin: Int?,
    val germinationDaysMax: Int?,
    val daysToMaturityMin: Int?,
    val daysToMaturityMax: Int?,
    val frostTolerance: String?,
)

data class PlantDetail(
    val id: PlantId,
    val name: String,
    val latinName: String?,
    val category: String,
    val emoji: String?,
    val imageUrl: String?,
    val lifespan: PlantLifespan?,
    val sunRequirement: SunExposure?,
    val pruningType: String?,
    val fertilizerType: String?,
    val sowingGuide: SowingGuide?,
    val heightMinCm: Int?,
    val heightMaxCm: Int?,
    val seedingMonths: List<Int>,
    val harvestingMonths: List<Int>,
    val countries: List<Country>,
    val companions: List<CompanionPlant>,
    val insects: List<InsectAttraction>,
)

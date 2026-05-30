package org.marnixrenne.kitchengarden.plants.domain

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
    val sunRequirement: String?,
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

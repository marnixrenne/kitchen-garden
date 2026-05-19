package org.marnixrenne.kitchengarden.plants

import java.util.UUID

data class Country(val code: String, val name: String)

data class CompanionPlant(val id: UUID, val name: String, val emoji: String?, val relationship: String)

data class InsectAttraction(val name: String, val type: String)

data class SowingGuide(
    val method: String?,
    val seedDepthMm: Int?,
    val spacingCm: Int?,
    val germinationDaysMin: Int?,
    val germinationDaysMax: Int?,
    val daysToMaturityMin: Int?,
    val daysToMaturityMax: Int?,
    val frostTolerance: String?,
)

data class PlantDetail(
    val id: UUID,
    val name: String,
    val latinName: String?,
    val category: String,
    val emoji: String?,
    val imageUrl: String?,
    val sunRequirement: String?,
    val pruningType: String?,
    val pruningTip: String?,
    val fertilizerType: String?,
    val fertilizerTip: String?,
    val sowingGuide: SowingGuide?,
    val heightMinCm: Int?,
    val heightMaxCm: Int?,
    val seedingMonths: List<Int>,
    val harvestingMonths: List<Int>,
    val countries: List<Country>,
    val companions: List<CompanionPlant>,
    val insects: List<InsectAttraction>,
)

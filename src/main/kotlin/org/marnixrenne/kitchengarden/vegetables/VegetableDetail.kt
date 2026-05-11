package org.marnixrenne.kitchengarden.vegetables

import java.util.UUID

data class Country(val code: String, val name: String)

data class CompanionPlant(val id: UUID, val name: String, val emoji: String?, val relationship: String)

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

data class VegetableDetail(
    val id: UUID,
    val name: String,
    val category: String,
    val emoji: String?,
    val imageUrl: String?,
    val sunRequirement: String?,
    val sowingGuide: SowingGuide?,
    val seedingMonths: List<Int>,
    val harvestingMonths: List<Int>,
    val countries: List<Country>,
    val companions: List<CompanionPlant>,
)

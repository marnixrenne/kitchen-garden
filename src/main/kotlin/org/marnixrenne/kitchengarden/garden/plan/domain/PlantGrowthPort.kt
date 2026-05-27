package org.marnixrenne.kitchengarden.garden.plan.domain

import java.util.UUID

data class PlantGrowthData(
    val germinationDaysMin: Int?,
    val germinationDaysMax: Int?,
    val daysToMaturityMin: Int?,
    val daysToMaturityMax: Int?,
    val harvestMonths: List<Int>,
    val pruningConfig: PruningConfig?,
    val fertilizingConfig: FertilizingConfig?,
    val wateringConfig: WateringConfig?,
)

interface PlantGrowthPort {
    fun loadGrowthData(plantId: UUID): PlantGrowthData?
}

package org.marnixrenne.kitchengarden.garden.plan.domain

import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import java.time.LocalDate

data class PlanPeriod(val action: String, val start: LocalDate, val end: LocalDate)

data class PruningConfig(val weeksBeforeStart: Int, val weeksBeforeEnd: Int)
data class FertilizingConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int, val maxApplications: Int)
data class WateringConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int)

data class PlanEntry(
    val id: PlanEntryId,
    val instanceId: PlantInstanceId,
    val plantId: PlantId,
    val action: String,
    val plannedDateStart: LocalDate,
    val plannedDateEnd: LocalDate,
    val seedDate: LocalDate,
    val seedAction: String,
)

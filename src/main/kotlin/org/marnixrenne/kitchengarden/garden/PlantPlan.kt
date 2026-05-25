package org.marnixrenne.kitchengarden.garden

import java.time.LocalDate
import java.util.UUID

data class PlanPeriod(val action: String, val start: LocalDate, val end: LocalDate)

data class PruningConfig(val weeksBeforeStart: Int, val weeksBeforeEnd: Int)
data class FertilizingConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int, val maxApplications: Int)
data class WateringConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int)

data class PlanEntry(
    val id: UUID,
    val instanceId: UUID,
    val plantId: UUID,
    val action: String,
    val plannedDateStart: LocalDate,
    val plannedDateEnd: LocalDate,
    val seedDate: LocalDate,
)

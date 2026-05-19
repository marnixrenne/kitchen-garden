package org.marnixrenne.kitchengarden.garden

import java.time.LocalDate
import java.util.UUID

data class PlanPeriod(val action: String, val start: LocalDate, val end: LocalDate)

data class PlanEntry(
    val id: UUID,
    val plantId: UUID,
    val action: String,
    val plannedDateStart: LocalDate,
    val plannedDateEnd: LocalDate,
)

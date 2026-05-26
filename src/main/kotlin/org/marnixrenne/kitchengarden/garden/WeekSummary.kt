package org.marnixrenne.kitchengarden.garden

import java.time.LocalDate
import java.util.UUID

data class LoggedEntry(
    val id: UUID,
    val action: String,
    val date: LocalDate,
    val comment: String?,
)

data class WeekAction(
    val type: String,              // "sow", "harvest", "both"
    val plant: SimpleVeg,
    val sowingMethod: String?,     // "indoor", "outdoor", "both"
    val germinationDaysMin: Int?,
    val germinationDaysMax: Int?,
    val logEntries: List<LoggedEntry>,
)

data class WeekSummary(
    val week: Int,
    val month: Int,
    val weekStartDay: Int,
    val weekStartMonth: Int,
    val weekEndDay: Int,
    val weekEndMonth: Int,
    val actions: List<WeekAction>,
)

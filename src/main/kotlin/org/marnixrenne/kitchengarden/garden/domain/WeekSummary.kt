package org.marnixrenne.kitchengarden.garden.domain

import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.plants.domain.SowingMethod
import java.time.LocalDate

enum class WeekActionType(@JsonValue val key: String) {
    SOW("sow"),
    HARVEST("harvest"),
    BOTH("both");
}

data class LoggedEntry(
    val id: PlantLogEntryId,
    val action: LogAction,
    val date: LocalDate,
    val comment: String?,
)

data class WeekAction(
    val type: WeekActionType,
    val plant: SimpleVeg,
    val sowingMethod: SowingMethod?,
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

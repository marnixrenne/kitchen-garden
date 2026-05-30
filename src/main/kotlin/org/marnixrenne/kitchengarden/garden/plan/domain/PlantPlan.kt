package org.marnixrenne.kitchengarden.garden.plan.domain

import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.garden.domain.LogAction
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import java.time.LocalDate

enum class PlanAction(@JsonValue val key: String) {
    GERMINATION("germination"),
    HARVEST("harvest"),
    PRUNING("pruning"),
    FERTILIZING("fertilizing"),
    WATERING("watering");

    companion object {
        fun from(key: String): PlanAction = entries.first { it.key == key }
    }
}

data class PlanPeriod(val action: PlanAction, val start: LocalDate, val end: LocalDate)

data class PruningConfig(val weeksBeforeStart: Int, val weeksBeforeEnd: Int)
data class FertilizingConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int, val maxApplications: Int)
data class WateringConfig(val startDaysAfterSeed: Int, val intervalDays: Int, val windowDays: Int)

data class PlanEntry(
    val id: PlanEntryId,
    val instanceId: PlantInstanceId,
    val plantId: PlantId,
    val action: PlanAction,
    val plannedDateStart: LocalDate,
    val plannedDateEnd: LocalDate,
    val seedDate: LocalDate,
    val seedAction: LogAction,
)

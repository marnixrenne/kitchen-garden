package org.marnixrenne.kitchengarden.garden.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import java.time.LocalDate

enum class LogAction(@JsonValue val key: String) {
    SEEDING_INDOOR("seeding_indoor"),
    SEEDING_OUTDOOR("seeding_outdoor"),
    PLANTING("planting"),
    FERTILIZING("fertilizing"),
    PRUNING("pruning"),
    WATERING("watering");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): LogAction = entries.first { it.key == key }
    }
}

data class PlantLogRequest(
    val instanceId: PlantInstanceId,
    val action: LogAction,
    val date: LocalDate,
    val comment: String?,
)

data class PlantLogResponse(
    val id: PlantLogEntryId,
    val logId: PlantLogId,
    val instanceId: PlantInstanceId,
    val plantId: PlantId,
    val action: LogAction,
    val date: LocalDate,
    val comment: String?,
)

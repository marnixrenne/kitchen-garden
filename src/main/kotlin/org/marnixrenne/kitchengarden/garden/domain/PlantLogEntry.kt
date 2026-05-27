package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantId
import java.time.LocalDate

data class PlantLogRequest(
    val instanceId: PlantInstanceId,
    val action: String,
    val date: LocalDate,
    val comment: String?,
)

data class PlantLogResponse(
    val id: PlantLogEntryId,
    val logId: PlantLogId,
    val instanceId: PlantInstanceId,
    val plantId: PlantId,
    val action: String,
    val date: LocalDate,
    val comment: String?,
)

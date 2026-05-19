package org.marnixrenne.kitchengarden.garden

import java.time.LocalDate
import java.util.UUID

data class PlantLogRequest(
    val plantId: UUID,
    val action: String,
    val date: LocalDate,
    val comment: String?,
)

data class PlantLogResponse(
    val id: UUID,
    val logId: UUID,
    val plantId: UUID,
    val action: String,
    val date: LocalDate,
    val comment: String?,
)

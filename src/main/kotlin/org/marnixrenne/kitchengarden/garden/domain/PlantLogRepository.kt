package org.marnixrenne.kitchengarden.garden.domain

import java.util.UUID

interface PlantLogRepository {
    fun save(userId: UUID, request: PlantLogRequest): PlantLogResponse
    fun deleteEntry(entryId: UUID)
    fun findAllByUser(userId: UUID, gardenId: UUID): Map<UUID, List<LoggedEntry>>
}

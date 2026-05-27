package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.user.domain.UserId

interface PlantLogRepository {
    fun save(userId: UserId, request: PlantLogRequest): PlantLogResponse
    fun deleteEntry(entryId: PlantLogEntryId)
    fun findAllByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<LoggedEntry>>
}

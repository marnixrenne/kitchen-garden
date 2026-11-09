package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.user.domain.UserId

interface PlantLogRepository {
    /** Null when the Plant instance isn't in this Garden. */
    fun save(userId: UserId, gardenId: GardenId, request: PlantLogRequest): PlantLogResponse?
    fun deleteEntry(entryId: PlantLogEntryId)
    fun findEntry(gardenId: GardenId, entryId: PlantLogEntryId): LoggedEntry?
    fun updateEntry(entryId: PlantLogEntryId, request: LogEntryUpdateRequest)
    fun findAllByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<LoggedEntry>>
}

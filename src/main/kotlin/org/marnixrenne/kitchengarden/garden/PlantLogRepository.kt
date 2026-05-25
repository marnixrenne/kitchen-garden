package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class PlantLogRepository {

    fun save(userId: UUID, request: PlantLogRequest): PlantLogResponse = transaction {
        val instanceRow = (GardenPlantInstances innerJoin Garden)
            .select(GardenPlantInstances.plantId)
            .where { (GardenPlantInstances.id eq request.instanceId) and (Garden.userId eq userId) }
            .firstOrNull() ?: error("Instance ${request.instanceId} not found for user")
        val plantId = instanceRow[GardenPlantInstances.plantId]

        val logId = PlantLog.selectAll()
            .where { PlantLog.instanceId eq request.instanceId }
            .map { it[PlantLog.id] }
            .firstOrNull()
            ?: run {
                val newLogId = UUID.randomUUID()
                val initialState = when (request.action) {
                    "seeding_indoor" -> "seeded_indoor"
                    "seeding_direct" -> "seeded_direct"
                    "planting"       -> "planted"
                    else             -> "seeded_direct"
                }
                PlantLog.insert {
                    it[id]                 = newLogId
                    it[PlantLog.userId]    = userId
                    it[PlantLog.plantId]   = plantId
                    it[PlantLog.instanceId] = request.instanceId
                    it[lifecycleState]     = initialState
                    it[createdAt]          = Instant.now()
                }
                newLogId
            }

        val entryId = UUID.randomUUID()
        PlantLogEntry.insert {
            it[id]               = entryId
            it[PlantLogEntry.logId] = logId
            it[action]           = request.action
            it[date]             = request.date
            it[comment]          = request.comment
            it[createdAt]        = Instant.now()
        }

        PlantLogResponse(
            id         = entryId,
            logId      = logId,
            instanceId = request.instanceId,
            plantId    = plantId,
            action     = request.action,
            date       = request.date,
            comment    = request.comment,
        )
    }

    fun findAllByUser(userId: UUID): Map<UUID, List<LoggedEntry>> = transaction {
        (PlantLog innerJoin PlantLogEntry)
            .selectAll()
            .where { (PlantLog.userId eq userId) and PlantLog.instanceId.isNotNull() }
            .orderBy(PlantLogEntry.date, SortOrder.DESC)
            .groupBy({ it[PlantLog.instanceId]!! }, { row ->
                LoggedEntry(
                    id      = row[PlantLogEntry.id],
                    action  = row[PlantLogEntry.action],
                    date    = row[PlantLogEntry.date],
                    comment = row[PlantLogEntry.comment],
                )
            })
    }
}

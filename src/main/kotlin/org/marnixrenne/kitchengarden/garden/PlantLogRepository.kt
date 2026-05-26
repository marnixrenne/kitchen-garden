package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.exceptions.ExposedSQLException
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class PlantLogRepository {

    fun save(userId: UUID, request: PlantLogRequest): PlantLogResponse {
        return try {
            doSave(userId, request)
        } catch (e: ExposedSQLException) {
            val msg = e.message.orEmpty().lowercase()
            if ("unique" !in msg && "duplicate" !in msg) throw e
            // UNIQUE(user_id, plant_id) fired from a concurrent insert for the same instance.
            // Retry in a fresh transaction: the PlantLog row now exists.
            doSave(userId, request)
        }
    }

    private fun doSave(userId: UUID, request: PlantLogRequest): PlantLogResponse = transaction {
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

    fun deleteEntry(entryId: UUID): Unit = transaction {
        PlantLogEntry.deleteWhere { PlantLogEntry.id eq entryId }
    }

    fun findAllByUser(userId: UUID, gardenId: UUID? = null): Map<UUID, List<LoggedEntry>> = transaction {
        val query = (PlantLog innerJoin PlantLogEntry)
            .selectAll()
            .where { (PlantLog.userId eq userId) and PlantLog.instanceId.isNotNull() }

        if (gardenId != null) {
            val instanceIds = GardenPlantInstances.selectAll()
                .where { GardenPlantInstances.gardenId eq gardenId }
                .map { it[GardenPlantInstances.id] }
            if (instanceIds.isEmpty()) return@transaction emptyMap()
            query.andWhere { PlantLog.instanceId inList instanceIds }
        }

        query.orderBy(PlantLogEntry.date, SortOrder.DESC)
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

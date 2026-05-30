package org.marnixrenne.kitchengarden.garden.infrastructure

import org.jetbrains.exposed.exceptions.ExposedSQLException
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.LifecycleState
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class ExposedPlantLogRepository : PlantLogRepository {

    override fun save(userId: UserId, request: PlantLogRequest): PlantLogResponse {
        return try {
            doSave(userId, request)
        } catch (e: ExposedSQLException) {
            val msg = e.message.orEmpty().lowercase()
            if ("unique" !in msg && "duplicate" !in msg) throw e
            doSave(userId, request)
        }
    }

    private fun doSave(userId: UserId, request: PlantLogRequest): PlantLogResponse = transaction {
        val instanceRow = (GardenPlantInstances innerJoin Garden)
            .select(GardenPlantInstances.plantId)
            .where { (GardenPlantInstances.id eq request.instanceId.value) and (Garden.userId eq userId.value) }
            .firstOrNull() ?: error("Instance ${request.instanceId} not found for user")
        val plantId = instanceRow[GardenPlantInstances.plantId]

        val logId = PlantLog.selectAll()
            .where { PlantLog.instanceId eq request.instanceId.value }
            .map { it[PlantLog.id] }
            .firstOrNull()
            ?: run {
                val newLogId = UUID.randomUUID()
                val initialState = when (request.action) {
                    LogAction.SEEDING_INDOOR -> LifecycleState.SEEDED_INDOOR
                    LogAction.SEEDING_OUTDOOR -> LifecycleState.SEEDED_OUTDOOR
                    LogAction.PLANTING       -> LifecycleState.PLANTED
                    else                     -> LifecycleState.GROWING
                }
                PlantLog.insert {
                    it[id]                  = newLogId
                    it[PlantLog.userId]     = userId.value
                    it[PlantLog.plantId]    = plantId
                    it[PlantLog.instanceId] = request.instanceId.value
                    it[lifecycleState]      = initialState.key
                    it[createdAt]           = Instant.now()
                }
                newLogId
            }

        val entryId = UUID.randomUUID()
        PlantLogEntry.insert {
            it[id]                  = entryId
            it[PlantLogEntry.logId] = logId
            it[action]              = request.action.key
            it[date]                = request.date
            it[comment]             = request.comment
            it[createdAt]           = Instant.now()
        }

        PlantLogResponse(
            id         = PlantLogEntryId(entryId),
            logId      = PlantLogId(logId),
            instanceId = request.instanceId,
            plantId    = PlantId(plantId),
            action     = request.action,
            date       = request.date,
            comment    = request.comment,
        )
    }

    override fun deleteEntry(entryId: PlantLogEntryId): Unit = transaction {
        PlantLogEntry.deleteWhere { PlantLogEntry.id eq entryId.value }
    }

    override fun findAllByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<LoggedEntry>> = transaction {
        val instanceIds = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isEmpty()) return@transaction emptyMap()

        (PlantLog innerJoin PlantLogEntry)
            .selectAll()
            .where {
                (PlantLog.userId eq userId.value) and
                PlantLog.instanceId.isNotNull() and
                (PlantLog.instanceId inList instanceIds)
            }
            .orderBy(PlantLogEntry.date, SortOrder.DESC)
            .groupBy({ PlantInstanceId(it[PlantLog.instanceId]!!) }, { row ->
                LoggedEntry(
                    id      = PlantLogEntryId(row[PlantLogEntry.id]),
                    action  = LogAction.from(row[PlantLogEntry.action]),
                    date    = row[PlantLogEntry.date],
                    comment = row[PlantLogEntry.comment],
                )
            })
    }
}

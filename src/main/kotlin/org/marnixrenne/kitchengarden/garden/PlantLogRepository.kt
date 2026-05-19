package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID
import org.marnixrenne.kitchengarden.garden.LoggedEntry

@Repository
class PlantLogRepository {

    fun save(userId: UUID, request: PlantLogRequest): PlantLogResponse = transaction {
        val logId = PlantLog.selectAll()
            .where { (PlantLog.userId eq userId) and (PlantLog.plantId eq request.plantId) }
            .map { it[PlantLog.id] }
            .firstOrNull()
            ?: run {
                val newLogId = UUID.randomUUID()
                PlantLog.insert {
                    it[id]        = newLogId
                    it[PlantLog.userId]  = userId
                    it[PlantLog.plantId] = request.plantId
                    it[createdAt] = Instant.now()
                }
                newLogId
            }

        val entryId = UUID.randomUUID()
        PlantLogEntry.insert {
            it[id]        = entryId
            it[PlantLogEntry.logId]  = logId
            it[action]    = request.action
            it[date]      = request.date
            it[comment]   = request.comment
            it[createdAt] = Instant.now()
        }

        PlantLogResponse(
            id      = entryId,
            logId   = logId,
            plantId = request.plantId,
            action  = request.action,
            date    = request.date,
            comment = request.comment,
        )
    }

    fun findAllByUser(userId: UUID): Map<UUID, List<LoggedEntry>> = transaction {
        (PlantLog innerJoin PlantLogEntry)
            .selectAll()
            .where { PlantLog.userId eq userId }
            .orderBy(PlantLogEntry.date, SortOrder.DESC)
            .groupBy({ it[PlantLog.plantId] }, { row ->
                LoggedEntry(
                    id      = row[PlantLogEntry.id],
                    action  = row[PlantLogEntry.action],
                    date    = row[PlantLogEntry.date],
                    comment = row[PlantLogEntry.comment],
                )
            })
    }
}

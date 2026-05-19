package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class PlantPlanRepository {

    fun save(logEntryId: UUID, periods: List<PlanPeriod>) = transaction {
        for ((action, start, end) in periods) {
            PlantPlanEntry.insert {
                it[PlantPlanEntry.id]              = UUID.randomUUID()
                it[PlantPlanEntry.logEntryId]      = logEntryId
                it[PlantPlanEntry.action]          = action
                it[PlantPlanEntry.plannedDateStart] = start
                it[PlantPlanEntry.plannedDateEnd]   = end
                it[PlantPlanEntry.createdAt]        = Instant.now()
            }
        }
    }

    fun findByUser(userId: UUID): Map<UUID, List<PlanEntry>> = transaction {
        (PlantLog innerJoin PlantLogEntry innerJoin PlantPlanEntry)
            .selectAll()
            .where { PlantLog.userId eq userId }
            .orderBy(PlantPlanEntry.plannedDateStart, SortOrder.ASC)
            .groupBy({ it[PlantLog.plantId] }, { row ->
                PlanEntry(
                    id               = row[PlantPlanEntry.id],
                    plantId          = row[PlantLog.plantId],
                    action           = row[PlantPlanEntry.action],
                    plannedDateStart = row[PlantPlanEntry.plannedDateStart],
                    plannedDateEnd   = row[PlantPlanEntry.plannedDateEnd],
                )
            })
    }
}

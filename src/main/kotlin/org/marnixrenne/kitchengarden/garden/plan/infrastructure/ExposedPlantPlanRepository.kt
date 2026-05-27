package org.marnixrenne.kitchengarden.garden.plan.infrastructure

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.domain.PlantLogEntryId
import org.marnixrenne.kitchengarden.garden.infrastructure.*
import org.marnixrenne.kitchengarden.garden.plan.domain.*
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class ExposedPlantPlanRepository : PlantPlanRepository {

    override fun save(logEntryId: PlantLogEntryId, periods: List<PlanPeriod>) = transaction {
        for ((action, start, end) in periods) {
            PlantPlanEntry.insert {
                it[PlantPlanEntry.id]               = UUID.randomUUID()
                it[PlantPlanEntry.logEntryId]       = logEntryId.value
                it[PlantPlanEntry.action]           = action
                it[PlantPlanEntry.plannedDateStart] = start
                it[PlantPlanEntry.plannedDateEnd]   = end
                it[PlantPlanEntry.createdAt]        = Instant.now()
            }
        }
    }

    override fun findByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>> = transaction {
        val instanceIds = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isEmpty()) return@transaction emptyMap()

        (PlantLog innerJoin PlantLogEntry innerJoin PlantPlanEntry)
            .selectAll()
            .where {
                (PlantLog.userId eq userId.value) and
                PlantLog.instanceId.isNotNull() and
                (PlantLog.instanceId inList instanceIds)
            }
            .orderBy(PlantPlanEntry.plannedDateStart, SortOrder.ASC)
            .groupBy({ PlantInstanceId(it[PlantLog.instanceId]!!) }, { row ->
                PlanEntry(
                    id               = PlanEntryId(row[PlantPlanEntry.id]),
                    instanceId       = PlantInstanceId(row[PlantLog.instanceId]!!),
                    plantId          = PlantId(row[PlantLog.plantId]),
                    action           = row[PlantPlanEntry.action],
                    plannedDateStart = row[PlantPlanEntry.plannedDateStart],
                    plannedDateEnd   = row[PlantPlanEntry.plannedDateEnd],
                    seedDate         = row[PlantLogEntry.date],
                    seedAction       = row[PlantLogEntry.action],
                )
            })
    }
}

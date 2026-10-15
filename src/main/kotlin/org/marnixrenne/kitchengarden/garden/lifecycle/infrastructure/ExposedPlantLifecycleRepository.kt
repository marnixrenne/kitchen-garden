package org.marnixrenne.kitchengarden.garden.lifecycle.infrastructure

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.infrastructure.GardenPlantInstances
import org.marnixrenne.kitchengarden.garden.infrastructure.PlantLog
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.*
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Repository
import java.time.Instant

@Repository
class ExposedPlantLifecycleRepository : PlantLifecycleRepository {

    override fun findAllByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, PlantLifecycle> = transaction {
        val instanceIds = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isEmpty()) return@transaction emptyMap()

        PlantLog.selectAll()
            .where {
                (PlantLog.userId eq userId.value) and
                PlantLog.instanceId.isNotNull() and
                (PlantLog.instanceId inList instanceIds)
            }
            .mapNotNull { row ->
                val state      = row[PlantLog.lifecycleState]?.let { LifecycleState.from(it) } ?: return@mapNotNull null
                val instanceId = PlantInstanceId(row[PlantLog.instanceId]!!)
                instanceId to PlantLifecycle(
                    instanceId = instanceId,
                    plantId    = PlantId(row[PlantLog.plantId]),
                    state      = state,
                    nextState  = state.next(),
                    date       = row[PlantLog.lifecycleDate],
                    comment    = row[PlantLog.lifecycleComment],
                )
            }
            .toMap()
    }

    override fun advance(userId: UserId, gardenId: GardenId, instanceId: PlantInstanceId, request: AdvanceRequest?): PlantLifecycle? = transaction {
        val instanceExists = GardenPlantInstances.selectAll()
            .where { (GardenPlantInstances.id eq instanceId.value) and (GardenPlantInstances.gardenId eq gardenId.value) }
            .count() > 0
        if (!instanceExists) return@transaction null

        val row = PlantLog.selectAll()
            .where { (PlantLog.userId eq userId.value) and (PlantLog.instanceId eq instanceId.value) }
            .firstOrNull() ?: return@transaction null

        val current = row[PlantLog.lifecycleState]?.let { LifecycleState.from(it) } ?: return@transaction null
        val next    = current.next() ?: return@transaction null

        val date    = request?.date
        val comment = request?.comment?.takeIf { it.isNotBlank() }

        val updated = PlantLog.update({
            (PlantLog.userId eq userId.value) and
            (PlantLog.instanceId eq instanceId.value) and
            (PlantLog.lifecycleState eq current.key)
        }) {
            it[lifecycleState]     = next.key
            it[lifecycleUpdatedAt] = Instant.now()
            it[lifecycleDate]      = date
            it[lifecycleComment]   = comment
        }

        if (updated == 0) {
            val currentRow = PlantLog.selectAll()
                .where { (PlantLog.userId eq userId.value) and (PlantLog.instanceId eq instanceId.value) }
                .firstOrNull() ?: return@transaction null
            val currentState = currentRow[PlantLog.lifecycleState]?.let { LifecycleState.from(it) } ?: return@transaction null
            return@transaction PlantLifecycle(
                instanceId = instanceId,
                plantId    = PlantId(currentRow[PlantLog.plantId]),
                state      = currentState,
                nextState  = currentState.next(),
                date       = currentRow[PlantLog.lifecycleDate],
                comment    = currentRow[PlantLog.lifecycleComment],
            )
        }

        PlantLifecycle(
            instanceId = instanceId,
            plantId    = PlantId(row[PlantLog.plantId]),
            state      = next,
            nextState  = next.next(),
            date       = date,
            comment    = comment,
        )
    }
}

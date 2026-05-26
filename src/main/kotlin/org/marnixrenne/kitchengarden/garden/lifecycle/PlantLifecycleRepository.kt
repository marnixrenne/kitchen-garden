package org.marnixrenne.kitchengarden.garden.lifecycle

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.PlantLog
import org.springframework.stereotype.Repository
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

@Repository
class PlantLifecycleRepository {

    fun findAllByUser(userId: UUID): Map<UUID, PlantLifecycle> = transaction {
        PlantLog.selectAll()
            .where { (PlantLog.userId eq userId) and PlantLog.instanceId.isNotNull() }
            .associate { row ->
                val state      = LifecycleState.from(row[PlantLog.lifecycleState])
                val instanceId = row[PlantLog.instanceId]!!
                instanceId to PlantLifecycle(
                    instanceId = instanceId,
                    plantId    = row[PlantLog.plantId],
                    state      = state.key,
                    nextState  = state.next()?.key,
                    date       = row[PlantLog.lifecycleDate],
                    comment    = row[PlantLog.lifecycleComment],
                )
            }
    }

    fun advance(userId: UUID, instanceId: UUID, request: AdvanceRequest?): PlantLifecycle? = transaction {
        val row = PlantLog.selectAll()
            .where { (PlantLog.userId eq userId) and (PlantLog.instanceId eq instanceId) }
            .firstOrNull() ?: return@transaction null

        val current = LifecycleState.from(row[PlantLog.lifecycleState])
        val next    = current.next() ?: return@transaction null

        val date    = request?.date
        val comment = request?.comment?.takeIf { it.isNotBlank() }

        PlantLog.update({ (PlantLog.userId eq userId) and (PlantLog.instanceId eq instanceId) }) {
            it[lifecycleState]     = next.key
            it[lifecycleUpdatedAt] = Instant.now()
            it[lifecycleDate]      = date
            it[lifecycleComment]   = comment
        }

        PlantLifecycle(
            instanceId = instanceId,
            plantId    = row[PlantLog.plantId],
            state      = next.key,
            nextState  = next.next()?.key,
            date       = date,
            comment    = comment,
        )
    }
}

package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import org.springframework.stereotype.Repository
import java.time.Instant
import java.util.UUID

@Repository
class PlantLifecycleRepository {

    fun findAllByUser(userId: UUID): Map<UUID, PlantLifecycle> = transaction {
        PlantLog.selectAll()
            .where { PlantLog.userId eq userId }
            .associate { row ->
                val state = LifecycleState.from(row[PlantLog.lifecycleState])
                row[PlantLog.plantId] to PlantLifecycle(
                    plantId   = row[PlantLog.plantId],
                    state     = state.key,
                    nextState = state.next()?.key,
                )
            }
    }

    fun advance(userId: UUID, plantId: UUID): PlantLifecycle? = transaction {
        val row = PlantLog.selectAll()
            .where { (PlantLog.userId eq userId) and (PlantLog.plantId eq plantId) }
            .firstOrNull() ?: return@transaction null

        val current = LifecycleState.from(row[PlantLog.lifecycleState])
        val next    = current.next() ?: return@transaction null

        PlantLog.update({ (PlantLog.userId eq userId) and (PlantLog.plantId eq plantId) }) {
            it[lifecycleState]     = next.key
            it[lifecycleUpdatedAt] = Instant.now()
        }

        PlantLifecycle(plantId = plantId, state = next.key, nextState = next.next()?.key)
    }
}

package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class GardenRepository {

    fun findVegetableIds(userId: UUID): Set<UUID> = transaction {
        GardenVegetables.selectAll()
            .where { GardenVegetables.userId eq userId }
            .map { it[GardenVegetables.vegetableId] }
            .toSet()
    }

    fun add(userId: UUID, vegetableId: UUID): Unit = transaction {
        GardenVegetables.upsert {
            it[GardenVegetables.userId]      = userId
            it[GardenVegetables.vegetableId] = vegetableId
        }
    }

    fun remove(userId: UUID, vegetableId: UUID): Unit = transaction {
        GardenVegetables.deleteWhere {
            (GardenVegetables.userId eq userId) and (GardenVegetables.vegetableId eq vegetableId)
        }
    }
}

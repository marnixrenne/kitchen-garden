package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.vegetables.*
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

    fun findDetails(userId: UUID): List<VegetableDetail> = transaction {
        val ids = GardenVegetables.selectAll()
            .where { GardenVegetables.userId eq userId }
            .map { it[GardenVegetables.vegetableId] }

        ids.mapNotNull { id ->
            Vegetables.selectAll()
                .where { Vegetables.id eq id }
                .map { row ->
                    val seedingMonths = SeedingMonths.selectAll()
                        .where { SeedingMonths.vegetableId eq id }
                        .map { it[SeedingMonths.monthNum] }
                        .sorted()
                    val harvestingMonths = HarvestingMonths.selectAll()
                        .where { HarvestingMonths.vegetableId eq id }
                        .map { it[HarvestingMonths.monthNum] }
                        .sorted()
                    val countries = (VegetableCountries innerJoin Countries)
                        .selectAll()
                        .where { VegetableCountries.vegetableId eq id }
                        .map { Country(it[Countries.code], it[Countries.name]) }
                        .sortedBy { it.name }
                    VegetableDetail(
                        id               = row[Vegetables.id],
                        name             = row[Vegetables.name],
                        category         = row[Vegetables.category],
                        emoji            = row[Vegetables.emoji],
                        imageUrl         = row[Vegetables.imageUrl],
                        seedingMonths    = seedingMonths,
                        harvestingMonths = harvestingMonths,
                        countries        = countries,
                        companions       = emptyList(),
                    )
                }
                .firstOrNull()
        }.sortedBy { it.name }
    }
}

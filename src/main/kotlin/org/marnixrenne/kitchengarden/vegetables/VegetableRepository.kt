package org.marnixrenne.kitchengarden.vegetables

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class VegetableRepository {

    fun findAll(): List<Vegetable> = transaction {
        Vegetables.selectAll()
            .orderBy(Vegetables.category to SortOrder.ASC, Vegetables.name to SortOrder.ASC)
            .map { row ->
                Vegetable(
                    id       = row[Vegetables.id],
                    name     = row[Vegetables.name],
                    category = row[Vegetables.category],
                    emoji    = row[Vegetables.emoji],
                    imageUrl = row[Vegetables.imageUrl]
                )
            }
    }

    fun findByMonth(month: Int): List<Vegetable> = transaction {
        (Vegetables innerJoin SeedingMonths)
            .selectAll()
            .where { SeedingMonths.monthNum eq month }
            .orderBy(Vegetables.category to SortOrder.ASC, Vegetables.name to SortOrder.ASC)
            .map { row ->
                Vegetable(
                    id       = row[Vegetables.id],
                    name     = row[Vegetables.name],
                    category = row[Vegetables.category],
                    emoji    = row[Vegetables.emoji],
                    imageUrl = row[Vegetables.imageUrl]
                )
            }
    }

    fun findById(id: UUID): VegetableDetail? = transaction {
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
                val companions = run {
                    val pairs = CompanionPlants.selectAll()
                        .where { (CompanionPlants.vegetableId eq id) or (CompanionPlants.companionId eq id) }
                        .map { r ->
                            val companionId = if (r[CompanionPlants.vegetableId] == id)
                                r[CompanionPlants.companionId] else r[CompanionPlants.vegetableId]
                            companionId to r[CompanionPlants.relationship]
                        }
                    val vegMap = Vegetables.selectAll()
                        .where { Vegetables.id inList pairs.map { it.first } }
                        .associate { it[Vegetables.id] to it }
                    pairs.mapNotNull { (companionId, relationship) ->
                        val veg = vegMap[companionId] ?: return@mapNotNull null
                        CompanionPlant(companionId, veg[Vegetables.name], veg[Vegetables.emoji], relationship)
                    }.sortedWith(compareBy({ it.relationship }, { it.name }))
                }
                VegetableDetail(
                    id               = row[Vegetables.id],
                    name             = row[Vegetables.name],
                    category         = row[Vegetables.category],
                    emoji            = row[Vegetables.emoji],
                    imageUrl         = row[Vegetables.imageUrl],
                    sunRequirement   = row[Vegetables.sunRequirement],
                    seedingMonths    = seedingMonths,
                    harvestingMonths = harvestingMonths,
                    countries        = countries,
                    companions       = companions,
                )
            }
            .firstOrNull()
    }

    fun countPerMonth(): Map<Int, Int> = transaction {
        SeedingMonths
            .selectAll()
            .map { it[SeedingMonths.monthNum] }
            .groupingBy { it }
            .eachCount()
    }
}

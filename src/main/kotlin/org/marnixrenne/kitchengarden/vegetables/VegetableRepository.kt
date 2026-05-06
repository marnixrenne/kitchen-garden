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
                    emoji    = row[Vegetables.emoji]
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
                    emoji    = row[Vegetables.emoji]
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
                VegetableDetail(
                    id               = row[Vegetables.id],
                    name             = row[Vegetables.name],
                    category         = row[Vegetables.category],
                    emoji            = row[Vegetables.emoji],
                    seedingMonths    = seedingMonths,
                    harvestingMonths = harvestingMonths,
                    countries        = countries
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

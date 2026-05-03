package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository

@Repository
class VegetableRepository {

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

    fun countPerMonth(): Map<Int, Int> = transaction {
        SeedingMonths
            .selectAll()
            .map { it[SeedingMonths.monthNum] }
            .groupingBy { it }
            .eachCount()
    }
}
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

    fun findByMonth(month: Int, countryCode: String?): List<Vegetable> = transaction {
        val ids = seedingIdsForMonth(month, countryCode)
        Vegetables.selectAll()
            .where { Vegetables.id inList ids }
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

    fun findById(id: UUID, countryCode: String?): VegetableDetail? = transaction {
        Vegetables.selectAll()
            .where { Vegetables.id eq id }
            .map { row ->
                val seedingMonths    = resolvedSeedingMonths(id, countryCode)
                val harvestingMonths = resolvedHarvestingMonths(id, countryCode)
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
                val sowingGuide = SowingGuide(
                    method             = row[Vegetables.sowingMethod],
                    seedDepthMm        = row[Vegetables.seedDepthMm],
                    spacingCm          = row[Vegetables.spacingCm],
                    germinationDaysMin = row[Vegetables.germinationDaysMin],
                    germinationDaysMax = row[Vegetables.germinationDaysMax],
                    daysToMaturityMin  = row[Vegetables.daysToMaturityMin],
                    daysToMaturityMax  = row[Vegetables.daysToMaturityMax],
                    frostTolerance     = row[Vegetables.frostTolerance],
                ).takeIf { it.method != null }
                VegetableDetail(
                    id               = row[Vegetables.id],
                    name             = row[Vegetables.name],
                    category         = row[Vegetables.category],
                    emoji            = row[Vegetables.emoji],
                    imageUrl         = row[Vegetables.imageUrl],
                    sunRequirement   = row[Vegetables.sunRequirement],
                    pruningType      = row[Vegetables.pruningType],
                    pruningTip       = row[Vegetables.pruningTip],
                    sowingGuide      = sowingGuide,
                    seedingMonths    = seedingMonths,
                    harvestingMonths = harvestingMonths,
                    countries        = countries,
                    companions       = companions,
                )
            }
            .firstOrNull()
    }

    fun countPerMonth(countryCode: String?): Map<Int, Int> = transaction {
        if (countryCode == null) {
            SeedingMonths.selectAll()
                .where { SeedingMonths.countryCode.isNull() }
                .map { it[SeedingMonths.monthNum] }
                .groupingBy { it }.eachCount()
        } else {
            val vegsWithCountryData = SeedingMonths.selectAll()
                .where { SeedingMonths.countryCode eq countryCode }
                .map { it[SeedingMonths.vegetableId] }.toSet()

            val countryMonths = SeedingMonths.selectAll()
                .where { SeedingMonths.countryCode eq countryCode }
                .map { it[SeedingMonths.monthNum] }

            val globalMonths = SeedingMonths.selectAll()
                .where {
                    SeedingMonths.countryCode.isNull() and
                    (SeedingMonths.vegetableId notInList vegsWithCountryData.toList())
                }
                .map { it[SeedingMonths.monthNum] }

            (countryMonths + globalMonths).groupingBy { it }.eachCount()
        }
    }

    // Returns vegetable IDs that are seedable in the given month, respecting country fallback.
    internal fun seedingIdsForMonth(month: Int, countryCode: String?): List<UUID> {
        if (countryCode == null) {
            return SeedingMonths.selectAll()
                .where { (SeedingMonths.monthNum eq month) and SeedingMonths.countryCode.isNull() }
                .map { it[SeedingMonths.vegetableId] }
        }
        val vegsWithCountryData = SeedingMonths.selectAll()
            .where { SeedingMonths.countryCode eq countryCode }
            .map { it[SeedingMonths.vegetableId] }.toSet()

        val fromCountry = SeedingMonths.selectAll()
            .where { (SeedingMonths.monthNum eq month) and (SeedingMonths.countryCode eq countryCode) }
            .map { it[SeedingMonths.vegetableId] }

        val fromGlobal = SeedingMonths.selectAll()
            .where {
                (SeedingMonths.monthNum eq month) and
                SeedingMonths.countryCode.isNull() and
                (SeedingMonths.vegetableId notInList vegsWithCountryData.toList())
            }
            .map { it[SeedingMonths.vegetableId] }

        return fromCountry + fromGlobal
    }

    private fun resolvedSeedingMonths(vegetableId: UUID, countryCode: String?): List<Int> {
        if (countryCode != null) {
            val country = SeedingMonths.selectAll()
                .where { (SeedingMonths.vegetableId eq vegetableId) and (SeedingMonths.countryCode eq countryCode) }
                .map { it[SeedingMonths.monthNum] }.sorted()
            if (country.isNotEmpty()) return country
        }
        return SeedingMonths.selectAll()
            .where { (SeedingMonths.vegetableId eq vegetableId) and SeedingMonths.countryCode.isNull() }
            .map { it[SeedingMonths.monthNum] }.sorted()
    }

    private fun resolvedHarvestingMonths(vegetableId: UUID, countryCode: String?): List<Int> {
        if (countryCode != null) {
            val country = HarvestingMonths.selectAll()
                .where { (HarvestingMonths.vegetableId eq vegetableId) and (HarvestingMonths.countryCode eq countryCode) }
                .map { it[HarvestingMonths.monthNum] }.sorted()
            if (country.isNotEmpty()) return country
        }
        return HarvestingMonths.selectAll()
            .where { (HarvestingMonths.vegetableId eq vegetableId) and HarvestingMonths.countryCode.isNull() }
            .map { it[HarvestingMonths.monthNum] }.sorted()
    }
}

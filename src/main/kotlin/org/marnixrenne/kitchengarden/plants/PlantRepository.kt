package org.marnixrenne.kitchengarden.plants

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class PlantRepository {

    fun findAll(): List<Plant> = transaction {
        Plants.selectAll()
            .orderBy(Plants.category to SortOrder.ASC, Plants.name to SortOrder.ASC)
            .map { row ->
                Plant(
                    id       = row[Plants.id],
                    name     = row[Plants.name],
                    category = row[Plants.category],
                    emoji    = row[Plants.emoji],
                    imageUrl = row[Plants.imageUrl]
                )
            }
    }

    fun findByMonth(month: Int, countryCode: String?): List<Plant> = transaction {
        val ids = seedingIdsForMonth(month, countryCode)
        Plants.selectAll()
            .where { Plants.id inList ids }
            .orderBy(Plants.category to SortOrder.ASC, Plants.name to SortOrder.ASC)
            .map { row ->
                Plant(
                    id       = row[Plants.id],
                    name     = row[Plants.name],
                    category = row[Plants.category],
                    emoji    = row[Plants.emoji],
                    imageUrl = row[Plants.imageUrl]
                )
            }
    }

    fun findById(id: UUID, countryCode: String?): PlantDetail? = transaction {
        Plants.selectAll()
            .where { Plants.id eq id }
            .map { row ->
                val seedingMonths    = resolvedSeedingMonths(id, countryCode)
                val harvestingMonths = resolvedHarvestingMonths(id, countryCode)
                val countries = (PlantCountries innerJoin Countries)
                    .selectAll()
                    .where { PlantCountries.plantId eq id }
                    .map { Country(it[Countries.code], it[Countries.name]) }
                    .sortedBy { it.name }
                val companions = run {
                    val pairs = CompanionPlants.selectAll()
                        .where { (CompanionPlants.plantId eq id) or (CompanionPlants.companionId eq id) }
                        .map { r ->
                            val companionId = if (r[CompanionPlants.plantId] == id)
                                r[CompanionPlants.companionId] else r[CompanionPlants.plantId]
                            companionId to r[CompanionPlants.relationship]
                        }
                    val plantMap = Plants.selectAll()
                        .where { Plants.id inList pairs.map { it.first } }
                        .associate { it[Plants.id] to it }
                    pairs.mapNotNull { (companionId, relationship) ->
                        val plant = plantMap[companionId] ?: return@mapNotNull null
                        CompanionPlant(companionId, plant[Plants.name], plant[Plants.emoji], relationship)
                    }.sortedWith(compareBy({ it.relationship }, { it.name }))
                }
                val sowingGuide = SowingGuide(
                    method             = row[Plants.sowingMethod],
                    seedDepthMm        = row[Plants.seedDepthMm],
                    spacingCm          = row[Plants.spacingCm],
                    germinationDaysMin = row[Plants.germinationDaysMin],
                    germinationDaysMax = row[Plants.germinationDaysMax],
                    daysToMaturityMin  = row[Plants.daysToMaturityMin],
                    daysToMaturityMax  = row[Plants.daysToMaturityMax],
                    frostTolerance     = row[Plants.frostTolerance],
                ).takeIf { it.method != null }
                val typeOrder = mapOf("pollinator" to 0, "beneficial" to 1, "pest" to 2)
                val insects = PlantInsects.selectAll()
                    .where { PlantInsects.plantId eq id }
                    .map { InsectAttraction(it[PlantInsects.insectName], it[PlantInsects.insectType]) }
                    .sortedWith(compareBy({ typeOrder[it.type] ?: 99 }, { it.name }))
                PlantDetail(
                    id               = row[Plants.id],
                    name             = row[Plants.name],
                    latinName        = row[Plants.latinName],
                    category         = row[Plants.category],
                    emoji            = row[Plants.emoji],
                    imageUrl         = row[Plants.imageUrl],
                    sunRequirement   = row[Plants.sunRequirement],
                    pruningType      = row[Plants.pruningType],
                    pruningTip       = row[Plants.pruningTip],
                    sowingGuide      = sowingGuide,
                    heightMinCm      = row[Plants.heightMinCm]?.toInt(),
                    heightMaxCm      = row[Plants.heightMaxCm]?.toInt(),
                    seedingMonths    = seedingMonths,
                    harvestingMonths = harvestingMonths,
                    countries        = countries,
                    companions       = companions,
                    insects          = insects,
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
            val plantsWithCountryData = SeedingMonths.selectAll()
                .where { SeedingMonths.countryCode eq countryCode }
                .map { it[SeedingMonths.plantId] }.toSet()

            val countryMonths = SeedingMonths.selectAll()
                .where { SeedingMonths.countryCode eq countryCode }
                .map { it[SeedingMonths.monthNum] }

            val globalMonths = SeedingMonths.selectAll()
                .where {
                    SeedingMonths.countryCode.isNull() and
                    (SeedingMonths.plantId notInList plantsWithCountryData.toList())
                }
                .map { it[SeedingMonths.monthNum] }

            (countryMonths + globalMonths).groupingBy { it }.eachCount()
        }
    }

    // Returns plant IDs that are seedable in the given month, respecting country fallback.
    internal fun seedingIdsForMonth(month: Int, countryCode: String?): List<UUID> {
        if (countryCode == null) {
            return SeedingMonths.selectAll()
                .where { (SeedingMonths.monthNum eq month) and SeedingMonths.countryCode.isNull() }
                .map { it[SeedingMonths.plantId] }
        }
        val plantsWithCountryData = SeedingMonths.selectAll()
            .where { SeedingMonths.countryCode eq countryCode }
            .map { it[SeedingMonths.plantId] }.toSet()

        val fromCountry = SeedingMonths.selectAll()
            .where { (SeedingMonths.monthNum eq month) and (SeedingMonths.countryCode eq countryCode) }
            .map { it[SeedingMonths.plantId] }

        val fromGlobal = SeedingMonths.selectAll()
            .where {
                (SeedingMonths.monthNum eq month) and
                SeedingMonths.countryCode.isNull() and
                (SeedingMonths.plantId notInList plantsWithCountryData.toList())
            }
            .map { it[SeedingMonths.plantId] }

        return fromCountry + fromGlobal
    }

    private fun resolvedSeedingMonths(plantId: UUID, countryCode: String?): List<Int> {
        if (countryCode != null) {
            val country = SeedingMonths.selectAll()
                .where { (SeedingMonths.plantId eq plantId) and (SeedingMonths.countryCode eq countryCode) }
                .map { it[SeedingMonths.monthNum] }.sorted()
            if (country.isNotEmpty()) return country
        }
        return SeedingMonths.selectAll()
            .where { (SeedingMonths.plantId eq plantId) and SeedingMonths.countryCode.isNull() }
            .map { it[SeedingMonths.monthNum] }.sorted()
    }

    private fun resolvedHarvestingMonths(plantId: UUID, countryCode: String?): List<Int> {
        if (countryCode != null) {
            val country = HarvestingMonths.selectAll()
                .where { (HarvestingMonths.plantId eq plantId) and (HarvestingMonths.countryCode eq countryCode) }
                .map { it[HarvestingMonths.monthNum] }.sorted()
            if (country.isNotEmpty()) return country
        }
        return HarvestingMonths.selectAll()
            .where { (HarvestingMonths.plantId eq plantId) and HarvestingMonths.countryCode.isNull() }
            .map { it[HarvestingMonths.monthNum] }.sorted()
    }
}

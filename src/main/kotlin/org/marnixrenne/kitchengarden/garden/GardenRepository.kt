package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.vegetables.*
import org.marnixrenne.kitchengarden.vegetables.CompanionPlants
import org.springframework.stereotype.Repository
import java.time.LocalDate
import java.time.temporal.WeekFields
import java.util.UUID

private fun resolvedMonthNums(
    vegetableIdCol: Column<UUID>,
    monthNumCol: Column<Int>,
    countryCodeCol: Column<String?>,
    vegetableId: UUID,
    countryCode: String?,
): List<Int> {
    if (countryCode != null) {
        val country = vegetableIdCol.table.selectAll()
            .where { (vegetableIdCol eq vegetableId) and (countryCodeCol eq countryCode) }
            .map { it[monthNumCol] }.sorted()
        if (country.isNotEmpty()) return country
    }
    return vegetableIdCol.table.selectAll()
        .where { (vegetableIdCol eq vegetableId) and countryCodeCol.isNull() }
        .map { it[monthNumCol] }.sorted()
}

private fun resolvedMonthIds(
    vegetableIdCol: Column<UUID>,
    monthNumCol: Column<Int>,
    countryCodeCol: Column<String?>,
    ids: List<UUID>,
    month: Int,
    countryCode: String?,
): Set<UUID> {
    if (countryCode == null) {
        return vegetableIdCol.table.selectAll()
            .where { (vegetableIdCol inList ids) and (monthNumCol eq month) and countryCodeCol.isNull() }
            .map { it[vegetableIdCol] }.toSet()
    }
    val vegsWithCountryData = vegetableIdCol.table.selectAll()
        .where { (vegetableIdCol inList ids) and (countryCodeCol eq countryCode) }
        .map { it[vegetableIdCol] }.toSet()

    val fromCountry = vegetableIdCol.table.selectAll()
        .where { (vegetableIdCol inList ids) and (monthNumCol eq month) and (countryCodeCol eq countryCode) }
        .map { it[vegetableIdCol] }.toSet()

    val remaining = ids - vegsWithCountryData
    val fromGlobal = if (remaining.isEmpty()) emptySet() else vegetableIdCol.table.selectAll()
        .where { (vegetableIdCol inList remaining) and (monthNumCol eq month) and countryCodeCol.isNull() }
        .map { it[vegetableIdCol] }.toSet()

    return fromCountry + fromGlobal
}

private val SUN_ORDER = listOf("full_sun", "partial_shade", "shade")

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

    fun findSuggestions(userId: UUID): PlantingSuggestions = transaction {
        val ids = GardenVegetables.selectAll()
            .where { GardenVegetables.userId eq userId }
            .map { it[GardenVegetables.vegetableId] }

        if (ids.size < 2) return@transaction PlantingSuggestions(emptyList(), emptyList())

        val vegs = Vegetables.selectAll()
            .where { Vegetables.id inList ids }
            .map { row ->
                Triple(
                    SimpleVeg(row[Vegetables.id], row[Vegetables.name], row[Vegetables.emoji]),
                    row[Vegetables.sunRequirement],
                    row[Vegetables.id],
                )
            }

        val vegById = vegs.associate { it.first.id to it.first }

        // Companion pairs where both are in the garden
        val companionRows = CompanionPlants.selectAll()
            .where { (CompanionPlants.vegetableId inList ids) and (CompanionPlants.companionId inList ids) }
            .map { Triple(it[CompanionPlants.vegetableId], it[CompanionPlants.companionId], it[CompanionPlants.relationship]) }

        val goodPairIds = companionRows.filter { it.third == "good" }.map { it.first to it.second }.toSet()
        val badPairIds  = companionRows.filter { it.third == "bad"  }.map { it.first to it.second }.toSet()

        // Group by sun requirement
        val sunGroups = vegs
            .groupBy { it.second ?: "unknown" }
            .entries
            .sortedBy { SUN_ORDER.indexOf(it.key).takeIf { i -> i >= 0 } ?: Int.MAX_VALUE }
            .map { (sun, members) ->
                val memberIds = members.map { it.first.id }.toSet()
                val goodPairs = goodPairIds
                    .filter { (a, b) -> a in memberIds && b in memberIds }
                    .mapNotNull { (a, b) ->
                        val va = vegById[a] ?: return@mapNotNull null
                        val vb = vegById[b] ?: return@mapNotNull null
                        VegPair(va, vb)
                    }
                SunGroup(sun, members.map { it.first }.sortedBy { it.name }, goodPairs)
            }

        val conflicts = badPairIds.mapNotNull { (a, b) ->
            val va = vegById[a] ?: return@mapNotNull null
            val vb = vegById[b] ?: return@mapNotNull null
            VegPair(va, vb)
        }

        PlantingSuggestions(sunGroups, conflicts)
    }

    fun findWeekSummary(userId: UUID, countryCode: String?): WeekSummary = transaction {
        val today      = LocalDate.now()
        val month      = today.monthValue
        val week       = today.get(WeekFields.ISO.weekOfWeekBasedYear())
        val weekStart  = today.with(WeekFields.ISO.dayOfWeek(), 1)
        val weekEnd    = weekStart.plusDays(6)

        val ids = GardenVegetables.selectAll()
            .where { GardenVegetables.userId eq userId }
            .map { it[GardenVegetables.vegetableId] }

        if (ids.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val seedingIds   = resolvedMonthIds(SeedingMonths.vegetableId,   SeedingMonths.monthNum,   SeedingMonths.countryCode,   ids, month, countryCode)
        val harvestingIds = resolvedMonthIds(HarvestingMonths.vegetableId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, month, countryCode)

        val activeIds = seedingIds + harvestingIds
        if (activeIds.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val actions = Vegetables.selectAll()
            .where { Vegetables.id inList activeIds }
            .map { row ->
                val id       = row[Vegetables.id]
                val sows     = id in seedingIds
                val harvests = id in harvestingIds
                val type     = when {
                    sows && harvests -> "both"
                    sows             -> "sow"
                    else             -> "harvest"
                }
                WeekAction(
                    type               = type,
                    vegetable          = SimpleVeg(id, row[Vegetables.name], row[Vegetables.emoji]),
                    sowingMethod       = row[Vegetables.sowingMethod],
                    germinationDaysMin = row[Vegetables.germinationDaysMin],
                    germinationDaysMax = row[Vegetables.germinationDaysMax],
                )
            }
            .sortedWith(compareBy({ it.type }, { it.vegetable.name }))

        WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, actions)
    }

    fun findDetails(userId: UUID, countryCode: String?): List<VegetableDetail> = transaction {
        val ids = GardenVegetables.selectAll()
            .where { GardenVegetables.userId eq userId }
            .map { it[GardenVegetables.vegetableId] }

        ids.mapNotNull { id ->
            Vegetables.selectAll()
                .where { Vegetables.id eq id }
                .map { row ->
                    val seedingMonths    = resolvedMonthNums(SeedingMonths.vegetableId,   SeedingMonths.monthNum,   SeedingMonths.countryCode,   id, countryCode)
                    val harvestingMonths = resolvedMonthNums(HarvestingMonths.vegetableId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, id, countryCode)
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
                        sunRequirement   = null,
                        pruningType      = null,
                        pruningTip       = null,
                        sowingGuide      = null,
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

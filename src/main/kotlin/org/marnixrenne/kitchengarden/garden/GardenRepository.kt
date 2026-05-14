package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.plants.*
import org.marnixrenne.kitchengarden.plants.CompanionPlants
import org.marnixrenne.kitchengarden.plants.batchResolvedMonthNums
import org.marnixrenne.kitchengarden.plants.resolvedMonthNums
import org.springframework.stereotype.Repository
import java.time.LocalDate
import java.time.temporal.WeekFields
import java.util.UUID

private fun resolvedMonthIds(
    plantIdCol: Column<UUID>,
    monthNumCol: Column<Int>,
    countryCodeCol: Column<String?>,
    ids: List<UUID>,
    month: Int,
    countryCode: String?,
): Set<UUID> {
    if (countryCode == null) {
        return plantIdCol.table.selectAll()
            .where { (plantIdCol inList ids) and (monthNumCol eq month) and countryCodeCol.isNull() }
            .map { it[plantIdCol] }.toSet()
    }
    val plantsWithCountryData = plantIdCol.table.selectAll()
        .where { (plantIdCol inList ids) and (countryCodeCol eq countryCode) }
        .map { it[plantIdCol] }.toSet()

    val fromCountry = plantIdCol.table.selectAll()
        .where { (plantIdCol inList ids) and (monthNumCol eq month) and (countryCodeCol eq countryCode) }
        .map { it[plantIdCol] }.toSet()

    val remaining = ids - plantsWithCountryData
    val fromGlobal = if (remaining.isEmpty()) emptySet() else plantIdCol.table.selectAll()
        .where { (plantIdCol inList remaining) and (monthNumCol eq month) and countryCodeCol.isNull() }
        .map { it[plantIdCol] }.toSet()

    return fromCountry + fromGlobal
}

private val SUN_ORDER = listOf("full_sun", "partial_shade", "shade")

@Repository
class GardenRepository {

    fun findPlantIds(userId: UUID): Set<UUID> = transaction {
        GardenPlants.selectAll()
            .where { GardenPlants.userId eq userId }
            .map { it[GardenPlants.plantId] }
            .toSet()
    }

    fun add(userId: UUID, plantId: UUID): Unit = transaction {
        GardenPlants.upsert {
            it[GardenPlants.userId]  = userId
            it[GardenPlants.plantId] = plantId
        }
    }

    fun remove(userId: UUID, plantId: UUID): Unit = transaction {
        GardenPlants.deleteWhere {
            (GardenPlants.userId eq userId) and (GardenPlants.plantId eq plantId)
        }
    }

    fun findSuggestions(userId: UUID): PlantingSuggestions = transaction {
        val ids = GardenPlants.selectAll()
            .where { GardenPlants.userId eq userId }
            .map { it[GardenPlants.plantId] }

        if (ids.size < 2) return@transaction PlantingSuggestions(emptyList(), emptyList())

        val plants = Plants.selectAll()
            .where { Plants.id inList ids }
            .map { row ->
                Triple(
                    SimpleVeg(row[Plants.id], row[Plants.name], row[Plants.emoji]),
                    row[Plants.sunRequirement],
                    row[Plants.id],
                )
            }

        val vegById = plants.associate { it.first.id to it.first }

        val companionRows = CompanionPlants.selectAll()
            .where { (CompanionPlants.plantId inList ids) and (CompanionPlants.companionId inList ids) }
            .map { Triple(it[CompanionPlants.plantId], it[CompanionPlants.companionId], it[CompanionPlants.relationship]) }

        val goodPairIds = companionRows.filter { it.third == "good" }.map { it.first to it.second }.toSet()
        val badPairIds  = companionRows.filter { it.third == "bad"  }.map { it.first to it.second }.toSet()

        val sunGroups = plants
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
        val today     = LocalDate.now()
        val month     = today.monthValue
        val week      = today.get(WeekFields.ISO.weekOfWeekBasedYear())
        val weekStart = today.with(WeekFields.ISO.dayOfWeek(), 1)
        val weekEnd   = weekStart.plusDays(6)

        val ids = GardenPlants.selectAll()
            .where { GardenPlants.userId eq userId }
            .map { it[GardenPlants.plantId] }

        if (ids.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val seedingIds   = resolvedMonthIds(SeedingMonths.plantId,   SeedingMonths.monthNum,   SeedingMonths.countryCode,   ids, month, countryCode)
        val harvestingIds = resolvedMonthIds(HarvestingMonths.plantId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, month, countryCode)

        val activeIds = seedingIds + harvestingIds
        if (activeIds.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val actions = Plants.selectAll()
            .where { Plants.id inList activeIds }
            .map { row ->
                val id       = row[Plants.id]
                val sows     = id in seedingIds
                val harvests = id in harvestingIds
                val type     = when {
                    sows && harvests -> "both"
                    sows             -> "sow"
                    else             -> "harvest"
                }
                WeekAction(
                    type               = type,
                    plant              = SimpleVeg(id, row[Plants.name], row[Plants.emoji]),
                    sowingMethod       = row[Plants.sowingMethod],
                    germinationDaysMin = row[Plants.germinationDaysMin],
                    germinationDaysMax = row[Plants.germinationDaysMax],
                )
            }
            .sortedWith(compareBy({ it.type }, { it.plant.name }))

        WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, actions)
    }

    fun findDetails(userId: UUID, countryCode: String?): List<PlantDetail> = transaction {
        val ids = GardenPlants.selectAll()
            .where { GardenPlants.userId eq userId }
            .map { it[GardenPlants.plantId] }

        if (ids.isEmpty()) return@transaction emptyList()

        // Batch-load all data upfront to avoid N+1 queries
        val plantRows = Plants.selectAll()
            .where { Plants.id inList ids }
            .associateBy { it[Plants.id] }

        val seedingByPlant    = batchResolvedMonthNums(SeedingMonths.plantId,   SeedingMonths.monthNum,   SeedingMonths.countryCode,   ids, countryCode)
        val harvestingByPlant = batchResolvedMonthNums(HarvestingMonths.plantId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, countryCode)

        val countriesByPlant = (PlantCountries innerJoin Countries)
            .selectAll()
            .where { PlantCountries.plantId inList ids }
            .groupBy({ it[PlantCountries.plantId] }, { Country(it[Countries.code], it[Countries.name]) })
            .mapValues { it.value.sortedBy { c -> c.name } }

        ids.mapNotNull { id ->
            val row = plantRows[id] ?: return@mapNotNull null
            PlantDetail(
                id               = row[Plants.id],
                name             = row[Plants.name],
                latinName        = row[Plants.latinName],
                category         = row[Plants.category],
                emoji            = row[Plants.emoji],
                imageUrl         = row[Plants.imageUrl],
                sunRequirement   = null,
                pruningType      = null,
                pruningTip       = null,
                sowingGuide      = null,
                heightMinCm      = row[Plants.heightMinCm]?.toInt(),
                heightMaxCm      = row[Plants.heightMaxCm]?.toInt(),
                seedingMonths    = seedingByPlant[id] ?: emptyList(),
                harvestingMonths = harvestingByPlant[id] ?: emptyList(),
                countries        = countriesByPlant[id] ?: emptyList(),
                companions       = emptyList(),
                insects          = emptyList(),
            )
        }.sortedBy { it.name }
    }
}

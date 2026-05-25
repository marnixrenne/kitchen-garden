package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.plants.*
import org.marnixrenne.kitchengarden.plants.CompanionPlants
import org.marnixrenne.kitchengarden.plants.batchResolvedMonthNums
import org.marnixrenne.kitchengarden.plants.resolvedMonthNums
import org.springframework.stereotype.Repository
import java.time.Instant
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

    // ── Garden CRUD ──────────────────────────────────────────────────────────

    fun findGardens(userId: UUID): List<GardenSummary> = transaction {
        Garden.selectAll()
            .where { Garden.userId eq userId }
            .orderBy(Garden.createdAt)
            .map { GardenSummary(it[Garden.id], it[Garden.name]) }
    }

    fun findOrCreateDefaultGarden(userId: UUID): UUID = transaction {
        Garden.selectAll()
            .where { Garden.userId eq userId }
            .orderBy(Garden.createdAt)
            .firstOrNull()
            ?.get(Garden.id)
            ?: createGardenInTx(userId, "My Garden")
    }

    fun createGarden(userId: UUID, name: String): GardenSummary = transaction {
        val id = createGardenInTx(userId, name)
        GardenSummary(id, name)
    }

    private fun createGardenInTx(userId: UUID, name: String): UUID {
        val id = UUID.randomUUID()
        Garden.insert {
            it[Garden.id]        = id
            it[Garden.userId]    = userId
            it[Garden.name]      = name
            it[Garden.createdAt] = Instant.now()
        }
        return id
    }

    fun deleteGarden(gardenId: UUID, userId: UUID): Boolean = transaction {
        val instanceIds = GardenPlantInstances
            .select(GardenPlantInstances.id)
            .where { GardenPlantInstances.gardenId eq gardenId }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isNotEmpty()) {
            PlantLog.deleteWhere { PlantLog.instanceId inList instanceIds }
        }
        Garden.deleteWhere { (Garden.id eq gardenId) and (Garden.userId eq userId) } > 0
    }

    // ── Plant membership ─────────────────────────────────────────────────────

    fun findPlantIds(gardenId: UUID): Set<UUID> = transaction {
        GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId }
            .map { it[GardenPlantInstances.plantId] }
            .toSet()
    }

    fun add(gardenId: UUID, plantId: UUID): Unit = transaction {
        val exists = GardenPlantInstances.selectAll()
            .where { (GardenPlantInstances.gardenId eq gardenId) and (GardenPlantInstances.plantId eq plantId) }
            .count() > 0
        if (!exists) {
            GardenPlantInstances.insert {
                it[GardenPlantInstances.id]        = UUID.randomUUID()
                it[GardenPlantInstances.gardenId]  = gardenId
                it[GardenPlantInstances.plantId]   = plantId
                it[GardenPlantInstances.createdAt] = Instant.now()
            }
        }
    }

    fun remove(gardenId: UUID, plantId: UUID): Unit = transaction {
        GardenPlantInstances.deleteWhere {
            (GardenPlantInstances.gardenId eq gardenId) and (GardenPlantInstances.plantId eq plantId)
        }
    }

    fun findInstances(gardenId: UUID): List<PlantInstance> = transaction {
        GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId }
            .orderBy(GardenPlantInstances.createdAt)
            .map { PlantInstance(it[GardenPlantInstances.id], it[GardenPlantInstances.plantId]) }
    }

    // ── Views ─────────────────────────────────────────────────────────────────

    fun findSuggestions(gardenId: UUID): PlantingSuggestions = transaction {
        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId }
            .map { it[GardenPlantInstances.plantId] }
            .distinct()

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

    fun findWeekSummary(gardenId: UUID, countryCode: String?): WeekSummary = transaction {
        val today     = LocalDate.now()
        val month     = today.monthValue
        val week      = today.get(WeekFields.ISO.weekOfWeekBasedYear())
        val weekStart = today.with(WeekFields.ISO.dayOfWeek(), 1)
        val weekEnd   = weekStart.plusDays(6)

        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId }
            .map { it[GardenPlantInstances.plantId] }
            .distinct()

        if (ids.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val seedingIds    = resolvedMonthIds(SeedingMonths.plantId,    SeedingMonths.monthNum,    SeedingMonths.countryCode,    ids, month, countryCode)
        val harvestingIds = resolvedMonthIds(HarvestingMonths.plantId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, month, countryCode)

        val activeIds = seedingIds + harvestingIds
        if (activeIds.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val userId = Garden.selectAll()
            .where { Garden.id eq gardenId }
            .first()[Garden.userId]

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
                    logEntries         = emptyList(),
                )
            }

        val entriesByPlant = (PlantLog innerJoin PlantLogEntry)
            .selectAll()
            .where {
                (PlantLog.userId eq userId) and
                (PlantLog.plantId inList activeIds.toList()) and
                (PlantLogEntry.date greaterEq weekStart) and
                (PlantLogEntry.date lessEq weekEnd)
            }
            .orderBy(PlantLogEntry.date)
            .groupBy({ it[PlantLog.plantId] }, { row ->
                LoggedEntry(
                    id      = row[PlantLogEntry.id],
                    action  = row[PlantLogEntry.action],
                    date    = row[PlantLogEntry.date],
                    comment = row[PlantLogEntry.comment],
                )
            })

        val actionsWithEntries = actions
            .map { it.copy(logEntries = entriesByPlant[it.plant.id] ?: emptyList()) }
            .sortedWith(compareBy({ it.type }, { it.plant.name }))

        WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, actionsWithEntries)
    }

    fun findDetails(gardenId: UUID, countryCode: String?): List<PlantDetail> = transaction {
        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId }
            .map { it[GardenPlantInstances.plantId] }
            .distinct()

        if (ids.isEmpty()) return@transaction emptyList()

        val plantRows = Plants.selectAll()
            .where { Plants.id inList ids }
            .associateBy { it[Plants.id] }

        val seedingByPlant    = batchResolvedMonthNums(SeedingMonths.plantId,    SeedingMonths.monthNum,    SeedingMonths.countryCode,    ids, countryCode)
        val harvestingByPlant = batchResolvedMonthNums(HarvestingMonths.plantId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, countryCode)

        val countriesByPlant = (PlantCountries innerJoin Countries)
            .selectAll()
            .where { PlantCountries.plantId inList ids }
            .groupBy({ it[PlantCountries.plantId] }, { Country(it[Countries.code], it[Countries.name]) })
            .mapValues { it.value.sortedBy { c -> c.name } }

        val companionsByPlant = CompanionPlants.selectAll()
            .where { (CompanionPlants.plantId inList ids) and (CompanionPlants.companionId inList ids) }
            .groupBy({ it[CompanionPlants.plantId] }, { row ->
                val companionRow = plantRows[row[CompanionPlants.companionId]]
                CompanionPlant(
                    id           = row[CompanionPlants.companionId],
                    name         = companionRow?.get(Plants.name) ?: "",
                    emoji        = companionRow?.get(Plants.emoji),
                    relationship = row[CompanionPlants.relationship],
                )
            })

        ids.mapNotNull { id ->
            val row = plantRows[id] ?: return@mapNotNull null
            PlantDetail(
                id               = row[Plants.id],
                name             = row[Plants.name],
                latinName        = row[Plants.latinName],
                category         = row[Plants.category],
                emoji            = row[Plants.emoji],
                imageUrl         = row[Plants.imageUrl],
                sunRequirement   = row[Plants.sunRequirement],
                pruningType      = null,
                pruningTip       = null,
                fertilizerType   = null,
                fertilizerTip    = null,
                sowingGuide      = SowingGuide(
                    method             = null,
                    seedDepthMm        = row[Plants.seedDepthMm],
                    spacingCm          = row[Plants.spacingCm],
                    germinationDaysMin = null,
                    germinationDaysMax = null,
                    daysToMaturityMin  = null,
                    daysToMaturityMax  = null,
                    frostTolerance     = null,
                ),
                heightMinCm      = row[Plants.heightMinCm]?.toInt(),
                heightMaxCm      = row[Plants.heightMaxCm]?.toInt(),
                seedingMonths    = seedingByPlant[id] ?: emptyList(),
                harvestingMonths = harvestingByPlant[id] ?: emptyList(),
                countries        = countriesByPlant[id] ?: emptyList(),
                companions       = companionsByPlant[id] ?: emptyList(),
                insects          = emptyList(),
            )
        }.sortedBy { it.name }
    }
}

package org.marnixrenne.kitchengarden.garden.infrastructure

import org.jetbrains.exposed.exceptions.ExposedSQLException
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.plants.domain.*
import org.marnixrenne.kitchengarden.plants.infrastructure.*
import org.marnixrenne.kitchengarden.user.domain.UserId
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
class ExposedGardenRepository : GardenRepository {

    // ── Garden CRUD ──────────────────────────────────────────────────────────

    override fun findGardens(userId: UserId): List<GardenSummary> = transaction {
        Garden.selectAll()
            .where { Garden.userId eq userId.value }
            .orderBy(Garden.createdAt)
            .map { GardenSummary(GardenId(it[Garden.id]), it[Garden.name]) }
    }

    override fun createGarden(userId: UserId, name: String): GardenSummary = transaction {
        val id = createGardenInTx(userId.value, name)
        GardenSummary(GardenId(id), name)
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

    override fun renameGarden(gardenId: GardenId, userId: UserId, name: String): Boolean = transaction {
        Garden.update({ (Garden.id eq gardenId.value) and (Garden.userId eq userId.value) }) {
            it[Garden.name] = name
        } > 0
    }

    override fun deleteGarden(gardenId: GardenId, userId: UserId): Boolean = transaction {
        val instanceIds = (GardenPlantInstances innerJoin Garden)
            .select(GardenPlantInstances.id)
            .where { (GardenPlantInstances.gardenId eq gardenId.value) and (Garden.userId eq userId.value) }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isNotEmpty()) {
            PlantLog.deleteWhere { PlantLog.instanceId inList instanceIds }
        }
        Garden.deleteWhere { (Garden.id eq gardenId.value) and (Garden.userId eq userId.value) } > 0
    }

    // ── Plant membership ─────────────────────────────────────────────────────

    override fun findPlantIds(gardenId: GardenId): Set<PlantId> = transaction {
        GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { PlantId(it[GardenPlantInstances.plantId]) }
            .toSet()
    }

    override fun add(gardenId: GardenId, plantId: PlantId) {
        try {
            transaction {
                GardenPlantInstances.insert {
                    it[GardenPlantInstances.id]        = UUID.randomUUID()
                    it[GardenPlantInstances.gardenId]  = gardenId.value
                    it[GardenPlantInstances.plantId]   = plantId.value
                    it[GardenPlantInstances.createdAt] = Instant.now()
                }
            }
        } catch (e: ExposedSQLException) {
            val msg = e.message.orEmpty().lowercase()
            if ("unique" !in msg && "duplicate" !in msg) throw e
        }
    }

    override fun remove(gardenId: GardenId, plantId: PlantId): Unit = transaction {
        GardenPlantInstances.deleteWhere {
            (GardenPlantInstances.gardenId eq gardenId.value) and (GardenPlantInstances.plantId eq plantId.value)
        }
    }

    override fun findInstances(gardenId: GardenId): List<PlantInstance> = transaction {
        GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .orderBy(GardenPlantInstances.createdAt)
            .map { PlantInstance(PlantInstanceId(it[GardenPlantInstances.id]), PlantId(it[GardenPlantInstances.plantId])) }
    }

    // ── Views ─────────────────────────────────────────────────────────────────

    override fun findSuggestions(gardenId: GardenId): PlantingSuggestions = transaction {
        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { it[GardenPlantInstances.plantId] }
            .distinct()

        if (ids.size < 2) return@transaction PlantingSuggestions(emptyList(), emptyList())

        val plants = Plants.selectAll()
            .where { Plants.id inList ids }
            .map { row ->
                Triple(
                    SimpleVeg(PlantId(row[Plants.id]), row[Plants.name], row[Plants.emoji]),
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
                val memberIds = members.map { it.third }.toSet()
                val goodPairs = goodPairIds
                    .filter { (a, b) -> a in memberIds && b in memberIds }
                    .mapNotNull { (a, b) ->
                        val va = vegById[PlantId(a)] ?: return@mapNotNull null
                        val vb = vegById[PlantId(b)] ?: return@mapNotNull null
                        VegPair(va, vb)
                    }
                SunGroup(sun, members.map { it.first }.sortedBy { it.name }, goodPairs)
            }

        val conflicts = badPairIds.mapNotNull { (a, b) ->
            val va = vegById[PlantId(a)] ?: return@mapNotNull null
            val vb = vegById[PlantId(b)] ?: return@mapNotNull null
            VegPair(va, vb)
        }

        PlantingSuggestions(sunGroups, conflicts)
    }

    override fun findWeekSummary(gardenId: GardenId, countryCode: String?): WeekSummary = transaction {
        val today     = LocalDate.now()
        val month     = today.monthValue
        val week      = today.get(WeekFields.ISO.weekOfWeekBasedYear())
        val weekStart = today.with(WeekFields.ISO.dayOfWeek(), 1)
        val weekEnd   = weekStart.plusDays(6)

        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
            .map { it[GardenPlantInstances.plantId] }
            .distinct()

        if (ids.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val seedingIds    = resolvedMonthIds(SeedingMonths.plantId,    SeedingMonths.monthNum,    SeedingMonths.countryCode,    ids, month, countryCode)
        val harvestingIds = resolvedMonthIds(HarvestingMonths.plantId, HarvestingMonths.monthNum, HarvestingMonths.countryCode, ids, month, countryCode)

        val activeIds = seedingIds + harvestingIds
        if (activeIds.isEmpty()) return@transaction WeekSummary(week, month, weekStart.dayOfMonth, weekStart.monthValue, weekEnd.dayOfMonth, weekEnd.monthValue, emptyList())

        val userId = Garden.selectAll()
            .where { Garden.id eq gardenId.value }
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
                    plant              = SimpleVeg(PlantId(id), row[Plants.name], row[Plants.emoji]),
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
            .groupBy({ PlantId(it[PlantLog.plantId]) }, { row ->
                LoggedEntry(
                    id      = PlantLogEntryId(row[PlantLogEntry.id]),
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

    override fun findDetails(gardenId: GardenId, countryCode: String?): List<PlantDetail> = transaction {
        val ids = GardenPlantInstances.selectAll()
            .where { GardenPlantInstances.gardenId eq gardenId.value }
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
                    id           = PlantId(row[CompanionPlants.companionId]),
                    name         = companionRow?.get(Plants.name) ?: "",
                    emoji        = companionRow?.get(Plants.emoji),
                    relationship = row[CompanionPlants.relationship],
                )
            })

        ids.mapNotNull { id ->
            val row = plantRows[id] ?: return@mapNotNull null
            PlantDetail(
                id               = PlantId(id),
                name             = row[Plants.name],
                latinName        = row[Plants.latinName],
                category         = row[Plants.category],
                emoji            = row[Plants.emoji],
                imageUrl         = row[Plants.imageUrl],
                sunRequirement   = row[Plants.sunRequirement],
                pruningType      = null,
                fertilizerType   = null,
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

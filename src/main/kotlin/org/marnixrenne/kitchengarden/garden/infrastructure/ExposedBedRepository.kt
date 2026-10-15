package org.marnixrenne.kitchengarden.garden.infrastructure

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.statements.UpdateBuilder
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.plants.domain.SunExposure
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Repository
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

internal fun ResultRow.toBed() = Bed(
    id          = BedId(this[GardenBeds.id]),
    name        = this[GardenBeds.name],
    type        = this[GardenBeds.bedType]?.let { BedType.from(it) },
    lengthCm    = this[GardenBeds.lengthCm],
    widthCm     = this[GardenBeds.widthCm],
    sunExposure = this[GardenBeds.sunExposure]?.let { SunExposure.from(it) },
    aspect      = this[GardenBeds.aspect]?.let { Aspect.from(it) },
)

internal fun ResultRow.toLoggedEntry() = LoggedEntry(
    id          = PlantLogEntryId(this[PlantLogEntry.id]),
    action      = LogAction.from(this[PlantLogEntry.action]),
    date        = this[PlantLogEntry.date],
    comment     = this[PlantLogEntry.comment],
    fromBedId   = this[PlantLogEntry.fromBedId]?.let { BedId(it) },
    toBedId     = this[PlantLogEntry.toBedId]?.let { BedId(it) },
    fromBedName = this[PlantLogEntry.fromBedName],
    toBedName   = this[PlantLogEntry.toBedName],
)

/** Inserts the bed every new garden starts with. Must run inside a transaction. */
internal fun insertInitialBed(gardenId: UUID) {
    GardenBeds.insert {
        it[GardenBeds.id]        = UUID.randomUUID()
        it[GardenBeds.gardenId]  = gardenId
        it[GardenBeds.createdAt] = Instant.now()
    }
}

@Repository
class ExposedBedRepository : BedRepository {

    override fun findAll(gardenId: GardenId): List<Bed> = transaction {
        GardenBeds.selectAll()
            .where { GardenBeds.gardenId eq gardenId.value }
            .orderBy(GardenBeds.createdAt to SortOrder.ASC, GardenBeds.id to SortOrder.ASC)
            .map { it.toBed() }
    }

    override fun find(gardenId: GardenId, bedId: BedId): Bed? = transaction {
        GardenBeds.selectAll()
            .where { (GardenBeds.id eq bedId.value) and (GardenBeds.gardenId eq gardenId.value) }
            .firstOrNull()?.toBed()
    }

    override fun create(gardenId: GardenId, request: BedRequest): Bed = transaction {
        val id = UUID.randomUUID()
        GardenBeds.insert {
            it[GardenBeds.id]        = id
            it[GardenBeds.gardenId]  = gardenId.value
            it[GardenBeds.createdAt] = Instant.now()
            it.setFields(request)
        }
        request.toBed(BedId(id))
    }

    override fun update(gardenId: GardenId, bedId: BedId, request: BedRequest): Bed? = transaction {
        val updated = GardenBeds.update({ (GardenBeds.id eq bedId.value) and (GardenBeds.gardenId eq gardenId.value) }) {
            it.setFields(request)
        }
        if (updated == 0) null else request.toBed(bedId)
    }

    private fun UpdateBuilder<*>.setFields(request: BedRequest) {
        this[GardenBeds.name]        = request.name
        this[GardenBeds.bedType]     = request.type?.key
        this[GardenBeds.lengthCm]    = request.lengthCm
        this[GardenBeds.widthCm]     = request.widthCm
        this[GardenBeds.sunExposure] = request.sunExposure?.key
        this[GardenBeds.aspect]      = request.aspect?.key
    }

    private fun BedRequest.toBed(id: BedId) = Bed(id, name, type, lengthCm, widthCm, sunExposure, aspect)

    override fun countInstances(bedId: BedId): Long = transaction {
        GardenPlantInstances.selectAll().where { GardenPlantInstances.bedId eq bedId.value }.count()
    }

    override fun findInstanceBed(gardenId: GardenId, instanceId: PlantInstanceId): BedId? = transaction {
        GardenPlantInstances.select(GardenPlantInstances.bedId)
            .where { (GardenPlantInstances.id eq instanceId.value) and (GardenPlantInstances.gardenId eq gardenId.value) }
            .firstOrNull()?.let { BedId(it[GardenPlantInstances.bedId]) }
    }

    override fun delete(bedId: BedId): Unit = transaction {
        GardenBeds.deleteWhere { GardenBeds.id eq bedId.value }
    }

    override fun deleteMovingPlants(userId: UserId, bedId: BedId, target: Bed, date: LocalDate): Unit = transaction {
        val instanceIds = GardenPlantInstances.select(GardenPlantInstances.id)
            .where { GardenPlantInstances.bedId eq bedId.value }
            .map { PlantInstanceId(it[GardenPlantInstances.id]) }
        instanceIds.forEach { moveInTx(userId, it, target, date, comment = null) }
        GardenBeds.deleteWhere { GardenBeds.id eq bedId.value }
    }

    override fun deleteWithPlants(bedId: BedId): Unit = transaction {
        val instanceIds = GardenPlantInstances.select(GardenPlantInstances.id)
            .where { GardenPlantInstances.bedId eq bedId.value }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isNotEmpty()) {
            // Entries and plan entries cascade from the log
            PlantLog.deleteWhere { PlantLog.instanceId inList instanceIds }
            GardenPlantInstances.deleteWhere { GardenPlantInstances.id inList instanceIds }
        }
        GardenBeds.deleteWhere { GardenBeds.id eq bedId.value }
    }

    override fun move(userId: UserId, instanceId: PlantInstanceId, target: Bed, date: LocalDate, comment: String?): LoggedEntry =
        transaction { moveInTx(userId, instanceId, target, date, comment) }

    private fun moveInTx(userId: UserId, instanceId: PlantInstanceId, target: Bed, date: LocalDate, comment: String?): LoggedEntry {
        val instance = GardenPlantInstances.select(GardenPlantInstances.plantId, GardenPlantInstances.bedId)
            .where { GardenPlantInstances.id eq instanceId.value }
            .single()
        val fromBedId = instance[GardenPlantInstances.bedId]
        val fromBedName = GardenBeds.select(GardenBeds.name)
            .where { GardenBeds.id eq fromBedId }
            .single()[GardenBeds.name]

        GardenPlantInstances.update({ GardenPlantInstances.id eq instanceId.value }) {
            it[GardenPlantInstances.bedId] = target.id.value
        }

        // A log created by a move has no lifecycle state; the first seeding or planting entry sets it
        val logId = PlantLog.select(PlantLog.id)
            .where { PlantLog.instanceId eq instanceId.value }
            .firstOrNull()?.get(PlantLog.id)
            ?: UUID.randomUUID().also { newLogId ->
                PlantLog.insert {
                    it[PlantLog.id]         = newLogId
                    it[PlantLog.userId]     = userId.value
                    it[PlantLog.plantId]    = instance[GardenPlantInstances.plantId]
                    it[PlantLog.instanceId] = instanceId.value
                    it[PlantLog.createdAt]  = Instant.now()
                }
            }

        val entry = LoggedEntry(
            id          = PlantLogEntryId(UUID.randomUUID()),
            action      = LogAction.MOVED,
            date        = date,
            comment     = comment,
            fromBedId   = BedId(fromBedId),
            toBedId     = target.id,
            fromBedName = fromBedName,
            toBedName   = target.name,
        )
        PlantLogEntry.insert {
            it[PlantLogEntry.id]          = entry.id.value
            it[PlantLogEntry.logId]       = logId
            it[PlantLogEntry.action]      = entry.action.key
            it[PlantLogEntry.date]        = date
            it[PlantLogEntry.comment]     = comment
            it[PlantLogEntry.fromBedId]   = fromBedId
            it[PlantLogEntry.toBedId]     = target.id.value
            it[PlantLogEntry.fromBedName] = fromBedName
            it[PlantLogEntry.toBedName]   = target.name
            it[PlantLogEntry.createdAt]   = Instant.now()
        }
        return entry
    }
}

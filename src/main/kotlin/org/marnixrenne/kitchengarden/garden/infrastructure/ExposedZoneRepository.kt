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

internal fun ResultRow.toZone() = Zone(
    id          = ZoneId(this[GardenZones.id]),
    name        = this[GardenZones.name],
    type        = this[GardenZones.zoneType]?.let { ZoneType.from(it) },
    lengthCm    = this[GardenZones.lengthCm],
    widthCm     = this[GardenZones.widthCm],
    sunExposure = this[GardenZones.sunExposure]?.let { SunExposure.from(it) },
    aspect      = this[GardenZones.aspect]?.let { Aspect.from(it) },
)

internal fun ResultRow.toLoggedEntry() = LoggedEntry(
    id          = PlantLogEntryId(this[PlantLogEntry.id]),
    action      = LogAction.from(this[PlantLogEntry.action]),
    date        = this[PlantLogEntry.date],
    comment     = this[PlantLogEntry.comment],
    fromZoneId  = this[PlantLogEntry.fromZoneId]?.let { ZoneId(it) },
    toZoneId    = this[PlantLogEntry.toZoneId]?.let { ZoneId(it) },
    fromZoneName = this[PlantLogEntry.fromZoneName],
    toZoneName  = this[PlantLogEntry.toZoneName],
)

/** Inserts the zone every new garden starts with. Must run inside a transaction. */
internal fun insertInitialZone(gardenId: UUID) {
    GardenZones.insert {
        it[GardenZones.id]        = UUID.randomUUID()
        it[GardenZones.gardenId]  = gardenId
        it[GardenZones.createdAt] = Instant.now()
    }
}

@Repository
class ExposedZoneRepository : ZoneRepository {

    override fun findAll(gardenId: GardenId): List<Zone> = transaction {
        GardenZones.selectAll()
            .where { GardenZones.gardenId eq gardenId.value }
            .orderBy(GardenZones.createdAt to SortOrder.ASC, GardenZones.id to SortOrder.ASC)
            .map { it.toZone() }
    }

    override fun find(gardenId: GardenId, zoneId: ZoneId): Zone? = transaction {
        GardenZones.selectAll()
            .where { (GardenZones.id eq zoneId.value) and (GardenZones.gardenId eq gardenId.value) }
            .firstOrNull()?.toZone()
    }

    override fun create(gardenId: GardenId, request: ZoneRequest): Zone = transaction {
        val id = UUID.randomUUID()
        GardenZones.insert {
            it[GardenZones.id]        = id
            it[GardenZones.gardenId]  = gardenId.value
            it[GardenZones.createdAt] = Instant.now()
            it.setFields(request)
        }
        request.toZone(ZoneId(id))
    }

    override fun update(gardenId: GardenId, zoneId: ZoneId, request: ZoneRequest): Zone? = transaction {
        val updated = GardenZones.update({ (GardenZones.id eq zoneId.value) and (GardenZones.gardenId eq gardenId.value) }) {
            it.setFields(request)
        }
        if (updated == 0) null else request.toZone(zoneId)
    }

    private fun UpdateBuilder<*>.setFields(request: ZoneRequest) {
        this[GardenZones.name]        = request.name
        this[GardenZones.zoneType]     = request.type?.key
        this[GardenZones.lengthCm]    = request.lengthCm
        this[GardenZones.widthCm]     = request.widthCm
        this[GardenZones.sunExposure] = request.sunExposure?.key
        this[GardenZones.aspect]      = request.aspect?.key
    }

    private fun ZoneRequest.toZone(id: ZoneId) = Zone(id, name, type, lengthCm, widthCm, sunExposure, aspect)

    override fun countInstances(zoneId: ZoneId): Long = transaction {
        GardenPlantInstances.selectAll().where { GardenPlantInstances.zoneId eq zoneId.value }.count()
    }

    override fun findInstanceZone(gardenId: GardenId, instanceId: PlantInstanceId): ZoneId? = transaction {
        GardenPlantInstances.select(GardenPlantInstances.zoneId)
            .where { (GardenPlantInstances.id eq instanceId.value) and (GardenPlantInstances.gardenId eq gardenId.value) }
            .firstOrNull()?.let { ZoneId(it[GardenPlantInstances.zoneId]) }
    }

    override fun delete(zoneId: ZoneId): Unit = transaction {
        GardenZones.deleteWhere { GardenZones.id eq zoneId.value }
    }

    override fun deleteMovingPlants(userId: UserId, zoneId: ZoneId, target: Zone, date: LocalDate): Unit = transaction {
        val instanceIds = GardenPlantInstances.select(GardenPlantInstances.id)
            .where { GardenPlantInstances.zoneId eq zoneId.value }
            .map { PlantInstanceId(it[GardenPlantInstances.id]) }
        instanceIds.forEach { moveInTx(userId, it, target, date, comment = null) }
        GardenZones.deleteWhere { GardenZones.id eq zoneId.value }
    }

    override fun deleteWithPlants(zoneId: ZoneId): Unit = transaction {
        val instanceIds = GardenPlantInstances.select(GardenPlantInstances.id)
            .where { GardenPlantInstances.zoneId eq zoneId.value }
            .map { it[GardenPlantInstances.id] }
        if (instanceIds.isNotEmpty()) {
            // Entries and plan entries cascade from the log
            PlantLog.deleteWhere { PlantLog.instanceId inList instanceIds }
            GardenPlantInstances.deleteWhere { GardenPlantInstances.id inList instanceIds }
        }
        GardenZones.deleteWhere { GardenZones.id eq zoneId.value }
    }

    override fun move(userId: UserId, instanceId: PlantInstanceId, target: Zone, date: LocalDate, comment: String?): LoggedEntry =
        transaction { moveInTx(userId, instanceId, target, date, comment) }

    private fun moveInTx(userId: UserId, instanceId: PlantInstanceId, target: Zone, date: LocalDate, comment: String?): LoggedEntry {
        val instance = GardenPlantInstances.select(GardenPlantInstances.plantId, GardenPlantInstances.zoneId)
            .where { GardenPlantInstances.id eq instanceId.value }
            .single()
        val fromZoneId = instance[GardenPlantInstances.zoneId]
        val fromZoneName = GardenZones.select(GardenZones.name)
            .where { GardenZones.id eq fromZoneId }
            .single()[GardenZones.name]

        GardenPlantInstances.update({ GardenPlantInstances.id eq instanceId.value }) {
            it[GardenPlantInstances.zoneId] = target.id.value
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
            fromZoneId  = ZoneId(fromZoneId),
            toZoneId    = target.id,
            fromZoneName = fromZoneName,
            toZoneName  = target.name,
        )
        PlantLogEntry.insert {
            it[PlantLogEntry.id]          = entry.id.value
            it[PlantLogEntry.logId]       = logId
            it[PlantLogEntry.action]      = entry.action.key
            it[PlantLogEntry.date]        = date
            it[PlantLogEntry.comment]     = comment
            it[PlantLogEntry.fromZoneId]   = fromZoneId
            it[PlantLogEntry.toZoneId]     = target.id.value
            it[PlantLogEntry.fromZoneName] = fromZoneName
            it[PlantLogEntry.toZoneName]   = target.name
            it[PlantLogEntry.createdAt]   = Instant.now()
        }
        return entry
    }
}

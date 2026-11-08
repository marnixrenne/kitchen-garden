package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.user.domain.UserId
import java.time.LocalDate

interface ZoneRepository {
    fun findAll(gardenId: GardenId): List<Zone>
    fun find(gardenId: GardenId, zoneId: ZoneId): Zone?
    fun create(gardenId: GardenId, request: ZoneRequest): Zone
    fun update(gardenId: GardenId, zoneId: ZoneId, request: ZoneRequest): Zone?
    fun countInstances(zoneId: ZoneId): Long
    fun findInstanceZone(gardenId: GardenId, instanceId: PlantInstanceId): ZoneId?

    /** Deletes an empty zone. */
    fun delete(zoneId: ZoneId)

    /** Moves every instance in [zoneId] to [target], logging each move on [date], then deletes the zone. */
    fun deleteMovingPlants(userId: UserId, zoneId: ZoneId, target: Zone, date: LocalDate)

    /** Deletes the zone together with its instances, their logs and their plans. */
    fun deleteWithPlants(zoneId: ZoneId)

    fun move(userId: UserId, instanceId: PlantInstanceId, target: Zone, date: LocalDate, comment: String?): LoggedEntry
}

package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.user.domain.UserId
import java.time.LocalDate

interface BedRepository {
    fun findAll(gardenId: GardenId): List<Bed>
    fun find(gardenId: GardenId, bedId: BedId): Bed?
    fun create(gardenId: GardenId, request: BedRequest): Bed
    fun update(gardenId: GardenId, bedId: BedId, request: BedRequest): Bed?
    fun countInstances(bedId: BedId): Long
    fun findInstanceBed(gardenId: GardenId, instanceId: PlantInstanceId): BedId?

    /** Deletes an empty bed. */
    fun delete(bedId: BedId)

    /** Moves every instance in [bedId] to [target], logging each move on [date], then deletes the bed. */
    fun deleteMovingPlants(userId: UserId, bedId: BedId, target: Bed, date: LocalDate)

    /** Deletes the bed together with its instances, their logs and their plans. */
    fun deleteWithPlants(bedId: BedId)

    fun move(userId: UserId, instanceId: PlantInstanceId, target: Bed, date: LocalDate, comment: String?): LoggedEntry
}

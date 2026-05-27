package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import java.util.UUID

interface GardenRepository {
    fun findGardens(userId: UUID): List<GardenSummary>
    fun createGarden(userId: UUID, name: String): GardenSummary
    fun renameGarden(gardenId: UUID, userId: UUID, name: String): Boolean
    fun deleteGarden(gardenId: UUID, userId: UUID): Boolean
    fun findPlantIds(gardenId: UUID): Set<UUID>
    fun add(gardenId: UUID, plantId: UUID)
    fun remove(gardenId: UUID, plantId: UUID)
    fun findInstances(gardenId: UUID): List<PlantInstance>
    fun findSuggestions(gardenId: UUID): PlantingSuggestions
    fun findWeekSummary(gardenId: UUID, countryCode: String?): WeekSummary
    fun findDetails(gardenId: UUID, countryCode: String?): List<PlantDetail>
}

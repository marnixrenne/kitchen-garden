package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId

interface GardenRepository {
    fun findGardens(userId: UserId): List<GardenSummary>
    fun createGarden(userId: UserId, name: String): GardenSummary
    fun renameGarden(gardenId: GardenId, userId: UserId, name: String): Boolean
    fun deleteGarden(gardenId: GardenId, userId: UserId): Boolean
    fun findPlantIds(gardenId: GardenId): Set<PlantId>
    fun add(gardenId: GardenId, plantId: PlantId)
    fun remove(gardenId: GardenId, plantId: PlantId)
    fun findInstances(gardenId: GardenId): List<PlantInstance>
    fun findSuggestions(gardenId: GardenId): PlantingSuggestions
    fun findWeekSummary(gardenId: GardenId, countryCode: String?): WeekSummary
    fun findDetails(gardenId: GardenId, countryCode: String?): List<PlantDetail>
}

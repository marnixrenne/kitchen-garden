package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId

interface GardenRepository {
    fun findGardens(userId: UserId): List<GardenSummary>
    fun createGarden(userId: UserId, name: String): GardenSummary
    fun renameGarden(gardenId: GardenId, userId: UserId, name: String): GardenSummary?
    fun deleteGarden(gardenId: GardenId, userId: UserId): Boolean
    fun findPlantIds(gardenId: GardenId): Set<PlantId>
    /** Null when the Plant doesn't exist. */
    fun add(gardenId: GardenId, plantId: PlantId, zoneId: ZoneId): PlantInstanceId?
    fun removeInstance(gardenId: GardenId, instanceId: PlantInstanceId): Boolean
    fun findRecommendationCandidates(countryCode: String?): List<RecommendationCandidate>
    /** Companion relationships with at least one side in [plantIds]. */
    fun findCompanionLinks(plantIds: Set<PlantId>): List<CompanionLink>
    fun findInstances(gardenId: GardenId): List<PlantInstance>
    fun findSuggestions(gardenId: GardenId): PlantingSuggestions
    fun findWeekSummary(userId: UserId, gardenId: GardenId, countryCode: String?): WeekSummary
    fun findDetails(gardenId: GardenId, countryCode: String?): List<PlantDetail>
}

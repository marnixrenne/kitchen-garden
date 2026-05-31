package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.plan.application.PlantPlanQueryService
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.preferences.application.PreferenceApplicationService
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class GardenQueryService(
    private val repository: GardenRepository,
    private val plantLogRepository: PlantLogRepository,
    private val plantPlanQueryService: PlantPlanQueryService,
    private val preferenceService: PreferenceApplicationService,
    private val userResolver: UserResolver,
    private val accessGuard: GardenAccessGuard,
) {

    fun listGardens(authentication: Authentication): List<GardenSummary> =
        repository.findGardens(userResolver.resolve(authentication))

    fun getPlantIds(authentication: Authentication, gardenId: GardenId): Set<PlantId> =
        repository.findPlantIds(accessGuard.validate(authentication, gardenId))

    fun getDetails(authentication: Authentication, gardenId: GardenId): List<PlantDetail> =
        repository.findDetails(accessGuard.validate(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getWeekSummary(authentication: Authentication, gardenId: GardenId): WeekSummary =
        repository.findWeekSummary(userResolver.resolve(authentication), accessGuard.validate(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getSuggestions(authentication: Authentication, gardenId: GardenId): PlantingSuggestions =
        repository.findSuggestions(accessGuard.validate(authentication, gardenId))

    fun getInstances(authentication: Authentication, gardenId: GardenId): List<PlantInstance> =
        repository.findInstances(accessGuard.validate(authentication, gardenId))

    fun getPlantLog(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, List<LoggedEntry>> =
        plantLogRepository.findAllByUser(userResolver.resolve(authentication), accessGuard.validate(authentication, gardenId))

    fun getPlan(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>> =
        plantPlanQueryService.findByUser(userResolver.resolve(authentication), accessGuard.validate(authentication, gardenId))
}

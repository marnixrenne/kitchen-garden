package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.plan.application.PlantPlanApplicationService
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.preferences.application.PreferenceApplicationService
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException

@Service
class GardenApplicationService(
    private val repository: GardenRepository,
    private val plantLogRepository: PlantLogRepository,
    private val plantPlanService: PlantPlanApplicationService,
    private val preferenceService: PreferenceApplicationService,
    private val userResolver: UserResolver,
) {

    private fun validateGarden(authentication: Authentication, gardenId: GardenId): GardenId {
        val userId = userResolver.resolve(authentication)
        if (repository.findGardens(userId).none { it.id == gardenId })
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        return gardenId
    }

    // ── Garden management ─────────────────────────────────────────────────────

    fun listGardens(authentication: Authentication): List<GardenSummary> =
        repository.findGardens(userResolver.resolve(authentication))

    fun createGarden(authentication: Authentication, name: String): GardenSummary {
        if (name.isBlank()) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name cannot be blank")
        if (name.length > 100) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name must be at most 100 characters")
        return repository.createGarden(userResolver.resolve(authentication), name)
    }

    fun renameGarden(authentication: Authentication, gardenId: GardenId, name: String) {
        if (name.isBlank()) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name cannot be blank")
        if (name.length > 100) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name must be at most 100 characters")
        val renamed = repository.renameGarden(gardenId, userResolver.resolve(authentication), name)
        if (!renamed) throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun deleteGarden(authentication: Authentication, gardenId: GardenId) {
        val deleted = repository.deleteGarden(gardenId, userResolver.resolve(authentication))
        if (!deleted) throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    // ── Plant operations ──────────────────────────────────────────────────────

    fun getPlantIds(authentication: Authentication, gardenId: GardenId): Set<PlantId> =
        repository.findPlantIds(validateGarden(authentication, gardenId))

    fun getDetails(authentication: Authentication, gardenId: GardenId): List<PlantDetail> =
        repository.findDetails(validateGarden(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getWeekSummary(authentication: Authentication, gardenId: GardenId): WeekSummary =
        repository.findWeekSummary(validateGarden(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getSuggestions(authentication: Authentication, gardenId: GardenId): PlantingSuggestions =
        repository.findSuggestions(validateGarden(authentication, gardenId))

    fun add(authentication: Authentication, gardenId: GardenId, plantId: PlantId) =
        repository.add(validateGarden(authentication, gardenId), plantId)

    fun remove(authentication: Authentication, gardenId: GardenId, plantId: PlantId) =
        repository.remove(validateGarden(authentication, gardenId), plantId)

    fun getInstances(authentication: Authentication, gardenId: GardenId): List<PlantInstance> =
        repository.findInstances(validateGarden(authentication, gardenId))

    fun logAction(authentication: Authentication, request: PlantLogRequest): PlantLogResponse {
        val entry = plantLogRepository.save(userResolver.resolve(authentication), request)
        if (request.action in setOf("seeding_indoor", "seeding_direct", "planting")) {
            try {
                plantPlanService.generateAndSave(entry.id, entry.plantId, request.date)
            } catch (e: Exception) {
                plantLogRepository.deleteEntry(entry.id)
                throw e
            }
        }
        return entry
    }

    fun getPlantLog(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, List<LoggedEntry>> =
        plantLogRepository.findAllByUser(userResolver.resolve(authentication), validateGarden(authentication, gardenId))

    fun getPlan(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>> =
        plantPlanService.findByUser(userResolver.resolve(authentication), validateGarden(authentication, gardenId))
}

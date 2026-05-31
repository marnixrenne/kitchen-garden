package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.plan.application.PlantPlanCommandService
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException

@Service
class GardenCommandService(
    private val repository: GardenRepository,
    private val plantLogRepository: PlantLogRepository,
    private val plantPlanCommandService: PlantPlanCommandService,
    private val userResolver: UserResolver,
    private val accessGuard: GardenAccessGuard,
) {

    fun createGarden(authentication: Authentication, name: String): GardenSummary {
        if (name.isBlank()) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name cannot be blank")
        if (name.length > 100) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name must be at most 100 characters")
        return repository.createGarden(userResolver.resolve(authentication), name)
    }

    fun renameGarden(authentication: Authentication, gardenId: GardenId, name: String): GardenSummary {
        if (name.isBlank()) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name cannot be blank")
        if (name.length > 100) throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden name must be at most 100 characters")
        return repository.renameGarden(gardenId, userResolver.resolve(authentication), name)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun deleteGarden(authentication: Authentication, gardenId: GardenId) {
        val deleted = repository.deleteGarden(gardenId, userResolver.resolve(authentication))
        if (!deleted) throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun add(authentication: Authentication, gardenId: GardenId, plantId: PlantId) =
        repository.add(accessGuard.validate(authentication, gardenId), plantId)

    fun remove(authentication: Authentication, gardenId: GardenId, plantId: PlantId) =
        repository.remove(accessGuard.validate(authentication, gardenId), plantId)

    fun logAction(authentication: Authentication, gardenId: GardenId, request: PlantLogRequest): PlantLogResponse {
        accessGuard.validate(authentication, gardenId)
        val entry = plantLogRepository.save(userResolver.resolve(authentication), gardenId, request)
        if (request.action in setOf(LogAction.SEEDING_INDOOR, LogAction.SEEDING_OUTDOOR, LogAction.PLANTING)) {
            try {
                plantPlanCommandService.generateAndSave(entry.id, entry.plantId, request.date)
            } catch (e: Exception) {
                plantLogRepository.deleteEntry(entry.id)
                throw e
            }
        }
        return entry
    }
}

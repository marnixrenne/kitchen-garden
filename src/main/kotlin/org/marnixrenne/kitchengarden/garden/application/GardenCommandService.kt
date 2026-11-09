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
    private val zoneRepository: ZoneRepository,
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

    fun add(authentication: Authentication, gardenId: GardenId, plantId: PlantId, zoneId: ZoneId?): PlantInstance {
        accessGuard.validate(authentication, gardenId)
        val zone = if (zoneId != null) {
            zoneRepository.find(gardenId, zoneId) ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Zone is not in this garden")
        } else {
            // Only a garden with a single zone can place a plant without being told where
            zoneRepository.findAll(gardenId).singleOrNull()
                ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden has several zones; choose one")
        }
        val instanceId = repository.add(gardenId, plantId, zone.id) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        return repository.findInstances(gardenId).first { it.id == instanceId }
    }

    fun removeInstance(authentication: Authentication, gardenId: GardenId, instanceId: PlantInstanceId) {
        val removed = repository.removeInstance(accessGuard.validate(authentication, gardenId), instanceId)
        if (!removed) throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun logAction(authentication: Authentication, gardenId: GardenId, request: PlantLogRequest): PlantLogResponse {
        accessGuard.validate(authentication, gardenId)
        if (request.action == LogAction.MOVED)
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Moves are recorded by moving the plant to another zone")
        val entry = plantLogRepository.save(userResolver.resolve(authentication), gardenId, request.copy(comment = validatedComment(request.comment)))
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
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

    fun updateLogEntry(authentication: Authentication, gardenId: GardenId, entryId: PlantLogEntryId, request: LogEntryUpdateRequest): LoggedEntry {
        accessGuard.validate(authentication, gardenId)
        val entry = plantLogRepository.findEntry(gardenId, entryId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        // Other entries drive generated plans, which a date change would leave stale
        if (entry.action != LogAction.MOVED)
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Only move entries can be edited")
        val comment = validatedComment(request.comment)
        plantLogRepository.updateEntry(entryId, request.copy(comment = comment))
        return entry.copy(date = request.date, comment = comment)
    }
}

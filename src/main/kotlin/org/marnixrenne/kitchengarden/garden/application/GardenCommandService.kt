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
    private val bedRepository: BedRepository,
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

    fun add(authentication: Authentication, gardenId: GardenId, plantId: PlantId, bedId: BedId?) {
        accessGuard.validate(authentication, gardenId)
        val bed = if (bedId != null) {
            bedRepository.find(gardenId, bedId) ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Bed is not in this garden")
        } else {
            // Only a garden with a single bed can place a plant without being told where
            bedRepository.findAll(gardenId).singleOrNull()
                ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Garden has several beds; choose one")
        }
        repository.add(gardenId, plantId, bed.id)
    }

    fun remove(authentication: Authentication, gardenId: GardenId, plantId: PlantId) =
        repository.remove(accessGuard.validate(authentication, gardenId), plantId)

    fun logAction(authentication: Authentication, gardenId: GardenId, request: PlantLogRequest): PlantLogResponse {
        accessGuard.validate(authentication, gardenId)
        if (request.action == LogAction.MOVED)
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Moves are recorded by moving the plant to another bed")
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

    fun updateLogEntry(authentication: Authentication, gardenId: GardenId, entryId: PlantLogEntryId, request: LogEntryUpdateRequest): LoggedEntry {
        accessGuard.validate(authentication, gardenId)
        val entry = plantLogRepository.findEntry(gardenId, entryId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        // Other entries drive generated plans, which a date change would leave stale
        if (entry.action != LogAction.MOVED)
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Only move entries can be edited")
        val comment = request.comment?.takeIf { it.isNotBlank() }
        plantLogRepository.updateEntry(entryId, request.copy(comment = comment))
        return entry.copy(date = request.date, comment = comment)
    }
}

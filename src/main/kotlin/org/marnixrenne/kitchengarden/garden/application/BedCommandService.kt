package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.time.LocalDate

private const val MAX_DIMENSION_CM = 10_000

@Service
class BedCommandService(
    private val repository: BedRepository,
    private val userResolver: UserResolver,
    private val accessGuard: GardenAccessGuard,
) {

    fun create(authentication: Authentication, gardenId: GardenId, request: BedRequest): Bed {
        accessGuard.validate(authentication, gardenId)
        if (request.name.isNullOrBlank()) throw badRequest("Bed name cannot be blank")
        return repository.create(gardenId, validated(request))
    }

    fun update(authentication: Authentication, gardenId: GardenId, bedId: BedId, request: BedRequest): Bed {
        accessGuard.validate(authentication, gardenId)
        val existing = repository.find(gardenId, bedId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        // Only the unnamed bed a garden starts with may stay unnamed; once named, a bed keeps a name
        if (request.name.isNullOrBlank() && existing.name != null) throw badRequest("Bed name cannot be blank")
        return repository.update(gardenId, bedId, validated(request)) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun delete(
        authentication: Authentication,
        gardenId: GardenId,
        bedId: BedId,
        disposition: BedPlantsDisposition?,
        targetBedId: BedId?,
    ) {
        accessGuard.validate(authentication, gardenId)
        repository.find(gardenId, bedId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        if (repository.findAll(gardenId).size <= 1)
            throw ResponseStatusException(HttpStatus.CONFLICT, "A garden must keep at least one bed")
        if (repository.countInstances(bedId) == 0L) return repository.delete(bedId)

        when (disposition) {
            null -> throw ResponseStatusException(HttpStatus.CONFLICT, "Bed has plants; choose whether to move or delete them")
            BedPlantsDisposition.DELETE -> repository.deleteWithPlants(bedId)
            BedPlantsDisposition.MOVE -> {
                val target = targetBedId?.takeIf { it != bedId }?.let { repository.find(gardenId, it) }
                    ?: throw badRequest("Moving plants needs another bed in this garden as target")
                repository.deleteMovingPlants(userResolver.resolve(authentication), bedId, target, LocalDate.now())
            }
        }
    }

    fun move(authentication: Authentication, gardenId: GardenId, instanceId: PlantInstanceId, request: MoveRequest): LoggedEntry {
        accessGuard.validate(authentication, gardenId)
        val currentBedId = repository.findInstanceBed(gardenId, instanceId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        val target = repository.find(gardenId, request.bedId) ?: throw badRequest("Target bed is not in this garden")
        if (target.id == currentBedId) throw badRequest("Plant is already in this bed")
        val comment = request.comment?.takeIf { it.isNotBlank() }
        return repository.move(userResolver.resolve(authentication), instanceId, target, request.date ?: LocalDate.now(), comment)
    }

    private fun validated(request: BedRequest): BedRequest {
        val name = request.name?.trim()?.takeIf { it.isNotEmpty() }
        if (name != null && name.length > 100) throw badRequest("Bed name must be at most 100 characters")
        for (dimension in listOfNotNull(request.lengthCm, request.widthCm)) {
            if (dimension !in 1..MAX_DIMENSION_CM) throw badRequest("Bed dimensions must be between 1 and $MAX_DIMENSION_CM cm")
        }
        return request.copy(name = name)
    }

    private fun badRequest(reason: String) = ResponseStatusException(HttpStatus.BAD_REQUEST, reason)
}

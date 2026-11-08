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
class ZoneCommandService(
    private val repository: ZoneRepository,
    private val userResolver: UserResolver,
    private val accessGuard: GardenAccessGuard,
) {

    fun create(authentication: Authentication, gardenId: GardenId, request: ZoneRequest): Zone {
        accessGuard.validate(authentication, gardenId)
        if (request.name.isNullOrBlank()) throw badRequest("Zone name cannot be blank")
        return repository.create(gardenId, validated(request))
    }

    fun update(authentication: Authentication, gardenId: GardenId, zoneId: ZoneId, request: ZoneRequest): Zone {
        accessGuard.validate(authentication, gardenId)
        val existing = repository.find(gardenId, zoneId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        // Only the unnamed zone a garden starts with may stay unnamed; once named, a zone keeps a name
        if (request.name.isNullOrBlank() && existing.name != null) throw badRequest("Zone name cannot be blank")
        return repository.update(gardenId, zoneId, validated(request)) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    fun delete(
        authentication: Authentication,
        gardenId: GardenId,
        zoneId: ZoneId,
        disposition: ZonePlantsDisposition?,
        targetZoneId: ZoneId?,
    ) {
        accessGuard.validate(authentication, gardenId)
        repository.find(gardenId, zoneId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        if (repository.findAll(gardenId).size <= 1)
            throw ResponseStatusException(HttpStatus.CONFLICT, "A garden must keep at least one zone")
        if (repository.countInstances(zoneId) == 0L) return repository.delete(zoneId)

        when (disposition) {
            null -> throw ResponseStatusException(HttpStatus.CONFLICT, "Zone has plants; choose whether to move or delete them")
            ZonePlantsDisposition.DELETE -> repository.deleteWithPlants(zoneId)
            ZonePlantsDisposition.MOVE -> {
                val target = targetZoneId?.takeIf { it != zoneId }?.let { repository.find(gardenId, it) }
                    ?: throw badRequest("Moving plants needs another zone in this garden as target")
                repository.deleteMovingPlants(userResolver.resolve(authentication), zoneId, target, LocalDate.now())
            }
        }
    }

    fun move(authentication: Authentication, gardenId: GardenId, instanceId: PlantInstanceId, request: MoveRequest): LoggedEntry {
        accessGuard.validate(authentication, gardenId)
        val currentZoneId = repository.findInstanceZone(gardenId, instanceId) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        val target = repository.find(gardenId, request.zoneId) ?: throw badRequest("Target zone is not in this garden")
        if (target.id == currentZoneId) throw badRequest("Plant is already in this zone")
        val comment = request.comment?.takeIf { it.isNotBlank() }
        return repository.move(userResolver.resolve(authentication), instanceId, target, request.date ?: LocalDate.now(), comment)
    }

    private fun validated(request: ZoneRequest): ZoneRequest {
        val name = request.name?.trim()?.takeIf { it.isNotEmpty() }
        if (name != null && name.length > 100) throw badRequest("Zone name must be at most 100 characters")
        for (dimension in listOfNotNull(request.lengthCm, request.widthCm)) {
            if (dimension !in 1..MAX_DIMENSION_CM) throw badRequest("Zone dimensions must be between 1 and $MAX_DIMENSION_CM cm")
        }
        return request.copy(name = name)
    }

    private fun badRequest(reason: String) = ResponseStatusException(HttpStatus.BAD_REQUEST, reason)
}

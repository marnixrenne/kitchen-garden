package org.marnixrenne.kitchengarden.garden

import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.util.UUID

@Service
class PlantLifecycleService(
    private val repository: PlantLifecycleRepository,
    private val gardenService: GardenService,
) {

    fun getAll(authentication: Authentication): Map<UUID, PlantLifecycle> =
        repository.findAllByUser(gardenService.resolveUserId(authentication))

    fun advance(authentication: Authentication, instanceId: UUID): PlantLifecycle =
        repository.advance(gardenService.resolveUserId(authentication), instanceId)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
}

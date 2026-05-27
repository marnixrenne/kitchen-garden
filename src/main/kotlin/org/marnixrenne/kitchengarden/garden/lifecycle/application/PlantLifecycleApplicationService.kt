package org.marnixrenne.kitchengarden.garden.lifecycle.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.AdvanceRequest
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycle
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycleRepository
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException

@Service
class PlantLifecycleApplicationService(
    private val repository: PlantLifecycleRepository,
    private val userResolver: UserResolver,
) {

    fun getAll(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, PlantLifecycle> =
        repository.findAllByUser(userResolver.resolve(authentication), gardenId)

    fun advance(authentication: Authentication, instanceId: PlantInstanceId, request: AdvanceRequest?): PlantLifecycle =
        repository.advance(userResolver.resolve(authentication), instanceId, request)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
}

package org.marnixrenne.kitchengarden.garden.lifecycle.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycle
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycleRepository
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class PlantLifecycleQueryService(
    private val repository: PlantLifecycleRepository,
    private val userResolver: UserResolver,
) {
    fun getAll(authentication: Authentication, gardenId: GardenId): Map<PlantInstanceId, PlantLifecycle> =
        repository.findAllByUser(userResolver.resolve(authentication), gardenId)
}

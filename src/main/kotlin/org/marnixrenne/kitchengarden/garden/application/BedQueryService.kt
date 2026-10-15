package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.Bed
import org.marnixrenne.kitchengarden.garden.domain.BedRepository
import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class BedQueryService(
    private val repository: BedRepository,
    private val accessGuard: GardenAccessGuard,
) {
    fun list(authentication: Authentication, gardenId: GardenId): List<Bed> =
        repository.findAll(accessGuard.validate(authentication, gardenId))
}

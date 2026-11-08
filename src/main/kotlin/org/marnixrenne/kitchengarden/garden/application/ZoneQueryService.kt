package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.Zone
import org.marnixrenne.kitchengarden.garden.domain.ZoneRepository
import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class ZoneQueryService(
    private val repository: ZoneRepository,
    private val accessGuard: GardenAccessGuard,
) {
    fun list(authentication: Authentication, gardenId: GardenId): List<Zone> =
        repository.findAll(accessGuard.validate(authentication, gardenId))
}

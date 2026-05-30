package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.GardenRepository
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component
import org.springframework.web.server.ResponseStatusException

@Component
class GardenAccessGuard(
    private val repository: GardenRepository,
    private val userResolver: UserResolver,
) {
    fun validate(authentication: Authentication, gardenId: GardenId): GardenId {
        val userId = userResolver.resolve(authentication)
        if (repository.findGardens(userId).none { it.id == gardenId })
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        return gardenId
    }
}

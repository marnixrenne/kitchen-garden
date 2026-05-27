package org.marnixrenne.kitchengarden.user.application

import org.marnixrenne.kitchengarden.security.AppUserDetails
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.marnixrenne.kitchengarden.user.domain.UserRepository
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component

@Component
class UserResolver(private val userRepository: UserRepository) {

    fun resolve(authentication: Authentication): UserId {
        val principal = authentication.principal
        if (principal is AppUserDetails) return UserId(principal.userId)
        return userRepository.findIdByUsername(authentication.name)
            ?: error("Authenticated user not found in database")
    }
}

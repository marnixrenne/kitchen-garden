package org.marnixrenne.kitchengarden.user.application

import org.marnixrenne.kitchengarden.security.AppUserDetails
import org.marnixrenne.kitchengarden.user.domain.UserRepository
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component
import java.util.UUID

@Component
class UserResolver(private val userRepository: UserRepository) {

    fun resolve(authentication: Authentication): UUID {
        val principal = authentication.principal
        if (principal is AppUserDetails) return principal.userId
        return userRepository.findIdByUsername(authentication.name)
            ?: error("Authenticated user not found in database")
    }
}

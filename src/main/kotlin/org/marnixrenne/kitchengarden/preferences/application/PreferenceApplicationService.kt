package org.marnixrenne.kitchengarden.preferences.application

import org.marnixrenne.kitchengarden.preferences.domain.PreferenceRepository
import org.marnixrenne.kitchengarden.user.application.UserResolver
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class PreferenceApplicationService(
    private val repository: PreferenceRepository,
    private val userResolver: UserResolver,
) {

    fun getAll(authentication: Authentication): Map<String, String> =
        repository.findAll(userResolver.resolve(authentication))

    fun getCountry(authentication: Authentication?): String? =
        if (authentication == null) null else getAll(authentication)["country"]

    fun set(authentication: Authentication, key: String, value: String) =
        repository.set(userResolver.resolve(authentication), key, value)

    fun delete(authentication: Authentication, key: String) =
        repository.delete(userResolver.resolve(authentication), key)
}

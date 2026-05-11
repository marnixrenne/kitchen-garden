package org.marnixrenne.kitchengarden.preferences

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.security.Users
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class PreferenceService(private val repository: PreferenceRepository) {

    private fun resolveUserId(authentication: Authentication): UUID = transaction {
        Users.selectAll()
            .where { Users.username eq authentication.name }
            .map { it[Users.id] }
            .firstOrNull()
    } ?: error("Authenticated user not found in database")

    fun getAll(authentication: Authentication): Map<String, String> =
        repository.findAll(resolveUserId(authentication))

    fun set(authentication: Authentication, key: String, value: String) =
        repository.set(resolveUserId(authentication), key, value)

    fun delete(authentication: Authentication, key: String) =
        repository.delete(resolveUserId(authentication), key)
}

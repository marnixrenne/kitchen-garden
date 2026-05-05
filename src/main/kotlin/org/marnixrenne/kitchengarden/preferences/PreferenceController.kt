package org.marnixrenne.kitchengarden.preferences

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.security.Users
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/preferences")
class PreferenceController(private val repository: PreferenceRepository) {

    private fun resolveUserId(authentication: Authentication) = transaction {
        Users.selectAll()
            .where { Users.username eq authentication.name }
            .map { it[Users.id] }
            .firstOrNull()
    } ?: error("Authenticated user not found in database")

    @GetMapping
    fun getAll(authentication: Authentication): Map<String, String> =
        repository.findAll(resolveUserId(authentication))

    @PutMapping("/{key}")
    fun set(
        @PathVariable key: String,
        @RequestBody body: Map<String, String>,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        val value = body["value"] ?: return ResponseEntity.badRequest().build()
        repository.set(resolveUserId(authentication), key, value)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{key}")
    fun delete(@PathVariable key: String, authentication: Authentication): ResponseEntity<Unit> {
        repository.delete(resolveUserId(authentication), key)
        return ResponseEntity.noContent().build()
    }
}

package org.marnixrenne.kitchengarden.preferences

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/preferences")
class PreferenceController(private val preferenceService: PreferenceService) {

    private val validKey = Regex("^[a-zA-Z0-9_.-]{1,100}$")

    @GetMapping
    fun getAll(authentication: Authentication): Map<String, String> =
        preferenceService.getAll(authentication)

    @PutMapping("/{key}")
    fun set(
        @PathVariable key: String,
        @RequestBody body: Map<String, String>,
        authentication: Authentication,
    ): ResponseEntity<*> {
        if (!validKey.matches(key))
            return ResponseEntity.badRequest().body(mapOf("error" to "Invalid preference key"))
        val value = body["value"]
            ?: return ResponseEntity.badRequest().body(mapOf("error" to "Value is required"))
        if (value.length > 1000)
            return ResponseEntity.badRequest().body(mapOf("error" to "Value too long (max 1000 characters)"))
        preferenceService.set(authentication, key, value)
        return ResponseEntity.noContent().build<Unit>()
    }

    @DeleteMapping("/{key}")
    fun delete(@PathVariable key: String, authentication: Authentication): ResponseEntity<*> {
        if (!validKey.matches(key))
            return ResponseEntity.badRequest().body(mapOf("error" to "Invalid preference key"))
        preferenceService.delete(authentication, key)
        return ResponseEntity.noContent().build<Unit>()
    }
}

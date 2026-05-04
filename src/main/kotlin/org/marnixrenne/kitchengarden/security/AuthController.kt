package org.marnixrenne.kitchengarden.security

import org.springframework.http.ResponseEntity
import org.springframework.security.authentication.AnonymousAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/auth")
class AuthController {

    @GetMapping("/me")
    fun me(authentication: Authentication?): ResponseEntity<*> {
        if (authentication == null
            || !authentication.isAuthenticated
            || authentication is AnonymousAuthenticationToken
        ) {
            return ResponseEntity.status(401).body(mapOf("error" to "Not authenticated"))
        }
        return ResponseEntity.ok(mapOf("username" to authentication.name))
    }
}

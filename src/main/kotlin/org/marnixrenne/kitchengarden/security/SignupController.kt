package org.marnixrenne.kitchengarden.security

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/auth")
class SignupController(private val signupService: SignupService) {

    @PostMapping("/signup")
    fun signup(@RequestBody body: Map<String, String>): ResponseEntity<Map<String, String>> {
        val email = body["email"]?.trim()
            ?: return ResponseEntity.badRequest().body(mapOf("error" to "Email is required"))

        return try {
            signupService.initiateSignup(email)
            ResponseEntity.ok(mapOf("message" to "Verification email sent"))
        } catch (e: IllegalArgumentException) {
            val status = if (e.message?.startsWith("Too many") == true) 429 else 400
            ResponseEntity.status(status).body(mapOf("error" to (e.message ?: "Signup failed")))
        }
    }

    @GetMapping("/verify/{token}")
    fun verify(@PathVariable token: String): ResponseEntity<Map<String, String>> {
        val email = signupService.validateToken(token)
            ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(mapOf("email" to email))
    }

    @PostMapping("/complete")
    fun complete(@RequestBody body: Map<String, String>): ResponseEntity<Map<String, String>> {
        val token    = body["token"]    ?: return ResponseEntity.badRequest().body(mapOf("error" to "Token is required"))
        val password = body["password"] ?: return ResponseEntity.badRequest().body(mapOf("error" to "Password is required"))

        return try {
            signupService.completeSignup(token, password)
            ResponseEntity.ok(mapOf("message" to "Account created"))
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("error" to (e.message ?: "Signup failed")))
        }
    }
}

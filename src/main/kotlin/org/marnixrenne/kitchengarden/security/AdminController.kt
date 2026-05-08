package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.security.core.session.SessionRegistry
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*

data class UserSummary(val username: String, val online: Boolean, val lastLogin: Long?, val disabled: Boolean)

@RestController
@RequestMapping("/api/admin")
class AdminController(private val sessionRegistry: SessionRegistry) {

    @GetMapping("/users")
    fun listUsers(): List<UserSummary> {
        val onlineUsernames = sessionRegistry.allPrincipals
            .filterIsInstance<UserDetails>()
            .filter { sessionRegistry.getAllSessions(it, false).isNotEmpty() }
            .map { it.username }
            .toSet()

        return transaction {
            Users.selectAll()
                .orderBy(Users.username)
                .map { row ->
                    UserSummary(
                        username  = row[Users.username],
                        online    = row[Users.username] in onlineUsernames,
                        lastLogin = row[Users.lastLogin]?.toEpochMilli(),
                        disabled  = row[Users.disabled],
                    )
                }
        }
    }

    @PutMapping("/users/{username}/disabled")
    fun setDisabled(
        @PathVariable username: String,
        @RequestBody body: Map<String, Boolean>,
        authentication: Authentication,
    ): ResponseEntity<*> {
        if (username == authentication.name)
            return ResponseEntity.badRequest().body(mapOf("error" to "Cannot disable your own account"))

        val disabled = body["disabled"] ?: return ResponseEntity.badRequest().body(mapOf("error" to "Missing 'disabled' field"))

        val updated = transaction {
            Users.update({ Users.username eq username }) { it[Users.disabled] = disabled }
        }
        if (updated == 0) return ResponseEntity.notFound().build<Unit>()

        // Expire active sessions of the disabled user immediately
        if (disabled) {
            sessionRegistry.allPrincipals
                .filterIsInstance<UserDetails>()
                .filter { it.username == username }
                .flatMap { sessionRegistry.getAllSessions(it, false) }
                .forEach { it.expireNow() }
        }

        return ResponseEntity.ok(mapOf("username" to username, "disabled" to disabled))
    }
}

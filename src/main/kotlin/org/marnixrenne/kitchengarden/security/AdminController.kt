package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.security.core.session.SessionRegistry
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class UserSummary(val username: String, val online: Boolean, val lastLogin: Long?)

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
                    )
                }
        }
    }
}

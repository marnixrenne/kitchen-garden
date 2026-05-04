package org.marnixrenne.kitchengarden.security

import jakarta.annotation.PostConstruct
import org.jetbrains.exposed.sql.Database
import org.marnixrenne.kitchengarden.*
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.context.annotation.DependsOn
import org.springframework.stereotype.Component
import java.util.UUID

@Component
@DependsOn("flywayInitializer")
class DataInitializer(
    private val passwordEncoder: PasswordEncoder,
    @Suppress("unused") private val database: Database,
) {

    @PostConstruct
    fun init() {
        transaction {
            if (Users.selectAll().count() == 0L) {
                val adminId = UUID.randomUUID()
                val hash: String = passwordEncoder.encode("admin").toString()
                Users.insert {
                    it[Users.id]          = adminId
                    it[Users.username]    = "admin"
                    it[Users.password]    = hash
                    it[Users.displayName] = "Admin"
                }

                val roleId = UUID.randomUUID()
                Roles.insert {
                    it[Roles.id]   = roleId
                    it[Roles.name] = "Admins"
                }
                RoleAuthorities.insert {
                    it[RoleAuthorities.roleId]    = roleId
                    it[RoleAuthorities.authority] = "ROLE_ADMIN"
                }
                UserRoles.insert {
                    it[UserRoles.userId] = adminId
                    it[UserRoles.roleId] = roleId
                }
            }
        }
    }
}

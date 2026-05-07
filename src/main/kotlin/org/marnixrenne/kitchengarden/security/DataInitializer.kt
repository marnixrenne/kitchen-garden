package org.marnixrenne.kitchengarden.security

import jakarta.annotation.PostConstruct
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.beans.factory.annotation.Value
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.context.annotation.DependsOn
import org.springframework.stereotype.Component
import java.util.UUID

@Component
@DependsOn("flywayInitializer", "springTransactionManager")
class DataInitializer(
    private val passwordEncoder: PasswordEncoder,
    @Value("\${app.admin.password:admin}") private val adminPassword: String,
) {

    @PostConstruct
    fun init() {
        transaction {
            if (Users.selectAll().count() == 0L) {
                val adminId = UUID.randomUUID()
                Users.insert {
                    it[Users.id]          = adminId
                    it[Users.username]    = "admin"
                    it[Users.password]    = passwordEncoder.encode(adminPassword).toString()
                    it[Users.displayName] = "Admin"
                }

                val roleId = Roles.selectAll()
                    .where { Roles.name eq "Admins" }
                    .map { it[Roles.id] }
                    .first()

                UserRoles.insert {
                    it[UserRoles.userId] = adminId
                    it[UserRoles.roleId] = roleId
                }
            }
        }
    }
}

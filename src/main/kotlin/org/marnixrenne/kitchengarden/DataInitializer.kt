package org.marnixrenne.kitchengarden

import jakarta.annotation.PostConstruct
import org.jetbrains.exposed.sql.Database
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
                val hash: String = passwordEncoder.encode("admin").toString()
                Users.insert {
                    it[Users.id]          = UUID.randomUUID()
                    it[Users.username]    = "admin"
                    it[Users.password]    = hash
                    it[Users.displayName] = "Admin"
                }
            }
        }
    }
}

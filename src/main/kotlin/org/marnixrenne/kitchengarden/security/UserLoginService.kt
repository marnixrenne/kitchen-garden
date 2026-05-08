package org.marnixrenne.kitchengarden.security

import java.time.Instant
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import org.springframework.stereotype.Service

@Service
class UserLoginService {

    fun recordLogin(username: String) {
        transaction {
            Users.update({ Users.username eq username }) {
                it[lastLogin] = Instant.now()
            }
        }
    }
}

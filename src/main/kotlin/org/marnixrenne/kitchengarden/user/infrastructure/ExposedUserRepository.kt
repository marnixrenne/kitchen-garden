package org.marnixrenne.kitchengarden.user.infrastructure

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.marnixrenne.kitchengarden.user.domain.UserRepository
import org.springframework.stereotype.Repository

@Repository
class ExposedUserRepository : UserRepository {

    override fun findIdByUsername(username: String): UserId? = transaction {
        Users.selectAll()
            .where { Users.username eq username }
            .map { UserId(it[Users.id]) }
            .firstOrNull()
    }
}

package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class PreferenceRepository {

    fun findAll(userId: UUID): Map<String, String> = transaction {
        UserPreferences.selectAll()
            .where { UserPreferences.userId eq userId }
            .associate { it[UserPreferences.key] to it[UserPreferences.value] }
    }

    fun set(userId: UUID, key: String, value: String): Unit = transaction {
        UserPreferences.upsert {
            it[UserPreferences.userId] = userId
            it[UserPreferences.key]    = key
            it[UserPreferences.value]  = value
        }
    }

    fun delete(userId: UUID, key: String): Unit = transaction {
        UserPreferences.deleteWhere {
            (UserPreferences.userId eq userId) and (UserPreferences.key eq key)
        }
    }
}

package org.marnixrenne.kitchengarden.preferences.infrastructure

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.preferences.domain.PreferenceRepository
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Repository

@Repository
class ExposedPreferenceRepository : PreferenceRepository {

    override fun findAll(userId: UserId): Map<String, String> = transaction {
        UserPreferences.selectAll()
            .where { UserPreferences.userId eq userId.value }
            .associate { it[UserPreferences.prefKey] to it[UserPreferences.prefValue] }
    }

    override fun set(userId: UserId, key: String, value: String): Unit = transaction {
        UserPreferences.upsert {
            it[UserPreferences.userId]    = userId.value
            it[UserPreferences.prefKey]   = key
            it[UserPreferences.prefValue] = value
        }
    }

    override fun delete(userId: UserId, key: String): Unit = transaction {
        UserPreferences.deleteWhere {
            (UserPreferences.userId eq userId.value) and (UserPreferences.prefKey eq key)
        }
    }
}

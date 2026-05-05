package org.marnixrenne.kitchengarden.preferences

import org.jetbrains.exposed.sql.Table
import org.marnixrenne.kitchengarden.security.Users

object UserPreferences : Table("user_preferences") {
    val userId    = uuid("user_id") references Users.id
    val prefKey   = varchar("pref_key", 100)
    val prefValue = varchar("pref_value", 500)

    override val primaryKey = PrimaryKey(userId, prefKey)
}

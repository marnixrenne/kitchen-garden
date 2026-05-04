package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.Table
import org.marnixrenne.kitchengarden.security.Users

object Vegetables : Table("vegetables") {
    val id       = uuid("id")
    val name     = varchar("name", 100)
    val category = varchar("category", 50)
    val emoji    = varchar("emoji", 10).nullable()

    override val primaryKey = PrimaryKey(id)
}

object SeedingMonths : Table("seeding_months") {
    val vegetableId = uuid("vegetable_id") references Vegetables.id
    val monthNum    = integer("month_num")
}

object GardenVegetables : Table("garden_vegetables") {
    val userId      = uuid("user_id")      references Users.id
    val vegetableId = uuid("vegetable_id") references Vegetables.id

    override val primaryKey = PrimaryKey(userId, vegetableId)
}

object UserPreferences : Table("user_preferences") {
    val userId    = uuid("user_id") references Users.id
    val prefKey   = varchar("pref_key", 100)
    val prefValue = varchar("pref_value", 500)

    override val primaryKey = PrimaryKey(userId, prefKey)
}

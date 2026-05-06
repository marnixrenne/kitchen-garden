package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.Table
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.vegetables.Vegetables

object GardenVegetables : Table("garden_vegetables") {
    val userId      = uuid("user_id")      references Users.id
    val vegetableId = uuid("vegetable_id") references Vegetables.id

    override val primaryKey = PrimaryKey(userId, vegetableId)
}

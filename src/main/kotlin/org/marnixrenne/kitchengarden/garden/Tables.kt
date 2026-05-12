package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.Table
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.plants.Plants

object GardenPlants : Table("garden_plants") {
    val userId  = uuid("user_id")  references Users.id
    val plantId = uuid("plant_id") references Plants.id

    override val primaryKey = PrimaryKey(userId, plantId)
}

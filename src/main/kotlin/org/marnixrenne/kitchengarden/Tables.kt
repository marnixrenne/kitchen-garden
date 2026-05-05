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

object HarvestingMonths : Table("harvesting_months") {
    val vegetableId = uuid("vegetable_id") references Vegetables.id
    val monthNum    = integer("month_num")
}

object Countries : Table("countries") {
    val code = char("code", 2)
    val name = varchar("name", 100)

    override val primaryKey = PrimaryKey(code)
}

object VegetableCountries : Table("vegetable_countries") {
    val vegetableId = uuid("vegetable_id") references Vegetables.id
    val countryCode = char("country_code", 2) references Countries.code

    override val primaryKey = PrimaryKey(vegetableId, countryCode)
}

object GardenVegetables : Table("garden_vegetables") {
    val userId      = uuid("user_id")      references Users.id
    val vegetableId = uuid("vegetable_id") references Vegetables.id

    override val primaryKey = PrimaryKey(userId, vegetableId)
}


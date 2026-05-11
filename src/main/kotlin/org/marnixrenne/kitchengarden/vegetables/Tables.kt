package org.marnixrenne.kitchengarden.vegetables

import org.jetbrains.exposed.sql.Table

object Vegetables : Table("vegetables") {
    val id       = uuid("id")
    val name     = varchar("name", 100)
    val category = varchar("category", 50)
    val emoji    = varchar("emoji", 10).nullable()
    val imageUrl        = varchar("image_url", 500).nullable()
    val sunRequirement  = varchar("sun_requirement", 15).nullable()

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

object CompanionPlants : Table("companion_plants") {
    val vegetableId  = uuid("vegetable_id") references Vegetables.id
    val companionId  = uuid("companion_id") references Vegetables.id
    val relationship = varchar("relationship", 4)

    override val primaryKey = PrimaryKey(vegetableId, companionId)
}

package org.marnixrenne.kitchengarden.vegetables

import org.jetbrains.exposed.sql.Table

object Vegetables : Table("vegetables") {
    val id       = uuid("id")
    val name     = varchar("name", 100)
    val category = varchar("category", 50)
    val emoji    = varchar("emoji", 10).nullable()
    val imageUrl           = varchar("image_url", 500).nullable()
    val sunRequirement     = varchar("sun_requirement", 15).nullable()
    val pruningType        = varchar("pruning_type", 20).nullable()
    val pruningTip         = text("pruning_tip").nullable()
    val sowingMethod       = varchar("sowing_method", 10).nullable()
    val seedDepthMm        = integer("seed_depth_mm").nullable()
    val spacingCm          = integer("spacing_cm").nullable()
    val germinationDaysMin = integer("germination_days_min").nullable()
    val germinationDaysMax = integer("germination_days_max").nullable()
    val daysToMaturityMin  = integer("days_to_maturity_min").nullable()
    val daysToMaturityMax  = integer("days_to_maturity_max").nullable()
    val frostTolerance     = varchar("frost_tolerance", 12).nullable()

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

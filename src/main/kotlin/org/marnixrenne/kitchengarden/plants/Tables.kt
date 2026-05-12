package org.marnixrenne.kitchengarden.plants

import org.jetbrains.exposed.sql.Table

object Plants : Table("pts_plants") {
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
    val heightMinCm        = short("height_min_cm").nullable()
    val heightMaxCm        = short("height_max_cm").nullable()

    override val primaryKey = PrimaryKey(id)
}

object SeedingMonths : Table("pts_seeding_months") {
    val plantId     = uuid("plant_id") references Plants.id
    val monthNum    = integer("month_num")
    val countryCode = char("country_code", 2).nullable()
}

object HarvestingMonths : Table("pts_harvesting_months") {
    val plantId     = uuid("plant_id") references Plants.id
    val monthNum    = integer("month_num")
    val countryCode = char("country_code", 2).nullable()
}

object Countries : Table("countries") {
    val code = char("code", 2)
    val name = varchar("name", 100)

    override val primaryKey = PrimaryKey(code)
}

object PlantCountries : Table("pts_plant_countries") {
    val plantId     = uuid("plant_id") references Plants.id
    val countryCode = char("country_code", 2) references Countries.code

    override val primaryKey = PrimaryKey(plantId, countryCode)
}

object CompanionPlants : Table("pts_companion_plants") {
    val plantId      = uuid("plant_id") references Plants.id
    val companionId  = uuid("companion_id") references Plants.id
    val relationship = varchar("relationship", 4)

    override val primaryKey = PrimaryKey(plantId, companionId)
}

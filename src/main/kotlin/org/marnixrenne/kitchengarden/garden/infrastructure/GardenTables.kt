package org.marnixrenne.kitchengarden.garden.infrastructure

import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.timestamp
import org.marnixrenne.kitchengarden.plants.infrastructure.Plants
import org.marnixrenne.kitchengarden.security.Users

object Garden : Table("pts_garden") {
    val id        = uuid("id")
    val userId    = uuid("user_id") references Users.id
    val name      = varchar("name", 100)
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object GardenBeds : Table("pts_garden_bed") {
    val id          = uuid("id")
    val gardenId    = uuid("garden_id") references Garden.id
    val name        = varchar("name", 100).nullable()
    val bedType     = varchar("bed_type", 20).nullable()
    val lengthCm    = integer("length_cm").nullable()
    val widthCm     = integer("width_cm").nullable()
    val sunExposure = varchar("sun_exposure", 15).nullable()
    val aspect      = varchar("aspect", 2).nullable()
    val createdAt   = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object GardenPlantInstances : Table("garden_plant_instances") {
    val id        = uuid("id")
    val gardenId  = uuid("garden_id") references Garden.id
    val bedId     = uuid("bed_id")    references GardenBeds.id
    val plantId   = uuid("plant_id")  references Plants.id
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object PlantLog : Table("pts_plant_log") {
    val id                  = uuid("id")
    val userId              = uuid("user_id")    references Users.id
    val plantId             = uuid("plant_id")   references Plants.id
    val instanceId          = uuid("instance_id").nullable()
    val lifecycleState      = varchar("lifecycle_state", 30).nullable()
    val lifecycleUpdatedAt  = timestamp("lifecycle_updated_at").nullable()
    val lifecycleDate       = date("lifecycle_date").nullable()
    val lifecycleComment    = text("lifecycle_comment").nullable()
    val createdAt           = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object PlantLogEntry : Table("pts_plant_log_entry") {
    val id        = uuid("id")
    val logId     = uuid("log_id")   references PlantLog.id
    val action    = varchar("action", 20)
    val date      = date("date")
    val comment   = text("comment").nullable()
    val fromBedId   = uuid("from_bed_id").nullable()
    val toBedId     = uuid("to_bed_id").nullable()
    val fromBedName = varchar("from_bed_name", 100).nullable()
    val toBedName   = varchar("to_bed_name", 100).nullable()
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object PruningSchedules : Table("pts_pruning_schedule") {
    val pruningType      = varchar("pruning_type", 20)
    val weeksBeforeStart = integer("weeks_before_start")
    val weeksBeforeEnd   = integer("weeks_before_end")

    override val primaryKey = PrimaryKey(pruningType)
}

object FertilizingSchedules : Table("pts_fertilizing_schedule") {
    val fertilizerType      = varchar("fertilizer_type", 20)
    val startDaysAfterSeed  = integer("start_days_after_seed")
    val intervalDays        = integer("interval_days")
    val windowDays          = integer("window_days")
    val maxApplications     = integer("max_applications")

    override val primaryKey = PrimaryKey(fertilizerType)
}

object WateringSchedules : Table("pts_watering_schedule") {
    val plantCategory      = varchar("plant_category", 50)
    val startDaysAfterSeed = integer("start_days_after_seed")
    val intervalDays       = integer("interval_days")
    val windowDays         = integer("window_days")

    override val primaryKey = PrimaryKey(plantCategory)
}

object PlantPlanEntry : Table("pts_plant_plan_entry") {
    val id          = uuid("id")
    val logEntryId  = uuid("log_entry_id") references PlantLogEntry.id
    val action      = varchar("action", 30)
    val plannedDateStart = date("planned_date_start")
    val plannedDateEnd   = date("planned_date_end")
    val createdAt   = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

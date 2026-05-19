package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.timestamp
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.plants.Plants

object Garden : Table("pts_garden") {
    val id        = uuid("id")
    val userId    = uuid("user_id") references Users.id
    val name      = varchar("name", 100)
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object GardenPlants : Table("garden_plants") {
    val gardenId = uuid("garden_id") references Garden.id
    val plantId  = uuid("plant_id")  references Plants.id

    override val primaryKey = PrimaryKey(gardenId, plantId)
}

object PlantLog : Table("pts_plant_log") {
    val id        = uuid("id")
    val userId    = uuid("user_id")  references Users.id
    val plantId   = uuid("plant_id") references Plants.id
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

object PlantLogEntry : Table("pts_plant_log_entry") {
    val id        = uuid("id")
    val logId     = uuid("log_id")   references PlantLog.id
    val action    = varchar("action", 20)
    val date      = date("date")
    val comment   = text("comment").nullable()
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
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

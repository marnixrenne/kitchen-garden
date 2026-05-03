package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.Table

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

object Users : Table("users") {
    val id          = uuid("id")
    val username    = varchar("username", 50)
    val password    = varchar("password", 100)
    val displayName = varchar("display_name", 100)

    override val primaryKey = PrimaryKey(id)
}
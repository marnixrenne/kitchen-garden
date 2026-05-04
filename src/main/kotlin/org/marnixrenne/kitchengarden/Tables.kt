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

object Roles : Table("roles") {
    val id   = uuid("id")
    val name = varchar("name", 50)

    override val primaryKey = PrimaryKey(id)
}

object RoleAuthorities : Table("role_authorities") {
    val roleId    = uuid("role_id") references Roles.id
    val authority = varchar("authority", 50)
}

object UserRoles : Table("user_roles") {
    val userId = uuid("user_id") references Users.id
    val roleId = uuid("role_id") references Roles.id
}
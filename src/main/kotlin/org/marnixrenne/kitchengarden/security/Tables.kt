package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestamp

object Users : Table("sec_users") {
    val id          = uuid("id")
    val username    = varchar("username", 50)
    val password    = varchar("password", 255)
    val displayName = varchar("display_name", 100)
    val email       = varchar("email", 200).nullable()
    val lastLogin   = timestamp("last_login").nullable()
    val disabled    = bool("disabled").default(false)

    override val primaryKey = PrimaryKey(id)
}

object SignupTokens : Table("sec_signup_tokens") {
    val token     = uuid("token")
    val email     = varchar("email", 200)
    val expiresAt = long("expires_at")

    override val primaryKey = PrimaryKey(token)
}

object Roles : Table("sec_roles") {
    val id   = uuid("id")
    val name = varchar("name", 50)

    override val primaryKey = PrimaryKey(id)
}

object Authorities : Table("sec_authorities") {
    val name        = varchar("name", 50)
    val description = varchar("description", 200).nullable()

    override val primaryKey = PrimaryKey(name)
}

object RoleAuthorities : Table("sec_role_authorities") {
    val roleId    = uuid("role_id")    references Roles.id
    val authority = varchar("authority", 50) references Authorities.name
}

object UserRoles : Table("sec_user_roles") {
    val userId = uuid("user_id") references Users.id
    val roleId = uuid("role_id") references Roles.id
}

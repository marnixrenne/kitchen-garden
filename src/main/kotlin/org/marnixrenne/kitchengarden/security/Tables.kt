package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.Table

object Users : Table("users") {
    val id          = uuid("id")
    val username    = varchar("username", 50)
    val password    = varchar("password", 100)
    val displayName = varchar("display_name", 100)
    val email       = varchar("email", 200).nullable()

    override val primaryKey = PrimaryKey(id)
}

object SignupTokens : Table("signup_tokens") {
    val token     = uuid("token")
    val email     = varchar("email", 200)
    val expiresAt = long("expires_at")

    override val primaryKey = PrimaryKey(token)
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

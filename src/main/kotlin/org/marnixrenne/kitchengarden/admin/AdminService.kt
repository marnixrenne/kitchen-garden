package org.marnixrenne.kitchengarden.admin

import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.count
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import org.marnixrenne.kitchengarden.garden.GardenPlants
import org.marnixrenne.kitchengarden.security.Users
import org.springframework.security.core.session.SessionRegistry
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.stereotype.Service

@Service
class AdminService(private val sessionRegistry: SessionRegistry) {

    fun listUsers(): List<UserSummary> {
        val onlineUsernames = sessionRegistry.allPrincipals
            .filterIsInstance<UserDetails>()
            .filter { sessionRegistry.getAllSessions(it, false).isNotEmpty() }
            .map { it.username }
            .toSet()

        return transaction {
            val countExpr = GardenPlants.plantId.count()
            val gardenCounts = GardenPlants
                .select(GardenPlants.userId, countExpr)
                .groupBy(GardenPlants.userId)
                .associate { it[GardenPlants.userId] to it[countExpr].toInt() }

            Users.selectAll()
                .orderBy(Users.username)
                .map { row ->
                    UserSummary(
                        username    = row[Users.username],
                        online      = row[Users.username] in onlineUsernames,
                        lastLogin   = row[Users.lastLogin]?.toEpochMilli(),
                        disabled    = row[Users.disabled],
                        gardenCount = gardenCounts[row[Users.id]] ?: 0,
                    )
                }
        }
    }

    fun setDisabled(username: String, disabled: Boolean): Boolean {
        val updated = transaction {
            Users.update({ Users.username eq username }) { it[Users.disabled] = disabled }
        }
        if (updated == 0) return false

        if (disabled) {
            sessionRegistry.allPrincipals
                .filterIsInstance<UserDetails>()
                .filter { it.username == username }
                .flatMap { sessionRegistry.getAllSessions(it, false) }
                .forEach { it.expireNow() }
        }

        return true
    }
}

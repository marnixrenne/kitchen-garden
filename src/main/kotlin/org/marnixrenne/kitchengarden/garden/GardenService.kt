package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.preferences.PreferenceService
import org.marnixrenne.kitchengarden.security.AppUserDetails
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.plants.PlantDetail
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class GardenService(
    private val repository: GardenRepository,
    private val preferenceService: PreferenceService,
) {

    private fun resolveUserId(authentication: Authentication): UUID {
        val principal = authentication.principal
        if (principal is AppUserDetails) return principal.userId
        return transaction {
            Users.selectAll()
                .where { Users.username eq authentication.name }
                .map { it[Users.id] }
                .firstOrNull()
        } ?: error("Authenticated user not found in database")
    }

    fun getPlantIds(authentication: Authentication): Set<UUID> =
        repository.findPlantIds(resolveUserId(authentication))

    fun getDetails(authentication: Authentication): List<PlantDetail> =
        repository.findDetails(resolveUserId(authentication), preferenceService.getCountry(authentication))

    fun getWeekSummary(authentication: Authentication): WeekSummary =
        repository.findWeekSummary(resolveUserId(authentication), preferenceService.getCountry(authentication))

    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        repository.findSuggestions(resolveUserId(authentication))

    fun add(authentication: Authentication, plantId: UUID) =
        repository.add(resolveUserId(authentication), plantId)

    fun remove(authentication: Authentication, plantId: UUID) =
        repository.remove(resolveUserId(authentication), plantId)
}

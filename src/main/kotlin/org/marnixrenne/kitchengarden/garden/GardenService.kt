package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.vegetables.VegetableDetail
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class GardenService(private val repository: GardenRepository) {

    private fun resolveUserId(authentication: Authentication): UUID = transaction {
        Users.selectAll()
            .where { Users.username eq authentication.name }
            .map { it[Users.id] }
            .firstOrNull()
    } ?: error("Authenticated user not found in database")

    fun getVegetableIds(authentication: Authentication): Set<UUID> =
        repository.findVegetableIds(resolveUserId(authentication))

    fun getDetails(authentication: Authentication): List<VegetableDetail> =
        repository.findDetails(resolveUserId(authentication))

    fun getWeekSummary(authentication: Authentication): WeekSummary =
        repository.findWeekSummary(resolveUserId(authentication))

    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        repository.findSuggestions(resolveUserId(authentication))

    fun add(authentication: Authentication, vegetableId: UUID) =
        repository.add(resolveUserId(authentication), vegetableId)

    fun remove(authentication: Authentication, vegetableId: UUID) =
        repository.remove(resolveUserId(authentication), vegetableId)
}

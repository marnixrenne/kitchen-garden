package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.preferences.PreferenceService
import org.marnixrenne.kitchengarden.security.AppUserDetails
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.plants.PlantDetail
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.util.UUID

@Service
class GardenService(
    private val repository: GardenRepository,
    private val plantLogRepository: PlantLogRepository,
    private val plantPlanRepository: PlantPlanRepository,
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

    private fun resolveDefaultGardenId(authentication: Authentication): UUID =
        repository.findOrCreateDefaultGarden(resolveUserId(authentication))

    // ── Garden management ─────────────────────────────────────────────────────

    fun listGardens(authentication: Authentication): List<GardenSummary> =
        repository.findGardens(resolveUserId(authentication))

    fun createGarden(authentication: Authentication, name: String): GardenSummary =
        repository.createGarden(resolveUserId(authentication), name)

    fun deleteGarden(authentication: Authentication, gardenId: UUID) {
        val deleted = repository.deleteGarden(gardenId, resolveUserId(authentication))
        if (!deleted) throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    // ── Plant operations (default garden) ────────────────────────────────────

    fun getPlantIds(authentication: Authentication): Set<UUID> =
        repository.findPlantIds(resolveDefaultGardenId(authentication))

    fun getDetails(authentication: Authentication): List<PlantDetail> =
        repository.findDetails(resolveDefaultGardenId(authentication), preferenceService.getCountry(authentication))

    fun getWeekSummary(authentication: Authentication): WeekSummary =
        repository.findWeekSummary(resolveDefaultGardenId(authentication), preferenceService.getCountry(authentication))

    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        repository.findSuggestions(resolveDefaultGardenId(authentication))

    fun add(authentication: Authentication, plantId: UUID) =
        repository.add(resolveDefaultGardenId(authentication), plantId)

    fun remove(authentication: Authentication, plantId: UUID) =
        repository.remove(resolveDefaultGardenId(authentication), plantId)

    fun logSeeding(authentication: Authentication, request: PlantLogRequest): PlantLogResponse {
        val entry = plantLogRepository.save(resolveUserId(authentication), request)
        if (request.action == "seeding") {
            plantPlanRepository.generateAndSave(entry.id, request.plantId, request.date)
        }
        return entry
    }

    fun getPlantLog(authentication: Authentication): Map<UUID, List<LoggedEntry>> =
        plantLogRepository.findAllByUser(resolveUserId(authentication))

    fun getPlan(authentication: Authentication): Map<UUID, List<PlanEntry>> =
        plantPlanRepository.findByUser(resolveUserId(authentication))
}

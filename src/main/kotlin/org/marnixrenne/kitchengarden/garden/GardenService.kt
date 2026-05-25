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
    private val plantPlanService: PlantPlanService,
    private val preferenceService: PreferenceService,
) {

    internal fun resolveUserId(authentication: Authentication): UUID {
        val principal = authentication.principal
        if (principal is AppUserDetails) return principal.userId
        return transaction {
            Users.selectAll()
                .where { Users.username eq authentication.name }
                .map { it[Users.id] }
                .firstOrNull()
        } ?: error("Authenticated user not found in database")
    }

    private fun resolveGardenId(authentication: Authentication, gardenId: UUID?): UUID {
        val userId = resolveUserId(authentication)
        if (gardenId == null) return repository.findOrCreateDefaultGarden(userId)
        val owned = repository.findGardens(userId).any { it.id == gardenId }
        if (!owned) throw ResponseStatusException(HttpStatus.NOT_FOUND)
        return gardenId
    }

    private fun resolveDefaultGardenId(authentication: Authentication): UUID =
        resolveGardenId(authentication, null)

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

    fun getDetails(authentication: Authentication, gardenId: UUID? = null): List<PlantDetail> =
        repository.findDetails(resolveGardenId(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getWeekSummary(authentication: Authentication, gardenId: UUID? = null): WeekSummary =
        repository.findWeekSummary(resolveGardenId(authentication, gardenId), preferenceService.getCountry(authentication))

    fun getSuggestions(authentication: Authentication, gardenId: UUID? = null): PlantingSuggestions =
        repository.findSuggestions(resolveGardenId(authentication, gardenId))

    fun add(authentication: Authentication, plantId: UUID) =
        repository.add(resolveDefaultGardenId(authentication), plantId)

    fun remove(authentication: Authentication, plantId: UUID) =
        repository.remove(resolveDefaultGardenId(authentication), plantId)

    fun getInstances(authentication: Authentication, gardenId: UUID? = null): List<PlantInstance> =
        repository.findInstances(resolveGardenId(authentication, gardenId))

    fun logAction(authentication: Authentication, request: PlantLogRequest): PlantLogResponse {
        val entry = plantLogRepository.save(resolveUserId(authentication), request)
        if (request.action == "seeding") {
            plantPlanService.generateAndSave(entry.id, entry.plantId, request.date)
        }
        return entry
    }

    fun getPlantLog(authentication: Authentication): Map<UUID, List<LoggedEntry>> =
        plantLogRepository.findAllByUser(resolveUserId(authentication))

    fun getPlan(authentication: Authentication): Map<UUID, List<PlanEntry>> =
        plantPlanService.findByUser(resolveUserId(authentication))
}

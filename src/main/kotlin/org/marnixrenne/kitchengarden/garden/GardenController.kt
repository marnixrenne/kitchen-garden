package org.marnixrenne.kitchengarden.garden

import org.marnixrenne.kitchengarden.plants.PlantDetail
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden")
class GardenController(private val gardenService: GardenService) {

    @GetMapping
    fun getGarden(authentication: Authentication): Set<UUID> =
        gardenService.getPlantIds(authentication)

    @GetMapping("/details")
    fun getGardenDetails(authentication: Authentication): List<PlantDetail> =
        gardenService.getDetails(authentication)

    @GetMapping("/week")
    fun getWeekSummary(authentication: Authentication): WeekSummary =
        gardenService.getWeekSummary(authentication)

    @GetMapping("/suggestions")
    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        gardenService.getSuggestions(authentication)

    @PutMapping("/{plantId}")
    fun addToGarden(
        @PathVariable plantId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.add(authentication, plantId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{plantId}")
    fun removeFromGarden(
        @PathVariable plantId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.remove(authentication, plantId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/instances")
    fun getInstances(authentication: Authentication): List<PlantInstance> =
        gardenService.getInstances(authentication)

    @GetMapping("/plant-log")
    fun getPlantLog(authentication: Authentication): Map<UUID, List<LoggedEntry>> =
        gardenService.getPlantLog(authentication)

    @GetMapping("/plan")
    fun getPlan(authentication: Authentication): Map<UUID, List<PlanEntry>> =
        gardenService.getPlan(authentication)

    @PostMapping("/plant-log")
    fun logAction(
        @RequestBody request: PlantLogRequest,
        authentication: Authentication,
    ): ResponseEntity<PlantLogResponse> {
        val entry = gardenService.logAction(authentication, request)
        return ResponseEntity.status(201).body(entry)
    }
}

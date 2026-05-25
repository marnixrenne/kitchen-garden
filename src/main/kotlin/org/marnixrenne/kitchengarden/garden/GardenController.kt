package org.marnixrenne.kitchengarden.garden

import org.marnixrenne.kitchengarden.plants.PlantDetail
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden")
class GardenController(private val gardenService: GardenService) {

    @GetMapping("/gardens")
    fun listGardens(authentication: Authentication): List<GardenSummary> =
        gardenService.listGardens(authentication)

    @PostMapping("/gardens")
    fun createGarden(
        @RequestBody request: CreateGardenRequest,
        authentication: Authentication,
    ): ResponseEntity<GardenSummary> {
        val garden = gardenService.createGarden(authentication, request.name)
        return ResponseEntity.status(201).body(garden)
    }

    @GetMapping
    fun getGarden(
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): Set<UUID> = gardenService.getPlantIds(authentication, gardenId)

    @GetMapping("/details")
    fun getGardenDetails(
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): List<PlantDetail> = gardenService.getDetails(authentication, gardenId)

    @GetMapping("/week")
    fun getWeekSummary(
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): WeekSummary = gardenService.getWeekSummary(authentication, gardenId)

    @GetMapping("/suggestions")
    fun getSuggestions(
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): PlantingSuggestions = gardenService.getSuggestions(authentication, gardenId)

    @PutMapping("/{plantId}")
    fun addToGarden(
        @PathVariable plantId: UUID,
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.add(authentication, plantId, gardenId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{plantId}")
    fun removeFromGarden(
        @PathVariable plantId: UUID,
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.remove(authentication, plantId, gardenId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/instances")
    fun getInstances(
        @RequestParam(required = false) gardenId: UUID?,
        authentication: Authentication,
    ): List<PlantInstance> = gardenService.getInstances(authentication, gardenId)

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

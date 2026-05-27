package org.marnixrenne.kitchengarden.garden.api

import org.marnixrenne.kitchengarden.garden.application.GardenApplicationService
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.lifecycle.application.PlantLifecycleApplicationService
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.AdvanceRequest
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycle
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/gardens")
class GardensController(
    private val gardenService: GardenApplicationService,
    private val lifecycleService: PlantLifecycleApplicationService,
) {

    // ── Collection ────────────────────────────────────────────────────────────

    @GetMapping
    fun listGardens(authentication: Authentication): List<GardenSummary> =
        gardenService.listGardens(authentication)

    @PostMapping
    fun createGarden(
        @RequestBody request: CreateGardenRequest,
        authentication: Authentication,
    ): ResponseEntity<GardenSummary> {
        val garden = gardenService.createGarden(authentication, request.name)
        return ResponseEntity.status(201).body(garden)
    }

    // ── Single garden ─────────────────────────────────────────────────────────

    @GetMapping("/{gardenId}")
    fun getGarden(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): Set<PlantId> = gardenService.getPlantIds(authentication, gardenId)

    @PatchMapping("/{gardenId}")
    fun renameGarden(
        @PathVariable gardenId: GardenId,
        @RequestBody body: Map<String, String>,
        authentication: Authentication,
    ): ResponseEntity<GardenSummary> {
        val name = body["name"] ?: return ResponseEntity.badRequest().build()
        gardenService.renameGarden(authentication, gardenId, name)
        return ResponseEntity.ok(GardenSummary(id = gardenId, name = name))
    }

    @DeleteMapping("/{gardenId}")
    fun deleteGarden(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.deleteGarden(authentication, gardenId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/{gardenId}/details")
    fun getDetails(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): List<PlantDetail> = gardenService.getDetails(authentication, gardenId)

    @GetMapping("/{gardenId}/week")
    fun getWeekSummary(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): WeekSummary = gardenService.getWeekSummary(authentication, gardenId)

    @GetMapping("/{gardenId}/suggestions")
    fun getSuggestions(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): PlantingSuggestions = gardenService.getSuggestions(authentication, gardenId)

    @GetMapping("/{gardenId}/plan")
    fun getPlan(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): Map<PlantInstanceId, List<PlanEntry>> = gardenService.getPlan(authentication, gardenId)

    @GetMapping("/{gardenId}/plant-log")
    fun getPlantLog(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): Map<PlantInstanceId, List<LoggedEntry>> = gardenService.getPlantLog(authentication, gardenId)

    @PostMapping("/{gardenId}/plant-log")
    fun logAction(
        @PathVariable gardenId: GardenId,
        @RequestBody request: PlantLogRequest,
        authentication: Authentication,
    ): ResponseEntity<PlantLogResponse> {
        val entry = gardenService.logAction(authentication, request)
        return ResponseEntity.status(201).body(entry)
    }

    @GetMapping("/{gardenId}/instances")
    fun getInstances(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): List<PlantInstance> = gardenService.getInstances(authentication, gardenId)

    // ── Plants ────────────────────────────────────────────────────────────────

    @PutMapping("/{gardenId}/plants/{plantId}")
    fun addPlant(
        @PathVariable gardenId: GardenId,
        @PathVariable plantId: PlantId,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.add(authentication, gardenId, plantId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{gardenId}/plants/{plantId}")
    fun removePlant(
        @PathVariable gardenId: GardenId,
        @PathVariable plantId: PlantId,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.remove(authentication, gardenId, plantId)
        return ResponseEntity.noContent().build()
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    @GetMapping("/{gardenId}/lifecycle")
    fun getLifecycle(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): Map<PlantInstanceId, PlantLifecycle> = lifecycleService.getAll(authentication, gardenId)

    @PutMapping("/{gardenId}/lifecycle/{instanceId}/advance")
    fun advanceLifecycle(
        @PathVariable gardenId: GardenId,
        @PathVariable instanceId: PlantInstanceId,
        @RequestBody(required = false) request: AdvanceRequest?,
        authentication: Authentication,
    ): PlantLifecycle = lifecycleService.advance(authentication, instanceId, request)
}

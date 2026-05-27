package org.marnixrenne.kitchengarden.garden.api

import org.marnixrenne.kitchengarden.garden.application.GardenApplicationService
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.lifecycle.application.PlantLifecycleApplicationService
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.AdvanceRequest
import org.marnixrenne.kitchengarden.garden.lifecycle.domain.PlantLifecycle
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

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
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): Set<UUID> = gardenService.getPlantIds(authentication, gardenId)

    @PatchMapping("/{gardenId}")
    fun renameGarden(
        @PathVariable gardenId: UUID,
        @RequestBody body: Map<String, String>,
        authentication: Authentication,
    ): ResponseEntity<GardenSummary> {
        val name = body["name"] ?: return ResponseEntity.badRequest().build()
        gardenService.renameGarden(authentication, gardenId, name)
        return ResponseEntity.ok(GardenSummary(gardenId, name))
    }

    @DeleteMapping("/{gardenId}")
    fun deleteGarden(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.deleteGarden(authentication, gardenId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/{gardenId}/details")
    fun getDetails(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): List<PlantDetail> = gardenService.getDetails(authentication, gardenId)

    @GetMapping("/{gardenId}/week")
    fun getWeekSummary(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): WeekSummary = gardenService.getWeekSummary(authentication, gardenId)

    @GetMapping("/{gardenId}/suggestions")
    fun getSuggestions(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): PlantingSuggestions = gardenService.getSuggestions(authentication, gardenId)

    @GetMapping("/{gardenId}/plan")
    fun getPlan(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): Map<UUID, List<PlanEntry>> = gardenService.getPlan(authentication, gardenId)

    @GetMapping("/{gardenId}/plant-log")
    fun getPlantLog(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): Map<UUID, List<LoggedEntry>> = gardenService.getPlantLog(authentication, gardenId)

    @PostMapping("/{gardenId}/plant-log")
    fun logAction(
        @PathVariable gardenId: UUID,
        @RequestBody request: PlantLogRequest,
        authentication: Authentication,
    ): ResponseEntity<PlantLogResponse> {
        val entry = gardenService.logAction(authentication, request)
        return ResponseEntity.status(201).body(entry)
    }

    @GetMapping("/{gardenId}/instances")
    fun getInstances(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): List<PlantInstance> = gardenService.getInstances(authentication, gardenId)

    // ── Plants ────────────────────────────────────────────────────────────────

    @PutMapping("/{gardenId}/plants/{plantId}")
    fun addPlant(
        @PathVariable gardenId: UUID,
        @PathVariable plantId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.add(authentication, gardenId, plantId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{gardenId}/plants/{plantId}")
    fun removePlant(
        @PathVariable gardenId: UUID,
        @PathVariable plantId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.remove(authentication, gardenId, plantId)
        return ResponseEntity.noContent().build()
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    @GetMapping("/{gardenId}/lifecycle")
    fun getLifecycle(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): Map<UUID, PlantLifecycle> = lifecycleService.getAll(authentication, gardenId)

    @PutMapping("/{gardenId}/lifecycle/{instanceId}/advance")
    fun advanceLifecycle(
        @PathVariable gardenId: UUID,
        @PathVariable instanceId: UUID,
        @RequestBody(required = false) request: AdvanceRequest?,
        authentication: Authentication,
    ): PlantLifecycle = lifecycleService.advance(authentication, instanceId, request)
}

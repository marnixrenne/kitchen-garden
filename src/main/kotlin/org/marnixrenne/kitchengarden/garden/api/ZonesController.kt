package org.marnixrenne.kitchengarden.garden.api

import org.marnixrenne.kitchengarden.garden.application.ZoneCommandService
import org.marnixrenne.kitchengarden.garden.application.ZoneQueryService
import org.marnixrenne.kitchengarden.garden.domain.*
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/gardens/{gardenId}")
class ZonesController(
    private val zoneCommandService: ZoneCommandService,
    private val zoneQueryService: ZoneQueryService,
) {

    // ── Zones ──────────────────────────────────────────────────────────────────

    @GetMapping("/zones")
    fun listZones(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): List<Zone> = zoneQueryService.list(authentication, gardenId)

    @GetMapping("/zones/{zoneId}/plant-options")
    fun plantOptions(
        @PathVariable gardenId: GardenId,
        @PathVariable zoneId: ZoneId,
        authentication: Authentication,
    ): List<PlantOption> = zoneQueryService.plantOptions(authentication, gardenId, zoneId)

    @PostMapping("/zones")
    fun createZone(
        @PathVariable gardenId: GardenId,
        @RequestBody request: ZoneRequest,
        authentication: Authentication,
    ): ResponseEntity<Zone> =
        ResponseEntity.status(201).body(zoneCommandService.create(authentication, gardenId, request))

    @PutMapping("/zones/{zoneId}")
    fun updateZone(
        @PathVariable gardenId: GardenId,
        @PathVariable zoneId: ZoneId,
        @RequestBody request: ZoneRequest,
        authentication: Authentication,
    ): Zone = zoneCommandService.update(authentication, gardenId, zoneId, request)

    /** A zone that still has plants needs `plants=move&targetZoneId=…` or `plants=delete`. */
    @DeleteMapping("/zones/{zoneId}")
    fun deleteZone(
        @PathVariable gardenId: GardenId,
        @PathVariable zoneId: ZoneId,
        @RequestParam(name = "plants", required = false) disposition: ZonePlantsDisposition?,
        @RequestParam(required = false) targetZoneId: ZoneId?,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        zoneCommandService.delete(authentication, gardenId, zoneId, disposition, targetZoneId)
        return ResponseEntity.noContent().build()
    }

    // ── Moves ─────────────────────────────────────────────────────────────────

    @PostMapping("/instances/{instanceId}/move")
    fun moveInstance(
        @PathVariable gardenId: GardenId,
        @PathVariable instanceId: PlantInstanceId,
        @RequestBody request: MoveRequest,
        authentication: Authentication,
    ): ResponseEntity<LoggedEntry> =
        ResponseEntity.status(201).body(zoneCommandService.move(authentication, gardenId, instanceId, request))
}

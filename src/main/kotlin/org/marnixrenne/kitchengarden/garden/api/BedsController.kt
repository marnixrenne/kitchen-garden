package org.marnixrenne.kitchengarden.garden.api

import org.marnixrenne.kitchengarden.garden.application.BedCommandService
import org.marnixrenne.kitchengarden.garden.application.BedQueryService
import org.marnixrenne.kitchengarden.garden.domain.*
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/gardens/{gardenId}")
class BedsController(
    private val bedCommandService: BedCommandService,
    private val bedQueryService: BedQueryService,
) {

    // ── Beds ──────────────────────────────────────────────────────────────────

    @GetMapping("/beds")
    fun listBeds(
        @PathVariable gardenId: GardenId,
        authentication: Authentication,
    ): List<Bed> = bedQueryService.list(authentication, gardenId)

    @PostMapping("/beds")
    fun createBed(
        @PathVariable gardenId: GardenId,
        @RequestBody request: BedRequest,
        authentication: Authentication,
    ): ResponseEntity<Bed> =
        ResponseEntity.status(201).body(bedCommandService.create(authentication, gardenId, request))

    @PutMapping("/beds/{bedId}")
    fun updateBed(
        @PathVariable gardenId: GardenId,
        @PathVariable bedId: BedId,
        @RequestBody request: BedRequest,
        authentication: Authentication,
    ): Bed = bedCommandService.update(authentication, gardenId, bedId, request)

    /** A bed that still has plants needs `plants=move&targetBedId=…` or `plants=delete`. */
    @DeleteMapping("/beds/{bedId}")
    fun deleteBed(
        @PathVariable gardenId: GardenId,
        @PathVariable bedId: BedId,
        @RequestParam(name = "plants", required = false) disposition: BedPlantsDisposition?,
        @RequestParam(required = false) targetBedId: BedId?,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        bedCommandService.delete(authentication, gardenId, bedId, disposition, targetBedId)
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
        ResponseEntity.status(201).body(bedCommandService.move(authentication, gardenId, instanceId, request))
}

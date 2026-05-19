package org.marnixrenne.kitchengarden.garden

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/gardens")
class GardensController(private val gardenService: GardenService) {

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

    @DeleteMapping("/{gardenId}")
    fun deleteGarden(
        @PathVariable gardenId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.deleteGarden(authentication, gardenId)
        return ResponseEntity.noContent().build()
    }
}

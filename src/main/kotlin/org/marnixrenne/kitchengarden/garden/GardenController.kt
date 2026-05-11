package org.marnixrenne.kitchengarden.garden

import org.marnixrenne.kitchengarden.vegetables.VegetableDetail
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden")
class GardenController(private val gardenService: GardenService) {

    @GetMapping
    fun getGarden(authentication: Authentication): Set<UUID> =
        gardenService.getVegetableIds(authentication)

    @GetMapping("/details")
    fun getGardenDetails(authentication: Authentication): List<VegetableDetail> =
        gardenService.getDetails(authentication)

    @GetMapping("/week")
    fun getWeekSummary(authentication: Authentication): WeekSummary =
        gardenService.getWeekSummary(authentication)

    @GetMapping("/suggestions")
    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        gardenService.getSuggestions(authentication)

    @PutMapping("/{vegetableId}")
    fun addToGarden(
        @PathVariable vegetableId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.add(authentication, vegetableId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{vegetableId}")
    fun removeFromGarden(
        @PathVariable vegetableId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        gardenService.remove(authentication, vegetableId)
        return ResponseEntity.noContent().build()
    }
}

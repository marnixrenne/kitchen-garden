package org.marnixrenne.kitchengarden.plants

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/plants")
class PlantController(private val plantService: PlantService) {

    @GetMapping
    fun getPlants(
        @RequestParam(required = false) month: Int?,
        authentication: Authentication?,
    ): ResponseEntity<List<Plant>> {
        if (month != null && (month < 1 || month > 12)) {
            return ResponseEntity.badRequest().build()
        }
        return ResponseEntity.ok(
            if (month != null) plantService.findByMonth(month, authentication)
            else plantService.findAll()
        )
    }

    @GetMapping("/{id}")
    fun getById(@PathVariable id: UUID, authentication: Authentication?): ResponseEntity<PlantDetail> {
        val plant = plantService.findById(id, authentication) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(plant)
    }

    @GetMapping("/counts")
    fun getCounts(authentication: Authentication?): Map<Int, Int> =
        plantService.countPerMonth(authentication)
}

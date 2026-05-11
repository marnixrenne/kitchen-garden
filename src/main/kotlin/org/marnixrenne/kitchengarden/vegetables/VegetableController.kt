package org.marnixrenne.kitchengarden.vegetables

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/vegetables")
class VegetableController(private val vegetableService: VegetableService) {

    @GetMapping
    fun getVegetables(
        @RequestParam(required = false) month: Int?,
        authentication: Authentication,
    ): ResponseEntity<List<Vegetable>> {
        if (month != null && (month < 1 || month > 12)) {
            return ResponseEntity.badRequest().build()
        }
        return ResponseEntity.ok(
            if (month != null) vegetableService.findByMonth(month, authentication)
            else vegetableService.findAll()
        )
    }

    @GetMapping("/{id}")
    fun getById(@PathVariable id: UUID, authentication: Authentication): ResponseEntity<VegetableDetail> {
        val vegetable = vegetableService.findById(id, authentication) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(vegetable)
    }

    @GetMapping("/counts")
    fun getCounts(authentication: Authentication): Map<Int, Int> =
        vegetableService.countPerMonth(authentication)
}

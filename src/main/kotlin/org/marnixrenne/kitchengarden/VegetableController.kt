package org.marnixrenne.kitchengarden

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/vegetables")
class VegetableController(private val repository: VegetableRepository) {

    @GetMapping
    fun getByMonth(@RequestParam month: Int): ResponseEntity<List<Vegetable>> {
        if (month < 1 || month > 12) {
            return ResponseEntity.badRequest().build()
        }
        return ResponseEntity.ok(repository.findByMonth(month))
    }

    @GetMapping("/counts")
    fun getCounts(): Map<Int, Int> = repository.countPerMonth()
}
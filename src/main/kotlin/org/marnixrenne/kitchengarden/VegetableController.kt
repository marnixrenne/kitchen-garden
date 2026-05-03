package org.marnixrenne.kitchengarden

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

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

    @GetMapping("/{id}")
    fun getById(@PathVariable id: UUID): ResponseEntity<VegetableDetail> {
        val vegetable = repository.findById(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(vegetable)
    }

    @GetMapping("/counts")
    fun getCounts(): Map<Int, Int> = repository.countPerMonth()
}
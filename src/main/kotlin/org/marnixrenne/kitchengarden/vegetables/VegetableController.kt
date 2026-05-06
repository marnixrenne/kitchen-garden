package org.marnixrenne.kitchengarden.vegetables

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
    fun getVegetables(@RequestParam(required = false) month: Int?): ResponseEntity<List<Vegetable>> {
        if (month != null && (month < 1 || month > 12)) {
            return ResponseEntity.badRequest().build()
        }
        return ResponseEntity.ok(if (month != null) repository.findByMonth(month) else repository.findAll())
    }

    @GetMapping("/{id}")
    fun getById(@PathVariable id: UUID): ResponseEntity<VegetableDetail> {
        val vegetable = repository.findById(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(vegetable)
    }

    @GetMapping("/counts")
    fun getCounts(): Map<Int, Int> = repository.countPerMonth()
}

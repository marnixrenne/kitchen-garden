package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.security.Users
import org.marnixrenne.kitchengarden.vegetables.VegetableDetail
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden")
class GardenController(private val repository: GardenRepository) {

    private fun resolveUserId(authentication: Authentication) = transaction {
        Users.selectAll()
            .where { Users.username eq authentication.name }
            .map { it[Users.id] }
            .firstOrNull()
    } ?: error("Authenticated user not found in database")

    @GetMapping
    fun getGarden(authentication: Authentication): Set<UUID> =
        repository.findVegetableIds(resolveUserId(authentication))

    @GetMapping("/details")
    fun getGardenDetails(authentication: Authentication): List<VegetableDetail> =
        repository.findDetails(resolveUserId(authentication))

    @GetMapping("/suggestions")
    fun getSuggestions(authentication: Authentication): PlantingSuggestions =
        repository.findSuggestions(resolveUserId(authentication))

    @PutMapping("/{vegetableId}")
    fun addToGarden(
        @PathVariable vegetableId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        repository.add(resolveUserId(authentication), vegetableId)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/{vegetableId}")
    fun removeFromGarden(
        @PathVariable vegetableId: UUID,
        authentication: Authentication,
    ): ResponseEntity<Unit> {
        repository.remove(resolveUserId(authentication), vegetableId)
        return ResponseEntity.noContent().build()
    }
}

package org.marnixrenne.kitchengarden.garden

import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden/lifecycle")
class PlantLifecycleController(private val service: PlantLifecycleService) {

    @GetMapping
    fun getAll(authentication: Authentication): Map<UUID, PlantLifecycle> =
        service.getAll(authentication)

    @PutMapping("/{plantId}/advance")
    fun advance(
        @PathVariable plantId: UUID,
        authentication: Authentication,
    ): PlantLifecycle = service.advance(authentication, plantId)
}

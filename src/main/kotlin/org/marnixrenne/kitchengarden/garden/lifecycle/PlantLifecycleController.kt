package org.marnixrenne.kitchengarden.garden.lifecycle

import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/api/garden/lifecycle")
class PlantLifecycleController(private val service: PlantLifecycleService) {

    @GetMapping
    fun getAll(authentication: Authentication): Map<UUID, PlantLifecycle> =
        service.getAll(authentication)

    @PutMapping("/{instanceId}/advance")
    fun advance(
        @PathVariable instanceId: UUID,
        @RequestBody(required = false) request: AdvanceRequest?,
        authentication: Authentication,
    ): PlantLifecycle = service.advance(authentication, instanceId, request)
}

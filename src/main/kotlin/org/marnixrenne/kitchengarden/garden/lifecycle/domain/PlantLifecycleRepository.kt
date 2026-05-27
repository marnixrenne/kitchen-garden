package org.marnixrenne.kitchengarden.garden.lifecycle.domain

import java.util.UUID

interface PlantLifecycleRepository {
    fun findAllByUser(userId: UUID, gardenId: UUID): Map<UUID, PlantLifecycle>
    fun advance(userId: UUID, instanceId: UUID, request: AdvanceRequest?): PlantLifecycle?
}

package org.marnixrenne.kitchengarden.garden.lifecycle.domain

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.user.domain.UserId

interface PlantLifecycleRepository {
    fun findAllByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, PlantLifecycle>
    fun advance(userId: UserId, gardenId: GardenId, instanceId: PlantInstanceId, request: AdvanceRequest?): PlantLifecycle?
}

package org.marnixrenne.kitchengarden.garden.plan.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantPlanRepository
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Service

@Service
class PlantPlanQueryService(
    private val repository: PlantPlanRepository,
) {
    fun findByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>> =
        repository.findByUser(userId, gardenId)
}

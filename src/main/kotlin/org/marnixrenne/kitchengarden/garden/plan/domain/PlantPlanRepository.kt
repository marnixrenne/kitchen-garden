package org.marnixrenne.kitchengarden.garden.plan.domain

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.domain.PlantLogEntryId
import org.marnixrenne.kitchengarden.user.domain.UserId

interface PlantPlanRepository {
    fun save(logEntryId: PlantLogEntryId, periods: List<PlanPeriod>)
    fun findByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>>
}

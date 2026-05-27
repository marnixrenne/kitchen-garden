package org.marnixrenne.kitchengarden.garden.plan.domain

import java.util.UUID

interface PlantPlanRepository {
    fun save(logEntryId: UUID, periods: List<PlanPeriod>)
    fun findByUser(userId: UUID, gardenId: UUID): Map<UUID, List<PlanEntry>>
}

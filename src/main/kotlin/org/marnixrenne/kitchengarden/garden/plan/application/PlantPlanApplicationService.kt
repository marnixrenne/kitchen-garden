package org.marnixrenne.kitchengarden.garden.plan.application

import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanPeriod
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantGrowthPort
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantPlanCalculator
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantPlanRepository
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.util.UUID

@Service
class PlantPlanApplicationService(
    private val repository: PlantPlanRepository,
    private val plantGrowthPort: PlantGrowthPort,
) {

    fun generateAndSave(logEntryId: UUID, plantId: UUID, seedDate: LocalDate) {
        val periods = computePeriods(plantId, seedDate)
        if (periods.isNotEmpty()) repository.save(logEntryId, periods)
    }

    fun findByUser(userId: UUID, gardenId: UUID): Map<UUID, List<PlanEntry>> =
        repository.findByUser(userId, gardenId)

    private fun computePeriods(plantId: UUID, seedDate: LocalDate): List<PlanPeriod> {
        val data = plantGrowthPort.loadGrowthData(plantId) ?: return emptyList()
        return PlantPlanCalculator.compute(
            seedDate           = seedDate,
            germinationDaysMin = data.germinationDaysMin,
            germinationDaysMax = data.germinationDaysMax,
            daysToMaturityMin  = data.daysToMaturityMin,
            daysToMaturityMax  = data.daysToMaturityMax,
            harvestMonths      = data.harvestMonths,
            pruningConfig      = data.pruningConfig,
            fertilizingConfig  = data.fertilizingConfig,
            wateringConfig     = data.wateringConfig,
        )
    }
}

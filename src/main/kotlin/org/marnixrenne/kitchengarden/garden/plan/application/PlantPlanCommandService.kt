package org.marnixrenne.kitchengarden.garden.plan.application

import org.marnixrenne.kitchengarden.garden.domain.PlantLogEntryId
import org.marnixrenne.kitchengarden.garden.plan.domain.*
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.springframework.stereotype.Service
import java.time.LocalDate

@Service
class PlantPlanCommandService(
    private val repository: PlantPlanRepository,
    private val plantGrowthPort: PlantGrowthPort,
) {
    fun generateAndSave(logEntryId: PlantLogEntryId, plantId: PlantId, seedDate: LocalDate) {
        val periods = computePeriods(plantId, seedDate)
        if (periods.isNotEmpty()) repository.save(logEntryId, periods)
    }

    private fun computePeriods(plantId: PlantId, seedDate: LocalDate): List<PlanPeriod> {
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

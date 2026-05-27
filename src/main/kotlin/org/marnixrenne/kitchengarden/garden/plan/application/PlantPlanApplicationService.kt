package org.marnixrenne.kitchengarden.garden.plan.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.garden.domain.PlantLogEntryId
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntry
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanPeriod
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantGrowthPort
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantPlanCalculator
import org.marnixrenne.kitchengarden.garden.plan.domain.PlantPlanRepository
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.stereotype.Service
import java.time.LocalDate

@Service
class PlantPlanApplicationService(
    private val repository: PlantPlanRepository,
    private val plantGrowthPort: PlantGrowthPort,
) {

    fun generateAndSave(logEntryId: PlantLogEntryId, plantId: PlantId, seedDate: LocalDate) {
        val periods = computePeriods(plantId, seedDate)
        if (periods.isNotEmpty()) repository.save(logEntryId, periods)
    }

    fun findByUser(userId: UserId, gardenId: GardenId): Map<PlantInstanceId, List<PlanEntry>> =
        repository.findByUser(userId, gardenId)

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

package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.plants.HarvestingMonths
import org.marnixrenne.kitchengarden.plants.Plants
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.util.UUID

@Service
class PlantPlanService(private val repository: PlantPlanRepository) {

    fun generateAndSave(logEntryId: UUID, plantId: UUID, seedDate: LocalDate) {
        val periods = computePeriods(plantId, seedDate)
        if (periods.isNotEmpty()) repository.save(logEntryId, periods)
    }

    fun findByUser(userId: UUID): Map<UUID, List<PlanEntry>> =
        repository.findByUser(userId)

    private fun computePeriods(plantId: UUID, seedDate: LocalDate): List<PlanPeriod> = transaction {
        val plant = Plants.selectAll().where { Plants.id eq plantId }.firstOrNull()
            ?: return@transaction emptyList()

        val harvestMonths = HarvestingMonths.selectAll()
            .where { (HarvestingMonths.plantId eq plantId) and HarvestingMonths.countryCode.isNull() }
            .map { it[HarvestingMonths.monthNum] }
            .sorted()

        PlantPlanCalculator.compute(
            seedDate          = seedDate,
            germinationDaysMin = plant[Plants.germinationDaysMin],
            germinationDaysMax = plant[Plants.germinationDaysMax],
            daysToMaturityMin  = plant[Plants.daysToMaturityMin],
            daysToMaturityMax  = plant[Plants.daysToMaturityMax],
            harvestMonths      = harvestMonths,
            hasPruning         = plant[Plants.pruningType] != null,
            hasFertilizing     = plant[Plants.fertilizerType] != null,
        )
    }
}

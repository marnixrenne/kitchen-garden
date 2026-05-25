package org.marnixrenne.kitchengarden.garden.plan

import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.FertilizingSchedules
import org.marnixrenne.kitchengarden.garden.PruningSchedules
import org.marnixrenne.kitchengarden.garden.WateringSchedules
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

        val pruningConfig = plant[Plants.pruningType]?.let { type ->
            PruningSchedules.selectAll().where { PruningSchedules.pruningType eq type }.firstOrNull()?.let {
                PruningConfig(
                    weeksBeforeStart = it[PruningSchedules.weeksBeforeStart],
                    weeksBeforeEnd   = it[PruningSchedules.weeksBeforeEnd],
                )
            }
        }

        val fertilizingConfig = plant[Plants.fertilizerType]?.let { type ->
            FertilizingSchedules.selectAll().where { FertilizingSchedules.fertilizerType eq type }.firstOrNull()?.let {
                FertilizingConfig(
                    startDaysAfterSeed = it[FertilizingSchedules.startDaysAfterSeed],
                    intervalDays       = it[FertilizingSchedules.intervalDays],
                    windowDays         = it[FertilizingSchedules.windowDays],
                    maxApplications    = it[FertilizingSchedules.maxApplications],
                )
            }
        }

        val wateringConfig = WateringSchedules.selectAll()
            .where { WateringSchedules.plantCategory eq plant[Plants.category] }
            .firstOrNull()?.let {
                WateringConfig(
                    startDaysAfterSeed = it[WateringSchedules.startDaysAfterSeed],
                    intervalDays       = it[WateringSchedules.intervalDays],
                    windowDays         = it[WateringSchedules.windowDays],
                )
            }

        PlantPlanCalculator.compute(
            seedDate           = seedDate,
            germinationDaysMin = plant[Plants.germinationDaysMin],
            germinationDaysMax = plant[Plants.germinationDaysMax],
            daysToMaturityMin  = plant[Plants.daysToMaturityMin],
            daysToMaturityMax  = plant[Plants.daysToMaturityMax],
            harvestMonths      = harvestMonths,
            pruningConfig      = pruningConfig,
            fertilizingConfig  = fertilizingConfig,
            wateringConfig     = wateringConfig,
        )
    }
}

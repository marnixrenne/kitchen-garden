package org.marnixrenne.kitchengarden.garden.plan.infrastructure

import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.garden.infrastructure.FertilizingSchedules
import org.marnixrenne.kitchengarden.garden.infrastructure.PruningSchedules
import org.marnixrenne.kitchengarden.garden.infrastructure.WateringSchedules
import org.marnixrenne.kitchengarden.garden.plan.domain.*
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.plants.infrastructure.HarvestingMonths
import org.marnixrenne.kitchengarden.plants.infrastructure.Plants
import org.springframework.stereotype.Component

@Component
class ExposedPlantGrowthAdapter : PlantGrowthPort {

    override fun loadGrowthData(plantId: PlantId): PlantGrowthData? = transaction {
        val plant = Plants.selectAll().where { Plants.id eq plantId.value }.firstOrNull()
            ?: return@transaction null

        val harvestMonths = HarvestingMonths.selectAll()
            .where { (HarvestingMonths.plantId eq plantId.value) and HarvestingMonths.countryCode.isNull() }
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

        PlantGrowthData(
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

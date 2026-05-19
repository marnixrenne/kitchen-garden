package org.marnixrenne.kitchengarden.garden

import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.plants.HarvestingMonths
import org.marnixrenne.kitchengarden.plants.Plants
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.YearMonth
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

        val daysToMaturityMin = plant[Plants.daysToMaturityMin]
        val daysToMaturityMax = plant[Plants.daysToMaturityMax]

        val harvestPeriod: Pair<LocalDate, LocalDate>? = when {
            daysToMaturityMin != null -> {
                val endDays = daysToMaturityMax ?: daysToMaturityMin
                seedDate.plusDays(daysToMaturityMin.toLong()) to seedDate.plusDays(endDays.toLong())
            }
            harvestMonths.isNotEmpty() -> {
                val seedMonth  = seedDate.monthValue
                val firstMonth = harvestMonths.firstOrNull { it > seedMonth } ?: harvestMonths.first()
                val lastMonth  = harvestMonths.last()
                val year       = if (firstMonth <= seedMonth) seedDate.year + 1 else seedDate.year
                val endYear    = if (lastMonth < firstMonth) year + 1 else year
                LocalDate.of(year, firstMonth, 1) to
                    LocalDate.of(endYear, lastMonth, YearMonth.of(endYear, lastMonth).lengthOfMonth())
            }
            else -> null
        }

        val periods = mutableListOf<PlanPeriod>()

        plant[Plants.germinationDaysMin]?.let { daysMin ->
            val daysMax = plant[Plants.germinationDaysMax] ?: daysMin
            periods += PlanPeriod("germination", seedDate.plusDays(daysMin.toLong()), seedDate.plusDays(daysMax.toLong()))
        }

        harvestPeriod?.let { (start, end) ->
            periods += PlanPeriod("harvest", start, end)
        }

        if (plant[Plants.pruningType] != null && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            val pruningEnd   = harvestStart.minusDays(14)
            val pruningStart = harvestStart.minusDays(42)
            if (pruningEnd.isAfter(seedDate)) {
                periods += PlanPeriod("pruning", maxOf(pruningStart, seedDate.plusDays(1)), pruningEnd)
            }
        }

        if (plant[Plants.fertilizerType] != null && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var fertStart = seedDate.plusDays(14)
            var count = 0
            while (fertStart.isBefore(harvestStart) && count < 3) {
                periods += PlanPeriod("fertilizing", fertStart, fertStart.plusDays(6))
                fertStart = fertStart.plusDays(28)
                count++
            }
        }

        periods.sortedBy { it.start }
    }
}

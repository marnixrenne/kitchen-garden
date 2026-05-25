package org.marnixrenne.kitchengarden.garden

import java.time.LocalDate
import java.time.YearMonth

object PlantPlanCalculator {

    fun compute(
        seedDate: LocalDate,
        germinationDaysMin: Int?,
        germinationDaysMax: Int?,
        daysToMaturityMin: Int?,
        daysToMaturityMax: Int?,
        harvestMonths: List<Int>,
        pruningConfig: PruningConfig?,
        fertilizingConfig: FertilizingConfig?,
        wateringConfig: WateringConfig? = null,
    ): List<PlanPeriod> {
        val harvestPeriod = resolveHarvestPeriod(seedDate, daysToMaturityMin, daysToMaturityMax, harvestMonths)
        val periods = mutableListOf<PlanPeriod>()

        germinationDaysMin?.let { daysMin ->
            val daysMax = germinationDaysMax ?: daysMin
            periods += PlanPeriod("germination", seedDate.plusDays(daysMin.toLong()), seedDate.plusDays(daysMax.toLong()))
        }

        harvestPeriod?.let { (start, end) ->
            periods += PlanPeriod("harvest", start, end)
        }

        if (pruningConfig != null && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            val pruningEnd   = harvestStart.minusWeeks(pruningConfig.weeksBeforeEnd.toLong())
            val pruningStart = harvestStart.minusWeeks(pruningConfig.weeksBeforeStart.toLong())
            if (pruningEnd.isAfter(seedDate)) {
                periods += PlanPeriod("pruning", maxOf(pruningStart, seedDate.plusDays(1)), pruningEnd)
            }
        }

        if (fertilizingConfig != null && fertilizingConfig.maxApplications > 0 && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var fertStart = seedDate.plusDays(fertilizingConfig.startDaysAfterSeed.toLong())
            var count = 0
            while (fertStart.isBefore(harvestStart) && count < fertilizingConfig.maxApplications) {
                periods += PlanPeriod("fertilizing", fertStart, fertStart.plusDays(fertilizingConfig.windowDays.toLong()))
                fertStart = fertStart.plusDays(fertilizingConfig.intervalDays.toLong())
                count++
            }
        }

        if (wateringConfig != null && wateringConfig.intervalDays > 0 && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var waterStart = seedDate.plusDays(wateringConfig.startDaysAfterSeed.toLong())
            while (waterStart.isBefore(harvestStart)) {
                periods += PlanPeriod("watering", waterStart, waterStart.plusDays(wateringConfig.windowDays.toLong()))
                waterStart = waterStart.plusDays(wateringConfig.intervalDays.toLong())
            }
        }

        return periods.sortedBy { it.start }
    }

    private fun resolveHarvestPeriod(
        seedDate: LocalDate,
        daysToMaturityMin: Int?,
        daysToMaturityMax: Int?,
        harvestMonths: List<Int>,
    ): Pair<LocalDate, LocalDate>? = when {
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
}

package org.marnixrenne.kitchengarden.garden.plan.domain

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
            periods += PlanPeriod(PlanAction.GERMINATION, seedDate.plusDays(daysMin.toLong()), seedDate.plusDays(daysMax.toLong()))
        }

        harvestPeriod?.let { (start, end) ->
            periods += PlanPeriod(PlanAction.HARVEST, start, end)
        }

        if (pruningConfig != null && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            val pruningEnd   = harvestStart.minusWeeks(pruningConfig.weeksBeforeEnd.toLong())
            val pruningStart = harvestStart.minusWeeks(pruningConfig.weeksBeforeStart.toLong())
            if (pruningEnd.isAfter(seedDate)) {
                periods += PlanPeriod(PlanAction.PRUNING, maxOf(pruningStart, seedDate.plusDays(1)), pruningEnd)
            }
        }

        if (fertilizingConfig != null && fertilizingConfig.maxApplications > 0 && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var fertStart = seedDate.plusDays(fertilizingConfig.startDaysAfterSeed.toLong())
            var count = 0
            while (fertStart.isBefore(harvestStart) && count < fertilizingConfig.maxApplications) {
                periods += PlanPeriod(PlanAction.FERTILIZING, fertStart, fertStart.plusDays(fertilizingConfig.windowDays.toLong()))
                fertStart = fertStart.plusDays(fertilizingConfig.intervalDays.toLong())
                count++
            }
        }

        if (wateringConfig != null && wateringConfig.intervalDays > 0 && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var waterStart = seedDate.plusDays(wateringConfig.startDaysAfterSeed.toLong())
            while (waterStart.isBefore(harvestStart)) {
                periods += PlanPeriod(PlanAction.WATERING, waterStart, waterStart.plusDays(wateringConfig.windowDays.toLong()))
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
            val months     = harvestMonths.distinct().sorted()
            val seedMonth  = seedDate.monthValue
            val firstMonth = months.firstOrNull { it > seedMonth } ?: months.first()
            val year       = if (firstMonth <= seedMonth) seedDate.year + 1 else seedDate.year
            LocalDate.of(year, firstMonth, 1) to
                YearMonth.of(year, firstMonth).plusMonths(monthsUntilSeasonEnd(months, firstMonth)).atEndOfMonth()
        }
        else -> null
    }

    /**
     * The season runs up to the longest stretch without harvest in the year. A shorter
     * pause doesn't end it, and a season can continue past New Year.
     */
    private fun monthsUntilSeasonEnd(months: List<Int>, firstMonth: Int): Long {
        val offsets = months.map { (it - firstMonth + 12) % 12 }.sorted()
        val gaps = offsets.zipWithNext { a, b -> b - a } + (12 - offsets.last())
        return offsets[gaps.lastIndexOf(gaps.max())].toLong()
    }
}

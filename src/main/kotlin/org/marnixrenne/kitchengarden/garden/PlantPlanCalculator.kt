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
        hasPruning: Boolean,
        hasFertilizing: Boolean,
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

        if (hasPruning && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            val pruningEnd   = harvestStart.minusDays(14)
            val pruningStart = harvestStart.minusDays(42)
            if (pruningEnd.isAfter(seedDate)) {
                periods += PlanPeriod("pruning", maxOf(pruningStart, seedDate.plusDays(1)), pruningEnd)
            }
        }

        if (hasFertilizing && harvestPeriod != null) {
            val (harvestStart, _) = harvestPeriod
            var fertStart = seedDate.plusDays(14)
            var count = 0
            while (fertStart.isBefore(harvestStart) && count < 3) {
                periods += PlanPeriod("fertilizing", fertStart, fertStart.plusDays(6))
                fertStart = fertStart.plusDays(28)
                count++
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

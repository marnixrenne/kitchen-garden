package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.marnixrenne.kitchengarden.garden.PlantPlanCalculator
import java.time.LocalDate

class PlantPlanCalculatorTest {

    private val seed = LocalDate.of(2025, 4, 1)

    @Test
    fun `germination period uses min and max days`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = 7, germinationDaysMax = 14,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = false,
        )
        val germination = periods.single { it.action == "germination" }
        assertEquals(seed.plusDays(7),  germination.start)
        assertEquals(seed.plusDays(14), germination.end)
    }

    @Test
    fun `germination end equals start when only min is provided`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = 10, germinationDaysMax = null,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = false,
        )
        val germination = periods.single { it.action == "germination" }
        assertEquals(germination.start, germination.end)
    }

    @Test
    fun `harvest period derived from days to maturity`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 60, daysToMaturityMax = 80,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = false,
        )
        val harvest = periods.single { it.action == "harvest" }
        assertEquals(seed.plusDays(60), harvest.start)
        assertEquals(seed.plusDays(80), harvest.end)
    }

    @Test
    fun `harvest period derived from harvest months when maturity unknown`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = listOf(7, 8, 9),
            hasPruning = false, hasFertilizing = false,
        )
        val harvest = periods.single { it.action == "harvest" }
        assertEquals(7, harvest.start.monthValue)
        assertEquals(9, harvest.end.monthValue)
    }

    @Test
    fun `harvest month in next year when all harvest months precede seed month`() {
        val lateSeed = LocalDate.of(2025, 10, 1)
        val periods = PlantPlanCalculator.compute(
            seedDate = lateSeed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = listOf(6, 7),
            hasPruning = false, hasFertilizing = false,
        )
        val harvest = periods.single { it.action == "harvest" }
        assertEquals(2026, harvest.start.year)
    }

    @Test
    fun `pruning window is 6 to 2 weeks before harvest start`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 90, daysToMaturityMax = 90,
            harvestMonths = emptyList(),
            hasPruning = true, hasFertilizing = false,
        )
        val harvestStart = seed.plusDays(90)
        val pruning = periods.single { it.action == "pruning" }
        assertEquals(harvestStart.minusDays(42), pruning.start)
        assertEquals(harvestStart.minusDays(14), pruning.end)
    }

    @Test
    fun `pruning is omitted when harvest is too soon after seeding`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 10, daysToMaturityMax = 10,
            harvestMonths = emptyList(),
            hasPruning = true, hasFertilizing = false,
        )
        assertTrue(periods.none { it.action == "pruning" })
    }

    @Test
    fun `fertilizing generates up to three weekly windows`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 120, daysToMaturityMax = 120,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = true,
        )
        val fertilizing = periods.filter { it.action == "fertilizing" }
        assertEquals(3, fertilizing.size)
        fertilizing.forEach { assertEquals(6, it.start.until(it.end).days) }
    }

    @Test
    fun `fertilizing is omitted when harvest is before first application`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 10, daysToMaturityMax = 10,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = true,
        )
        assertTrue(periods.none { it.action == "fertilizing" })
    }

    @Test
    fun `periods are sorted by start date`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = 7, germinationDaysMax = 14,
            daysToMaturityMin = 90, daysToMaturityMax = 120,
            harvestMonths = emptyList(),
            hasPruning = true, hasFertilizing = true,
        )
        val starts = periods.map { it.start }
        assertEquals(starts.sorted(), starts)
    }

    @Test
    fun `no periods when no plant data provided`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = emptyList(),
            hasPruning = false, hasFertilizing = false,
        )
        assertTrue(periods.isEmpty())
    }
}

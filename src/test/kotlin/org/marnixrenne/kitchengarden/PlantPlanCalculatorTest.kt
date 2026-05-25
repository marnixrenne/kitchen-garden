package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.marnixrenne.kitchengarden.garden.plan.FertilizingConfig
import org.marnixrenne.kitchengarden.garden.plan.PlantPlanCalculator
import org.marnixrenne.kitchengarden.garden.plan.PruningConfig
import org.marnixrenne.kitchengarden.garden.plan.WateringConfig
import java.time.LocalDate

class PlantPlanCalculatorTest {

    private val seed = LocalDate.of(2025, 4, 1)

    private val defaultPruning     = PruningConfig(weeksBeforeStart = 6, weeksBeforeEnd = 2)
    private val defaultFertilizing = FertilizingConfig(startDaysAfterSeed = 14, intervalDays = 28, windowDays = 6, maxApplications = 3)

    @Test
    fun `germination period uses min and max days`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = 7, germinationDaysMax = 14,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = null,
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
            pruningConfig = null, fertilizingConfig = null,
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
            pruningConfig = null, fertilizingConfig = null,
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
            pruningConfig = null, fertilizingConfig = null,
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
            pruningConfig = null, fertilizingConfig = null,
        )
        val harvest = periods.single { it.action == "harvest" }
        assertEquals(2026, harvest.start.year)
    }

    @Test
    fun `pruning window respects config weeks`() {
        val config = PruningConfig(weeksBeforeStart = 6, weeksBeforeEnd = 2)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 90, daysToMaturityMax = 90,
            harvestMonths = emptyList(),
            pruningConfig = config, fertilizingConfig = null,
        )
        val harvestStart = seed.plusDays(90)
        val pruning = periods.single { it.action == "pruning" }
        assertEquals(harvestStart.minusWeeks(6), pruning.start)
        assertEquals(harvestStart.minusWeeks(2), pruning.end)
    }

    @Test
    fun `pruning is omitted when harvest is too soon after seeding`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 10, daysToMaturityMax = 10,
            harvestMonths = emptyList(),
            pruningConfig = defaultPruning, fertilizingConfig = null,
        )
        assertTrue(periods.none { it.action == "pruning" })
    }

    @Test
    fun `fertilizing respects config interval and max applications`() {
        val config = FertilizingConfig(startDaysAfterSeed = 14, intervalDays = 28, windowDays = 6, maxApplications = 3)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 120, daysToMaturityMax = 120,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = config,
        )
        val fertilizing = periods.filter { it.action == "fertilizing" }
        assertEquals(3, fertilizing.size)
        fertilizing.forEach { assertEquals(config.windowDays, it.start.until(it.end).days) }
        assertEquals(seed.plusDays(14), fertilizing[0].start)
        assertEquals(seed.plusDays(42), fertilizing[1].start)
        assertEquals(seed.plusDays(70), fertilizing[2].start)
    }

    @Test
    fun `fertilizing is capped by max applications from config`() {
        val config = FertilizingConfig(startDaysAfterSeed = 14, intervalDays = 14, windowDays = 6, maxApplications = 2)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 120, daysToMaturityMax = 120,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = config,
        )
        assertEquals(2, periods.count { it.action == "fertilizing" })
    }

    @Test
    fun `fertilizing is omitted when max applications is zero`() {
        val config = FertilizingConfig(startDaysAfterSeed = 0, intervalDays = 0, windowDays = 0, maxApplications = 0)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 120, daysToMaturityMax = 120,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = config,
        )
        assertTrue(periods.none { it.action == "fertilizing" })
    }

    @Test
    fun `fertilizing is omitted when harvest is before first application`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 10, daysToMaturityMax = 10,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = defaultFertilizing,
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
            pruningConfig = defaultPruning, fertilizingConfig = defaultFertilizing,
        )
        val starts = periods.map { it.start }
        assertEquals(starts.sorted(), starts)
    }

    @Test
    fun `watering entries are generated at configured intervals until harvest`() {
        val config = WateringConfig(startDaysAfterSeed = 3, intervalDays = 14, windowDays = 7)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 60, daysToMaturityMax = 60,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = null,
            wateringConfig = config,
        )
        val watering = periods.filter { it.action == "watering" }
        assertTrue(watering.isNotEmpty())
        assertEquals(seed.plusDays(3), watering.first().start)
        assertEquals(seed.plusDays(10), watering.first().end)
        assertTrue(watering.all { it.start.isBefore(seed.plusDays(60)) })
    }

    @Test
    fun `watering is omitted when interval is zero`() {
        val config = WateringConfig(startDaysAfterSeed = 0, intervalDays = 0, windowDays = 0)
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = 60, daysToMaturityMax = 60,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = null,
            wateringConfig = config,
        )
        assertTrue(periods.none { it.action == "watering" })
    }

    @Test
    fun `no periods when no plant data provided`() {
        val periods = PlantPlanCalculator.compute(
            seedDate = seed,
            germinationDaysMin = null, germinationDaysMax = null,
            daysToMaturityMin = null, daysToMaturityMax = null,
            harvestMonths = emptyList(),
            pruningConfig = null, fertilizingConfig = null,
        )
        assertTrue(periods.isEmpty())
    }
}

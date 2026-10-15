package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.marnixrenne.kitchengarden.plants.domain.SunExposure
import org.marnixrenne.kitchengarden.plants.domain.SunExposure.*

class SunExposureTest {

    @Test
    fun `a bed is short of sun only when it gets less than the plant needs`() {
        val shortfalls = setOf(
            SHADE to PARTIAL_SHADE,
            SHADE to FULL_SUN,
            PARTIAL_SHADE to FULL_SUN,
        )
        for (exposure in SunExposure.entries) for (requirement in SunExposure.entries) {
            assertEquals(
                (exposure to requirement) in shortfalls,
                SunExposure.isShortfall(exposure, requirement),
                "bed $exposure, plant needs $requirement",
            )
        }
    }

    @Test
    fun `an unknown bed exposure or plant requirement is never a shortfall`() {
        assertEquals(false, SunExposure.isShortfall(null, FULL_SUN))
        assertEquals(false, SunExposure.isShortfall(SHADE, null))
        assertEquals(false, SunExposure.isShortfall(null, null))
    }
}

package org.marnixrenne.kitchengarden.garden.lifecycle.domain

import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.garden.domain.PlantInstanceId
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import java.time.LocalDate

enum class LifecycleState(@JsonValue val key: String) {
    SEEDED_INDOOR("seeded_indoor"),
    SEEDED_OUTDOOR("seeded_outdoor"),
    PLANTED("planted"),
    GERMINATING_INDOOR("germinating_indoor"),
    GERMINATING_OUTDOOR("germinating_outdoor"),
    TRANSPLANTED("transplanted"),
    GROWING("growing"),
    READY_TO_HARVEST("ready_to_harvest"),
    HARVESTED("harvested");

    fun next(): LifecycleState? = when (this) {
        SEEDED_INDOOR      -> GERMINATING_INDOOR
        SEEDED_OUTDOOR      -> GERMINATING_OUTDOOR
        PLANTED            -> GROWING
        GERMINATING_INDOOR -> TRANSPLANTED
        GERMINATING_OUTDOOR -> GROWING
        TRANSPLANTED       -> GROWING
        GROWING            -> READY_TO_HARVEST
        READY_TO_HARVEST   -> HARVESTED
        HARVESTED          -> null
    }

    companion object {
        fun from(key: String): LifecycleState =
            entries.first { it.key == key }
    }
}

data class PlantLifecycle(
    val instanceId: PlantInstanceId,
    val plantId: PlantId,
    val state: LifecycleState,
    val nextState: LifecycleState?,
    val date: LocalDate? = null,
    val comment: String? = null,
)

data class AdvanceRequest(
    val date: LocalDate?,
    val comment: String?,
)

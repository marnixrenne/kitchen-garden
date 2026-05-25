package org.marnixrenne.kitchengarden.garden.lifecycle

import java.util.UUID

enum class LifecycleState(val key: String) {
    SEEDED_INDOOR("seeded_indoor"),
    SEEDED_DIRECT("seeded_direct"),
    PLANTED("planted"),
    GERMINATING_INDOOR("germinating_indoor"),
    GERMINATING_DIRECT("germinating_direct"),
    TRANSPLANTED("transplanted"),
    GROWING("growing"),
    READY_TO_HARVEST("ready_to_harvest"),
    HARVESTED("harvested");

    fun next(): LifecycleState? = when (this) {
        SEEDED_INDOOR      -> GERMINATING_INDOOR
        SEEDED_DIRECT      -> GERMINATING_DIRECT
        PLANTED            -> GROWING
        GERMINATING_INDOOR -> TRANSPLANTED
        GERMINATING_DIRECT -> GROWING
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
    val instanceId: UUID,
    val plantId: UUID,
    val state: String,
    val nextState: String?,
)

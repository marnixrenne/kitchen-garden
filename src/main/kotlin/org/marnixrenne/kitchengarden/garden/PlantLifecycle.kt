package org.marnixrenne.kitchengarden.garden

import java.util.UUID

enum class LifecycleState(val key: String) {
    SEEDED("seeded"),
    GERMINATING("germinating"),
    GROWING("growing"),
    READY_TO_HARVEST("ready_to_harvest"),
    HARVESTED("harvested");

    fun next(): LifecycleState? = when (this) {
        SEEDED           -> GERMINATING
        GERMINATING      -> GROWING
        GROWING          -> READY_TO_HARVEST
        READY_TO_HARVEST -> HARVESTED
        HARVESTED        -> null
    }

    companion object {
        fun from(key: String): LifecycleState =
            entries.first { it.key == key }
    }
}

data class PlantLifecycle(
    val plantId: UUID,
    val state: String,
    val nextState: String?,
)

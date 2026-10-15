package org.marnixrenne.kitchengarden.garden.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonCreator.Mode.DELEGATING
import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.plants.domain.SunExposure
import java.time.LocalDate
import java.util.UUID

data class BedId @JsonCreator(mode = DELEGATING) constructor(@get:JsonValue val value: UUID) {
    override fun toString() = value.toString()
}

enum class BedType(@JsonValue val key: String) {
    IN_GROUND("in_ground"),
    RAISED("raised"),
    CONTAINER("container"),
    GREENHOUSE("greenhouse");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): BedType = entries.first { it.key == key }
    }
}

/** The compass direction a bed faces or slopes toward. */
enum class Aspect(@JsonValue val key: String) {
    N("N"), NE("NE"), E("E"), SE("SE"), S("S"), SW("SW"), W("W"), NW("NW");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): Aspect = entries.first { it.key == key }
    }
}

/** A null [name] marks the bed created together with its garden; the UI labels it "Main bed". */
data class Bed(
    val id: BedId,
    val name: String?,
    val type: BedType?,
    val lengthCm: Int?,
    val widthCm: Int?,
    val sunExposure: SunExposure?,
    val aspect: Aspect?,
)

data class BedRequest(
    val name: String?,
    val type: BedType?,
    val lengthCm: Int?,
    val widthCm: Int?,
    val sunExposure: SunExposure?,
    val aspect: Aspect?,
)

/** What happens to a bed's plant instances when the bed is deleted. */
enum class BedPlantsDisposition(@JsonValue val key: String) {
    MOVE("move"),
    DELETE("delete");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): BedPlantsDisposition = entries.first { it.key == key }
    }
}

data class MoveRequest(
    val bedId: BedId,
    val date: LocalDate?,
    val comment: String?,
)

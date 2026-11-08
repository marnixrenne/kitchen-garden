package org.marnixrenne.kitchengarden.garden.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonCreator.Mode.DELEGATING
import com.fasterxml.jackson.annotation.JsonValue
import org.marnixrenne.kitchengarden.plants.domain.SunExposure
import java.time.LocalDate
import java.util.UUID

data class ZoneId @JsonCreator(mode = DELEGATING) constructor(@get:JsonValue val value: UUID) {
    override fun toString() = value.toString()
}

enum class ZoneType(@JsonValue val key: String) {
    IN_GROUND("in_ground"),
    RAISED("raised"),
    CONTAINER("container"),
    GREENHOUSE("greenhouse");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): ZoneType = entries.first { it.key == key }
    }
}

/** The compass direction a zone faces or slopes toward. */
enum class Aspect(@JsonValue val key: String) {
    N("N"), NE("NE"), E("E"), SE("SE"), S("S"), SW("SW"), W("W"), NW("NW");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): Aspect = entries.first { it.key == key }
    }
}

/** A null [name] marks the zone created together with its garden; the UI labels it "Main zone". */
data class Zone(
    val id: ZoneId,
    val name: String?,
    val type: ZoneType?,
    val lengthCm: Int?,
    val widthCm: Int?,
    val sunExposure: SunExposure?,
    val aspect: Aspect?,
)

data class ZoneRequest(
    val name: String?,
    val type: ZoneType?,
    val lengthCm: Int?,
    val widthCm: Int?,
    val sunExposure: SunExposure?,
    val aspect: Aspect?,
)

/** What happens to a zone's plant instances when the zone is deleted. */
enum class ZonePlantsDisposition(@JsonValue val key: String) {
    MOVE("move"),
    DELETE("delete");

    companion object {
        @JsonCreator
        @JvmStatic
        fun from(key: String): ZonePlantsDisposition = entries.first { it.key == key }
    }
}

data class MoveRequest(
    val zoneId: ZoneId,
    val date: LocalDate?,
    val comment: String?,
)

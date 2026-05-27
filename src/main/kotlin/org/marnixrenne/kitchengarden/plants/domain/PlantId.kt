package org.marnixrenne.kitchengarden.plants.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonCreator.Mode.DELEGATING
import com.fasterxml.jackson.annotation.JsonValue
import java.util.UUID

data class PlantId @JsonCreator(mode = DELEGATING) constructor(@get:JsonValue val value: UUID) {
    override fun toString() = value.toString()
}

package org.marnixrenne.kitchengarden.garden.domain

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonCreator.Mode.DELEGATING
import com.fasterxml.jackson.annotation.JsonValue
import java.util.UUID

data class PlantLogEntryId @JsonCreator(mode = DELEGATING) constructor(@get:JsonValue val value: UUID) {
    override fun toString() = value.toString()
}

package org.marnixrenne.kitchengarden.garden

import java.util.UUID

data class GardenSummary(val id: UUID, val name: String)
data class CreateGardenRequest(val name: String)

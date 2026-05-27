package org.marnixrenne.kitchengarden.garden.domain

import org.marnixrenne.kitchengarden.plants.domain.PlantId

data class GardenSummary(val id: GardenId, val name: String)
data class CreateGardenRequest(val name: String)
data class PlantInstance(val id: PlantInstanceId, val plantId: PlantId)

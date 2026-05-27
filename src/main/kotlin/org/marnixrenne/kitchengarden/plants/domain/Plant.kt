package org.marnixrenne.kitchengarden.plants.domain

data class Plant(
    val id: PlantId,
    val name: String,
    val category: String,
    val emoji: String?,
    val imageUrl: String?
)

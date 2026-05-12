package org.marnixrenne.kitchengarden.plants

import java.util.UUID

data class Plant(
    val id: UUID,
    val name: String,
    val category: String,
    val emoji: String?,
    val imageUrl: String?
)

package org.marnixrenne.kitchengarden.vegetables

import java.util.UUID

data class Vegetable(
    val id: UUID,
    val name: String,
    val category: String,
    val emoji: String?
)

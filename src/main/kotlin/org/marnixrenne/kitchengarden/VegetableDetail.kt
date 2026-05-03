package org.marnixrenne.kitchengarden

import java.util.UUID

data class VegetableDetail(
    val id: UUID,
    val name: String,
    val category: String,
    val emoji: String?,
    val seedingMonths: List<Int>
)

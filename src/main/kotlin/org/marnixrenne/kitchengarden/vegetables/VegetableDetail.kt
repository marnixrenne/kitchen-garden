package org.marnixrenne.kitchengarden.vegetables

import java.util.UUID

data class Country(val code: String, val name: String)

data class VegetableDetail(
    val id: UUID,
    val name: String,
    val category: String,
    val emoji: String?,
    val seedingMonths: List<Int>,
    val harvestingMonths: List<Int>,
    val countries: List<Country>
)

package org.marnixrenne.kitchengarden.garden

data class WeekAction(
    val type: String,              // "sow", "harvest", "both"
    val vegetable: SimpleVeg,
    val sowingMethod: String?,     // "indoor", "direct", "both"
    val germinationDaysMin: Int?,
    val germinationDaysMax: Int?,
)

data class WeekSummary(
    val week: Int,
    val month: Int,
    val weekStartDay: Int,
    val weekStartMonth: Int,
    val weekEndDay: Int,
    val weekEndMonth: Int,
    val actions: List<WeekAction>,
)

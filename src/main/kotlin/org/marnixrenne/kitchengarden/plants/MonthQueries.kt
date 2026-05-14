package org.marnixrenne.kitchengarden.plants

import org.jetbrains.exposed.sql.*
import java.util.UUID

internal fun resolvedMonthNums(
    plantIdCol: Column<UUID>,
    monthNumCol: Column<Int>,
    countryCodeCol: Column<String?>,
    plantId: UUID,
    countryCode: String?,
): List<Int> {
    if (countryCode != null) {
        val country = plantIdCol.table.selectAll()
            .where { (plantIdCol eq plantId) and (countryCodeCol eq countryCode) }
            .map { it[monthNumCol] }.sorted()
        if (country.isNotEmpty()) return country
    }
    return plantIdCol.table.selectAll()
        .where { (plantIdCol eq plantId) and countryCodeCol.isNull() }
        .map { it[monthNumCol] }.sorted()
}

internal fun batchResolvedMonthNums(
    plantIdCol: Column<UUID>,
    monthNumCol: Column<Int>,
    countryCodeCol: Column<String?>,
    ids: List<UUID>,
    countryCode: String?,
): Map<UUID, List<Int>> {
    if (ids.isEmpty()) return emptyMap()

    if (countryCode == null) {
        return plantIdCol.table.selectAll()
            .where { (plantIdCol inList ids) and countryCodeCol.isNull() }
            .groupBy({ it[plantIdCol] }, { it[monthNumCol] })
            .mapValues { it.value.sorted() }
    }

    val countryRows = plantIdCol.table.selectAll()
        .where { (plantIdCol inList ids) and (countryCodeCol eq countryCode) }
        .map { it[plantIdCol] to it[monthNumCol] }

    val plantsWithCountryData = countryRows.map { it.first }.toSet()
    val countryMonthsByPlant  = countryRows.groupBy({ it.first }, { it.second })

    val remaining = ids.filter { it !in plantsWithCountryData }
    val globalMonthsByPlant = if (remaining.isEmpty()) emptyMap() else
        plantIdCol.table.selectAll()
            .where { (plantIdCol inList remaining) and countryCodeCol.isNull() }
            .groupBy({ it[plantIdCol] }, { it[monthNumCol] })

    return ids.associateWith { id ->
        (countryMonthsByPlant[id] ?: globalMonthsByPlant[id] ?: emptyList()).sorted()
    }
}

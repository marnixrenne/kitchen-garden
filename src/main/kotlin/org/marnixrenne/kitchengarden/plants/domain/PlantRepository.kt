package org.marnixrenne.kitchengarden.plants.domain

import java.util.UUID

interface PlantRepository {
    fun findAll(): List<Plant>
    fun findByMonth(month: Int, countryCode: String?): List<Plant>
    fun findById(id: UUID, countryCode: String?): PlantDetail?
    fun countPerMonth(countryCode: String?): Map<Int, Int>
}

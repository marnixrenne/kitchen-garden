package org.marnixrenne.kitchengarden.plants

import org.marnixrenne.kitchengarden.preferences.PreferenceService
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class PlantService(
    private val plantRepository: PlantRepository,
    private val preferenceService: PreferenceService,
) {

    fun findAll(): List<Plant> = plantRepository.findAll()

    fun findByMonth(month: Int, authentication: Authentication?): List<Plant> =
        plantRepository.findByMonth(month, preferenceService.getCountry(authentication))

    fun findById(id: UUID, authentication: Authentication?): PlantDetail? =
        plantRepository.findById(id, preferenceService.getCountry(authentication))

    fun countPerMonth(authentication: Authentication?): Map<Int, Int> =
        plantRepository.countPerMonth(preferenceService.getCountry(authentication))
}

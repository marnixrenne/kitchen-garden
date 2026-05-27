package org.marnixrenne.kitchengarden.plants.application

import org.marnixrenne.kitchengarden.plants.domain.Plant
import org.marnixrenne.kitchengarden.plants.domain.PlantDetail
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.plants.domain.PlantRepository
import org.marnixrenne.kitchengarden.preferences.application.PreferenceApplicationService
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class PlantQueryService(
    private val plantRepository: PlantRepository,
    private val preferenceService: PreferenceApplicationService,
) {

    fun findAll(): List<Plant> = plantRepository.findAll()

    fun findByMonth(month: Int, authentication: Authentication?): List<Plant> =
        plantRepository.findByMonth(month, preferenceService.getCountry(authentication))

    fun findById(id: PlantId, authentication: Authentication?): PlantDetail? =
        plantRepository.findById(id, preferenceService.getCountry(authentication))

    fun countPerMonth(authentication: Authentication?): Map<Int, Int> =
        plantRepository.countPerMonth(preferenceService.getCountry(authentication))
}

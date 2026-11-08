package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.GardenId
import org.marnixrenne.kitchengarden.garden.domain.GardenRepository
import org.marnixrenne.kitchengarden.garden.domain.PlantOption
import org.marnixrenne.kitchengarden.garden.domain.PlantRecommender
import org.marnixrenne.kitchengarden.garden.domain.Zone
import org.marnixrenne.kitchengarden.garden.domain.ZoneId
import org.marnixrenne.kitchengarden.garden.domain.ZoneRepository
import org.marnixrenne.kitchengarden.preferences.application.PreferenceApplicationService
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException

@Service
class ZoneQueryService(
    private val repository: ZoneRepository,
    private val gardenRepository: GardenRepository,
    private val preferenceService: PreferenceApplicationService,
    private val accessGuard: GardenAccessGuard,
) {
    fun list(authentication: Authentication, gardenId: GardenId): List<Zone> =
        repository.findAll(accessGuard.validate(authentication, gardenId))

    fun plantOptions(authentication: Authentication, gardenId: GardenId, zoneId: ZoneId): List<PlantOption> {
        accessGuard.validate(authentication, gardenId)
        val zones = repository.findAll(gardenId)
        val zone = zones.firstOrNull { it.id == zoneId } ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        val instances = gardenRepository.findInstances(gardenId)
        val plantedHere = instances.filter { it.zoneId == zoneId }.map { it.plantId }.toSet()
        return PlantRecommender.options(
            zone = zone,
            zones = zones,
            instances = instances,
            candidates = gardenRepository.findRecommendationCandidates(preferenceService.getCountry(authentication)),
            companions = gardenRepository.findCompanionLinks(plantedHere),
        )
    }
}

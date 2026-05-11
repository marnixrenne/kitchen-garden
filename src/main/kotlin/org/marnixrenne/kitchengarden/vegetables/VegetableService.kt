package org.marnixrenne.kitchengarden.vegetables

import org.marnixrenne.kitchengarden.preferences.PreferenceService
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class VegetableService(
    private val repository: VegetableRepository,
    private val preferenceService: PreferenceService,
) {

    fun findAll(): List<Vegetable> = repository.findAll()

    fun findByMonth(month: Int, authentication: Authentication): List<Vegetable> =
        repository.findByMonth(month, preferenceService.getCountry(authentication))

    fun findById(id: UUID, authentication: Authentication): VegetableDetail? =
        repository.findById(id, preferenceService.getCountry(authentication))

    fun countPerMonth(authentication: Authentication): Map<Int, Int> =
        repository.countPerMonth(preferenceService.getCountry(authentication))
}

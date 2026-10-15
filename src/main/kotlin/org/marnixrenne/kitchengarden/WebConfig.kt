package org.marnixrenne.kitchengarden

import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.garden.plan.domain.PlanEntryId
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.user.domain.UserId
import org.springframework.context.annotation.Configuration
import org.springframework.format.FormatterRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import java.util.UUID

@Configuration
class WebConfig : WebMvcConfigurer {
    override fun addFormatters(registry: FormatterRegistry) {
        registry.addConverter(String::class.java, PlantId::class.java)       { PlantId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, GardenId::class.java)      { GardenId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, PlantInstanceId::class.java) { PlantInstanceId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, PlantLogId::class.java)    { PlantLogId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, PlantLogEntryId::class.java) { PlantLogEntryId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, BedId::class.java)         { BedId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, BedPlantsDisposition::class.java) { BedPlantsDisposition.from(it) }
        registry.addConverter(String::class.java, PlanEntryId::class.java)   { PlanEntryId(UUID.fromString(it)) }
        registry.addConverter(String::class.java, UserId::class.java)        { UserId(UUID.fromString(it)) }
    }
}

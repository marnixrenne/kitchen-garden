package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.spring.autoconfigure.ExposedAutoConfiguration
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication(exclude = [ExposedAutoConfiguration::class])
class KitchenGardenApplication

fun main(args: Array<String>) {
    runApplication<KitchenGardenApplication>(*args)
}

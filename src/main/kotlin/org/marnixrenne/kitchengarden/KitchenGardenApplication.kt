package org.marnixrenne.kitchengarden

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class KitchenGardenApplication

fun main(args: Array<String>) {
    runApplication<KitchenGardenApplication>(*args)
}

package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.Database
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import javax.sql.DataSource

@Configuration
class ExposedConfig {

    @Bean
    fun exposedDatabase(dataSource: DataSource): Database =
        Database.connect(dataSource)
}
package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.spring.ExposedSpringTransactionAttributeSource
import org.jetbrains.exposed.spring.SpringTransactionManager
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import javax.sql.DataSource

@Configuration
class ExposedConfig {

    @Bean
    fun springTransactionManager(dataSource: DataSource): SpringTransactionManager =
        SpringTransactionManager(dataSource)

    @Bean
    @Primary
    fun exposedSpringTransactionAttributeSource(): ExposedSpringTransactionAttributeSource =
        ExposedSpringTransactionAttributeSource()
}

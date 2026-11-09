package org.marnixrenne.kitchengarden

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.context.annotation.Bean
import org.testcontainers.containers.PostgreSQLContainer

@TestConfiguration(proxyBeanMethods = false)
class TestcontainersConfig {

    // One database for every Spring context: Exposed uses whichever context connected last
    @Bean(destroyMethod = "")
    @ServiceConnection
    fun postgres(): PostgreSQLContainer<*> = container

    private companion object {
        val container: PostgreSQLContainer<*> by lazy { PostgreSQLContainer("postgres:15-alpine").apply { start() } }
    }
}

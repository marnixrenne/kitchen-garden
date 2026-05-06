package org.marnixrenne.kitchengarden

import org.hamcrest.Matchers.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.put

class GardenApiTest : IntegrationTestBase() {

    @Autowired lateinit var jdbc: JdbcTemplate

    private fun tomatoId() =
        jdbc.queryForObject("SELECT id FROM vegetables WHERE name = 'Tomato'", String::class.java)!!

    @Test
    fun `authenticated user starts with empty garden`() {
        mvc.get("/api/garden") {
            with(httpBasic("admin", "admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(empty<String>()) }
        }
    }

    @Test
    fun `user can add and remove a vegetable from garden`() {
        val id = tomatoId()

        mvc.put("/api/garden/$id") {
            with(httpBasic("admin", "admin"))
        }.andExpect { status { isNoContent() } }

        mvc.get("/api/garden") {
            with(httpBasic("admin", "admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(hasItem(id)) }
        }

        mvc.delete("/api/garden/$id") {
            with(httpBasic("admin", "admin"))
        }.andExpect { status { isNoContent() } }

        mvc.get("/api/garden") {
            with(httpBasic("admin", "admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(not(hasItem(id))) }
        }
    }

    @Test
    fun `garden details returns full vegetable info including countries`() {
        val id = tomatoId()

        mvc.put("/api/garden/$id") { with(httpBasic("admin", "admin")) }

        mvc.get("/api/garden/details") {
            with(httpBasic("admin", "admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$[*].name") { value(hasItem("Tomato")) }
            jsonPath("$[?(@.name=='Tomato')].countries") { value(hasSize<Any>(greaterThan(0))) }
            jsonPath("$[?(@.name=='Tomato')].seedingMonths") { value(hasSize<Any>(greaterThan(0))) }
        }

        mvc.delete("/api/garden/$id") { with(httpBasic("admin", "admin")) }
    }
}

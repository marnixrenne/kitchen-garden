package org.marnixrenne.kitchengarden

import org.hamcrest.Matchers.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.web.servlet.get

class VegetableApiTest : IntegrationTestBase() {

    @Autowired lateinit var jdbc: JdbcTemplate

    @Test
    fun `GET vegetables returns all 157 vegetables when no month given`() {
        mvc.get("/api/vegetables")
            .andExpect {
                status { isOk() }
                content { contentTypeCompatibleWith(MediaType.APPLICATION_JSON) }
                jsonPath("$.length()") { value(157) }
            }
    }

    @Test
    fun `GET vegetables filtered by month returns only seeding vegetables for that month`() {
        mvc.get("/api/vegetables?month=3")
            .andExpect {
                status { isOk() }
                jsonPath("$.length()") { value(greaterThan(0)) }
                jsonPath("$[*].name") { value(hasItem("Tomato")) }
            }
    }

    @Test
    fun `GET vegetables with invalid month returns 400`() {
        mvc.get("/api/vegetables?month=13")
            .andExpect { status { isBadRequest() } }

        mvc.get("/api/vegetables?month=0")
            .andExpect { status { isBadRequest() } }
    }

    @Test
    fun `GET vegetable by id returns detail with months and countries`() {
        val id = jdbc.queryForObject("SELECT id FROM vegetables WHERE name = 'Tomato'", String::class.java)!!

        mvc.get("/api/vegetables/$id")
            .andExpect {
                status { isOk() }
                jsonPath("$.name") { value("Tomato") }
                jsonPath("$.category") { value("Fruiting") }
                jsonPath("$.seedingMonths") { value(hasItems(2, 3, 4)) }
                jsonPath("$.harvestingMonths") { value(hasSize<Int>(greaterThan(0))) }
                jsonPath("$.countries") { value(hasSize<Int>(greaterThan(0))) }
                jsonPath("$.countries[*].code") { value(hasItem("NL")) }
            }
    }

    @Test
    fun `GET vegetable by unknown id returns 404`() {
        mvc.get("/api/vegetables/00000000-0000-0000-0000-000000000000")
            .andExpect { status { isNotFound() } }
    }

    @Test
    fun `GET counts returns entries for months that have seeding vegetables`() {
        mvc.get("/api/vegetables/counts")
            .andExpect {
                status { isOk() }
                jsonPath("$.3") { value(greaterThan(0)) }
                jsonPath("$.6") { value(greaterThan(0)) }
            }
    }
}

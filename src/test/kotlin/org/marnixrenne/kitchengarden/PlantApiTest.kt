package org.marnixrenne.kitchengarden

import org.hamcrest.Matchers.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.web.servlet.get

class PlantApiTest : IntegrationTestBase() {

    @Autowired lateinit var jdbc: JdbcTemplate

    @Test
    fun `GET plants returns all 181 plants when no month given`() {
        mvc.get("/api/plants")
            .andExpect {
                status { isOk() }
                content { contentTypeCompatibleWith(MediaType.APPLICATION_JSON) }
                jsonPath("$.length()") { value(181) }
            }
    }

    @Test
    fun `GET plants filtered by month returns only seeding plants for that month`() {
        mvc.get("/api/plants?month=3")
            .andExpect {
                status { isOk() }
                jsonPath("$.length()") { value(greaterThan(0)) }
                jsonPath("$[*].name") { value(hasItem("Tomato")) }
            }
    }

    @Test
    fun `GET plants with invalid month returns 400`() {
        mvc.get("/api/plants?month=13")
            .andExpect { status { isBadRequest() } }

        mvc.get("/api/plants?month=0")
            .andExpect { status { isBadRequest() } }
    }

    @Test
    fun `GET plant by id returns detail with months and countries`() {
        val id = jdbc.queryForObject("SELECT id FROM pts_plants WHERE name = 'Tomato'", String::class.java)!!

        mvc.get("/api/plants/$id")
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
    fun `GET plant by unknown id returns 404`() {
        mvc.get("/api/plants/00000000-0000-0000-0000-000000000000")
            .andExpect { status { isNotFound() } }
    }

    @Test
    fun `GET counts returns entries for months that have seeding plants`() {
        mvc.get("/api/plants/counts")
            .andExpect {
                status { isOk() }
                jsonPath("$.3") { value(greaterThan(0)) }
                jsonPath("$.6") { value(greaterThan(0)) }
            }
    }
}

package org.marnixrenne.kitchengarden

import org.hamcrest.Matchers.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post
import org.springframework.test.web.servlet.put

class GardenApiTest : IntegrationTestBase() {

    @Autowired lateinit var jdbc: JdbcTemplate

    private fun tomatoId() =
        jdbc.queryForObject("SELECT id FROM pts_plants WHERE name = 'Tomato'", String::class.java)!!

    private fun createGardenId(username: String = "admin", name: String = "Test-${System.nanoTime()}"): String {
        mvc.post("/api/gardens") {
            with(user(username)); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":"$name"}"""
        }.andExpect { status { isCreated() } }
        return jdbc.queryForObject("SELECT id FROM pts_garden WHERE name = ?", String::class.java, name)!!
    }

    @Test
    fun `authenticated user starts with empty garden`() {
        val gardenId = createGardenId()
        mvc.get("/api/gardens/$gardenId") {
            with(user("admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(empty<String>()) }
        }
    }

    @Test
    fun `user can add and remove a plant from garden`() {
        val gardenId = createGardenId()
        val id = tomatoId()

        mvc.put("/api/gardens/$gardenId/plants/$id") {
            with(user("admin"))
            with(csrf())
        }.andExpect { status { isNoContent() } }

        mvc.get("/api/gardens/$gardenId") {
            with(user("admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(hasItem(id)) }
        }

        mvc.delete("/api/gardens/$gardenId/plants/$id") {
            with(user("admin"))
            with(csrf())
        }.andExpect { status { isNoContent() } }

        mvc.get("/api/gardens/$gardenId") {
            with(user("admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$") { value(not(hasItem(id))) }
        }
    }

    @Test
    fun `garden details returns full plant info including countries`() {
        val gardenId = createGardenId()
        val id = tomatoId()

        mvc.put("/api/gardens/$gardenId/plants/$id") { with(user("admin")); with(csrf()) }

        mvc.get("/api/gardens/$gardenId/details") {
            with(user("admin"))
        }.andExpect {
            status { isOk() }
            jsonPath("$[*].name") { value(hasItem("Tomato")) }
            jsonPath("$[?(@.name=='Tomato')].countries") { value(hasSize<Any>(greaterThan(0))) }
            jsonPath("$[?(@.name=='Tomato')].seedingMonths") { value(hasSize<Any>(greaterThan(0))) }
        }

        mvc.delete("/api/gardens/$gardenId/plants/$id") { with(user("admin")); with(csrf()) }
    }

    @Test
    fun `deleting a garden removes all instances, log entries and plan entries`() {
        val tomatoId = tomatoId()
        val gardenId = createGardenId(name = "Delete Cascade Test Garden ${System.nanoTime()}")

        // Add tomato to the garden, creating an instance
        mvc.put("/api/gardens/$gardenId/plants/$tomatoId") {
            with(user("admin")); with(csrf())
        }.andExpect { status { isNoContent() } }

        val instanceId = jdbc.queryForObject(
            "SELECT id FROM garden_plant_instances WHERE garden_id = ?::uuid",
            String::class.java, gardenId)!!

        // Seed the plant — creates a plant log row and multiple plan entries
        mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"$instanceId","action":"seeding_direct","date":"2025-04-01","comment":null}"""
        }.andExpect { status { isCreated() } }

        val logId = jdbc.queryForObject(
            "SELECT id FROM pts_plant_log WHERE instance_id = ?::uuid",
            String::class.java, instanceId)!!

        val logEntryId = jdbc.queryForObject(
            "SELECT id FROM pts_plant_log_entry WHERE log_id = ?::uuid",
            String::class.java, logId)!!

        // Sanity-check preconditions
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM pts_garden WHERE id = ?::uuid", Int::class.java, gardenId))
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM garden_plant_instances WHERE id = ?::uuid", Int::class.java, instanceId))
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_log WHERE id = ?::uuid", Int::class.java, logId))
        assertTrue(
            jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_plan_entry WHERE log_entry_id = ?::uuid", Int::class.java, logEntryId)!! > 0,
            "Expected plan entries to exist before deletion"
        )

        // Delete the garden
        mvc.delete("/api/gardens/$gardenId") {
            with(user("admin")); with(csrf())
        }.andExpect { status { isNoContent() } }

        // Verify every related row is gone
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_garden WHERE id = ?::uuid", Int::class.java, gardenId))
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM garden_plant_instances WHERE id = ?::uuid", Int::class.java, instanceId))
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_log WHERE id = ?::uuid", Int::class.java, logId))
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_log_entry WHERE log_id = ?::uuid", Int::class.java, logId))
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_plan_entry WHERE log_entry_id = ?::uuid", Int::class.java, logEntryId))
    }
}

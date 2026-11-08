package org.marnixrenne.kitchengarden

import com.jayway.jsonpath.JsonPath
import org.hamcrest.Matchers.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user
import org.springframework.test.web.servlet.*
import java.time.LocalDate
import java.util.UUID

class ZoneApiTest : IntegrationTestBase() {

    @Autowired lateinit var jdbc: JdbcTemplate

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun plantId(name: String) =
        jdbc.queryForObject("SELECT id FROM pts_plants WHERE name = ?", String::class.java, name)!!

    private fun createGarden(username: String = "admin"): String {
        val name = "Zones-${System.nanoTime()}"
        mvc.post("/api/gardens") {
            with(user(username)); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":"$name"}"""
        }.andExpect { status { isCreated() } }
        return jdbc.queryForObject("SELECT id FROM pts_garden WHERE name = ?", String::class.java, name)!!
    }

    private fun initialZone(gardenId: String) =
        jdbc.queryForObject("SELECT id FROM pts_garden_zone WHERE garden_id = ?::uuid AND name IS NULL", String::class.java, gardenId)!!

    private fun createZone(gardenId: String, body: String): ResultActionsDsl =
        mvc.post("/api/gardens/$gardenId/zones") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = body
        }

    private fun createZoneId(gardenId: String, name: String, sun: String? = null): String {
        val sunJson = sun?.let { "\"$it\"" } ?: "null"
        val json = createZone(gardenId, """{"name":"$name","sunExposure":$sunJson}""")
            .andExpect { status { isCreated() } }
            .andReturn().response.contentAsString
        return JsonPath.read(json, "$.id")
    }

    private fun addPlant(gardenId: String, plant: String, zoneId: String? = null): ResultActionsDsl =
        mvc.put("/api/gardens/$gardenId/plants/${plantId(plant)}" + (zoneId?.let { "?zoneId=$it" } ?: "")) {
            with(user("admin")); with(csrf())
        }

    private fun instanceId(gardenId: String, plant: String) = jdbc.queryForObject(
        "SELECT id FROM garden_plant_instances WHERE garden_id = ?::uuid AND plant_id = ?::uuid",
        String::class.java, gardenId, plantId(plant))!!

    private fun zoneOf(instanceId: String) =
        jdbc.queryForObject("SELECT zone_id FROM garden_plant_instances WHERE id = ?::uuid", String::class.java, instanceId)

    private fun move(gardenId: String, instanceId: String, zoneId: String, extra: String = ""): ResultActionsDsl =
        mvc.post("/api/gardens/$gardenId/instances/$instanceId/move") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"zoneId":"$zoneId"$extra}"""
        }

    private fun deleteZone(gardenId: String, zoneId: String, query: String = ""): ResultActionsDsl =
        mvc.delete("/api/gardens/$gardenId/zones/$zoneId$query") { with(user("admin")); with(csrf()) }

    private fun movedEntries(instanceId: String) = jdbc.queryForList(
        """
        SELECT e.id::text AS id, e.date, e.comment, e.from_zone_id::text AS from_zone_id, e.to_zone_id::text AS to_zone_id,
               e.from_zone_name, e.to_zone_name
        FROM pts_plant_log_entry e JOIN pts_plant_log l ON l.id = e.log_id
        WHERE l.instance_id = ?::uuid AND e.action = 'moved'
        ORDER BY e.created_at
        """, instanceId)

    // ── Zones ──────────────────────────────────────────────────────────────────

    @Test
    fun `a new garden starts with exactly one unnamed zone`() {
        val gardenId = createGarden()

        mvc.get("/api/gardens/$gardenId/zones") { with(user("admin")) }.andExpect {
            status { isOk() }
            jsonPath("$") { value(hasSize<Any>(1)) }
            jsonPath("$[0].name") { value(nullValue()) }
        }
    }

    @Test
    fun `zones are created with all properties and listed in creation order`() {
        val gardenId = createGarden()

        createZone(gardenId, """{"name":"Raised one","type":"raised","lengthCm":240,"widthCm":120,"sunExposure":"partial_shade","aspect":"SW"}""")
            .andExpect {
                status { isCreated() }
                jsonPath("$.name") { value("Raised one") }
                jsonPath("$.type") { value("raised") }
                jsonPath("$.lengthCm") { value(240) }
                jsonPath("$.widthCm") { value(120) }
                jsonPath("$.sunExposure") { value("partial_shade") }
                jsonPath("$.aspect") { value("SW") }
            }
        createZoneId(gardenId, "Second")

        mvc.get("/api/gardens/$gardenId/zones") { with(user("admin")) }.andExpect {
            jsonPath("$[*].name") { value(contains(null, "Raised one", "Second")) }
        }
    }

    @Test
    fun `a created zone needs a name and dimensions between 1 and 10000 cm`() {
        val gardenId = createGarden()

        createZone(gardenId, """{"name":"  "}""").andExpect { status { isBadRequest() } }
        createZone(gardenId, """{"name":"Tiny","lengthCm":0}""").andExpect { status { isBadRequest() } }
        createZone(gardenId, """{"name":"Huge","widthCm":10001}""").andExpect { status { isBadRequest() } }
        createZone(gardenId, """{"name":"Edges","lengthCm":1,"widthCm":10000}""").andExpect { status { isCreated() } }
    }

    @Test
    fun `the initial zone can be updated while staying unnamed, but a named zone keeps a name`() {
        val gardenId = createGarden()
        val zoneId = initialZone(gardenId)

        mvc.put("/api/gardens/$gardenId/zones/$zoneId") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":null,"sunExposure":"full_sun","aspect":"S"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.name") { value(nullValue()) }
            jsonPath("$.sunExposure") { value("full_sun") }
        }

        val namedId = createZoneId(gardenId, "Herbs")
        mvc.put("/api/gardens/$gardenId/zones/$namedId") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":""}"""
        }.andExpect { status { isBadRequest() } }
    }

    @Test
    fun `another user cannot see or change zones`() {
        val gardenId = createGarden()
        val zoneId = initialZone(gardenId)
        val otherUser = "zone-intruder-${System.nanoTime()}"
        jdbc.update(
            "INSERT INTO sec_users (id, username, password, display_name) VALUES (?, ?, 'x', 'Intruder')",
            UUID.randomUUID(), otherUser,
        )

        mvc.get("/api/gardens/$gardenId/zones") { with(user(otherUser)) }
            .andExpect { status { isNotFound() } }
        mvc.put("/api/gardens/$gardenId/zones/$zoneId") {
            with(user(otherUser)); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":"Mine now"}"""
        }.andExpect { status { isNotFound() } }
        mvc.delete("/api/gardens/$gardenId/zones/$zoneId") { with(user(otherUser)); with(csrf()) }
            .andExpect { status { isNotFound() } }
    }

    // ── Adding plants ─────────────────────────────────────────────────────────

    @Test
    fun `with one zone a plant is added without naming a zone`() {
        val gardenId = createGarden()

        addPlant(gardenId, "Tomato").andExpect { status { isNoContent() } }

        assertEquals(initialZone(gardenId), zoneOf(instanceId(gardenId, "Tomato")))
        mvc.get("/api/gardens/$gardenId/instances") { with(user("admin")) }.andExpect {
            jsonPath("$[0].zoneId") { value(initialZone(gardenId)) }
        }
    }

    @Test
    fun `with several zones a plant needs an explicit zone from the same garden`() {
        val gardenId = createGarden()
        val herbs = createZoneId(gardenId, "Herbs")
        val otherGardenZone = initialZone(createGarden())

        addPlant(gardenId, "Basil").andExpect { status { isBadRequest() } }
        addPlant(gardenId, "Basil", otherGardenZone).andExpect { status { isBadRequest() } }
        addPlant(gardenId, "Basil", herbs).andExpect { status { isNoContent() } }

        assertEquals(herbs, zoneOf(instanceId(gardenId, "Basil")))
    }

    @Test
    fun `instances flag a sun shortfall only when the zone gets less sun than the plant needs`() {
        val gardenId = createGarden()
        val shady = createZoneId(gardenId, "Shady", sun = "shade")
        val sunny = createZoneId(gardenId, "Sunny", sun = "full_sun")
        val unknown = initialZone(gardenId)

        addPlant(gardenId, "Tomato", shady)     // full sun plant in shade
        addPlant(gardenId, "Lettuce", sunny)    // partial shade plant in full sun
        addPlant(gardenId, "Carrot", unknown)   // zone sun unknown

        mvc.get("/api/gardens/$gardenId/instances") { with(user("admin")) }.andExpect {
            jsonPath("$[?(@.plantId=='${plantId("Tomato")}')].sunShortfall") { value(contains(true)) }
            jsonPath("$[?(@.plantId=='${plantId("Lettuce")}')].sunShortfall") { value(contains(false)) }
            jsonPath("$[?(@.plantId=='${plantId("Carrot")}')].sunShortfall") { value(contains(false)) }
        }
    }

    // ── Moves ─────────────────────────────────────────────────────────────────

    @Test
    fun `moving a plant changes its zone and logs a move without touching lifecycle or plan`() {
        val gardenId = createGarden()
        val main = initialZone(gardenId)
        addPlant(gardenId, "Tomato")
        val instance = instanceId(gardenId, "Tomato")
        mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"$instance","action":"seeding_outdoor","date":"2025-04-01","comment":null}"""
        }.andExpect { status { isCreated() } }
        val planBefore = jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_plan_entry", Int::class.java)
        val greenhouse = createZoneId(gardenId, "Greenhouse")

        move(gardenId, instance, greenhouse, ""","date":"2025-05-02","comment":"Too cold outside"""").andExpect {
            status { isCreated() }
            jsonPath("$.action") { value("moved") }
            jsonPath("$.fromZoneId") { value(main) }
            jsonPath("$.toZoneId") { value(greenhouse) }
            jsonPath("$.fromZoneName") { value(nullValue()) }
            jsonPath("$.toZoneName") { value("Greenhouse") }
        }

        assertEquals(greenhouse, zoneOf(instance))
        val entry = movedEntries(instance).single()
        assertEquals("2025-05-02", entry["date"].toString())
        assertEquals("Too cold outside", entry["comment"])
        assertEquals(planBefore, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_plan_entry", Int::class.java))
        mvc.get("/api/gardens/$gardenId/lifecycle") { with(user("admin")) }.andExpect {
            jsonPath("$['$instance'].state") { value("seeded_outdoor") }
        }
    }

    @Test
    fun `moving a plant that has no log yet gives it no lifecycle state`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")
        val zone = createZoneId(gardenId, "Roots")

        move(gardenId, instance, zone).andExpect { status { isCreated() } }

        assertEquals(LocalDate.now().toString(), movedEntries(instance).single()["date"].toString())
        mvc.get("/api/gardens/$gardenId/lifecycle") { with(user("admin")) }.andExpect {
            jsonPath("$['$instance']") { doesNotExist() }
        }

        // The first real action still sets the starting lifecycle state
        mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"$instance","action":"seeding_indoor","date":"2025-03-01","comment":null}"""
        }.andExpect { status { isCreated() } }
        mvc.get("/api/gardens/$gardenId/lifecycle") { with(user("admin")) }.andExpect {
            jsonPath("$['$instance'].state") { value("seeded_indoor") }
        }
    }

    @Test
    fun `a move needs a different zone in the same garden`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")

        move(gardenId, instance, initialZone(gardenId)).andExpect { status { isBadRequest() } }
        move(gardenId, instance, initialZone(createGarden())).andExpect { status { isBadRequest() } }
    }

    @Test
    fun `moves cannot be posted as ordinary log entries`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")

        mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"${instanceId(gardenId, "Carrot")}","action":"moved","date":"2025-03-01","comment":null}"""
        }.andExpect { status { isBadRequest() } }
    }

    @Test
    fun `only the date and comment of a move entry can be edited and it cannot be deleted`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")
        val roots = createZoneId(gardenId, "Roots")
        move(gardenId, instance, roots)
        val entryId = movedEntries(instance).single()["id"] as String

        mvc.patch("/api/gardens/$gardenId/plant-log/$entryId") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"date":"2025-06-10","comment":"Fixed date","toZoneId":"${initialZone(gardenId)}"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.date") { value("2025-06-10") }
            jsonPath("$.toZoneId") { value(roots) }
        }

        val entry = movedEntries(instance).single()
        assertEquals("2025-06-10", entry["date"].toString())
        assertEquals("Fixed date", entry["comment"])
        assertEquals(roots, entry["to_zone_id"])

        mvc.delete("/api/gardens/$gardenId/plant-log/$entryId") { with(user("admin")); with(csrf()) }
            .andExpect { status { isMethodNotAllowed() } }
    }

    @Test
    fun `other log entries cannot be edited`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")
        val json = mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"$instance","action":"watering","date":"2025-06-01","comment":null}"""
        }.andReturn().response.contentAsString
        val entryId: String = JsonPath.read(json, "$.id")

        mvc.patch("/api/gardens/$gardenId/plant-log/$entryId") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"date":"2025-06-02","comment":null}"""
        }.andExpect { status { isBadRequest() } }
    }

    // ── Deleting zones ─────────────────────────────────────────────────────────

    @Test
    fun `the last zone of a garden cannot be deleted`() {
        val gardenId = createGarden()

        deleteZone(gardenId, initialZone(gardenId)).andExpect { status { isConflict() } }
    }

    @Test
    fun `an empty zone is deleted without further questions`() {
        val gardenId = createGarden()
        val spare = createZoneId(gardenId, "Spare")

        deleteZone(gardenId, spare).andExpect { status { isNoContent() } }

        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_garden_zone WHERE id = ?::uuid", Int::class.java, spare))
    }

    @Test
    fun `a zone with plants needs to be told what happens to them`() {
        val gardenId = createGarden()
        val herbs = createZoneId(gardenId, "Herbs")
        addPlant(gardenId, "Basil", herbs)

        deleteZone(gardenId, herbs).andExpect { status { isConflict() } }
        deleteZone(gardenId, herbs, "?plants=move").andExpect { status { isBadRequest() } }
        deleteZone(gardenId, herbs, "?plants=move&targetZoneId=$herbs").andExpect { status { isBadRequest() } }
    }

    @Test
    fun `deleting a zone while moving its plants logs a move for each one dated today`() {
        val gardenId = createGarden()
        val main = initialZone(gardenId)
        val herbs = createZoneId(gardenId, "Herbs")
        addPlant(gardenId, "Basil", herbs)
        addPlant(gardenId, "Parsley", herbs)

        deleteZone(gardenId, herbs, "?plants=move&targetZoneId=$main").andExpect { status { isNoContent() } }

        for (plant in listOf("Basil", "Parsley")) {
            val instance = instanceId(gardenId, plant)
            assertEquals(main, zoneOf(instance))
            val entry = movedEntries(instance).single()
            assertEquals(LocalDate.now().toString(), entry["date"].toString())
            assertNull(entry["from_zone_id"], "The deleted zone's id is cleared")
            assertEquals("Herbs", entry["from_zone_name"], "The deleted zone's name survives")
            assertEquals(main, entry["to_zone_id"])
        }
    }

    @Test
    fun `deleting a zone with its plants removes their instances, logs and plans`() {
        val gardenId = createGarden()
        val herbs = createZoneId(gardenId, "Herbs")
        addPlant(gardenId, "Basil", herbs)
        val instance = instanceId(gardenId, "Basil")
        mvc.post("/api/gardens/$gardenId/plant-log") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"instanceId":"$instance","action":"seeding_outdoor","date":"2025-04-01","comment":null}"""
        }.andExpect { status { isCreated() } }
        val logId = jdbc.queryForObject("SELECT id FROM pts_plant_log WHERE instance_id = ?::uuid", String::class.java, instance)!!

        deleteZone(gardenId, herbs, "?plants=delete").andExpect { status { isNoContent() } }

        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM garden_plant_instances WHERE id = ?::uuid", Int::class.java, instance))
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_log WHERE id = ?::uuid", Int::class.java, logId))
        assertEquals(0, jdbc.queryForObject(
            "SELECT COUNT(*) FROM pts_plant_plan_entry p JOIN pts_plant_log_entry e ON e.id = p.log_entry_id WHERE e.log_id = ?::uuid",
            Int::class.java, logId))
    }

    @Test
    fun `renaming or deleting a zone keeps the names recorded in earlier moves`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")
        val roots = createZoneId(gardenId, "Roots")
        move(gardenId, instance, roots)
        move(gardenId, instance, initialZone(gardenId))

        mvc.put("/api/gardens/$gardenId/zones/$roots") {
            with(user("admin")); with(csrf())
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":"Renamed"}"""
        }.andExpect { status { isOk() } }
        deleteZone(gardenId, roots).andExpect { status { isNoContent() } }

        val (first, second) = movedEntries(instance)
        assertNull(first["to_zone_id"])
        assertEquals("Roots", first["to_zone_name"])
        assertNull(second["from_zone_id"])
        assertEquals("Roots", second["from_zone_name"])
        mvc.get("/api/gardens/$gardenId/plant-log") { with(user("admin")) }.andExpect {
            jsonPath("$['$instance'][*].action") { value(everyItem(equalTo("moved"))) }
        }
    }

    @Test
    fun `deleting a garden removes its zones`() {
        val gardenId = createGarden()
        addPlant(gardenId, "Carrot")
        val instance = instanceId(gardenId, "Carrot")
        move(gardenId, instance, createZoneId(gardenId, "Roots"))

        mvc.delete("/api/gardens/$gardenId") { with(user("admin")); with(csrf()) }
            .andExpect { status { isNoContent() } }

        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM pts_garden_zone WHERE garden_id = ?::uuid", Int::class.java, gardenId))
    }
}

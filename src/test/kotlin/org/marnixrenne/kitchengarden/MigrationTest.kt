package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.JdbcTemplate

class MigrationTest : IntegrationTestBase() {

    @Autowired
    lateinit var jdbc: JdbcTemplate

    @Test
    fun `all flyway migrations apply cleanly`() {
        val count = jdbc.queryForObject(
            "SELECT COUNT(*) FROM flyway_schema_history WHERE success = true",
            Int::class.java
        )!!
        // V1 through V64 (no V32)
        assertEquals(63, count, "Expected 63 successful migrations")
    }

    @Test
    fun `plants table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM pts_plants", Int::class.java)!!
        // 24 (V2) + 45 (V12) + 1 (V13) + 87 (V14) + 9 (V33) + 3 (V34) + 12 (V44) + 2 (V61) = 183
        assertEquals(183, count, "Expected 183 plants total")
    }

    @Test
    fun `countries table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM countries", Int::class.java)!!
        assertEquals(35, count, "Expected 35 countries")
    }

    @Test
    fun `plant_countries table is populated`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM pts_plant_countries", Int::class.java)!!
        assert(count > 0) { "pts_plant_countries should have entries" }
    }

    @Test
    fun `every original plant has seeding months`() {
        val missing = jdbc.queryForList(
            """
            SELECT v.name FROM pts_plants v
            LEFT JOIN pts_seeding_months sm ON sm.plant_id = v.id
            WHERE sm.plant_id IS NULL
              AND v.name NOT IN ('Grape Leaves', 'Aonori', 'Arame', 'Dulse', 'Hijiki',
                                  'Kombu', 'Nori', 'Sea Lettuce', 'Sea Grape', 'Wakame')
            """,
            String::class.java
        )
        assertEquals(emptyList<String>(), missing, "These plants have no seeding months: $missing")
    }

    @Test
    fun `every plant has harvesting months except sea vegetables and grape leaves`() {
        val missing = jdbc.queryForList(
            """
            SELECT v.name FROM pts_plants v
            LEFT JOIN pts_harvesting_months hm ON hm.plant_id = v.id
            WHERE hm.plant_id IS NULL
              AND v.name NOT IN ('Aonori', 'Arame', 'Dulse', 'Hijiki',
                                  'Kombu', 'Nori', 'Sea Lettuce', 'Sea Grape', 'Wakame')
            """,
            String::class.java
        )
        assertEquals(emptyList<String>(), missing, "These plants have no harvesting months: $missing")
    }
}

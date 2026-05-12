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
        // V1 through V20
        assertEquals(24, count, "Expected 24 successful migrations")
    }

    @Test
    fun `plants table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM plants", Int::class.java)!!
        // 24 (V2) + 45 (V12) + 1 (V13) + 87 (V14) = 157
        assertEquals(157, count, "Expected 157 plants total")
    }

    @Test
    fun `countries table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM countries", Int::class.java)!!
        assertEquals(35, count, "Expected 35 countries")
    }

    @Test
    fun `plant_countries table is populated`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM plant_countries", Int::class.java)!!
        assert(count > 0) { "plant_countries should have entries" }
    }

    @Test
    fun `every original plant has seeding months`() {
        val missing = jdbc.queryForList(
            """
            SELECT v.name FROM plants v
            LEFT JOIN seeding_months sm ON sm.plant_id = v.id
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
            SELECT v.name FROM plants v
            LEFT JOIN harvesting_months hm ON hm.plant_id = v.id
            WHERE hm.plant_id IS NULL
              AND v.name NOT IN ('Aonori', 'Arame', 'Dulse', 'Hijiki',
                                  'Kombu', 'Nori', 'Sea Lettuce', 'Sea Grape', 'Wakame')
            """,
            String::class.java
        )
        assertEquals(emptyList<String>(), missing, "These plants have no harvesting months: $missing")
    }
}

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
        // V1 through V17
        assertEquals(17, count, "Expected 17 successful migrations")
    }

    @Test
    fun `vegetables table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM vegetables", Int::class.java)!!
        // 24 (V2) + 45 (V12) + 1 (V13) + 87 (V14) = 157
        assertEquals(157, count, "Expected 157 vegetables total")
    }

    @Test
    fun `countries table contains all seeded records`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM countries", Int::class.java)!!
        assertEquals(35, count, "Expected 35 countries")
    }

    @Test
    fun `vegetable_countries table is populated`() {
        val count = jdbc.queryForObject("SELECT COUNT(*) FROM vegetable_countries", Int::class.java)!!
        assert(count > 0) { "vegetable_countries should have entries" }
    }

    @Test
    fun `every original vegetable has seeding months`() {
        val missing = jdbc.queryForList(
            """
            SELECT v.name FROM vegetables v
            LEFT JOIN seeding_months sm ON sm.vegetable_id = v.id
            WHERE sm.vegetable_id IS NULL
              AND v.name NOT IN ('Grape Leaves', 'Aonori', 'Arame', 'Dulse', 'Hijiki',
                                  'Kombu', 'Nori', 'Sea Lettuce', 'Sea Grape', 'Wakame')
            """,
            String::class.java
        )
        assertEquals(emptyList<String>(), missing, "These vegetables have no seeding months: $missing")
    }

    @Test
    fun `every vegetable has harvesting months except sea vegetables and grape leaves`() {
        val missing = jdbc.queryForList(
            """
            SELECT v.name FROM vegetables v
            LEFT JOIN harvesting_months hm ON hm.vegetable_id = v.id
            WHERE hm.vegetable_id IS NULL
              AND v.name NOT IN ('Aonori', 'Arame', 'Dulse', 'Hijiki',
                                  'Kombu', 'Nori', 'Sea Lettuce', 'Sea Grape', 'Wakame')
            """,
            String::class.java
        )
        assertEquals(emptyList<String>(), missing, "These vegetables have no harvesting months: $missing")
    }
}

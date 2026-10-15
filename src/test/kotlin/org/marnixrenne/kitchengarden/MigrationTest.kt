package org.marnixrenne.kitchengarden

import org.flywaydb.core.Flyway
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.JdbcTemplate
import javax.sql.DataSource

class MigrationTest : IntegrationTestBase() {

    @Autowired
    lateinit var jdbc: JdbcTemplate

    @Autowired
    lateinit var dataSource: DataSource

    @Test
    fun `all flyway migrations apply cleanly`() {
        val count = jdbc.queryForObject(
            "SELECT COUNT(*) FROM flyway_schema_history WHERE success = true",
            Int::class.java
        )!!
        // V1 through V77 (no V32)
        assertEquals(76, count, "Expected 76 successful migrations")
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

    @Test
    fun `bed migration gives every existing garden one unnamed bed holding all its instances`() {
        val schema = "bed_backfill_${System.nanoTime()}"
        fun flyway(target: String) = Flyway.configure()
            .dataSource(dataSource)
            .schemas(schema)
            .target(target)
            .load()

        try {
            flyway("74").migrate()
            jdbc.execute("INSERT INTO $schema.sec_users SELECT * FROM public.sec_users WHERE username = 'admin'")
            jdbc.execute(
                """
                INSERT INTO $schema.pts_garden (id, user_id, name)
                SELECT g.id, u.id, g.name
                FROM (VALUES ('11111111-1111-1111-1111-111111111111'::uuid, 'Front'),
                             ('22222222-2222-2222-2222-222222222222'::uuid, 'Back'),
                             ('33333333-3333-3333-3333-333333333333'::uuid, 'Empty')) AS g(id, name)
                CROSS JOIN (SELECT id FROM $schema.sec_users WHERE username = 'admin') u
                """
            )
            jdbc.execute(
                """
                INSERT INTO $schema.garden_plant_instances (garden_id, plant_id)
                SELECT g.id, p.id
                FROM (VALUES ('11111111-1111-1111-1111-111111111111'::uuid),
                             ('22222222-2222-2222-2222-222222222222'::uuid)) AS g(id)
                CROSS JOIN (SELECT id FROM $schema.pts_plants WHERE name IN ('Tomato', 'Carrot', 'Basil')) p
                """
            )

            flyway("latest").migrate()

            val bedsPerGarden = jdbc.queryForList(
                "SELECT garden_id::text AS garden, COUNT(*) AS beds, COUNT(name) AS named FROM $schema.pts_garden_bed GROUP BY garden_id"
            ).associate { it["garden"] as String to (it["beds"] as Long to it["named"] as Long) }
            assertEquals(3, bedsPerGarden.size, "Every garden, including an empty one, gets a bed")
            bedsPerGarden.values.forEach { assertEquals(1L to 0L, it, "Exactly one unnamed bed per garden") }

            val misplaced = jdbc.queryForObject(
                """
                SELECT COUNT(*) FROM $schema.garden_plant_instances i
                JOIN $schema.pts_garden_bed b ON b.id = i.bed_id
                WHERE b.garden_id <> i.garden_id
                """,
                Int::class.java,
            )
            val placed = jdbc.queryForObject("SELECT COUNT(*) FROM $schema.garden_plant_instances WHERE bed_id IS NOT NULL", Int::class.java)
            assertEquals(0, misplaced)
            assertEquals(6, placed)
        } finally {
            jdbc.execute("DROP SCHEMA IF EXISTS $schema CASCADE")
        }
    }
}

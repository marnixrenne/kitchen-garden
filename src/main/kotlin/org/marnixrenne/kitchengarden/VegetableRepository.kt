package org.marnixrenne.kitchengarden

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate
import org.springframework.stereotype.Repository

@Repository
class VegetableRepository(private val jdbc: NamedParameterJdbcTemplate) {

    fun findByMonth(month: Int): List<Vegetable> =
        jdbc.query(
            """
            SELECT v.id, v.name, v.category, v.emoji
            FROM vegetables v
            JOIN seeding_months sm ON v.id = sm.vegetable_id
            WHERE sm.month_num = :month
            ORDER BY v.category, v.name
            """.trimIndent(),
            mapOf("month" to month)
        ) { rs, _ ->
            Vegetable(
                id       = rs.getLong("id"),
                name     = rs.getString("name"),
                category = rs.getString("category"),
                emoji    = rs.getString("emoji")
            )
        }

    fun countPerMonth(): Map<Int, Int> =
        jdbc.query(
            """
            SELECT month_num, COUNT(*) AS cnt
            FROM seeding_months
            GROUP BY month_num
            ORDER BY month_num
            """.trimIndent(),
            emptyMap<String, Any>()
        ) { rs, _ -> rs.getInt("month_num") to rs.getInt("cnt") }
            .toMap()
}
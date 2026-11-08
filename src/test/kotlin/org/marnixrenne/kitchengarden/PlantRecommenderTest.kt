package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.marnixrenne.kitchengarden.garden.domain.*
import org.marnixrenne.kitchengarden.plants.domain.InsectAttraction
import org.marnixrenne.kitchengarden.plants.domain.PlantId
import org.marnixrenne.kitchengarden.plants.domain.SunExposure
import org.marnixrenne.kitchengarden.plants.domain.SunExposure.*
import java.util.UUID

class PlantRecommenderTest {

    private val plantIds = mutableMapOf<String, PlantId>()
    private fun id(name: String) = plantIds.getOrPut(name) { PlantId(UUID.randomUUID()) }

    private fun zone(sun: SunExposure? = null, name: String? = "Bed") =
        Zone(ZoneId(UUID.randomUUID()), name, null, null, null, sun, null)

    private fun veg(name: String) = SimpleVeg(id(name), name, null)

    private fun candidate(
        name: String,
        sun: SunExposure? = FULL_SUN,
        category: String = "Root",
        available: Boolean = true,
        insects: List<InsectAttraction> = emptyList(),
    ) = RecommendationCandidate(veg(name), category, sun, available, insects)

    private fun pest(name: String) = InsectAttraction(name, "pest")
    private fun beneficial(name: String) = InsectAttraction(name, "beneficial")
    private val bee = InsectAttraction("bumblebee", "pollinator")

    private fun planting(name: String, zone: Zone) =
        PlantInstance(PlantInstanceId(UUID.randomUUID()), id(name), zone.id, false)

    private fun good(a: String, b: String) = CompanionLink(id(a), id(b), good = true)
    private fun bad(a: String, b: String) = CompanionLink(id(a), id(b), good = false)

    private fun recommended(options: List<PlantOption>) = options.filter { it.recommended }.map { it.name }
    private fun List<PlantOption>.named(name: String) = first { it.name == name }

    private fun options(
        zone: Zone,
        candidates: List<RecommendationCandidate>,
        instances: List<PlantInstance> = emptyList(),
        companions: List<CompanionLink> = emptyList(),
        zones: List<Zone> = listOf(zone),
    ) = PlantRecommender.options(zone, zones, instances, candidates, companions)

    // ── Exclusions ────────────────────────────────────────────────────────────

    @Test
    fun `plants needing more sun than the zone gets are not recommended but stay available`() {
        val result = options(zone(PARTIAL_SHADE), listOf(candidate("Tomato", FULL_SUN), candidate("Parsley", PARTIAL_SHADE)))

        assertEquals(listOf("Parsley"), recommended(result))
        assertTrue(result.named("Tomato").sunShortfall)
    }

    @Test
    fun `a bad companion of anything in the zone is not recommended, whichever way the pair is stored`() {
        val bed = zone(FULL_SUN)
        val candidates = listOf(candidate("Carrot"), candidate("Dill"), candidate("Fennel"), candidate("Basil"))

        val result = options(
            bed, candidates,
            instances = listOf(planting("Carrot", bed)),
            companions = listOf(bad("Carrot", "Dill"), bad("Fennel", "Carrot")),
        )

        assertEquals(listOf("Basil"), recommended(result))
        assertEquals(listOf("Carrot"), result.named("Dill").badWith.map { it.name })
        assertEquals(listOf("Carrot"), result.named("Fennel").badWith.map { it.name })
    }

    @Test
    fun `companions of plants in other zones do not count`() {
        val bed = zone(FULL_SUN)
        val other = zone(FULL_SUN, "Kas")

        val result = options(
            bed, listOf(candidate("Carrot"), candidate("Dill")),
            instances = listOf(planting("Carrot", other)),
            companions = listOf(bad("Carrot", "Dill")),
            zones = listOf(bed, other),
        )

        assertTrue(result.named("Dill").recommended)
    }

    @Test
    fun `a plant already in this zone is not recommended and reports its count`() {
        val bed = zone(FULL_SUN)

        val result = options(bed, listOf(candidate("Carrot")), instances = listOf(planting("Carrot", bed), planting("Carrot", bed)))

        assertFalse(result.named("Carrot").recommended)
        assertEquals(2, result.named("Carrot").inThisZone)
    }

    @Test
    fun `sea plants and fruit are never recommended but stay available`() {
        val result = options(zone(FULL_SUN), listOf(candidate("Nori", category = "Sea"), candidate("Apple", category = "Fruit"), candidate("Beet")))

        assertEquals(listOf("Beet"), recommended(result))
        assertEquals(3, result.size)
    }

    @Test
    fun `plants not listed for the country are not recommended but stay available`() {
        val result = options(zone(FULL_SUN), listOf(candidate("Cassava", available = false), candidate("Beet")))

        assertEquals(listOf("Beet"), recommended(result))
        assertEquals(2, result.size)
    }

    // ── Needing a reason ──────────────────────────────────────────────────────

    @Test
    fun `a plant with no reason is not recommended, even if nothing rules it out`() {
        val result = options(zone(FULL_SUN), listOf(candidate("Unknown", null), candidate("Shade", SHADE), candidate("Exact", FULL_SUN)))

        assertEquals(listOf("Exact"), recommended(result))
    }

    @Test
    fun `an empty zone with no sun exposure recommends nothing`() {
        assertEquals(emptyList<String>(), recommended(options(zone(null), listOf(candidate("Beet"), candidate("Kale")))))
    }

    @Test
    fun `a good companion is enough on its own, without knowing the sun`() {
        val bed = zone(null)

        val result = options(bed, listOf(candidate("Carrot"), candidate("Leek", null)), instances = listOf(planting("Carrot", bed)), companions = listOf(good("Carrot", "Leek")))

        assertEquals(listOf("Leek"), recommended(result))
    }

    @Test
    fun `only an exact sun match is reported as one`() {
        val result = options(zone(FULL_SUN), listOf(candidate("Exact", FULL_SUN), candidate("Shade", SHADE)))

        assertEquals(FULL_SUN, result.named("Exact").sunMatch)
        assertNull(result.named("Shade").sunMatch)
    }

    // ── Insects ───────────────────────────────────────────────────────────────

    @Test
    fun `a plant attracting a predator of a pest in the zone earns pest control`() {
        val bed = zone(null)
        val candidates = listOf(candidate("Tomato", insects = listOf(pest("aphid"))), candidate("Calendula", null, insects = listOf(beneficial("ladybird"))))

        val result = options(bed, candidates, instances = listOf(planting("Tomato", bed)))

        assertEquals(PestControl("ladybird", "aphid", veg("Tomato")), result.named("Calendula").pestControl)
        assertTrue(result.named("Calendula").recommended)
    }

    @Test
    fun `a predator only counts for the pests it tackles`() {
        val bed = zone(null)
        val candidates = listOf(candidate("Bean", insects = listOf(pest("blackfly"))), candidate("Wasp plant", null, insects = listOf(beneficial("parasitic_wasp"))))

        val result = options(bed, candidates, instances = listOf(planting("Bean", bed)))

        assertNull(result.named("Wasp plant").pestControl)
        assertFalse(result.named("Wasp plant").recommended)
    }

    @Test
    fun `a plant attracting the pest as well as its predator still counts`() {
        val bed = zone(null)
        val candidates = listOf(candidate("Tomato", insects = listOf(pest("aphid"))), candidate("Nasturtium", null, insects = listOf(beneficial("ladybird"), pest("aphid"))))

        assertTrue(options(bed, candidates, instances = listOf(planting("Tomato", bed))).named("Nasturtium").recommended)
    }

    @Test
    fun `pests of plants in other zones do not count`() {
        val bed = zone(null)
        val other = zone(null, "Kas")
        val candidates = listOf(candidate("Tomato", insects = listOf(pest("aphid"))), candidate("Calendula", null, insects = listOf(beneficial("ladybird"))))

        val result = options(bed, candidates, instances = listOf(planting("Tomato", other)), zones = listOf(bed, other))

        assertNull(result.named("Calendula").pestControl)
    }

    @Test
    fun `pollinators count only when something in the zone sets fruit or pods`() {
        val leafy = zone(null)
        val fruiting = zone(null, "Kas")
        val candidates = listOf(candidate("Lettuce", category = "Leafy"), candidate("Tomato", category = "Fruiting"), candidate("Pea", category = "Legume"), candidate("Borage", null, insects = listOf(bee)))
        val instances = listOf(planting("Lettuce", leafy), planting("Tomato", fruiting), planting("Pea", fruiting))
        val zones = listOf(leafy, fruiting)

        assertEquals(emptyList<SimpleVeg>(), options(leafy, candidates, instances, zones = zones).named("Borage").pollinatorsFor)
        assertEquals(listOf("Pea", "Tomato"), options(fruiting, candidates, instances, zones = zones).named("Borage").pollinatorsFor.map { it.name })
    }

    @Test
    fun `sharing a pest with the zone neither penalises nor excludes a plant`() {
        val bed = zone(FULL_SUN)
        val candidates = listOf(candidate("Tomato", insects = listOf(pest("aphid"))), candidate("Kale", insects = listOf(pest("aphid"))))

        assertTrue(options(bed, candidates, instances = listOf(planting("Tomato", bed))).named("Kale").recommended)
    }

    // ── Order ─────────────────────────────────────────────────────────────────

    @Test
    fun `good companions outrank insect benefits, which outrank an exact sun match`() {
        val bed = zone(FULL_SUN)
        val candidates = listOf(
            candidate("Neighbour", category = "Fruiting"),
            candidate("Exact", FULL_SUN),
            candidate("Insect", SHADE, insects = listOf(bee)),
            candidate("Companion", SHADE),
        )

        val result = options(bed, candidates, instances = listOf(planting("Neighbour", bed)), companions = listOf(good("Neighbour", "Companion")))

        assertEquals(listOf("Companion", "Insect", "Exact"), recommended(result))
    }

    @Test
    fun `more good companions rank higher`() {
        val bed = zone(FULL_SUN)
        val candidates = listOf(candidate("One"), candidate("Two"), candidate("A"), candidate("B"))

        val result = options(
            bed, candidates,
            instances = listOf(planting("A", bed), planting("B", bed)),
            companions = listOf(good("A", "One"), good("A", "Two"), good("B", "Two")),
        )

        assertEquals(listOf("Two", "One"), recommended(result))
        assertEquals(listOf("A", "B"), result.named("Two").goodWith.map { it.name })
    }

    @Test
    fun `two insect benefits outrank one`() {
        val bed = zone(null)
        val candidates = listOf(
            candidate("Tomato", category = "Fruiting", insects = listOf(pest("aphid"))),
            candidate("One", null, insects = listOf(bee)),
            candidate("Both", null, insects = listOf(bee, beneficial("lacewing"))),
        )

        assertEquals(listOf("Both", "One"), recommended(options(bed, candidates, instances = listOf(planting("Tomato", bed)))))
    }

    @Test
    fun `ties spread across categories, alphabetically within each`() {
        val candidates = listOf(
            candidate("Beet", category = "Root"), candidate("Carrot", category = "Root"), candidate("Radish", category = "Root"),
            candidate("Kale", category = "Leafy"), candidate("Chard", category = "Leafy"),
        )

        assertEquals(listOf("Chard", "Beet", "Kale", "Carrot", "Radish"), recommended(options(zone(FULL_SUN), candidates)))
    }

    @Test
    fun `at most eight are recommended, and the rest follow by name`() {
        val candidates = (1..10).map { candidate("Plant $it") } + candidate("Aardappel", SHADE)

        val result = options(zone(FULL_SUN), candidates)

        assertEquals(8, result.count { it.recommended })
        assertEquals(11, result.size)
        val rest = result.filter { !it.recommended }.map { it.name }
        assertEquals(rest.sorted(), rest)
    }

    // ── Notes ─────────────────────────────────────────────────────────────────

    @Test
    fun `a plant in another zone is still recommended, noting where it grows`() {
        val bed = zone(FULL_SUN)
        val kas = zone(FULL_SUN, "Kas")
        val unnamed = zone(FULL_SUN, null)

        val result = options(
            bed, listOf(candidate("Tomato")),
            instances = listOf(planting("Tomato", kas), planting("Tomato", kas), planting("Tomato", unnamed)),
            zones = listOf(bed, kas, unnamed),
        )

        assertTrue(result.named("Tomato").recommended)
        assertEquals(listOf("Kas", null), result.named("Tomato").alsoIn)
    }
}

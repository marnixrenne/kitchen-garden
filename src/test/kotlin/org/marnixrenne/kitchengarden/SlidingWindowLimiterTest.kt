package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.marnixrenne.kitchengarden.security.BruteForceProtectionService
import org.marnixrenne.kitchengarden.security.SlidingWindowLimiter

class SlidingWindowLimiterTest {

    private var time = 1_000_000L

    private fun limiter(maxHits: Int = 2, maxKeys: Int = 100) =
        SlidingWindowLimiter(windowMs = 1_000, maxHits = maxHits, maxKeys = maxKeys, now = { time })

    @Test
    fun `stops counting at the limit, per key`() {
        val limiter = limiter()

        assertTrue(limiter.tryAcquire("a"))
        assertTrue(limiter.tryAcquire("a"))
        assertFalse(limiter.tryAcquire("a"))
        assertTrue(limiter.tryAcquire("b"))
    }

    @Test
    fun `allows hits again once the window has passed`() {
        val limiter = limiter()
        repeat(2) { limiter.tryAcquire("a") }

        time += 1_001

        assertTrue(limiter.tryAcquire("a"))
    }

    @Test
    fun `release takes back one hit`() {
        val limiter = limiter()
        repeat(2) { limiter.tryAcquire("a") }

        limiter.release("a")

        assertTrue(limiter.tryAcquire("a"))
        assertFalse(limiter.tryAcquire("a"))
    }

    @Test
    fun `keeps the most recent keys when random keys flood it`() {
        val limiter = limiter(maxHits = 1, maxKeys = 10)
        limiter.record("oldest")
        repeat(10) { time += 1; limiter.record("key-$it") }
        time += 1
        limiter.record("newest")

        assertFalse(limiter.isAtLimit("oldest"))
        assertTrue(limiter.isAtLimit("newest"))
    }

    @Test
    fun `never holds more keys than its maximum`() {
        val limiter = limiter(maxHits = 1, maxKeys = 10)
        repeat(1_000) { limiter.record("key-$it") }

        val held = (0 until 1_000).count { limiter.isAtLimit("key-$it") }

        assertTrue(held <= 10, "held $held keys")
    }
}

class BruteForceProtectionTest {

    private var time = 1_000_000L
    private val protection = BruteForceProtectionService { time }

    @Test
    fun `guessing one account from many addresses blocks that account`() {
        repeat(99) { protection.recordFailure("victim", "ip-$it") }
        assertFalse(protection.isBlocked("victim", "ip-new"))

        protection.recordFailure("victim", "ip-99")

        assertTrue(protection.isBlocked("victim", "ip-new"))
    }

    @Test
    fun `an unknown address falls back to a limit per account`() {
        repeat(10) { protection.recordFailure("user", null) }

        assertTrue(protection.isBlocked("user", null))
        assertFalse(protection.isBlocked("other", null))
    }

    @Test
    fun `usernames differing only in case count as one account`() {
        repeat(10) { protection.recordFailure("User@Example.test", "ip") }

        assertTrue(protection.isBlocked("user@example.test", "ip"))
    }

    @Test
    fun `logging in to your own account does not excuse guessing at others`() {
        repeat(49) { protection.recordFailure("user-$it", "ip") }
        protection.reset("mine", "ip")
        protection.recordFailure("user-49", "ip")

        assertTrue(protection.isBlocked("anyone", "ip"))
    }

    @Test
    fun `a block ends after the window`() {
        repeat(10) { protection.recordFailure("user", "ip") }

        time += 15 * 60 * 1_000L + 1

        assertFalse(protection.isBlocked("user", "ip"))
    }
}

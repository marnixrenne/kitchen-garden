package org.marnixrenne.kitchengarden.security

import java.util.concurrent.ConcurrentHashMap

/**
 * Counts hits per key over a sliding time window. Holds at most [maxKeys] keys: once
 * full, it drops expired keys and then the ones longest unused, so random keys can't
 * grow memory without limit.
 */
class SlidingWindowLimiter(
    private val windowMs: Long,
    private val maxHits: Int,
    private val maxKeys: Int = 10_000,
    private val now: () -> Long = System::currentTimeMillis,
) {
    private val hits = ConcurrentHashMap<String, List<Long>>()

    /** Counts a hit unless the key is already at its limit; returns whether it was counted. */
    fun tryAcquire(key: String): Boolean {
        val time = now()
        var acquired = false
        hits.compute(key) { _, list ->
            val live = live(list, time)
            if (live.size < maxHits) {
                acquired = true
                live + time
            } else {
                live
            }.ifEmpty { null }
        }
        if (acquired) keepBounded(time)
        return acquired
    }

    fun record(key: String) {
        val time = now()
        hits.compute(key) { _, list -> live(list, time) + time }
        keepBounded(time)
    }

    fun isAtLimit(key: String): Boolean {
        val time = now()
        var atLimit = false
        hits.computeIfPresent(key) { _, list ->
            val live = live(list, time)
            atLimit = live.size >= maxHits
            live.ifEmpty { null }
        }
        return atLimit
    }

    /** Takes back the latest hit, for work that turned out not to happen. */
    fun release(key: String) {
        hits.computeIfPresent(key) { _, list -> list.dropLast(1).ifEmpty { null } }
    }

    fun reset(key: String) {
        hits.remove(key)
    }

    private fun live(list: List<Long>?, time: Long): List<Long> =
        list.orEmpty().filter { it >= time - windowMs }

    private fun keepBounded(time: Long) {
        if (hits.size <= maxKeys) return
        hits.keys.toList().forEach { key ->
            hits.computeIfPresent(key) { _, list -> live(list, time).ifEmpty { null } }
        }
        val excess = hits.size - maxKeys
        if (excess <= 0) return
        // Free a tenth at once, so a full map isn't sorted again on every new key
        hits.entries
            .map { it.key to it.value.last() }
            .sortedBy { it.second }
            .take(excess + maxKeys / 10)
            .forEach { hits.remove(it.first) }
    }
}

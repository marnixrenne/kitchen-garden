package org.marnixrenne.kitchengarden.security

import org.springframework.stereotype.Service
import java.util.concurrent.ConcurrentHashMap

@Service
class BruteForceProtectionService {

    private val failedAttempts = ConcurrentHashMap<String, MutableList<Long>>()

    private val windowMs    = 15 * 60 * 1_000L
    private val maxAttempts = 10

    fun recordFailure(username: String) {
        val now = System.currentTimeMillis()
        // compute() holds a bucket-level lock, making the get-or-create + append atomic.
        failedAttempts.compute(username) { _, list ->
            (list ?: mutableListOf()).also { it.add(now) }
        }
    }

    fun isBlocked(username: String): Boolean {
        val now = System.currentTimeMillis()
        var blocked = false
        failedAttempts.compute(username) { _, list ->
            if (list == null) return@compute null
            list.removeIf { it < now - windowMs }
            blocked = list.size >= maxAttempts
            list.ifEmpty { null }
        }
        return blocked
    }

    fun reset(username: String) {
        failedAttempts.remove(username)
    }
}

package org.marnixrenne.kitchengarden.security

import org.springframework.stereotype.Service
import java.util.concurrent.ConcurrentHashMap

@Service
class BruteForceProtectionService {

    private val failedAttempts = ConcurrentHashMap<String, MutableList<Long>>()

    private val windowMs = 15 * 60 * 1_000L
    private val maxAttempts = 10

    fun recordFailure(username: String) {
        val now = System.currentTimeMillis()
        val list = failedAttempts.getOrPut(username) { mutableListOf() }
        synchronized(list) { list.add(now) }
    }

    fun isBlocked(username: String): Boolean {
        val now = System.currentTimeMillis()
        val list = failedAttempts[username] ?: return false
        synchronized(list) {
            list.removeIf { it < now - windowMs }
            return list.size >= maxAttempts
        }
    }

    fun reset(username: String) {
        failedAttempts.remove(username)
    }
}

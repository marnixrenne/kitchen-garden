package org.marnixrenne.kitchengarden.security

import org.springframework.stereotype.Service

/**
 * Limits failed logins over 15 minutes. A block normally applies only to the address
 * doing the guessing, so that a stranger can't lock someone out of their account. The
 * much higher limit per account catches guessing spread over many addresses.
 *
 * An unknown address (null) falls back to the limit per account and address alone.
 */
@Service
class BruteForceProtectionService(now: () -> Long = System::currentTimeMillis) {

    private val windowMs = 15 * 60 * 1_000L

    private val perAccountAndAddress = SlidingWindowLimiter(windowMs, maxHits = 10, now = now)
    private val perAddress           = SlidingWindowLimiter(windowMs, maxHits = 50, now = now)
    private val perAccount           = SlidingWindowLimiter(windowMs, maxHits = 100, now = now)

    fun recordFailure(username: String, ip: String?) {
        val account = accountKey(username)
        perAccountAndAddress.record(pairKey(account, ip))
        perAccount.record(account)
        ip?.let(perAddress::record)
    }

    fun isBlocked(username: String, ip: String?): Boolean {
        val account = accountKey(username)
        return perAccountAndAddress.isAtLimit(pairKey(account, ip)) ||
            perAccount.isAtLimit(account) ||
            (ip != null && perAddress.isAtLimit(ip))
    }

    /** After a successful login. The address keeps its count: logging in to one's own account mustn't excuse guessing at others. */
    fun reset(username: String, ip: String?) {
        val account = accountKey(username)
        perAccountAndAddress.reset(pairKey(account, ip))
        perAccount.reset(account)
    }

    // Capped at the longest possible email address, so huge usernames can't fill memory
    private fun accountKey(username: String) = username.lowercase().take(254)

    private fun pairKey(account: String, ip: String?) = "${ip ?: "unknown"}|$account"
}

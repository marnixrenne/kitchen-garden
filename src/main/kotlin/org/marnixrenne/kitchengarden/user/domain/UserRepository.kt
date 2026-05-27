package org.marnixrenne.kitchengarden.user.domain

interface UserRepository {
    fun findIdByUsername(username: String): UserId?
}

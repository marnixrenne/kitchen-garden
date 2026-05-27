package org.marnixrenne.kitchengarden.user.domain

import java.util.UUID

interface UserRepository {
    fun findIdByUsername(username: String): UUID?
}

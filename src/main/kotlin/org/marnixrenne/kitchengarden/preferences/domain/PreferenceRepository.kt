package org.marnixrenne.kitchengarden.preferences.domain

import java.util.UUID

interface PreferenceRepository {
    fun findAll(userId: UUID): Map<String, String>
    fun set(userId: UUID, key: String, value: String)
    fun delete(userId: UUID, key: String)
}

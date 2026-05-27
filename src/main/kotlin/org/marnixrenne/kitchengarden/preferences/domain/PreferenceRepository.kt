package org.marnixrenne.kitchengarden.preferences.domain

import org.marnixrenne.kitchengarden.user.domain.UserId

interface PreferenceRepository {
    fun findAll(userId: UserId): Map<String, String>
    fun set(userId: UserId, key: String, value: String)
    fun delete(userId: UserId, key: String)
}

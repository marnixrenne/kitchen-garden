package org.marnixrenne.kitchengarden.security

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import java.util.UUID

class AppUserDetails(
    val userId: UUID,
    private val username: String,
    private val password: String,
    private val authorities: Collection<GrantedAuthority>,
    private val enabled: Boolean,
) : UserDetails {
    override fun getUsername()             = username
    override fun getPassword()             = password
    override fun getAuthorities()          = authorities
    override fun isEnabled()               = enabled
    override fun isAccountNonExpired()     = true
    override fun isAccountNonLocked()      = true
    override fun isCredentialsNonExpired() = true
}

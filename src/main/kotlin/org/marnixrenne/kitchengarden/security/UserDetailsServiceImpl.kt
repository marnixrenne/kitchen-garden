package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.marnixrenne.kitchengarden.*
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class UserDetailsServiceImpl : UserDetailsService {

    override fun loadUserByUsername(username: String): UserDetails =
        transaction {
            val userRow = Users.selectAll()
                .where { Users.username eq username }
                .firstOrNull()
                ?: throw UsernameNotFoundException("User not found: $username")

            val authorities = UserRoles
                .join(RoleAuthorities, JoinType.INNER, UserRoles.roleId, RoleAuthorities.roleId)
                .select(RoleAuthorities.authority)
                .where { UserRoles.userId eq userRow[Users.id] }
                .map { SimpleGrantedAuthority(it[RoleAuthorities.authority]) }

            User.builder()
                .username(userRow[Users.username])
                .password(userRow[Users.password])
                .authorities(authorities)
                .build()
        }
}

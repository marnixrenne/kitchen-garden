package org.marnixrenne.kitchengarden

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class UserDetailsServiceImpl : UserDetailsService {

    override fun loadUserByUsername(username: String): UserDetails =
        transaction {
            Users.selectAll()
                .where { Users.username eq username }
                .map { row ->
                    User.builder()
                        .username(row[Users.username])
                        .password(row[Users.password])
                        .roles("USER")
                        .build()
                }
                .firstOrNull()
        } ?: throw UsernameNotFoundException("User not found: $username")
}

package org.marnixrenne.kitchengarden.security

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.beans.factory.annotation.Value
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.marnixrenne.kitchengarden.mail.MailService
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

@Service
class SignupService(
    private val passwordEncoder: PasswordEncoder,
    private val mailService: MailService,
    @Value("\${app.base-url}") private val baseUrl: String,
) {

    private val emailRegex = Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")

    // Simple in-memory rate limiter: max 3 signup attempts per email per hour
    private val signupAttempts = ConcurrentHashMap<String, MutableList<Long>>()

    fun initiateSignup(email: String) {
        if (!emailRegex.matches(email)) throw IllegalArgumentException("Invalid email address")

        checkSignupRateLimit(email)

        // If the email is already registered, silently succeed to avoid account enumeration
        val alreadyRegistered = transaction {
            Users.selectAll().where { Users.username eq email }.count() > 0
        }
        if (alreadyRegistered) return

        val token     = UUID.randomUUID()
        val expiresAt = System.currentTimeMillis() + 24 * 60 * 60 * 1_000L

        transaction {
            SignupTokens.deleteWhere { SignupTokens.email eq email }
            SignupTokens.insert {
                it[SignupTokens.token]     = token
                it[SignupTokens.email]     = email
                it[SignupTokens.expiresAt] = expiresAt
            }
        }

        val verifyUrl = "$baseUrl/verify?token=$token"
        mailService.send(
            to      = email,
            subject = "Verify your Kitchen Garden account",
            text    = "Click the link below to complete your registration:\n\n$verifyUrl\n\nThe link expires in 24 hours.",
            html    = """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                </head>
                <body style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:2rem;color:#1b4332">
                  <h2 style="margin-bottom:0.5rem">🌱 Kitchen Garden</h2>
                  <p style="color:#52796f;margin-bottom:1.5rem">Verify your email address to complete your registration.</p>
                  <a href="$verifyUrl" target="_blank" rel="noopener noreferrer"
                     style="display:inline-block;padding:0.75rem 1.5rem;background:#2d6a4f;color:#ffffff;text-decoration:none;border-radius:8px;font-weight:600;font-size:1rem">
                    Verify my email
                  </a>
                  <p style="margin-top:1.5rem;font-size:0.85rem;color:#52796f">
                    Or copy this link into your browser:<br>
                    <a href="$verifyUrl" target="_blank" rel="noopener noreferrer" style="color:#2d6a4f;word-break:break-all">$verifyUrl</a>
                  </p>
                  <p style="font-size:0.8rem;color:#52796f">This link expires in 24 hours.</p>
                </body>
                </html>
            """.trimIndent(),
        )
    }

    /** Returns the email address if the token is valid and unexpired, null otherwise. */
    fun validateToken(tokenStr: String): String? {
        val token = runCatching { UUID.fromString(tokenStr) }.getOrNull() ?: return null
        return transaction {
            SignupTokens.selectAll()
                .where { (SignupTokens.token eq token) and (SignupTokens.expiresAt greater System.currentTimeMillis()) }
                .map { it[SignupTokens.email] }
                .firstOrNull()
        }
    }

    fun completeSignup(tokenStr: String, password: String) {
        validatePassword(password)

        val token = runCatching { UUID.fromString(tokenStr) }.getOrNull()
            ?: throw IllegalArgumentException("Invalid token")

        transaction {
            val row = SignupTokens.selectAll()
                .where { (SignupTokens.token eq token) and (SignupTokens.expiresAt greater System.currentTimeMillis()) }
                .firstOrNull() ?: throw IllegalArgumentException("Token expired or invalid")

            val email = row[SignupTokens.email]

            if (Users.selectAll().where { Users.username eq email }.count() > 0)
                throw IllegalArgumentException("Token expired or invalid")

            val hash: String = passwordEncoder.encode(password).toString()
            Users.insert {
                it[Users.id]          = UUID.randomUUID()
                it[Users.username]    = email
                it[Users.password]    = hash
                it[Users.displayName] = email
                it[Users.email]       = email as String?
            }

            SignupTokens.deleteWhere { SignupTokens.token eq token }
        }
    }

    private fun validatePassword(password: String) {
        require(password.length >= 8)          { "Password must be at least 8 characters" }
        require(password.any { it.isUpperCase() }) { "Password must contain an uppercase letter" }
        require(password.any { it.isLowerCase() }) { "Password must contain a lowercase letter" }
        require(password.any { it.isDigit() })     { "Password must contain a digit" }
    }

    private fun checkSignupRateLimit(email: String) {
        val now = System.currentTimeMillis()
        val windowMs = 60 * 60 * 1_000L
        val attempts = signupAttempts.getOrPut(email) { mutableListOf() }
        synchronized(attempts) {
            attempts.removeIf { it < now - windowMs }
            if (attempts.size >= 3)
                throw IllegalArgumentException("Too many signup requests. Please try again later.")
            attempts.add(now)
        }
    }

}

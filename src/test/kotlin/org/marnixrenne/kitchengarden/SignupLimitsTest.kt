package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Test
import org.mockito.Mockito.doThrow
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyString
import org.marnixrenne.kitchengarden.mail.MailService
import org.springframework.http.MediaType
import org.springframework.test.context.TestPropertySource
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.post
import org.springframework.test.web.servlet.request.RequestPostProcessor
import java.util.UUID

private fun from(ip: String) = RequestPostProcessor { it.remoteAddr = ip; it }

private fun newEmail() = "${UUID.randomUUID()}@example.test"

class SignupAddressLimitTest : IntegrationTestBase() {

    @MockitoBean lateinit var mail: MailService

    private fun signup(ip: String) = mvc.post("/api/auth/signup") {
        contentType = MediaType.APPLICATION_JSON
        content = """{"email":"${newEmail()}"}"""
        with(from(ip))
    }

    @Test
    fun `one address cannot request mail for endless different emails`() {
        repeat(5) { signup("198.51.100.1").andExpect { status { isOk() } } }

        signup("198.51.100.1").andExpect { status { isTooManyRequests() } }
        signup("198.51.100.2").andExpect { status { isOk() } }
    }

    @Test
    fun `a mail that could not be sent does not count`() {
        doThrow(RuntimeException("mail down")).`when`(mail).send(anyString(), anyString(), anyString(), any())
        repeat(6) { runCatching { signup("198.51.100.3") } }

        org.mockito.Mockito.reset(mail)
        signup("198.51.100.3").andExpect { status { isOk() } }
    }
}

@TestPropertySource(properties = ["app.signup.max-mails-per-day=3"])
class SignupDailyLimitTest : IntegrationTestBase() {

    @MockitoBean lateinit var mail: MailService

    @Test
    fun `no more mail goes out once the daily limit is reached, from any address`() {
        fun signup(n: Int) = mvc.post("/api/auth/signup") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"email":"${newEmail()}"}"""
            with(from("203.0.113.$n"))
        }

        repeat(3) { signup(it).andExpect { status { isOk() } } }

        signup(50).andExpect { status { isTooManyRequests() } }
    }
}

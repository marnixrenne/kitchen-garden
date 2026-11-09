package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Test
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf
import org.springframework.test.web.servlet.post
import org.springframework.test.web.servlet.request.RequestPostProcessor

class LoginProtectionTest : IntegrationTestBase() {

    private fun login(username: String, password: String, ip: String) = mvc.post("/api/auth/login") {
        param("username", username)
        param("password", password)
        with(csrf())
        with(RequestPostProcessor { it.remoteAddr = ip; it })
    }

    @Test
    fun `an attacker cannot lock someone out from elsewhere`() {
        repeat(10) { login("admin", "wrong", "192.0.2.10") }

        login("admin", "wrong", "192.0.2.10").andExpect { status { isForbidden() } }
        login("admin", "admin", "192.0.2.11").andExpect { status { isOk() } }
    }

    @Test
    fun `trying many accounts from one address gets blocked`() {
        repeat(50) { login("user-$it", "wrong", "192.0.2.20") }

        login("someone-else", "wrong", "192.0.2.20").andExpect { status { isForbidden() } }
        login("someone-else", "wrong", "192.0.2.21").andExpect { status { isUnauthorized() } }
    }
}

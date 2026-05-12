package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Test
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

class AuthTest : IntegrationTestBase() {

    @Test
    fun `login with valid credentials returns 200`() {
        mvc.post("/api/auth/login") {
            param("username", "admin")
            param("password", "admin")
            with(csrf())
        }.andExpect {
            status { isOk() }
            jsonPath("$.username") { value("admin") }
        }
    }

    @Test
    fun `login with invalid credentials returns 401`() {
        mvc.post("/api/auth/login") {
            param("username", "admin")
            param("password", "wrong")
            with(csrf())
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun `garden endpoint requires authentication`() {
        mvc.get("/api/garden")
            .andExpect { status { isUnauthorized() } }
    }

    @Test
    fun `preferences endpoint requires authentication`() {
        mvc.get("/api/preferences")
            .andExpect { status { isUnauthorized() } }
    }

    @Test
    fun `plants endpoint is publicly accessible`() {
        mvc.get("/api/plants")
            .andExpect { status { isOk() } }
    }
}

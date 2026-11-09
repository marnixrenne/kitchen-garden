package org.marnixrenne.kitchengarden

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.server.LocalServerPort
import org.springframework.context.annotation.Import
import org.springframework.test.context.ActiveProfiles
import java.net.URI
import java.net.URLEncoder
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse

/** Runs against a real server: the session cookie is written by Tomcat, which MockMvc doesn't exercise. */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["app.base-url=https://garden.example", "app.client-ip-header=CF-Connecting-IP"],
)
@ActiveProfiles("test")
@Import(TestcontainersConfig::class)
class SessionCookieTest {

    @LocalServerPort var port: Int = 0

    private val http = HttpClient.newHttpClient()

    private fun cookies(response: HttpResponse<*>, name: String) =
        response.headers().allValues("Set-Cookie").first { it.startsWith("$name=") }

    private fun csrf() = http.send(
        HttpRequest.newBuilder(URI("http://localhost:$port/api/auth/me")).build(),
        HttpResponse.BodyHandlers.discarding(),
    ).let { cookies(it, "XSRF-TOKEN") }

    private fun login(username: String, password: String, clientIp: String, spoofed: String? = null): HttpResponse<String> {
        val token = csrf().substringAfter("=").substringBefore(";")
        val enc = { s: String -> URLEncoder.encode(s, Charsets.UTF_8) }
        val request = HttpRequest.newBuilder(URI("http://localhost:$port/api/auth/login"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .header("Cookie", "XSRF-TOKEN=$token")
            .header("X-XSRF-TOKEN", token)
            .header("CF-Connecting-IP", clientIp)
        if (spoofed != null) request.header("X-Forwarded-For", spoofed)
        return http.send(
            request.POST(HttpRequest.BodyPublishers.ofString("username=${enc(username)}&password=${enc(password)}")).build(),
            HttpResponse.BodyHandlers.ofString(),
        )
    }

    @Test
    fun `the csrf cookie is secure on an https site`() {
        val cookie = csrf()

        assertTrue(cookie.contains("Secure"), cookie)
        assertTrue(cookie.contains("SameSite=Lax"), cookie)
    }

    @Test
    fun `the session cookie is secure, http only and same-site on an https site`() {
        val response = login("admin", "admin", "192.0.2.30")

        assertEquals(200, response.statusCode())
        val cookie = cookies(response, "JSESSIONID")
        assertTrue(cookie.contains("Secure"), cookie)
        assertTrue(cookie.contains("HttpOnly"), cookie)
        assertTrue(cookie.contains("SameSite=Lax", ignoreCase = true), cookie)
    }

    @Test
    fun `visitors are told apart by the configured header, not a header they can forge`() {
        repeat(10) { login("cf-user", "wrong", "192.0.2.40", spoofed = "198.51.100.$it") }

        assertEquals(403, login("cf-user", "wrong", "192.0.2.40", spoofed = "198.51.100.99").statusCode())
        assertEquals(401, login("cf-user", "wrong", "192.0.2.41").statusCode())
    }
}

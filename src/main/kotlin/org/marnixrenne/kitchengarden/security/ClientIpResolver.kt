package org.marnixrenne.kitchengarden.security

import jakarta.servlet.http.HttpServletRequest
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

/**
 * Tells visitors apart for rate limiting. On Render every connection comes from the proxy,
 * so [header] names the header carrying the visitor's address: Cloudflare's, by default.
 * X-Forwarded-For won't do there, as visitors can seed it themselves. A blank [header]
 * means visitors connect directly.
 */
@Component
class ClientIpResolver(@Value("\${app.client-ip-header:}") private val header: String) {

    /** The visitor's address, or null when the configured header is missing. */
    fun resolve(request: HttpServletRequest): String? =
        if (header.isBlank()) request.remoteAddr
        else request.getHeader(header)?.trim()?.takeIf { it.isNotEmpty() }
}

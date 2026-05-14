package org.marnixrenne.kitchengarden.security

import com.fasterxml.jackson.databind.ObjectMapper
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.security.web.csrf.CookieCsrfTokenRepository
import org.springframework.security.web.csrf.CsrfToken
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler
import org.springframework.security.web.session.HttpSessionEventPublisher
import org.springframework.security.core.session.SessionRegistry
import org.springframework.security.core.session.SessionRegistryImpl
import java.util.function.Supplier
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import org.springframework.web.filter.OncePerRequestFilter

@Configuration
@EnableWebSecurity
class SecurityConfig(
    @Value("\${app.base-url}") private val baseUrl: String,
    private val userLoginService: UserLoginService,
    private val bruteForce: BruteForceProtectionService,
) {
    private val json = ObjectMapper()

    @Bean
    fun sessionRegistry(): SessionRegistry = SessionRegistryImpl()

    @Bean
    fun httpSessionEventPublisher() = HttpSessionEventPublisher()

    @Bean
    fun securityFilterChain(http: HttpSecurity, sessionRegistry: SessionRegistry): SecurityFilterChain {
        http
            .csrf { csrf ->
                csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                // Use the non-XOR handler: the JS SPA reads the raw cookie value and sends
                // it as X-XSRF-TOKEN, so we must not apply XOR-masking on the server side.
                csrf.csrfTokenRequestHandler(CsrfTokenRequestAttributeHandler())
                // Signup and complete-signup are genuinely public endpoints: no authenticated
                // session is involved, so CSRF adds no meaningful protection here.
                csrf.ignoringRequestMatchers("/api/auth/signup", "/api/auth/complete")
            }
            .cors { cors -> cors.configurationSource(corsConfigurationSource()) }
            .headers { headers ->
                headers.referrerPolicy {
                    it.policy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN)
                }
                headers.contentSecurityPolicy {
                    it.policyDirectives("default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:")
                }
            }
            .sessionManagement { session ->
                session.sessionFixation { it.newSession() }
                session.maximumSessions(5).sessionRegistry(sessionRegistry)
            }
            .authorizeHttpRequests { auth ->
                auth.requestMatchers("/api/health").permitAll()
                auth.requestMatchers("/api/auth/**").permitAll()
                auth.requestMatchers("/api/plants/**").permitAll()
                auth.requestMatchers("/api/admin/**").hasRole("ADMIN")
                auth.requestMatchers("/api/**").authenticated()
                auth.anyRequest().permitAll()
            }
            .addFilterAfter(CsrfCookieFilter(), UsernamePasswordAuthenticationFilter::class.java)
            .formLogin { form ->
                form.loginProcessingUrl("/api/auth/login")
                form.successHandler { _, response, authentication ->
                    bruteForce.reset(authentication.name)
                    userLoginService.recordLogin(authentication.name)
                    val roles = authentication.authorities.map { it.authority }
                    response.status = HttpServletResponse.SC_OK
                    response.contentType = "application/json"
                    response.writer.write(
                        json.writeValueAsString(
                            mapOf("username" to authentication.name, "roles" to roles)
                        )
                    )
                }
                form.failureHandler { request, response, _ ->
                    val username = request.getParameter("username").orEmpty()
                    bruteForce.recordFailure(username)
                    val blocked = bruteForce.isBlocked(username)
                    response.status = if (blocked) HttpServletResponse.SC_FORBIDDEN else HttpServletResponse.SC_UNAUTHORIZED
                    response.contentType = "application/json"
                    response.writer.write(
                        json.writeValueAsString(
                            mapOf("error" to if (blocked) "Too many failed attempts. Try again later." else "Invalid username or password")
                        )
                    )
                }
            }
            .logout { logout ->
                logout.logoutUrl("/api/auth/logout")
                logout.invalidateHttpSession(true)
                logout.deleteCookies("JSESSIONID")
                logout.clearAuthentication(true)
                logout.logoutSuccessHandler { _, response, _ ->
                    response.status = HttpServletResponse.SC_OK
                }
            }
            .exceptionHandling { exceptions ->
                exceptions.authenticationEntryPoint { _, response, _ ->
                    response.status = HttpServletResponse.SC_UNAUTHORIZED
                    response.contentType = "application/json"
                    response.writer.write(json.writeValueAsString(mapOf("error" to "Unauthorized")))
                }
            }

        return http.build()
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val config = CorsConfiguration()
        config.allowedOrigins = listOf(baseUrl)
        config.allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS")
        config.allowedHeaders = listOf("Content-Type", "X-XSRF-TOKEN")
        config.allowCredentials = true
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/api/**", config)
        return source
    }

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    /**
     * Forces the deferred CSRF token to be loaded so the XSRF-TOKEN cookie is written on every response.
     *
     * Spring Security 6 stores a Supplier<CsrfToken> (not a CsrfToken directly) in the request
     * attribute. Calling get() on the supplier triggers CookieCsrfTokenRepository to write the cookie.
     */
    private class CsrfCookieFilter : OncePerRequestFilter() {
        override fun doFilterInternal(
            request: HttpServletRequest,
            response: HttpServletResponse,
            filterChain: FilterChain,
        ) {
            when (val attr = request.getAttribute(CsrfToken::class.java.name)) {
                is CsrfToken   -> attr.token
                is Supplier<*> -> (attr.get() as? CsrfToken)?.token
            }
            filterChain.doFilter(request, response)
        }
    }
}

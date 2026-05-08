package org.marnixrenne.kitchengarden.mail

import com.resend.Resend
import com.resend.services.emails.model.CreateEmailOptions
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Service

@Service
@ConditionalOnProperty("app.mail.resend.api-key")
class ResendMailService(
    @Value("\${app.mail.from}") private val mailFrom: String,
    @Value("\${app.mail.resend.api-key}") private val apiKey: String,
) : MailService {
    private val log = LoggerFactory.getLogger(javaClass)

    private val resend = Resend(apiKey)

    override fun send(to: String, subject: String, text: String, html: String?) {
        try {
            val builder = CreateEmailOptions.builder()
                .from(mailFrom)
                .to(to)
                .subject(subject)
                .text(text)
            if (html != null) builder.html(html)
            val params = builder.build()
            resend.emails().send(params)
            log.info("Mail sent via Resend to {}", to)
        } catch (e: Exception) {
            log.warn("Failed to send mail via Resend to {}: {}", to, e.message, e)
        }
    }
}

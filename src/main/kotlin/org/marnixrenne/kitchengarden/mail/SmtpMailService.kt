package org.marnixrenne.kitchengarden.mail

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.stereotype.Service

@Service
@ConditionalOnMissingBean(MailService::class)
class SmtpMailService(
    private val mailSender: JavaMailSender?,
    @Value("\${app.mail.from}") private val mailFrom: String,
) : MailService {
    private val log = LoggerFactory.getLogger(javaClass)

    override fun send(to: String, subject: String, body: String) {
        if (mailSender == null) {
            log.info("Mail not configured — skipping send to {}", to)
            log.debug("Subject: {}\nBody: {}", subject, body)
            return
        }
        try {
            val msg = SimpleMailMessage().apply {
                setTo(to)
                from         = mailFrom
                this.subject = subject
                text         = body
            }
            mailSender.send(msg)
            log.info("Mail sent to {}", to)
        } catch (e: Exception) {
            log.warn("Failed to send mail to {}: {}", to, e.message, e)
        }
    }
}

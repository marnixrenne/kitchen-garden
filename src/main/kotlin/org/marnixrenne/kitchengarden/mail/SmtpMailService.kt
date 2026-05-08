package org.marnixrenne.kitchengarden.mail

import jakarta.mail.internet.MimeMessage
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.mail.javamail.MimeMessageHelper
import org.springframework.stereotype.Service

@Service
@ConditionalOnMissingBean(MailService::class)
class SmtpMailService(
    private val mailSender: JavaMailSender?,
    @Value("\${app.mail.from}") private val mailFrom: String,
) : MailService {
    private val log = LoggerFactory.getLogger(javaClass)

    override fun send(to: String, subject: String, text: String, html: String?) {
        if (mailSender == null) {
            log.info("Mail not configured — skipping send to {}", to)
            log.debug("Subject: {}\nBody: {}", subject, text)
            return
        }
        try {
            val message: MimeMessage = mailSender.createMimeMessage()
            MimeMessageHelper(message, html != null, "UTF-8").apply {
                setTo(to)
                setFrom(mailFrom)
                setSubject(subject)
                if (html != null) setText(text, html) else setText(text)
            }
            mailSender.send(message)
            log.info("Mail sent to {}", to)
        } catch (e: Exception) {
            log.warn("Failed to send mail to {}: {}", to, e.message, e)
        }
    }
}

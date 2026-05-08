package org.marnixrenne.kitchengarden.mail

interface MailService {
    fun send(to: String, subject: String, text: String, html: String? = null)
}

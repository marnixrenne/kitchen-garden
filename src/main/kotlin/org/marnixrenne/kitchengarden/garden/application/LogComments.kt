package org.marnixrenne.kitchengarden.garden.application

import org.marnixrenne.kitchengarden.garden.domain.MAX_COMMENT_LENGTH
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

/** A log comment ready to store: refused when too long, and null when blank. */
fun validatedComment(comment: String?): String? {
    if (comment != null && comment.length > MAX_COMMENT_LENGTH)
        throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Comment must be at most $MAX_COMMENT_LENGTH characters")
    return comment?.takeIf { it.isNotBlank() }
}

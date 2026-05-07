package org.marnixrenne.kitchengarden

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping

/**
 * Forwards all non-API, non-asset requests to index.html so Vue Router handles them.
 * Paths containing a dot (e.g. app.js, style.css) are served directly by the static resource handler.
 */
@Controller
class SpaController {

    @RequestMapping(value = ["/{path:[^.]*}", "/{path:[^.]*}/**"])
    fun forward(): String = "forward:/index.html"
}

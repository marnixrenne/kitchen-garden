package org.marnixrenne.kitchengarden

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping

/**
 * Forwards SPA routes to index.html so Vue Router handles client-side navigation.
 * Uses explicit paths rather than a wildcard to avoid intercepting asset files under /assets/.
 */
@Controller
class SpaController {

    @RequestMapping(value = ["/", "/{path:[^.]*}", "/plant/{id:[^.]+}", "/settings"])
    fun forward(): String = "forward:/index.html"
}

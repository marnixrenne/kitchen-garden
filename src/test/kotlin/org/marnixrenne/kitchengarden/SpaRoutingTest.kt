package org.marnixrenne.kitchengarden

import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.forwardedUrl
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

class SpaRoutingTest : IntegrationTestBase() {

    @ParameterizedTest
    @ValueSource(strings = ["/", "/discover", "/garden", "/garden/log", "/plant/abc", "/settings", "/gardens/abc", "/gardens/abc/zones/def"])
    fun `a page opened directly is handed to the frontend`(path: String) {
        mvc.perform(get(path))
            .andExpect(status().isOk)
            .andExpect(forwardedUrl("/index.html"))
    }
}

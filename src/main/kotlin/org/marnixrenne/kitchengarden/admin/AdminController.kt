package org.marnixrenne.kitchengarden.admin

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

data class UserSummary(val username: String, val online: Boolean, val lastLogin: Long?, val disabled: Boolean, val gardenCount: Int)

@RestController
@RequestMapping("/api/admin")
class AdminController(private val adminService: AdminService) {

    @GetMapping("/users")
    fun listUsers(): List<UserSummary> = adminService.listUsers()

    @PutMapping("/users/{username}/disabled")
    fun setDisabled(
        @PathVariable username: String,
        @RequestBody body: Map<String, Boolean>,
        authentication: Authentication,
    ): ResponseEntity<*> {
        if (username == authentication.name)
            return ResponseEntity.badRequest().body(mapOf("error" to "Cannot disable your own account"))

        val disabled = body["disabled"] ?: return ResponseEntity.badRequest().body(mapOf("error" to "Missing 'disabled' field"))

        if (!adminService.setDisabled(username, disabled))
            return ResponseEntity.notFound().build<Unit>()

        return ResponseEntity.ok(mapOf("username" to username, "disabled" to disabled))
    }
}

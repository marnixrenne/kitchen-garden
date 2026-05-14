package org.marnixrenne.kitchengarden.admin

import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

data class UserSummary(val username: String, val online: Boolean, val lastLogin: Long?, val disabled: Boolean, val gardenCount: Int)
data class SetDisabledRequest(val disabled: Boolean)

@RestController
@RequestMapping("/api/admin")
class AdminController(private val adminService: AdminService) {

    @GetMapping("/users")
    fun listUsers(): List<UserSummary> = adminService.listUsers()

    @PutMapping("/users/{username}/disabled")
    fun setDisabled(
        @PathVariable username: String,
        @RequestBody body: SetDisabledRequest,
        authentication: Authentication,
    ): ResponseEntity<*> {
        return try {
            if (!adminService.setDisabled(authentication.name, username, body.disabled))
                return ResponseEntity.notFound().build<Unit>()
            ResponseEntity.ok(mapOf("username" to username, "disabled" to body.disabled))
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("error" to e.message))
        }
    }
}

package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.admin.AdminUserRequest;
import com.example.mentee_mentor.dto.admin.AdminUserResponse;
import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.model.Permission;
import com.example.mentee_mentor.model.Role;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = adminService.getStats();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/users")
    public ResponseEntity<Page<AdminUserResponse>> getAllUsers(
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<AdminUserResponse> users = adminService.getAllUsers(pageable);
        return ResponseEntity.ok(users);
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<AdminUserResponse> getUserById(@PathVariable Long id) {
        AdminUserResponse user = adminService.getUserById(id);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/users")
    public ResponseEntity<AdminUserResponse> createUser(
            @Valid @RequestBody AdminUserRequest request) {
        AdminUserResponse user = adminService.createUser(request);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<AdminUserResponse> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody AdminUserRequest request) {
        AdminUserResponse user = adminService.updateUser(id, request);
        return ResponseEntity.ok(user);
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        adminService.deleteUser(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/roles")
    public ResponseEntity<List<Role>> getAllRoles() {
        List<Role> roles = adminService.getAllRoles();
        return ResponseEntity.ok(roles);
    }

    @GetMapping("/permissions")
    public ResponseEntity<List<Permission>> getAllPermissions() {
        List<Permission> permissions = adminService.getAllPermissions();
        return ResponseEntity.ok(permissions);
    }

    @GetMapping("/bookings")
    public ResponseEntity<Page<Booking>> getAllBookings(
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<Booking> bookings = adminService.getAllBookings(pageable);
        return ResponseEntity.ok(bookings);
    }
}
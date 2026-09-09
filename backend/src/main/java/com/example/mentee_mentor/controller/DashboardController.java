package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.dashboard.*;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDashboardResponse> getAdminDashboard() {
        AdminDashboardResponse dashboard = dashboardService.getAdminDashboard();
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/mentor/me")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<MentorDashboardResponse> getMyMentorDashboard(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MentorDashboardResponse dashboard = dashboardService.getMentorDashboard(userPrincipal.getId());
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/mentor/{mentorId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MentorDashboardResponse> getMentorDashboard(@PathVariable Long mentorId) {
        MentorDashboardResponse dashboard = dashboardService.getMentorDashboard(mentorId);
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/mentee/me")
    @PreAuthorize("hasRole('MENTEE')")
    public ResponseEntity<MenteeDashboardResponse> getMyMenteeDashboard(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MenteeDashboardResponse dashboard = dashboardService.getMenteeDashboard(userPrincipal.getId());
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/mentee/{menteeId}")
    @PreAuthorize("hasRole('MENTOR') or hasRole('ADMIN')")
    public ResponseEntity<MenteeDashboardResponse> getMenteeDashboard(@PathVariable Long menteeId) {
        MenteeDashboardResponse dashboard = dashboardService.getMenteeDashboard(menteeId);
        return ResponseEntity.ok(dashboard);
    }
}
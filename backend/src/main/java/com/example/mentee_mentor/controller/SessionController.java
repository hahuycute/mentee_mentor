package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.session.SessionRequest;
import com.example.mentee_mentor.dto.session.SessionResponse;
import com.example.mentee_mentor.model.Session;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.SessionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class SessionController {

    private final SessionService sessionService;

    @PostMapping
    public ResponseEntity<SessionResponse> startSession(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody SessionRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        SessionResponse session = sessionService.startSession(userPrincipal.getId(), request);
        return ResponseEntity.ok(session);
    }

    @PatchMapping("/{id}/end")
    public ResponseEntity<SessionResponse> endSession(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @RequestBody(required = false) String notes) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        SessionResponse session = sessionService.endSession(userPrincipal.getId(), id, notes);
        return ResponseEntity.ok(session);
    }

    @GetMapping("/my")
    public ResponseEntity<Page<SessionResponse>> getMySessions(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<SessionResponse> sessions = sessionService.getMySessions(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(sessions);
    }

    @GetMapping("/{id}")
    public ResponseEntity<SessionResponse> getSession(@PathVariable Long id) {
        SessionResponse session = sessionService.getSessionById(id);
        return ResponseEntity.ok(session);
    }
}
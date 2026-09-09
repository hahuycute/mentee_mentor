package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.notification.NotificationResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<Page<NotificationResponse>> getMyNotifications(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<NotificationResponse> notifications = notificationService.getMyNotifications(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        long count = notificationService.getUnreadCount(userPrincipal.getId());
        return ResponseEntity.ok(count);
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        notificationService.markAsRead(userPrincipal.getId(), id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        notificationService.markAllAsRead(userPrincipal.getId());
        return ResponseEntity.ok().build();
    }
}
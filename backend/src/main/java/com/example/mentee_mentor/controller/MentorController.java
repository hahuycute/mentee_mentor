package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.profile.MentorProfileRequest;
import com.example.mentee_mentor.dto.profile.MentorProfileResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.ProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mentors")
@RequiredArgsConstructor
public class MentorController {

    private final ProfileService profileService;

    @PostMapping("/me")
    public ResponseEntity<MentorProfileResponse> createMentorProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody MentorProfileRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MentorProfileResponse profile = profileService.createMentorProfile(userPrincipal.getId(), request);
        return ResponseEntity.ok(profile);
    }

    @PutMapping("/me")
    public ResponseEntity<MentorProfileResponse> updateMentorProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody MentorProfileRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MentorProfileResponse profile = profileService.updateMentorProfile(userPrincipal.getId(), request);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/me")
    public ResponseEntity<MentorProfileResponse> getMyMentorProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MentorProfileResponse profile = profileService.getMentorProfile(userPrincipal.getId());
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<MentorProfileResponse> getMentorProfile(@PathVariable Long userId) {
        MentorProfileResponse profile = profileService.getMentorProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/recommended")
    public ResponseEntity<Page<MentorProfileResponse>> getRecommendedMentors(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10) Pageable pageable) {
        Long currentUserId = userPrincipal != null ? userPrincipal.getId() : null;
        // TODO: Implement recommendation logic
        // For now return empty page
        return ResponseEntity.ok(new org.springframework.data.domain.PageImpl<>(java.util.Collections.emptyList(), pageable, 0));
    }
}
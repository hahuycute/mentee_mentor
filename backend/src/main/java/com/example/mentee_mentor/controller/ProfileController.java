package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.profile.MenteeProfileResponse;
import com.example.mentee_mentor.dto.profile.MentorProfileResponse;
import com.example.mentee_mentor.dto.profile.ProfileStatsResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profiles")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/{userId}/stats")
    public ResponseEntity<ProfileStatsResponse> getProfileStats(@PathVariable Long userId) {
        ProfileStatsResponse stats = profileService.getProfileStats(userId);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/mentor/{userId}")
    public ResponseEntity<MentorProfileResponse> getMentorProfile(@PathVariable Long userId) {
        MentorProfileResponse profile = profileService.getMentorProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/mentee/{userId}")
    public ResponseEntity<MenteeProfileResponse> getMenteeProfile(@PathVariable Long userId) {
        MenteeProfileResponse profile = profileService.getMenteeProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/mentor/me")
    public ResponseEntity<MentorProfileResponse> getMyMentorProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MentorProfileResponse profile = profileService.getMentorProfile(userPrincipal.getId());
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/mentee/me")
    public ResponseEntity<MenteeProfileResponse> getMyMenteeProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        MenteeProfileResponse profile = profileService.getMenteeProfile(userPrincipal.getId());
        return ResponseEntity.ok(profile);
    }
}
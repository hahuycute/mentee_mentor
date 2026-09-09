package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.feedback.FeedbackRequest;
import com.example.mentee_mentor.dto.feedback.FeedbackResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.FeedbackService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @PostMapping
    public ResponseEntity<FeedbackResponse> createFeedback(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody FeedbackRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        FeedbackResponse feedback = feedbackService.createFeedback(userPrincipal.getId(), request);
        return ResponseEntity.ok(feedback);
    }

    @GetMapping("/my")
    public ResponseEntity<Page<FeedbackResponse>> getMyFeedbacks(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<FeedbackResponse> feedbacks = feedbackService.getMyFeedbacks(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(feedbacks);
    }

    @GetMapping("/mentor/{mentorId}")
    public ResponseEntity<Page<FeedbackResponse>> getFeedbacksByMentor(
            @PathVariable Long mentorId,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        Page<FeedbackResponse> feedbacks = feedbackService.getFeedbacksByMentor(mentorId, pageable);
        return ResponseEntity.ok(feedbacks);
    }

    @GetMapping("/mentor/{mentorId}/average-rating")
    public ResponseEntity<Double> getAverageRatingByMentor(@PathVariable Long mentorId) {
        double average = feedbackService.getAverageRatingByMentor(mentorId);
        return ResponseEntity.ok(average);
    }

    @GetMapping("/{id}")
    public ResponseEntity<FeedbackResponse> getFeedback(@PathVariable Long id) {
        FeedbackResponse feedback = feedbackService.getFeedbackById(id);
        return ResponseEntity.ok(feedback);
    }
}
package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.topic.TopicRequest;
import com.example.mentee_mentor.dto.topic.TopicResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.TopicService;
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

@RestController
@RequestMapping("/api/topics")
@RequiredArgsConstructor
public class TopicController {

    private final TopicService topicService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TopicResponse> createTopic(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody TopicRequest request) {
        TopicResponse topic = topicService.createTopic(request);
        return ResponseEntity.ok(topic);
    }

    @GetMapping
    public ResponseEntity<Page<TopicResponse>> getAllTopics(
            @PageableDefault(size = 50) Pageable pageable) {
        Page<TopicResponse> topics = topicService.getAllTopics(pageable);
        return ResponseEntity.ok(topics);
    }

    @GetMapping("/list")
    public ResponseEntity<List<TopicResponse>> getAllTopicsList() {
        List<TopicResponse> topics = topicService.getAllTopics();
        return ResponseEntity.ok(topics);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TopicResponse> getTopic(@PathVariable Long id) {
        TopicResponse topic = topicService.getTopicById(id);
        return ResponseEntity.ok(topic);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TopicResponse> updateTopic(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @Valid @RequestBody TopicRequest request) {
        TopicResponse topic = topicService.updateTopic(id, request);
        return ResponseEntity.ok(topic);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteTopic(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        topicService.deleteTopic(id);
        return ResponseEntity.ok().build();
    }
}
package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.post.PostRequest;
import com.example.mentee_mentor.dto.post.PostResponse;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.PostService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @PostMapping
    public ResponseEntity<PostResponse> createPost(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody PostRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        PostResponse post = postService.createPost(userPrincipal.getId(), request);
        return ResponseEntity.ok(post);
    }

    @GetMapping
    public ResponseEntity<Page<PostResponse>> getPublicPosts(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        Long currentUserId = userPrincipal != null ? userPrincipal.getId() : null;
        Page<PostResponse> posts = postService.getPublicPosts(pageable, currentUserId);
        return ResponseEntity.ok(posts);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<PostResponse>> searchPosts(
            @RequestParam String keyword,
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        Long currentUserId = userPrincipal != null ? userPrincipal.getId() : null;
        Page<PostResponse> posts = postService.searchPublicPosts(keyword, pageable, currentUserId);
        return ResponseEntity.ok(posts);
    }

    @GetMapping("/my")
    public ResponseEntity<Page<PostResponse>> getMyPosts(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<PostResponse> posts = postService.getMyPosts(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(posts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PostResponse> getPost(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        Long currentUserId = userPrincipal != null ? userPrincipal.getId() : null;
        PostResponse post = postService.getPostById(id, currentUserId);
        return ResponseEntity.ok(post);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PostResponse> updatePost(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @Valid @RequestBody PostRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        PostResponse post = postService.updatePost(userPrincipal.getId(), id, request);
        return ResponseEntity.ok(post);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        postService.deletePost(userPrincipal.getId(), id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<PostResponse> likePost(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        PostResponse post = postService.likePost(userPrincipal.getId(), id);
        return ResponseEntity.ok(post);
    }

    @DeleteMapping("/{id}/like")
    public ResponseEntity<PostResponse> unlikePost(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        PostResponse post = postService.unlikePost(userPrincipal.getId(), id);
        return ResponseEntity.ok(post);
    }
}
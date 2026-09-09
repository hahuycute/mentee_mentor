package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostStatsResponse {

    private Long totalPosts;
    private Long publishedPosts;
    private Long draftPosts;
    private Long totalLikes;
    private Long totalComments;
    private Long postsThisMonth;
    private Double averageLikesPerPost;
    private Double engagementRate;
}
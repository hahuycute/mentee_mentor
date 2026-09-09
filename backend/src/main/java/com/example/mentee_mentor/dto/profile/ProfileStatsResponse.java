package com.example.mentee_mentor.dto.profile;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileStatsResponse {

    private Long completedSessions;
    private Double averageRating;
    private Long totalReviews;
}
package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TopicProgressResponse {

    private Long topicId;
    private String topicName;
    private Integer sessionsCompleted;
    private Double averageRating;
    private Long totalHours;
}
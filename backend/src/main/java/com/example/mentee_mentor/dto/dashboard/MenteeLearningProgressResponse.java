package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeLearningProgressResponse {

    private Long totalTopicsLearned;
    private Long totalHoursLearned;
    private Double averageRatingGiven;
    private List<TopicProgressResponse> topicProgress;
}
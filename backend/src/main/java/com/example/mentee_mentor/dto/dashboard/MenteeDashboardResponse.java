package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeDashboardResponse {

    private MenteeProfileSummaryResponse profileSummary;
    private MenteeBookingStatsResponse bookingStats;
    private MenteeSessionStatsResponse sessionStats;
    private MenteeLearningProgressResponse learningProgress;
    private MenteeUpcomingResponse upcoming;
}
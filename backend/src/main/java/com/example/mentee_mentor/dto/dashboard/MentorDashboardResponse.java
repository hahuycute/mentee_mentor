package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorDashboardResponse {

    private MentorProfileSummaryResponse profileSummary;
    private MentorBookingStatsResponse bookingStats;
    private MentorSessionStatsResponse sessionStats;
    private MentorEarningsResponse earnings;
    private MentorRatingResponse rating;
    private MentorUpcomingResponse upcoming;
}
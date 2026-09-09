package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeSessionStatsResponse {

    private Long totalSessions;
    private Long scheduledSessions;
    private Long inProgressSessions;
    private Long completedSessions;
    private Long cancelledSessions;
    private Long sessionsThisWeek;
    private Long sessionsThisMonth;
    private Double averageSessionDurationMinutes;
    private Double completionRate;
}
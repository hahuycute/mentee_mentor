package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardResponse {

    private UserStatsResponse userStats;
    private BookingStatsResponse bookingStats;
    private SessionStatsResponse sessionStats;
    private PostStatsResponse postStats;
    private RevenueStatsResponse revenueStats;
    private SystemHealthResponse systemHealth;
}
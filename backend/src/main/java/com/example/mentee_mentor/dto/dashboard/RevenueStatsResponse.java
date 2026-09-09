package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueStatsResponse {

    private Double totalRevenue;
    private Double revenueThisMonth;
    private Double revenueLastMonth;
    private Double averageRevenuePerBooking;
    private Long totalPaidBookings;
    private Double growthRatePercent;
}
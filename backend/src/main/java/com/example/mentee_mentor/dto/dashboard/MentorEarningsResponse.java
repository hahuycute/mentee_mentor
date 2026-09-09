package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorEarningsResponse {

    private Double totalEarnings;
    private Double earningsThisMonth;
    private Double earningsLastMonth;
    private Double pendingEarnings;
    private Double averageEarningsPerSession;
    private Double growthRatePercent;
}
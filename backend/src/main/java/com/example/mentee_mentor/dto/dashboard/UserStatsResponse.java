package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsResponse {

    private Long totalUsers;
    private Long totalMentors;
    private Long totalMentees;
    private Long totalAdmins;
    private Long newUsersThisMonth;
    private Long activeUsersThisMonth;
    private Long inactiveUsers;
    private Long verifiedUsers;
    private Long unverifiedUsers;
}
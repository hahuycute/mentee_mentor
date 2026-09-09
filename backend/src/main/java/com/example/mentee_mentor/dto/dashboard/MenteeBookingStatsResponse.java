package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeBookingStatsResponse {

    private Long totalBookings;
    private Long pendingBookings;
    private Long confirmedBookings;
    private Long completedBookings;
    private Long cancelledBookings;
    private Long bookingsThisWeek;
    private Long bookingsThisMonth;
}
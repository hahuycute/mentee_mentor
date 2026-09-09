package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeUpcomingResponse {

    private List<UpcomingSessionResponse> upcomingSessions;
    private List<UpcomingBookingResponse> upcomingBookings;
    private Long nextSessionId;
    private LocalDateTime nextSessionTime;
    private String nextMentorName;
    private String nextTopicName;
}
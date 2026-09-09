package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpcomingBookingResponse {

    private Long bookingId;
    private Long scheduleId;
    private String menteeName;
    private String menteeAvatar;
    private LocalDateTime scheduledStartTime;
    private LocalDateTime scheduledEndTime;
    private String topicName;
    private String status;
}
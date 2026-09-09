package com.example.mentee_mentor.dto.schedule;

import com.example.mentee_mentor.dto.user.UserResponse;
import com.example.mentee_mentor.model.Schedule;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleResponse {

    private Long id;
    private UserResponse mentor;
    private String topic;
    private String description;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private Integer capacity;
    private Schedule.ScheduleStatus status;
    private LocalDateTime createdAt;
    private Long bookingsCount;

    public static ScheduleResponse fromEntity(Schedule schedule) {
        if (schedule == null) return null;
        return ScheduleResponse.builder()
                .id(schedule.getId())
                .mentor(UserResponse.fromEntity(schedule.getMentor()))
                .topic(schedule.getTopic())
                .description(schedule.getDescription())
                .startAt(schedule.getStartAt())
                .endAt(schedule.getEndAt())
                .capacity(schedule.getCapacity())
                .status(schedule.getStatus())
                .createdAt(schedule.getCreatedAt())
                .bookingsCount(schedule.getBookings() != null ? (long) schedule.getBookings().size() : 0L)
                .build();
    }
}
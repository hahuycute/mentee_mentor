package com.example.mentee_mentor.dto.schedule;

import com.example.mentee_mentor.model.Schedule;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleRequest {

    @NotBlank(message = "Topic is required")
    @Size(max = 255)
    private String topic;

    @Size(max = 2000)
    private String description;

    @NotNull(message = "Start time is required")
    private LocalDateTime startAt;

    @NotNull(message = "End time is required")
    private LocalDateTime endAt;

    @Min(value = 1, message = "Capacity must be at least 1")
    @Max(value = 100, message = "Capacity cannot exceed 100")
    @Builder.Default
    private Integer capacity = 1;

    @NotNull(message = "Status is required")
    @Builder.Default
    private Schedule.ScheduleStatus status = Schedule.ScheduleStatus.AVAILABLE;
}
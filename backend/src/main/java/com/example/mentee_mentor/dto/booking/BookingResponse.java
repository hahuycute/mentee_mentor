package com.example.mentee_mentor.dto.booking;

import com.example.mentee_mentor.dto.schedule.ScheduleResponse;
import com.example.mentee_mentor.dto.user.UserResponse;
import com.example.mentee_mentor.model.Booking;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {

    private Long id;
    private ScheduleResponse schedule;
    private UserResponse mentee;
    private UserResponse mentor;
    private Booking.BookingStatus status;
    private String notes;
    private LocalDateTime createdAt;

    public static BookingResponse fromEntity(Booking booking) {
        if (booking == null) return null;
        return BookingResponse.builder()
                .id(booking.getId())
                .schedule(ScheduleResponse.fromEntity(booking.getSchedule()))
                .mentee(UserResponse.fromEntity(booking.getMentee()))
                .mentor(booking.getSchedule() != null ? UserResponse.fromEntity(booking.getSchedule().getMentor()) : null)
                .status(booking.getStatus())
                .notes(booking.getNotes())
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
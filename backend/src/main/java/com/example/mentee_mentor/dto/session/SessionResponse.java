package com.example.mentee_mentor.dto.session;

import com.example.mentee_mentor.dto.booking.BookingResponse;
import com.example.mentee_mentor.model.Session;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionResponse {

    private Long id;
    private BookingResponse booking;
    private Long mentorId;
    private String mentorName;
    private String mentorAvatar;
    private Long menteeId;
    private String menteeName;
    private String menteeAvatar;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Session.SessionStatus status;
    private String notes;
    private Boolean autoStarted;
    private Boolean autoEnded;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static SessionResponse fromEntity(Session session) {
        if (session == null) return null;

        return SessionResponse.builder()
                .id(session.getId())
                .booking(BookingResponse.fromEntity(session.getBooking()))
                .mentorId(session.getMentor() != null ? session.getMentor().getId() : null)
                .mentorName(session.getMentor() != null ? session.getMentor().getFullName() : null)
                .mentorAvatar(session.getMentor() != null ? session.getMentor().getAvatar() : null)
                .menteeId(session.getMentee() != null ? session.getMentee().getId() : null)
                .menteeName(session.getMentee() != null ? session.getMentee().getFullName() : null)
                .menteeAvatar(session.getMentee() != null ? session.getMentee().getAvatar() : null)
                .startedAt(session.getStartedAt())
                .endedAt(session.getEndedAt())
                .status(session.getStatus())
                .notes(session.getNotes())
                .autoStarted(session.getAutoStarted())
                .autoEnded(session.getAutoEnded())
                .createdAt(session.getCreatedAt())
                .updatedAt(session.getUpdatedAt())
                .build();
    }
}
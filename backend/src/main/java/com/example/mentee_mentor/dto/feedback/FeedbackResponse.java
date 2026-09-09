package com.example.mentee_mentor.dto.feedback;

import com.example.mentee_mentor.dto.session.SessionResponse;
import com.example.mentee_mentor.model.Feedback;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeedbackResponse {

    private Long id;
    private SessionResponse session;
    private Long mentorId;
    private String mentorName;
    private String mentorAvatar;
    private Long menteeId;
    private String menteeName;
    private String menteeAvatar;
    private Integer rating;
    private String comment;
    private LocalDateTime createdAt;

    public static FeedbackResponse fromEntity(Feedback feedback) {
        if (feedback == null) return null;

        return FeedbackResponse.builder()
                .id(feedback.getId())
                .session(SessionResponse.fromEntity(feedback.getSession()))
                .mentorId(feedback.getMentor() != null ? feedback.getMentor().getId() : null)
                .mentorName(feedback.getMentor() != null ? feedback.getMentor().getFullName() : null)
                .mentorAvatar(feedback.getMentor() != null ? feedback.getMentor().getAvatar() : null)
                .menteeId(feedback.getMentee() != null ? feedback.getMentee().getId() : null)
                .menteeName(feedback.getMentee() != null ? feedback.getMentee().getFullName() : null)
                .menteeAvatar(feedback.getMentee() != null ? feedback.getMentee().getAvatar() : null)
                .rating(feedback.getRating())
                .comment(feedback.getComment())
                .createdAt(feedback.getCreatedAt())
                .build();
    }
}
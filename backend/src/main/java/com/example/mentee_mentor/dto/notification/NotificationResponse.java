package com.example.mentee_mentor.dto.notification;

import com.example.mentee_mentor.model.Notification;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private Long id;
    private Long userId;
    private String type;
    private String title;
    private String content;
    private Boolean isRead;
    private LocalDateTime createdAt;

    public static NotificationResponse fromEntity(Notification notification) {
        if (notification == null) return null;

        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUser() != null ? notification.getUser().getId() : null)
                .type(notification.getType())
                .title(notification.getTitle())
                .content(notification.getContent())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
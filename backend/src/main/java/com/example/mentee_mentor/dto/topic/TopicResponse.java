package com.example.mentee_mentor.dto.topic;

import com.example.mentee_mentor.model.Topic;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TopicResponse {

    private Long id;
    private String name;
    private String description;
    private String icon;
    private String color;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static TopicResponse fromEntity(Topic topic) {
        if (topic == null) return null;

        return TopicResponse.builder()
                .id(topic.getId())
                .name(topic.getName())
                .description(topic.getDescription())
                .icon(topic.getIcon())
                .color(topic.getColor())
                .createdAt(topic.getCreatedAt())
                .updatedAt(topic.getUpdatedAt())
                .build();
    }
}
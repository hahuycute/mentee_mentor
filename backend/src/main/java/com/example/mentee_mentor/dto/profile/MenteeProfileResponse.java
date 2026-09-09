package com.example.mentee_mentor.dto.profile;

import com.example.mentee_mentor.model.Topic;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeProfileResponse {

    private Long id;
    private String fullName;
    private String avatar;
    private String phoneNumber;
    private String learningGoals;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Set<TopicSummary> interests;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopicSummary {
        private Long id;
        private String name;
        private String description;
        private String icon;
        private String color;

        public static TopicSummary fromEntity(Topic topic) {
            if (topic == null) return null;
            return TopicSummary.builder()
                    .id(topic.getId())
                    .name(topic.getName())
                    .description(topic.getDescription())
                    .icon(topic.getIcon())
                    .color(topic.getColor())
                    .build();
        }
    }

    public static MenteeProfileResponse fromEntity(com.example.mentee_mentor.model.MenteeProfile profile) {
        if (profile == null) return null;
        return MenteeProfileResponse.builder()
                .id(profile.getId())
                .fullName(profile.getFullName())
                .avatar(profile.getAvatar())
                .phoneNumber(profile.getPhoneNumber())
                .learningGoals(profile.getLearningGoals())
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .interests(profile.getInterests() != null ? profile.getInterests().stream()
                        .map(TopicSummary::fromEntity)
                        .collect(Collectors.toSet()) : Set.of())
                .build();
    }
}
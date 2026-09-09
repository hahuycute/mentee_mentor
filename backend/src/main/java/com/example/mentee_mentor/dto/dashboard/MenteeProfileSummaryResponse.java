package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenteeProfileSummaryResponse {

    private Long menteeId;
    private String fullName;
    private String avatar;
    private String school;
    private String grade;
    private String learningGoals;
    private Boolean isProfileComplete;
}
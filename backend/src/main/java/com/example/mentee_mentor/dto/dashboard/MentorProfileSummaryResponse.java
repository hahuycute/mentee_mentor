package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorProfileSummaryResponse {

    private Long mentorId;
    private String fullName;
    private String avatar;
    private Integer yearsExp;
    private String school;
    private String degree;
    private Boolean isProfileComplete;
}
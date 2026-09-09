package com.example.mentee_mentor.dto.profile;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorProfileRequest {

    @NotBlank(message = "Full name is required")
    @Size(max = 255, message = "Full name must not exceed 255 characters")
    private String fullName;

    @Size(max = 500, message = "Avatar URL must not exceed 500 characters")
    private String avatar;

    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phoneNumber;

    @Size(max = 255, message = "School must not exceed 255 characters")
    private String school;

    @Size(max = 255, message = "Degree must not exceed 255 characters")
    private String degree;

    private Integer yearsExp;

    @Size(max = 2000, message = "Bio must not exceed 2000 characters")
    private String bio;

    private List<Long> expertiseIds;
}
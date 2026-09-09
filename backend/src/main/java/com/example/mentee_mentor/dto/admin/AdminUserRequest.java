package com.example.mentee_mentor.dto.admin;

import com.example.mentee_mentor.model.User;
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
public class AdminUserRequest {

    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    @Size(max = 255, message = "Full name must not exceed 255 characters")
    private String fullName;

    @Size(max = 500, message = "Avatar URL must not exceed 500 characters")
    private String avatar;

    @Size(max = 20, message = "Phone must not exceed 20 characters")
    private String phone;

    private Boolean isActive;

    private User.UserRole role;

    private List<Long> roleIds;

    private List<Long> permissionIds;
}
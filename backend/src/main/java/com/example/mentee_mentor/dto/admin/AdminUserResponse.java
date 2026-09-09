package com.example.mentee_mentor.dto.admin;

import com.example.mentee_mentor.model.User;
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
public class AdminUserResponse {

    private Long id;
    private String email;
    private String fullName;
    private String avatar;
    private String phone;
    private Boolean isEmailVerified;
    private Boolean isActive;
    private User.UserRole role;
    private Set<String> roles;
    private Set<String> permissions;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static AdminUserResponse fromEntity(User user) {
        if (user == null) return null;

        return AdminUserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .avatar(user.getAvatar())
                .phone(user.getPhone())
                .isEmailVerified(user.getIsEmailVerified())
                .isActive(user.getIsActive())
                .role(user.getRole())
                .roles(user.getRoles() != null ? user.getRoles().stream().map(r -> r.getName()).collect(Collectors.toSet()) : Set.of())
                .permissions(user.getPermissions() != null ? user.getPermissions().stream().map(p -> p.getCode()).collect(Collectors.toSet()) : Set.of())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
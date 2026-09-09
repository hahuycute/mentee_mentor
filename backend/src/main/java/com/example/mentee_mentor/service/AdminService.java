package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.admin.AdminUserRequest;
import com.example.mentee_mentor.dto.admin.AdminUserResponse;
import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.model.Permission;
import com.example.mentee_mentor.model.Role;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.BookingRepository;
import com.example.mentee_mentor.repository.PermissionRepository;
import com.example.mentee_mentor.repository.RoleRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;
    private final BookingRepository bookingRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public Page<AdminUserResponse> getAllUsers(Pageable pageable) {
        Page<User> users = userRepository.findAll(pageable);
        return users.map(AdminUserResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public AdminUserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        return AdminUserResponse.fromEntity(user);
    }

    @Transactional
    public AdminUserResponse createUser(AdminUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already exists: " + request.getEmail());
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode("defaultPassword123"))
                .fullName(request.getFullName())
                .avatar(request.getAvatar())
                .phone(request.getPhone())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .isEmailVerified(false)
                .role(request.getRole() != null ? request.getRole() : User.UserRole.MENTEE)
                .build();

        if (request.getRoleIds() != null) {
            Set<Role> roles = request.getRoleIds().stream()
                    .map(id -> roleRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + id)))
                    .collect(Collectors.toSet());
            user.setRoles(roles);
        }

        if (request.getPermissionIds() != null) {
            Set<Permission> permissions = request.getPermissionIds().stream()
                    .map(id -> permissionRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException("Permission not found with id: " + id)))
                    .collect(Collectors.toSet());
            user.setPermissions(permissions);
        }

        User saved = userRepository.save(user);
        return AdminUserResponse.fromEntity(saved);
    }

    @Transactional
    public AdminUserResponse updateUser(Long id, AdminUserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));

        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new BadRequestException("Email already exists: " + request.getEmail());
            }
            user.setEmail(request.getEmail());
        }

        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getAvatar() != null) user.setAvatar(request.getAvatar());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        if (request.getIsActive() != null) user.setIsActive(request.getIsActive());
        if (request.getRole() != null) user.setRole(request.getRole());

        if (request.getRoleIds() != null) {
            Set<Role> roles = request.getRoleIds().stream()
                    .map(roleId -> roleRepository.findById(roleId)
                            .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + roleId)))
                    .collect(Collectors.toSet());
            user.setRoles(roles);
        }

        if (request.getPermissionIds() != null) {
            Set<Permission> permissions = request.getPermissionIds().stream()
                    .map(permissionId -> permissionRepository.findById(permissionId)
                            .orElseThrow(() -> new ResourceNotFoundException("Permission not found with id: " + permissionId)))
                    .collect(Collectors.toSet());
            user.setPermissions(permissions);
        }

        User saved = userRepository.save(user);
        return AdminUserResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        userRepository.delete(user);
    }

    @Transactional(readOnly = true)
    public List<Role> getAllRoles() {
        return roleRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Permission> getAllPermissions() {
        return permissionRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getStats() {
        List<User> allUsers = userRepository.findAll();
        long totalUsers = allUsers.size();
        long totalMentors = allUsers.stream().filter(u -> u.getRole() == User.UserRole.MENTOR).count();
        long totalMentees = allUsers.stream().filter(u -> u.getRole() == User.UserRole.MENTEE).count();
        long activeMentors = allUsers.stream()
                .filter(u -> u.getRole() == User.UserRole.MENTOR && u.getIsActive())
                .count();

        List<Booking> allBookings = bookingRepository.findAll();
        long totalSessions = allBookings.stream()
                .filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED)
                .count();

        return Map.of(
                "totalUsers", totalUsers,
                "activeMentors", activeMentors,
                "totalSessions", totalSessions,
                "totalRevenue", 0.0
        );
    }

    @Transactional(readOnly = true)
    public Page<Booking> getAllBookings(Pageable pageable) {
        return bookingRepository.findAll(pageable);
    }
}
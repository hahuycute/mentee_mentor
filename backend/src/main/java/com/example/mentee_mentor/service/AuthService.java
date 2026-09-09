package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.auth.JwtResponse;
import com.example.mentee_mentor.dto.auth.LoginRequest;
import com.example.mentee_mentor.dto.auth.OtpVerifyRequest;
import com.example.mentee_mentor.dto.auth.RegisterRequest;
import com.example.mentee_mentor.dto.auth.ResetPasswordRequest;
import com.example.mentee_mentor.dto.auth.ForgotPasswordRequest;
import com.example.mentee_mentor.dto.user.UserResponse;
import com.example.mentee_mentor.exception.BadRequestException;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.model.EmailVerification;
import com.example.mentee_mentor.model.PasswordReset;
import com.example.mentee_mentor.model.Role;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.EmailVerificationRepository;
import com.example.mentee_mentor.repository.PasswordResetRepository;
import com.example.mentee_mentor.repository.RoleRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.security.JwtUtil;
import com.example.mentee_mentor.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final EmailVerificationRepository emailVerificationRepository;
    private final PasswordResetRepository passwordResetRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;

    @Transactional
    public JwtResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already exists");
        }

        String roleName = request.getRole() != null ? request.getRole().toUpperCase() : "MENTEE";
        Role role = roleRepository.findByName(roleName)
                .orElseThrow(() -> new BadRequestException("Invalid role: " + roleName));

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .role(User.UserRole.valueOf(roleName))
                .isEmailVerified(false)
                .isActive(true)
                .build();

        user = userRepository.save(user);

        // Send OTP for email verification
        sendOtpEmail(user.getEmail());

        return buildJwtResponse(user);
    }

    public JwtResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        User user = userPrincipal.getUser();

        if (!user.getIsEmailVerified()) {
            throw new BadRequestException("Email not verified. Please verify your email first.");
        }

        if (!user.getIsActive()) {
            throw new BadRequestException("Account is deactivated. Please contact support.");
        }

        return buildJwtResponse(user);
    }

    public JwtResponse refreshToken(String refreshToken) {
        String email = jwtUtil.extractUsername(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!jwtUtil.validateToken(refreshToken)) {
            throw new BadRequestException("Invalid refresh token");
        }

        return buildJwtResponse(user);
    }

    @Transactional
    public void verifyOtp(OtpVerifyRequest request) {
        EmailVerification verification = emailVerificationRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadRequestException("No OTP found for this email"));

        if (!verification.getCodeHash().equals(request.getOtp())) {
            throw new BadRequestException("Invalid OTP");
        }

        if (verification.getExpiresAt().isBefore(LocalDateTime.now())) {
            emailVerificationRepository.delete(verification);
            throw new BadRequestException("OTP has expired");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setIsEmailVerified(true);
        userRepository.save(user);

        emailVerificationRepository.delete(verification);

        log.info("Email verified for user: {}", request.getEmail());
    }

    @Transactional
    public void resendOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getIsEmailVerified()) {
            throw new BadRequestException("Email is already verified");
        }

        sendOtpEmail(email);
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Delete any existing password reset tokens for this email
        passwordResetRepository.findByEmail(request.getEmail()).ifPresent(passwordResetRepository::delete);

        // Generate 6-digit OTP
        String otp = generateOtp();
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(15);

        PasswordReset passwordReset = new PasswordReset();
        passwordReset.setEmail(request.getEmail());
        passwordReset.setOtp(otp);
        passwordReset.setExpiresAt(expiresAt);
        passwordResetRepository.save(passwordReset);

        // Send OTP via email
        emailService.sendPasswordResetOtp(request.getEmail(), otp);

        log.info("Password reset OTP sent to: {}", request.getEmail());
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("Passwords do not match");
        }

        PasswordReset passwordReset = passwordResetRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadRequestException("No password reset request found for this email"));

        if (!passwordReset.getOtp().equals(request.getOtp())) {
            throw new BadRequestException("Invalid OTP");
        }

        if (passwordReset.getExpiresAt().isBefore(LocalDateTime.now())) {
            passwordResetRepository.delete(passwordReset);
            throw new BadRequestException("OTP has expired");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        passwordResetRepository.delete(passwordReset);

        log.info("Password reset for user: {}", request.getEmail());
    }

    public JwtResponse getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BadRequestException("Not authenticated");
        }

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        return buildJwtResponse(userPrincipal.getUser());
    }

    @Transactional
    public void changePassword(String currentPassword, String newPassword, String confirmPassword) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        User user = userPrincipal.getUser();

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new BadRequestException("Current password is incorrect");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new BadRequestException("New passwords do not match");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        log.info("Password changed for user: {}", user.getEmail());
    }

    private void sendOtpEmail(String email) {
        String otp = generateOtp();
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(10);

        EmailVerification verification = emailVerificationRepository.findByEmail(email).orElse(new EmailVerification());
        verification.setEmail(email);
        verification.setCodeHash(otp);
        verification.setExpiresAt(expiresAt);
        emailVerificationRepository.save(verification);

        emailService.sendVerificationOtp(email, otp);
    }

    private String generateOtp() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }

    private JwtResponse buildJwtResponse(User user) {
        String accessToken = jwtUtil.generateAccessToken(user);
        String refreshToken = jwtUtil.generateRefreshToken(user);

        return JwtResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtUtil.getAccessTokenExpiration())
                .user(UserResponse.fromEntity(user))
                .build();
    }
}
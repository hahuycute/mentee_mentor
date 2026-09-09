package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.auth.JwtResponse;
import com.example.mentee_mentor.dto.auth.LoginRequest;
import com.example.mentee_mentor.dto.auth.OtpVerifyRequest;
import com.example.mentee_mentor.dto.auth.RegisterRequest;
import com.example.mentee_mentor.dto.auth.ResetPasswordRequest;
import com.example.mentee_mentor.dto.auth.ForgotPasswordRequest;
import com.example.mentee_mentor.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<JwtResponse> register(@Valid @RequestBody RegisterRequest request) {
        JwtResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<JwtResponse> login(@Valid @RequestBody LoginRequest request) {
        JwtResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<JwtResponse> refreshToken(@RequestParam String refreshToken) {
        JwtResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<Void> verifyOtp(@Valid @RequestBody OtpVerifyRequest request) {
        authService.verifyOtp(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<Void> resendOtp(@RequestParam String email) {
        authService.resendOtp(email);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<JwtResponse> getCurrentUser() {
        JwtResponse response = authService.getCurrentUser();
        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            @RequestParam String currentPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword) {
        authService.changePassword(currentPassword, newPassword, confirmPassword);
        return ResponseEntity.ok().build();
    }
}
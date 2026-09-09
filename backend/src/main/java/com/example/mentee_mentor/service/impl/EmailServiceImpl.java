package com.example.mentee_mentor.service.impl;

import com.example.mentee_mentor.service.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class EmailServiceImpl implements EmailService {

    @Override
    public void sendVerificationOtp(String email, String otp) {
        // TODO: Implement actual email sending (e.g., Spring Mail, SendGrid, etc.)
        log.info("Sending verification OTP to {}: {}", email, otp);
    }

    @Override
    public void sendPasswordResetOtp(String email, String otp) {
        // TODO: Implement actual email sending
        log.info("Sending password reset OTP to {}: {}", email, otp);
    }

    @Override
    public void sendWelcomeEmail(String email, String fullName) {
        // TODO: Implement actual email sending
        log.info("Sending welcome email to {} ({})", email, fullName);
    }
}
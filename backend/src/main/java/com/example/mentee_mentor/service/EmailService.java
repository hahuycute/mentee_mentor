package com.example.mentee_mentor.service;

public interface EmailService {

    void sendVerificationOtp(String email, String otp);

    void sendPasswordResetOtp(String email, String otp);

    void sendWelcomeEmail(String email, String fullName);
}
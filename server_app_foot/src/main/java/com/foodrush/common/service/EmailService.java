package com.foodrush.common.service;

public interface EmailService {
    void sendPasswordResetEmail(String toEmail, String firstName, String resetToken);
    void sendEmailVerification(String toEmail, String firstName, String verificationToken);
    void sendOrderStatusEmail(String toEmail, String firstName, String orderNumber, String status);
}

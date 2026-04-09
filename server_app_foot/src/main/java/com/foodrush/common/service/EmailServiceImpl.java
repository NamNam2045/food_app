package com.foodrush.common.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import jakarta.mail.internet.MimeMessage;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username:noreply@foodrush.vn}")
    private String fromEmail;

    @Value("${app.frontend-url:http://localhost:3000}")
    private String frontendUrl;

    @Override
    @Async
    public void sendPasswordResetEmail(String toEmail, String firstName, String resetToken) {
        try {
            Context ctx = new Context();
            ctx.setVariable("firstName", firstName);
            ctx.setVariable("resetLink", frontendUrl + "/reset-password?token=" + resetToken);
            ctx.setVariable("expiryMinutes", 30);

            String html = templateEngine.process("email/reset-password", ctx);
            sendHtmlEmail(toEmail, "Đặt lại mật khẩu - FoodRush", html);
            log.info("Password reset email sent to: {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send password reset email to {}: {}", toEmail, e.getMessage());
        }
    }

    @Override
    @Async
    public void sendEmailVerification(String toEmail, String firstName, String verificationToken) {
        try {
            Context ctx = new Context();
            ctx.setVariable("firstName", firstName);
            ctx.setVariable("verifyLink", frontendUrl + "/verify-email?token=" + verificationToken);

            String html = templateEngine.process("email/verify-email", ctx);
            sendHtmlEmail(toEmail, "Xác nhận email - FoodRush", html);
            log.info("Verification email sent to: {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send verification email to {}: {}", toEmail, e.getMessage());
        }
    }

    @Override
    @Async
    public void sendOrderStatusEmail(String toEmail, String firstName, String orderNumber, String status) {
        try {
            Context ctx = new Context();
            ctx.setVariable("firstName", firstName);
            ctx.setVariable("orderNumber", orderNumber);
            ctx.setVariable("status", status);

            String html = templateEngine.process("email/order-status", ctx);
            sendHtmlEmail(toEmail, "Cập nhật đơn hàng " + orderNumber + " - FoodRush", html);
        } catch (Exception e) {
            log.error("Failed to send order status email: {}", e.getMessage());
        }
    }

    private void sendHtmlEmail(String to, String subject, String htmlContent) throws Exception {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true);
        mailSender.send(message);
    }
}

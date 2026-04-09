package com.foodrush.auth.service;

import com.foodrush.auth.dto.*;
import com.foodrush.common.enums.UserRole;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.common.exceptions.UnauthorizedException;
import com.foodrush.common.service.EmailService;
import com.foodrush.common.util.JwtUtil;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthServiceImpl implements AuthService {

    private static final String REVOKED_TOKEN_PREFIX = "revoked:token:";
    private static final int RESET_TOKEN_EXPIRY_MINUTES = 30;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    private final RedisTemplate<String, Object> redisTemplate;
    private final EmailService emailService;

    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessRuleException("AUTH_003", "Email đã được sử dụng");
        }
        if (request.getPhoneNumber() != null && userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new BusinessRuleException("AUTH_004", "Số điện thoại đã được sử dụng");
        }

        User user = User.builder()
                .email(request.getEmail().toLowerCase())
                .phoneNumber(request.getPhoneNumber())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .role(UserRole.CUSTOMER)
                .active(true)
                .emailVerified(false)
                .build();

        String verificationToken = UUID.randomUUID().toString();
        user.setEmailVerificationToken(verificationToken);
        user = userRepository.save(user);

        // Gửi email xác nhận (async, không chặn response)
        final User savedUser = user;
        emailService.sendEmailVerification(savedUser.getEmail(), savedUser.getFirstName(), verificationToken);

        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UnauthorizedException("Tài khoản không tồn tại"));

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String token = request.getRefreshToken();

        if (!jwtUtil.validateToken(token)) {
            throw new UnauthorizedException("Refresh token không hợp lệ hoặc đã hết hạn");
        }

        Boolean revoked = (Boolean) redisTemplate.opsForValue()
                .get(REVOKED_TOKEN_PREFIX + token.hashCode());
        if (Boolean.TRUE.equals(revoked)) {
            throw new UnauthorizedException("Refresh token đã bị thu hồi");
        }

        Claims claims = jwtUtil.parseToken(token);
        if (!"refresh".equals(claims.get("type"))) {
            throw new UnauthorizedException("Token không hợp lệ");
        }

        Long userId = Long.parseLong(claims.getSubject());
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Người dùng không tồn tại"));

        // Revoke old token
        redisTemplate.opsForValue().set(
                REVOKED_TOKEN_PREFIX + token.hashCode(),
                true,
                jwtUtil.getRefreshTokenExpiry(),
                TimeUnit.SECONDS
        );

        return buildAuthResponse(user);
    }

    @Override
    public void logout(String refreshToken) {
        if (jwtUtil.validateToken(refreshToken)) {
            redisTemplate.opsForValue().set(
                    REVOKED_TOKEN_PREFIX + refreshToken.hashCode(),
                    true,
                    jwtUtil.getRefreshTokenExpiry(),
                    TimeUnit.SECONDS
            );
        }
    }

    @Override
    public void forgotPassword(ForgotPasswordRequest request) {
        // Không tiết lộ email có tồn tại hay không (bảo mật)
        userRepository.findByEmail(request.getEmail().toLowerCase()).ifPresent(user -> {
            String token = UUID.randomUUID().toString();
            user.setPasswordResetToken(token);
            user.setPasswordResetExpiresAt(LocalDateTime.now().plusMinutes(RESET_TOKEN_EXPIRY_MINUTES));
            userRepository.save(user);
            emailService.sendPasswordResetEmail(user.getEmail(), user.getFirstName(), token);
            log.info("Password reset email dispatched for userId={}", user.getId());
        });
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByPasswordResetToken(request.getToken())
                .orElseThrow(() -> new BusinessRuleException("AUTH_005", "Token đặt lại mật khẩu không hợp lệ"));

        if (user.getPasswordResetExpiresAt() == null ||
                LocalDateTime.now().isAfter(user.getPasswordResetExpiresAt())) {
            throw new BusinessRuleException("AUTH_006", "Token đặt lại mật khẩu đã hết hạn");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpiresAt(null);
        userRepository.save(user);
        log.info("Password reset successfully for userId={}", user.getId());
    }

    @Override
    public void verifyEmail(String token) {
        User user = userRepository.findByEmailVerificationToken(token)
                .orElseThrow(() -> new BusinessRuleException("AUTH_007", "Token xác nhận email không hợp lệ"));

        if (user.isEmailVerified()) {
            throw new BusinessRuleException("AUTH_008", "Email đã được xác nhận trước đó");
        }

        user.setEmailVerified(true);
        user.setEmailVerificationToken(null);
        userRepository.save(user);
        log.info("Email verified for userId={}", user.getId());
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtUtil.generateAccessToken(user.getId(), user.getEmail(), user.getRole().name());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .role(user.getRole().name())
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .accessTokenExpiresIn(jwtUtil.getAccessTokenExpiry())
                .build();
    }
}

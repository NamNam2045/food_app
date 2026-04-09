package com.foodrush.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateFcmTokenRequest {
    @NotBlank(message = "FCM token không được để trống")
    private String fcmToken;
}

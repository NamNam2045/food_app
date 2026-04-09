package com.foodrush.notification.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PushNotificationRequest {
    private String fcmToken;
    private String title;
    private String body;
    private String orderId;
    private String orderStatus;
    private String imageUrl;
}

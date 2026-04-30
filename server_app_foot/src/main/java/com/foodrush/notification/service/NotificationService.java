package com.foodrush.notification.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.notification.dto.PushNotificationRequest;

public interface NotificationService {
    void sendPushNotification(PushNotificationRequest request);
    void sendOrderStatusUpdate(Long orderId, String orderNumber, OrderStatus orderStatus, String fcmToken);
}

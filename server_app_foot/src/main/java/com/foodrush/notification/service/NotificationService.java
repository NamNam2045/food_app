package com.foodrush.notification.service;

import com.foodrush.notification.dto.PushNotificationRequest;
import com.foodrush.order.entity.Order;

public interface NotificationService {
    void sendPushNotification(PushNotificationRequest request);
    void sendOrderStatusUpdate(Order order);
}

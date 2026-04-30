package com.foodrush.notification.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.notification.dto.PushNotificationRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    @Override
    @Async
    public void sendPushNotification(PushNotificationRequest request) {
        if (!StringUtils.hasText(request.getFcmToken())) {
            log.debug("No FCM token — skip push notification");
            return;
        }
        try {
            Message message = Message.builder()
                    .setToken(request.getFcmToken())
                    .setNotification(Notification.builder()
                            .setTitle(request.getTitle())
                            .setBody(request.getBody())
                            .setImage(request.getImageUrl())
                            .build())
                    .putData("orderId", request.getOrderId() != null ? request.getOrderId() : "")
                    .putData("orderStatus", request.getOrderStatus() != null ? request.getOrderStatus() : "")
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("FCM push sent, messageId={}", response);
        } catch (Exception e) {
            log.error("FCM push failed for token={}: {}", request.getFcmToken(), e.getMessage());
        }
    }

    @Override
    @Async
    public void sendOrderStatusUpdate(Long orderId, String orderNumber, OrderStatus orderStatus, String fcmToken) {
        if (!StringUtils.hasText(fcmToken)) {
            return;
        }

        String statusMessage = getStatusMessage(orderStatus.name());

        PushNotificationRequest pushRequest = PushNotificationRequest.builder()
                .fcmToken(fcmToken)
                .title("Đơn hàng " + orderNumber)
                .body(statusMessage)
                .orderId(orderId != null ? orderId.toString() : "")
                .orderStatus(orderStatus.name())
                .build();

        sendPushNotification(pushRequest);
    }

    private String getStatusMessage(String status) {
        return switch (status) {
            case "CONFIRMED"        -> "Nhà hàng đã xác nhận đơn hàng của bạn!";
            case "PREPARING"        -> "Nhà hàng đang chuẩn bị món ăn...";
            case "READY_FOR_PICKUP" -> "Đơn hàng đã sẵn sàng, shipper đang đến lấy";
            case "PICKED_UP"        -> "Shipper đã lấy hàng!";
            case "ON_THE_WAY"       -> "Shipper đang trên đường giao hàng đến bạn";
            case "DELIVERED"        -> "Đơn hàng đã được giao thành công. Chúc ngon miệng! 🍜";
            case "CANCELLED"        -> "Đơn hàng của bạn đã bị hủy";
            default                 -> "Đơn hàng của bạn đã được cập nhật";
        };
    }
}

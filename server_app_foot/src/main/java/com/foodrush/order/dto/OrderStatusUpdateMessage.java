package com.foodrush.order.dto;

import com.foodrush.common.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data @Builder
public class OrderStatusUpdateMessage {
    private Long orderId;
    private String orderNumber;
    private OrderStatus newStatus;
    private OrderStatus previousStatus;
    private String message;
    private LocalDateTime estimatedDeliveryAt;
    private LocalDateTime timestamp;
}

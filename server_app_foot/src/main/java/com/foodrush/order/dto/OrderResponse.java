package com.foodrush.order.dto;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.enums.PaymentMethod;
import com.foodrush.common.enums.PaymentStatus;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder
public class OrderResponse {
    private Long id;
    private String orderNumber;
    private OrderStatus status;
    private Long restaurantId;
    private String restaurantName;
    private String restaurantPhone;
    private Long deliveryAgentId;
    private String deliveryAgentName;
    private String deliveryAgentPhone;
    private String deliveryAddressSnapshot;
    private List<OrderItemResponse> items;
    private List<OrderStatusHistoryResponse> statusHistory;
    private BigDecimal subtotal;
    private BigDecimal deliveryFee;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private String specialInstructions;
    private LocalDateTime estimatedDeliveryAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime cancelledAt;
    private String cancellationReason;
    private LocalDateTime createdAt;
}

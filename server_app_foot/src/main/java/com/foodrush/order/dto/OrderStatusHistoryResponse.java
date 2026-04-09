package com.foodrush.order.dto;

import com.foodrush.common.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data @Builder
public class OrderStatusHistoryResponse {
    private OrderStatus status;
    private String notes;
    private LocalDateTime createdAt;
}

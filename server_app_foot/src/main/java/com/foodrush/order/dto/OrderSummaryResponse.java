package com.foodrush.order.dto;

import com.foodrush.common.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @Builder
public class OrderSummaryResponse {
    private Long id;
    private String orderNumber;
    private OrderStatus status;
    private String restaurantName;
    private String restaurantLogoUrl;
    private Integer itemCount;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
}

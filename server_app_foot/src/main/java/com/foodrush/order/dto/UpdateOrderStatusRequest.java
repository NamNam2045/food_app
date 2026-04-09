package com.foodrush.order.dto;

import com.foodrush.common.enums.OrderStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateOrderStatusRequest {
    @NotNull private OrderStatus status;
    private String notes;
}

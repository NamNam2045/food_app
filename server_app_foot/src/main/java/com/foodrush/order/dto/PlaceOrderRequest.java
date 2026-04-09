package com.foodrush.order.dto;

import com.foodrush.common.enums.PaymentMethod;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PlaceOrderRequest {
    @NotNull private Long deliveryAddressId;
    @NotNull private PaymentMethod paymentMethod;
    private String specialInstructions;
    private String promoCode;
}

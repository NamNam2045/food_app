package com.foodrush.cart.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data @Builder
public class CartResponse {
    private Long id;
    private Long restaurantId;
    private String restaurantName;
    private List<CartItemResponse> items;
    private int itemCount;
    private BigDecimal subtotal;
    private BigDecimal deliveryFee;
    private BigDecimal total;
}

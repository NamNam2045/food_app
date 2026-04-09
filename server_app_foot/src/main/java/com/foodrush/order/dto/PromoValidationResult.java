package com.foodrush.order.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class PromoValidationResult {
    private boolean valid;
    private BigDecimal discountAmount;
    private String message;

    public static PromoValidationResult invalid(String message) {
        return PromoValidationResult.builder().valid(false)
                .discountAmount(BigDecimal.ZERO).message(message).build();
    }

    public static PromoValidationResult valid(BigDecimal discount) {
        return PromoValidationResult.builder().valid(true)
                .discountAmount(discount).message("Áp dụng thành công").build();
    }
}

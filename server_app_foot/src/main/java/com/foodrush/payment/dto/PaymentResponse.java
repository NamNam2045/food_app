package com.foodrush.payment.dto;

import com.foodrush.common.enums.PaymentMethod;
import com.foodrush.common.enums.PaymentStatus;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @Builder
public class PaymentResponse {
    private Long id;
    private Long orderId;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private BigDecimal amount;
    private String transactionId;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;
}

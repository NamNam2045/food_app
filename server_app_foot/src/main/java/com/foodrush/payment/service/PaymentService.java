package com.foodrush.payment.service;

import com.foodrush.payment.dto.PaymentResponse;

public interface PaymentService {
    PaymentResponse getPaymentByOrder(Long orderId, Long userId);
    PaymentResponse confirmCodPayment(Long orderId, Long actorId);
}

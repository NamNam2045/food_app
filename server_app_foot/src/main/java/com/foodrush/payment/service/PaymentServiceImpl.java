package com.foodrush.payment.service;

import com.foodrush.common.enums.PaymentStatus;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.order.entity.Order;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.payment.dto.PaymentResponse;
import com.foodrush.payment.entity.Payment;
import com.foodrush.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;

    @Override
    @Transactional(readOnly = true)
    public PaymentResponse getPaymentByOrder(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
                .filter(o -> o.getUser().getId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));
        Payment payment = paymentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Thông tin thanh toán không tồn tại"));
        return toResponse(payment);
    }

    @Override
    public PaymentResponse confirmCodPayment(Long orderId, Long actorId) {
        Payment payment = paymentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Thông tin thanh toán không tồn tại"));
        payment.setPaymentStatus(PaymentStatus.PAID);
        payment.setPaidAt(LocalDateTime.now());
        return toResponse(paymentRepository.save(payment));
    }

    private PaymentResponse toResponse(Payment p) {
        return PaymentResponse.builder()
                .id(p.getId()).orderId(p.getOrder().getId())
                .paymentMethod(p.getPaymentMethod()).paymentStatus(p.getPaymentStatus())
                .amount(p.getAmount()).transactionId(p.getTransactionId())
                .paidAt(p.getPaidAt()).createdAt(p.getCreatedAt()).build();
    }
}

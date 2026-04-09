package com.foodrush.payment.repository;

import com.foodrush.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Optional<Payment> findByOrderId(Long orderId);

    @org.springframework.data.jpa.repository.Query("SELECT SUM(p.amount) FROM Payment p WHERE p.paymentStatus = com.foodrush.common.enums.PaymentStatus.PAID")
    BigDecimal sumPaidAmount();

    @org.springframework.data.jpa.repository.Query("SELECT SUM(p.amount) FROM Payment p WHERE p.paymentStatus = com.foodrush.common.enums.PaymentStatus.PAID AND p.paidAt >= :after")
    BigDecimal sumPaidAmountAfter(@org.springframework.data.repository.query.Param("after") LocalDateTime after);
}

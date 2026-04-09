package com.foodrush.payment.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.payment.dto.PaymentResponse;
import com.foodrush.payment.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Payments", description = "Quản lý thanh toán")
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Lấy thông tin thanh toán của đơn hàng")
    public ApiResponse<PaymentResponse> getPayment(
            @PathVariable Long orderId,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(paymentService.getPaymentByOrder(orderId, user.getId()));
    }

    @PatchMapping("/orders/{orderId}/confirm-cod")
    @PreAuthorize("hasAnyRole('DELIVERY_AGENT', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xác nhận thanh toán COD")
    public ApiResponse<PaymentResponse> confirmCod(
            @PathVariable Long orderId,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(paymentService.confirmCodPayment(orderId, user.getId()));
    }
}

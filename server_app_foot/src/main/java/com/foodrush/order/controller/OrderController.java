package com.foodrush.order.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.common.dto.PageResponse;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.order.dto.*;
import com.foodrush.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Orders", description = "Đặt hàng và theo dõi đơn")
public class OrderController {

    private final OrderService orderService;

    @PostMapping("/orders")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Đặt hàng từ giỏ hàng hiện tại")
    public ApiResponse<OrderResponse> placeOrder(
            @Valid @RequestBody PlaceOrderRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.placeOrder(request, user.getId()), "Đặt hàng thành công");
    }

    @GetMapping("/orders")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Lịch sử đơn hàng của tôi")
    public ApiResponse<PageResponse<OrderSummaryResponse>> getMyOrders(
            @RequestParam(required = false) OrderStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.getMyOrders(user.getId(), status, page, size));
    }

    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Chi tiết đơn hàng")
    public ApiResponse<OrderResponse> getOrder(
            @PathVariable Long orderId,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.getOrderById(orderId, user.getId()));
    }

    @PatchMapping("/orders/{orderId}/cancel")
    @PreAuthorize("hasRole('CUSTOMER')")
    @Operation(summary = "Hủy đơn hàng")
    public ApiResponse<OrderResponse> cancelOrder(
            @PathVariable Long orderId,
            @RequestBody CancelOrderRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.cancelOrder(orderId, request, user.getId()));
    }

    @PutMapping("/orders/{orderId}/status")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'DELIVERY_AGENT', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật trạng thái đơn (Admin/Shipper)")
    public ApiResponse<OrderResponse> updateStatus(
            @PathVariable Long orderId,
            @Valid @RequestBody UpdateOrderStatusRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.updateStatus(orderId, request, user.getId()));
    }

    @GetMapping("/restaurants/{restaurantId}/orders")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Danh sách đơn hàng của nhà hàng (filter theo status và ngày)")
    public ApiResponse<PageResponse<OrderSummaryResponse>> getRestaurantOrders(
            @PathVariable Long restaurantId,
            @RequestParam(required = false) OrderStatus status,
            @RequestParam(required = false) String date,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(orderService.getRestaurantOrders(restaurantId, status, date, page, size));
    }
}

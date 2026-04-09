package com.foodrush.order.service;

import com.foodrush.common.dto.PageResponse;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.order.dto.*;

public interface OrderService {
    OrderResponse placeOrder(PlaceOrderRequest request, Long userId);
    PageResponse<OrderSummaryResponse> getMyOrders(Long userId, OrderStatus status, int page, int size);
    OrderResponse getOrderById(Long orderId, Long userId);
    OrderResponse cancelOrder(Long orderId, CancelOrderRequest request, Long userId);
    OrderResponse updateStatus(Long orderId, UpdateOrderStatusRequest request, Long actorId);
    PageResponse<OrderSummaryResponse> getRestaurantOrders(Long restaurantId, OrderStatus status,
            String date, int page, int size);
}

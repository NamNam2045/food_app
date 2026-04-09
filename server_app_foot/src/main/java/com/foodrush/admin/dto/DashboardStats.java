package com.foodrush.admin.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class DashboardStats {
    private long totalUsers;
    private long totalRestaurants;
    private long totalOrders;
    private long totalOrdersToday;
    private BigDecimal totalRevenue;
    private BigDecimal revenueToday;
    private long pendingOrders;
    private long activeRestaurants;
    private long totalReviews;
}

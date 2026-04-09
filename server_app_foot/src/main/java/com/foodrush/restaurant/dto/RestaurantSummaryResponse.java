package com.foodrush.restaurant.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data @Builder
public class RestaurantSummaryResponse {
    private Long id;
    private String name;
    private String slug;
    private String cuisineType;
    private String logoUrl;
    private String bannerUrl;
    private BigDecimal ratingAvg;
    private Integer ratingCount;
    private BigDecimal deliveryFee;
    private Integer estimatedDeliveryMinutes;
    private boolean open;
    private String city;
}

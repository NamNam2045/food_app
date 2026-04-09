package com.foodrush.restaurant.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder
public class RestaurantResponse {
    private Long id;
    private String name;
    private String slug;
    private String description;
    private String cuisineType;
    private String logoUrl;
    private String bannerUrl;
    private String phone;
    private String streetAddress;
    private String city;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private BigDecimal ratingAvg;
    private Integer ratingCount;
    private BigDecimal minOrderAmount;
    private BigDecimal deliveryFee;
    private Integer estimatedDeliveryMinutes;
    private boolean active;
    private boolean open;
    private LocalDateTime createdAt;
    private List<OperatingHoursResponse> operatingHours;
}

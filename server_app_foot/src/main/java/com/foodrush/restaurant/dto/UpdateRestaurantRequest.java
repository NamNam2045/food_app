package com.foodrush.restaurant.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class UpdateRestaurantRequest {
    private String name;
    private String description;
    private String cuisineType;
    private String logoUrl;
    private String bannerUrl;
    private String phone;
    private String streetAddress;
    private String city;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private BigDecimal minOrderAmount;
    private BigDecimal deliveryFee;
    private Integer estimatedDeliveryMinutes;
    private Boolean active;
    private Boolean open;
    private List<OperatingHoursRequest> operatingHours;
}

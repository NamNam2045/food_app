package com.foodrush.restaurant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class CreateRestaurantRequest {
    @NotBlank private String name;
    private String description;
    @NotBlank private String cuisineType;
    private String logoUrl;
    private String bannerUrl;
    private String phone;
    private String email;
    @NotBlank private String streetAddress;
    @NotBlank private String city;
    private BigDecimal latitude;
    private BigDecimal longitude;
    @NotNull private BigDecimal minOrderAmount;
    @NotNull private BigDecimal deliveryFee;
    private Integer estimatedDeliveryMinutes = 30;
    private List<OperatingHoursRequest> operatingHours;
}
